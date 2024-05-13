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
        Uri.parse('http://127.0.0.1:8000/api/get-presensi'),
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
      appBar: AppBar(
        title: Text('History'),
      ),
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
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          TextField(
            onChanged: updateSearchQuery,
            decoration: const InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
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
                        return Card(
                          child: ListTile(
                            leading: Text(presensi.tanggal),
                            title: Row(
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      presensi.masuk,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    const Text("Masuk",
                                        style: TextStyle(fontSize: 14))
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  children: [
                                    Text(
                                      presensi.pulang ?? 'Data tidak tersedia',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    const Text("Pulang",
                                        style: TextStyle(fontSize: 14))
                                  ],
                                ),
                              ],
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
    );
  }
}
