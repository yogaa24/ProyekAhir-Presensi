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
    final url = Uri.parse('http://localhost:8000/api/izin');
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
      // Reset nilai terpilih setelah izin berhasil disimpan
      setState(() {
        _selectedReason = null;
        _additionalInfo = null;
      });

      // Jika izin berhasil disimpan, tampilkan pesan sukses
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Izin berhasil disimpan'),
            content: Text('Anda telah memberikan izin.'),
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
        title: Text('Form Izin'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.grey[200], // Ganti warna latar belakang
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
              SizedBox(height: 20),
            Text(
              'Keterangan Tambahan:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              onChanged: (value) {
                setState(() {
                  _additionalInfo = value;
                });
              },
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
                  _sendIzinData();
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Pilih Alasan Izin'),
                        content:
                            Text('Harap pilih alasan izin sebelum menyimpan.'),
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
              },
              style: ButtonStyle(
                // Tambahkan style untuk tombol
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                elevation: MaterialStateProperty.all<double>(5),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              child: Text('Simpan Izin', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
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
    );
  }
}
