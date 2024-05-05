import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import library untuk mengelola gambar dari galeri
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// Import the EditProfilePage

class EditProfilePage extends StatefulWidget {
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
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

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController jobTitleController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    _loadName(); // Panggil fungsi untuk mengambil nama saat halaman dimuat
    super.initState();
  }

  // Fungsi untuk mengambil nama pengguna dari SharedPreferences
  Future<void> _loadName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ??
          ''; // Jika tidak ada nama, gunakan string kosong
    });
    print('nama adalah: $name');
    // Setelah mendapatkan nama, panggil fungsi untuk mengambil profil
    _fetchProfile();
  }

  // Fungsi untuk logout
  void logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        profileImageUrl = pickedImage.path;
      });
    }
  }

  // Fungsi untuk mengambil data profil dari database menggunakan email
  Future<void> _fetchProfile() async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/profile/${name}'),
    );
    print(name);
    // print(response.body);
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
          // Anda mungkin tidak ingin menampilkan password di sini

          // Set data to controllers
          nameController.text = nama;
          phoneNumberController.text = nomorTelepon;
          emailController.text = email;
          jobTitleController.text = jabatan;
          addressController.text = alamat;
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  // Fungsi untuk memperbarui profil pengguna
  Future<void> _updateProfile() async {
    final Uri uri = Uri.parse('http://localhost:8000/api/edit-profile/$name');
    final response = await http.put(
      uri,
      body: {
        'name': nameController.text,
        'phone_number': phoneNumberController.text,
        'email': emailController.text,
        'job_title': jobTitleController.text,
        'address': addressController.text,
      },
    );

    if (response.statusCode == 200) {
      // Jika penyuntingan profil berhasil, perbarui state lokal
      setState(() {
        // Perbarui data profil dengan data yang baru
        nama = nameController.text;
        nomorTelepon = phoneNumberController.text;
        email = emailController.text;
        jabatan = jobTitleController.text;
        alamat = addressController.text;
      });

      // Perbarui nilai 'name' di SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('name', nameController.text);

      // Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil berhasil diperbarui'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Jika gagal, tampilkan pesan error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Gagal memperbarui profil. Silakan coba lagi nanti.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/profile');
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          GestureDetector(
            onTap: () {
              _pickImage(ImageSource.gallery);
            },
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(profileImageUrl),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Ganti Profil',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nama'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: phoneNumberController,
                decoration: InputDecoration(labelText: 'No Telepon'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: jobTitleController,
                decoration: InputDecoration(labelText: 'Jabatan'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Alamat'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _updateProfile().then((_) {
                    _fetchProfile(); // Memperbarui profil setelah update
                    Navigator.pushReplacementNamed(context,
                        '/profile'); // Arahkan ke halaman home setelah berhasil
                  }).catchError((error) {
                    // Handle error
                    print('Error updating profile: $error');
                  });
                },
                child: Text('Simpan'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
