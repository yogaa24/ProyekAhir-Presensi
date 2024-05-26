import 'dart:convert';
import 'package:http/http.dart' as myHttp;
import 'package:flutter/material.dart';
import 'package:flutter_pesensimob/models/home-response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showTodayContainer = true;
  bool showMonthContainer = false;
  int currentPageIndex = 0;
  late String bulan = ''; // Variabel untuk menyimpan nilai bulan
  late int tahun = 0; // Variabel untuk menyimpan nilai tahun
  late String name;
  late String token;
  HomeResponseModel? homeResponseModel;
  Datum? hariIni;
  List<Datum> riwayat = [];

  String jumlahTepat = '0';
  String jumlahTerlambat = '0';
  String jumlahIzinKeperluan = '0';
  String jumlahIzinSakit = '0';

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Panggil fungsi resetPresensi setiap hari Senin
    if (DateTime.now().weekday == DateTime.monday) {
      resetPresensi();
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
      token = prefs.getString('token') ?? '';
    });
    print('Nama adalah: $name');
    print('Token adalah: $token');
    getData(); // Panggil fungsi getData setelah mendapatkan data user
    fetchIzinAndPresensiCounts();
  }

  Future<void> getData() async {
    final Map<String, String> headers = {'Authorization': 'Bearer $token'};

    try {
      var response = await myHttp.get(
        Uri.parse('https://agspresensi.framework-tif.com/api/get-presensi'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Respons sukses, tangani respons JSON
        homeResponseModel =
            HomeResponseModel.fromJson(json.decode(response.body));
        riwayat.clear();

        homeResponseModel!.data.forEach((element) {
          if (element.isHariIni) {
            hariIni = element;
          } else {
            riwayat.add(element);
          }

          String tanggal =
              element.tanggal; // Contoh tanggal: "Sabtu, 4 Mei 2024"
          bulan = _parseMonth(tanggal); // Simpan nilai bulan
          tahun = _parseYear(tanggal); // Simpan nilai tahun
          print('Bulan: $bulan, Tahun: $tahun');
        });
      } else {
        // Tangani kesalahan saat melakukan permintaan
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      // Tangani kesalahan koneksi atau permintaan
      print('Error: $error');
    }
  }

  Future<void> resetPresensi() async {
    // Lakukan reset riwayat presensi ke nilai awal
    riwayat.clear();
    // Panggil fungsi untuk mendapatkan data presensi terbaru setelah reset
    await getData();
  }

  String _parseMonth(String date) {
    List<String> parts = date.split(' ');
    return parts[2]; // Ambil bagian bulan dari string tanggal
  }

  int _parseYear(String date) {
    List<String> parts = date.split(' ');
    return int.parse(parts[3]); // Ambil bagian tahun dari string tanggal
  }

  Future<void> fetchIzinAndPresensiCounts() async {
    String apiUrl =
        'http://localhost:8000/api/izin-presensi-counts'; // URL API untuk mengambil izin dan presensi counts
    try {
      final response = await myHttp.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization':
              'Bearer $token', // Mengirim token pengguna di header Authorization
        },
      );

      if (response.statusCode == 200) {
        // Respons sukses, tangani respons JSON
        Map<String, dynamic> data = json.decode(response.body);
        print(response.body);
        int jumlahIzinSakit = int.parse(data['jumlah_izin_sakit'].toString());
        int jumlahIzinKeperluan =
            int.parse(data['jumlah_izin_keperluan'].toString());
        int jumlahTepat = int.parse(data['jumlah_tepat'].toString());
        int jumlahTerlambat = int.parse(data['jumlah_terlambat'].toString());

        // Set nilai variabel kelas dengan nilai yang diperoleh
        setState(() {
          this.jumlahIzinSakit = jumlahIzinSakit.toString();
          this.jumlahIzinKeperluan = jumlahIzinKeperluan.toString();
          this.jumlahTepat = jumlahTepat.toString();
          this.jumlahTerlambat = jumlahTerlambat.toString();
        });
      } else {
        // Tangani kesalahan saat melakukan permintaan
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      // Tangani kesalahan koneksi atau permintaan
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121481),
      bottomNavigationBar: NavigationBar(
        indicatorColor: Color.fromARGB(255, 27, 41, 238).withOpacity(0.5),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/izin');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/history');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment),
            label: 'Ijin',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            icon: Icon(Icons.person_2_outlined),
            label: 'Profil',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'images/bc.png'), // Sesuaikan dengan path gambar Anda
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              padding: EdgeInsets.all(20),
              child: ListView(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      CircleAvatar(
                        radius: 23,
                        backgroundImage: NetworkImage(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/768px-Windows_10_Default_Profile_Picture.svg.png?20221210150350'),
                      ),
                      SizedBox(width: 15),
                      Text(
                        'Hello,  ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$name',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Card(
                    margin: EdgeInsets.only(top: 20),
                    child: Container(
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white.withOpacity(0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                  context, '/profile');
                            },
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_circle_outlined,
                                  size: 40,
                                  color: Color(0xFF121481),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Profil',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                  context, '/history');
                            },
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history_outlined,
                                    size: 40,
                                    color: Color(0xFF121481)), // Warna orange
                                Text(
                                  'History',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                  context, '/lokasi');
                            },
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 40,
                                    color: Color(0xFF121481)), // Warna merah
                                Text(
                                  'Lokasi',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/absen');
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 20, right: 10),
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.white, // Warna border
                                width: 1, // Lebar border dalam logical pixels
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Color.fromARGB(255, 7, 241, 128),
                                  size: 40,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Masuk',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/absen');
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 20, left: 10),
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.white, // Warna border
                                width: 1, // Lebar border dalam logical pixels
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on_sharp,
                                  color: Color.fromARGB(255, 232, 19, 4),
                                  size: 40,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Pulang',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: 25), // Ubah sesuai kebutuhan marginnya
                    child: Text(
                      'Rekap Presensi Bulan $bulan $tahun',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Card(
                            margin: EdgeInsets.only(top: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withOpacity(0.5),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              height: 80,
                              width: 80,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_available_sharp,
                                    color: Color(0xFF121481),
                                    size: 35,
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    'Hadir',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            right: 2,
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromARGB(255, 232, 19, 4),
                              ),
                              child: Center(
                                child: Text(
                                  '$jumlahTepat', // Ganti dengan jumlah notifikasi yang sesuai
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Spacer(), // Memastikan ada ruang kosong di antara Card dan Container berikutnya
                      Stack(
                        children: [
                          Card(
                            margin: EdgeInsets.only(top: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withOpacity(0.5),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              height: 80,
                              width: 80,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.assignment_add,
                                    color: Color(0xFF121481),
                                    size: 35,
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    'Ijin',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            right: 2,
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromARGB(255, 232, 19, 4),
                              ),
                              child: Center(
                                child: Text(
                                  '$jumlahIzinKeperluan', // Ganti dengan jumlah notifikasi yang sesuai
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      Spacer(), // Memastikan ada ruang kosong di antara Card dan Container berikutnya
                      Stack(
                        children: [
                          Card(
                            margin: EdgeInsets.only(top: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withOpacity(0.5),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              height: 80,
                              width: 80,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.sick_outlined,
                                    color: Color(0xFF121481),
                                    size: 35,
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    'Sakit',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            right: 2,
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromARGB(255, 232, 19, 4),
                              ),
                              child: Center(
                                child: Text(
                                  '$jumlahIzinSakit', // Ganti dengan jumlah notifikasi yang sesuai
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Spacer(), // Memastikan ada ruang kosong di antara Card dan Container berikutnya
                      Stack(
                        children: [
                          Card(
                            margin: EdgeInsets.only(top: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withOpacity(0.5),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              height: 80,
                              width: 80,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.access_time_outlined,
                                    color: Color(0xFF121481),
                                    size: 35,
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    'Telat',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            right: 2,
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromARGB(255, 232, 19, 4),
                              ),
                              child: Center(
                                child: Text(
                                  '$jumlahTerlambat', // Ganti dengan jumlah notifikasi yang sesuai
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white.withOpacity(0.7),
                    ),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          height: 45,
                          width: 450,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color(0xFF121481),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    showTodayContainer = true;
                                    showMonthContainer = false;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 70, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide.none,
                                  ),
                                  primary: showTodayContainer
                                      ? Colors.white
                                      : Color(0xFF121481),
                                  elevation: showTodayContainer
                                      ? 0
                                      : 0, // Bayangan saat tidak ditekan
                                ),
                                child: Text(
                                  'Hari Ini',
                                  style: TextStyle(
                                    color: showTodayContainer
                                        ? Colors.black
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    showMonthContainer = true;
                                    showTodayContainer =
                                        false; // Pastikan kontainer lain disembunyikan
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 70, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide.none,
                                  ),
                                  primary: showTodayContainer
                                      ? Color(0xFF121481)
                                      : Colors.white,
                                  elevation: showTodayContainer
                                      ? 0
                                      : 0, // Bayangan saat tidak ditekan
                                ),
                                child: Text(
                                  'Minggu Ini',
                                  style: TextStyle(
                                    color: showTodayContainer
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showTodayContainer)
                                  FutureBuilder(
                                    future: getData(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      } else {
                                        return Container(
                                          width: 450,
                                          height: 250,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                Colors
                                                    .blue, // Warna kiri (biru)
                                                Color(
                                                    0xFF121481), // Warna kanan (ungu)
                                              ],
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  hariIni?.tanggal ?? '-',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(height: 50),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Text(
                                                          hariIni?.masuk ?? '-',
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 30,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        const Text(
                                                          "Masuk",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        Text(
                                                          hariIni?.pulang ??
                                                              '-',
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 30,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        const Text(
                                                          "Pulang",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                if (showMonthContainer)
                                  Container(
                                    height: MediaQuery.of(context).size.height,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: riwayat.length,
                                      itemBuilder: (context, index) => Card(
                                        child: ListTile(
                                          leading: Text(riwayat[index].tanggal),
                                          title: Row(
                                            children: [
                                              Column(
                                                children: [
                                                  Text(riwayat[index].masuk,
                                                      style: TextStyle(
                                                          fontSize: 18)),
                                                  const Text("Masuk",
                                                      style: TextStyle(
                                                          fontSize: 14))
                                                ],
                                              ),
                                              SizedBox(width: 20),
                                              Column(
                                                children: [
                                                  Text(
                                                    riwayat[index].pulang ??
                                                        'Belum Absen',
                                                    style: const TextStyle(
                                                        fontSize: 18),
                                                  ),
                                                  const Text("Pulang",
                                                      style: TextStyle(
                                                          fontSize: 14))
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
