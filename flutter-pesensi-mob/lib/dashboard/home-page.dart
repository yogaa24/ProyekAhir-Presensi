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
  late String name;
  late String token;
  HomeResponseModel? homeResponseModel;
  Datum? hariIni;
  List<Datum> riwayat = [];

  @override
  void initState() {
    _loadUserData();
    super.initState();
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
  }

  Future getData() async {
    final Map<String, String> headres = {
      'Authorization': 'Bearer ' + await token
    };
    print(headres);
    var response = await myHttp.get(
        Uri.parse('http://127.0.0.1:8000/api/get-presensi'),
        headers: headres);
    print(headres);
    homeResponseModel = HomeResponseModel.fromJson(json.decode(response.body));
    riwayat.clear();
    homeResponseModel!.data.forEach((element) {
      if (element.isHariIni) {
        hariIni = element;
      } else {
        riwayat.add(element);
      }
    });
    print(' riwayat: $riwayat');

    // print(
    //     'iniada: $Datum(id: id, userId: userId, latitude: latitude, longitude: longitude, tanggal: tanggal, masuk: masuk, pulang: pulang, keterangan: keterangan, createdAt: createdAt, updatedAt: updatedAt, isHariIni: isHariIni)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // Ganti warna latar bawah
        selectedItemColor: Colors.blue, // Ganti warna item terpilih
        unselectedItemColor: Colors.grey, // Ganti warna item tidak terpilih
        currentIndex: currentPageIndex,
        onTap: (int index) {
          setState(() {
            currentPageIndex = index;
          });

          switch (index) {
            case 0:
              //
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Ijin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
      body: Stack(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 180),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
            ),
          ),
          Container(
            height: double.infinity,
            padding: EdgeInsets.all(20),
            child: ListView(
              children: [
                SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/768px-Windows_10_Default_Profile_Picture.svg.png?20221210150350'),
                    ),
                    SizedBox(
                        width:
                            15), // Memberi sedikit jarak antara gambar dan teks
                    Baseline(
                      baseline:
                          45, // Sesuaikan dengan tinggi teks agar berada sedikit ke bawah
                      baselineType: TextBaseline.alphabetic,
                      child: Text(
                        'Hi, $name',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Card(
                  margin: EdgeInsets.only(top: 20),
                  child: Container(
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Profil
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.account_circle,
                                size: 40, color: Colors.blue), // Warna biru
                            Text('Profil'),
                          ],
                        ),
                        // History
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history,
                                size: 40, color: Colors.orange), // Warna orange
                            Text('History'),
                          ],
                        ),
                        // Lokasi
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on,
                                size: 40, color: Colors.red), // Warna merah
                            Text('Lokasi'),
                          ],
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
                            color: Colors.green[400],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                'Masuk',
                                style: TextStyle(
                                  color: Colors.white,
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
                            color: Colors.red[400],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                'Pulang',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Baseline(
                  baseline: 25, // Atur nilai baseline sesuai kebutuhan
                  baselineType: TextBaseline.alphabetic,
                  child: Text(
                    'Rekap presensi bulan April 2024',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.left, // Mepetkan teks ke paling kiri
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      margin: EdgeInsets.only(top: 10),
                      color: Colors.amber,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        height: 80,
                        width: 80,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check, color: Colors.white),
                            Text(
                              'Hadir',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Spacer(), // Memastikan ada ruang kosong di antara Card dan Container berikutnya
                    Card(
                      margin: EdgeInsets.only(top: 10),
                      color: Colors.blue,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        height: 80,
                        width: 80,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_available, color: Colors.white),
                            Text(
                              'Izin',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Spacer(), // Memastikan ada ruang kosong di antara Card dan Container berikutnya
                    Card(
                      margin: EdgeInsets.only(top: 10),
                      color: Colors.red,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        height: 80,
                        width: 80,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_hospital, color: Colors.white),
                            Text(
                              'Sakit',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Spacer(), // Memastikan ada ruang kosong di antara Card dan Container berikutnya
                    Card(
                      margin: EdgeInsets.only(top: 10),
                      color: Colors.orange,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        height: 80,
                        width: 80,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.access_time, color: Colors.white),
                            Text(
                              'Telat',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showTodayContainer = true;
                          showMonthContainer =
                              false; // Pastikan kontainer lain disembunyikan
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 90, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
                        primary: showTodayContainer
                            ? Colors.green
                            : Colors.blue, // Ubah warna saat ditekan
                      ),
                      child: Text(
                        'Hari Ini',
                        style: TextStyle(
                          color: Colors.black,
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 90, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
                        primary: showMonthContainer
                            ? Colors.orange
                            : Colors.grey[300], // Ubah warna saat ditekan
                      ),
                      child: Text(
                        'Bulan Ini',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (showTodayContainer)
                  FutureBuilder(
                    future: getData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        return Container(
                          width: 400,
                          decoration: BoxDecoration(color: Colors.blue[800]),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(hariIni?.tanggal ?? '-',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                                SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Text(hariIni?.masuk ?? '-',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24)),
                                        Text("Masuk",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16))
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(hariIni?.pulang ?? '-',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24)),
                                        Text("Pulang",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16))
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
                if (showMonthContainer) Container(child: SizedBox(height: 20)),
                Text("Riwayat Presensi"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
