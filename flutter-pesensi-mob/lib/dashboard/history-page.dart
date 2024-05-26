import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_pesensimob/models/home-response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as myHttp;

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int currentPageIndex = 2; // Sesuaikan dengan indeks item navigasi 'history'
  int? selectedDay; // Inisialisasi nilai default
  int? selectedMonth; // Inisialisasi nilai default
  int? selectedYear; // Inisialisasi nilai default
  late String searchQuery;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> name, _token;
  HomeResponseModel? homeResponseModel;
  Datum? hariIni;
  List<Datum> riwayat = [];

  @override
  void initState() {
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });

    name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });

    searchQuery = "";
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
  }

  Future<void> getData() async {
    final Map<String, String> headres = {
      'Authorization': 'Bearer ' + await _token
    };
    print(headres);
    var response = await myHttp.get(
        Uri.parse('https://agspresensi.framework-tif.com/api/get-presensi'),
        headers: headres);
    homeResponseModel = HomeResponseModel.fromJson(json.decode(response.body));
    riwayat.clear();
    homeResponseModel!.data.forEach((element) {
      if (element.isHariIni) {
        hariIni = element;
      } else {
        riwayat.add(element);
      }
    });
    print('ini $riwayat');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF121481),
        iconTheme: IconThemeData(
          color: Colors.white, // Ubah warna panah kembali ke putih
        ),
      ),
      bottomNavigationBar: NavigationBar(
        indicatorColor: Color.fromARGB(255, 27, 41, 238).withOpacity(0.5),
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
              //
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      'Temukan Riwayat Presensi Anda',
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      onChanged: updateSearchQuery,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'temukan riwayat presensi anda...',
                        suffixIcon: Icon(
                          Icons.search_sharp,
                          size: 30,
                        ),
                        contentPadding: EdgeInsets.all(25.0),
                      ),
                    ),
                    Container(
                      height: 20,
                    ),
                  ],
                )),
            Expanded(
              child: FutureBuilder(
                future: getData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return ListView.builder(
                      itemCount: riwayat.length,
                      itemBuilder: (context, index) {
                        final presensi = riwayat[index];
                        if (searchQuery.isEmpty ||
                            presensi.tanggal
                                .toLowerCase()
                                .contains(searchQuery.toLowerCase())) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Card(
                              color: Color(0xFF121481),
                              child: ListTile(
                                leading: Text(
                                  presensi.tanggal,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                title: Row(
                                  children: [
                                    const SizedBox(width: 40),
                                    Column(
                                      children: [
                                        Text(
                                          presensi.masuk,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white),
                                        ),
                                        const Text("Masuk",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white))
                                      ],
                                    ),
                                    const SizedBox(width: 40),
                                    Column(
                                      children: [
                                        Text(
                                          textAlign: TextAlign.right,
                                          presensi.pulang ??
                                              'Data tidak tersedia',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white),
                                        ),
                                        const Text("Pulang",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white))
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox
                              .shrink(); // Return empty widget if not matching search query
                        }
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
