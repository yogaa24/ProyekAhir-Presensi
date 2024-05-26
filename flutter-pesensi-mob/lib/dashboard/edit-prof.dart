import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
    _loadName();
    super.initState();
  }

  Future<void> _loadName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
    });
    _fetchProfile();
  }

  void logout() {
    Navigator.pushReplacementNamed(context, '/login');
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
      setState(() {
        nama = nameController.text;
        nomorTelepon = phoneNumberController.text;
        email = emailController.text;
        jabatan = jobTitleController.text;
        alamat = addressController.text;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('name', nameController.text);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            icon: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 40,
            ),
            title: Text('Profil Berhasil Diperbarui'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/profile');
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
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
        title: Text(
          'Edit Profil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/profile');
          },
        ),
        backgroundColor: Color(0xFF121481),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
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
                      Icon(Icons.camera_alt, color: Color(0xFF121481)),
                      SizedBox(width: 8),
                      Text(
                        'Ganti Profil',
                        style: TextStyle(
                          color: Color(0xFF121481),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildTextField('Nama', nameController),
            SizedBox(height: 10),
            _buildTextField('No Telepon', phoneNumberController),
            SizedBox(height: 10),
            _buildTextField('Email', emailController),
            SizedBox(height: 10),
            _buildTextField('Jabatan', jobTitleController),
            SizedBox(height: 10),
            _buildTextField('Alamat', addressController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _updateProfile().then((_) {
                  _fetchProfile();
                }).catchError((error) {
                  print('Error updating profile: $error');
                });
              },
              child: Text(
                'Simpan',
              ),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF121481),
                onPrimary:
                    Colors.white, // Ubah warna tombol Logout menjadi biru
                padding: EdgeInsets.symmetric(
                    horizontal: 0, vertical: 27), // Sesuaikan padding tombol
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF121481)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Color(0xFF121481)),
        ),
      ),
      style: TextStyle(color: Colors.black),
    );
  }
}
