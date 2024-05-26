import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int currentPageIndex = 3;
  String name = '';

  String profileImageUrl =
      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/768px-Windows_10_Default_Profile_Picture.svg.png?20221210150350';
  String nama = '-';
  String nomorTelepon = '-';
  String email = '-';
  String jabatan = '-';
  String alamat = '-';
  String password = '';

  @override
  void initState() {
    _loadName();
    super.initState();
  }

  Future<void> _loadName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
    });
    print('nama adalah: $name');
    _fetchProfile();
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi Logout"),
          content: Text("Apakah Anda yakin ingin keluar?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, '/login'); // Tutup dialog
              },
              child: Text("Ya"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        profileImageUrl = pickedImage.path;
      });
    }
  }

  Future<void> _fetchProfile() async {
    final response = await http.get(
      Uri.parse('https://agspresensi.framework-tif.com/api/profile/${name}'),
    );
    print(name);
    if (response.statusCode == 200) {
      List<dynamic> responseDataList = json.decode(response.body);
      if (responseDataList.isNotEmpty) {
        Map<String, dynamic> responseData = responseDataList[0];
        setState(() {
          nama = responseData['name'] ?? '';
          nomorTelepon = responseData['phone_number'] ?? '';
          email = responseData['email'] ?? '';
          jabatan = responseData['job_title'] ?? '';
          alamat = responseData['address'] ?? '';
          password = '';
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
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
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                color: Color(0xFF121481),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(profileImageUrl),
                  ),
                  SizedBox(height: 16),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Ubah warna teks menjadi putih
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // Ubah warna teks menjadi putih
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoRow(icon: Icons.person, label: 'Nama', value: nama),
                        Divider(
                          color: Color(
                              0xFF121481), // Ubah warna garis menjadi merah
                        ),
                        InfoRow(
                            icon: Icons.phone,
                            label: 'No Telepon',
                            value: nomorTelepon),
                        Divider(
                          color: Color(
                              0xFF121481), // Ubah warna garis menjadi merah
                        ),
                        InfoRow(
                            icon: Icons.email, label: 'Email', value: email),
                        Divider(
                          color: Color(
                              0xFF121481), // Ubah warna garis menjadi merah
                        ),
                        InfoRow(
                            icon: Icons.work, label: 'Jabatan', value: jabatan),
                        Divider(
                          color: Color(
                              0xFF121481), // Ubah warna garis menjadi merah
                        ),
                        InfoRow(
                            icon: Icons.home, label: 'Alamat', value: alamat),
                        Divider(
                          color: Color(
                              0xFF121481), // Ubah warna garis menjadi merah
                        ),
                        InfoRow(
                            icon: Icons.lock,
                            label: 'Password',
                            value: password),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/editprof');
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white, // Ubah warna tombol menjadi putih
                      onPrimary: Color(
                          0xFF121481), // Ubah warna teks tombol menjadi biru
                      side: BorderSide(
                          color: Color(
                              0xFF121481)), // Tambahkan garis tepi berwarna biru
                      padding: EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 25), // Sesuaikan padding tombol
                      minimumSize: Size(double.infinity,
                          1), // Panjang tombol mengikuti lebar parent
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        // Atur border radius
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Edit Profile'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _confirmLogout,
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF121481),
                      onPrimary:
                          Colors.white, // Ubah warna tombol Logout menjadi biru
                      padding: EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 27), // Sesuaikan padding tombol
                      minimumSize: Size(double.infinity,
                          0), // Panjang tombol mengikuti lebar parent
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        // Atur border radius
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Logout'),
                  ),
                ],
              ),
            ),
          ),
        ],
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
              Navigator.pushReplacementNamed(context, '/history');
              break;
            case 3:
              // Do nothing since we're already on the profile page
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
            label: 'Izin',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Color(0xFF121481),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blueGrey[900],
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
