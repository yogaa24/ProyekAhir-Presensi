import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class IzinPage extends StatefulWidget {
  const IzinPage({Key? key}) : super(key: key);

  @override
  State<IzinPage> createState() => _IzinPageState();
}

class _IzinPageState extends State<IzinPage> {
  int currentPageIndex = 1;

  String? _selectedReason;
  String? _additionalInfo;
  late SharedPreferences _prefs;

  final List<String> _izinOptions = [
    'Sakit',
    'Keperluan',
  ];

  final TextEditingController _additionalInfoController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    // Periksa apakah pengguna sudah login saat ini
    final isLoggedIn = _prefs.getString('token') != null;
    if (!isLoggedIn) {
      // Jika belum login, arahkan pengguna ke layar login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _sendIzinData() async {
    final token = _prefs.getString('token');
    final url = Uri.parse('https://agspresensi.framework-tif.com/api/izin');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'alasan': _selectedReason!,
        'keterangan': _additionalInfo ?? '',
      },
    );

    if (response.statusCode == 201) {
      // Jika izin berhasil disimpan, tampilkan pesan sukses
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            icon: Icon(
              Icons.check_circle,
              color: Color.fromARGB(255, 3, 246, 39),
              size: 40,
            ),
            title: Text(
              'Izin berhasil disimpan',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedReason = null;
                    _additionalInfo = null;
                    _additionalInfoController.clear();
                  });
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      );
    } else if (response.statusCode == 422) {
      // Validasi gagal, tampilkan pesan validasi dari server
      final responseData = json.decode(response.body);
      final errorMessage = responseData['message'];
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Validasi Gagal'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Kesalahan server internal, tampilkan pesan kesalahan server
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Terjadi kesalahan saat menyimpan izin.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Form Izin',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Alasan Izin:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedReason,
              onChanged: (String? value) {
                setState(() {
                  _selectedReason = value;
                });
              },
              items: _izinOptions.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Pilih Alasan Izin',
              ),
            ),
            if (_selectedReason != null &&
                (_selectedReason == 'Sakit' || _selectedReason == 'Keperluan'))
              Container(
                width: 300,
              ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Keterangan Tambahan:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _additionalInfoController,
              onChanged: (value) {
                setState(() {
                  _additionalInfo = value;
                });
              },
              minLines: 3, // Set minimum number of lines
              maxLines: 5, // Set maximum number of lines
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Masukkan keterangan tambahan...',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_selectedReason != null) {
                  if (_additionalInfo == null || _additionalInfo!.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          icon: Icon(
                            Icons.error_outline_sharp,
                            color: const Color.fromARGB(255, 245, 20, 4),
                            size: 40,
                          ),
                          title: Text('Keterangan Tambahan Perlu Diisi'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'OK',
                                style: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 240, 26, 11),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    _sendIzinData();
                  }
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        icon: Icon(
                          Icons.error_outline_sharp,
                          color: const Color.fromARGB(255, 245, 20, 4),
                          size: 40,
                        ),
                        title: Text('Pilih Alasan Izin'),
                        content:
                            Text('Harap pilih alasan izin sebelum menyimpan.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'OK',
                              style: TextStyle(
                                  color: const Color.fromARGB(255, 240, 26, 11),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Container(
                alignment: Alignment.center,
                height: 55,
                child: Text(
                  'Simpan Izin',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF0C2D57),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                shadowColor: Colors.black.withOpacity(0.1),
                elevation: 10,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        indicatorColor: Color.fromARGB(255, 27, 41, 238).withOpacity(0.5),
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              // Tidak perlu navigasi ulang ke halaman ini karena sudah di halaman ini
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/history');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profile');

              break;
          }
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.assignment),
            icon: Icon(Icons.assignment_outlined),
            label: 'Ijin',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.history),
            icon: Icon(Icons.history_outlined),
            label: 'History',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_2_outlined),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
