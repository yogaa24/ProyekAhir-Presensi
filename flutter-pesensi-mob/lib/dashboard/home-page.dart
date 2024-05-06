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
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
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
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_2_outlined),
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
                borderRadius: const BorderRadius.only(
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
                    const CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/768px-Windows_10_Default_Profile_Picture.svg.png?20221210150350'),
                    ),
                    const SizedBox(width: 15),
                    Baseline(
                      baseline:
                          45, // Sesuaikan dengan tinggi teks agar berada sedikit ke bawah
                      baselineType: TextBaseline.alphabetic,
                      child: Text(
                        'Hi, $name',
                        style: const TextStyle(
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
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/profile');
                          },
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.account_circle,
                                  size: 40, color: Colors.blue), // Warna biru
                              Text('Profil'),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/history');
                          },
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history,
                                  size: 40,
                                  color: Colors.orange), // Warna orange
                              Text('History'),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/lokasi');
                          },
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on,
                                  size: 40, color: Colors.red), // Warna merah
                              Text('Lokasi'),
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
                            color: Colors.green[400],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on_sharp,
                                  color: Colors.white),
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
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on_sharp,
                                  color: Colors.white),
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
                const SizedBox(height: 30),
                const Baseline(
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
                const SizedBox(height: 15),
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
                        child: const Column(
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
                        child: const Column(
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
                      color: Colors.orange,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        height: 80,
                        width: 80,
                        child: const Column(
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
                const SizedBox(height: 25),
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
                      child: const Text(
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
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16)),
                                SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Text(hariIni?.masuk ?? '-',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 24)),
                                        const Text("Masuk",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16))
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(hariIni?.pulang ?? '-',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 24)),
                                        const Text("Pulang",
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
                if (showMonthContainer)
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        Text("Riwayat Presensi"),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height,
                          child: ListView.builder(
                            itemCount: riwayat.length,
                            itemBuilder: (context, index) => Card(
                              child: ListTile(
                                leading: Text(riwayat[index].tanggal),
                                title: Row(children: [
                                  Column(
                                    children: [
                                      Text(riwayat[index].masuk,
                                          style: TextStyle(fontSize: 18)),
                                      const Text("Masuk",
                                          style: TextStyle(fontSize: 14))
                                    ],
                                  ),
                                  SizedBox(width: 20),
                                  Column(
                                    children: [
                                      Text(
                                          riwayat[index].pulang ??
                                              'Data tidak tersedia',
                                          style: const TextStyle(fontSize: 18)),
                                      const Text("Pulang",
                                          style: TextStyle(fontSize: 14))
                                    ],
                                  ),
                                ]),
                              ),
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
    );
  }
}
