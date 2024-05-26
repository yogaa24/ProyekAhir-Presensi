import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;

  Future<void> _login(BuildContext context) async {
    final response = await http.post(
      Uri.parse('https://agspresensi.framework-tif.com/api/login'),
      body: {
        'email': _emailController.text,
        'password': _passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      // Login berhasil
      final responseData = jsonDecode(response.body);
      final token = responseData['data']['token'];
      final name = responseData['data']['name']; // Mengambil nama dari server

      // Simpan token dan nama pengguna secara aman menggunakan shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('name', name);

      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Login gagal

      if (response.statusCode == 401) {
        // Kesalahan input dari pengguna (misalnya, email atau kata sandi salah)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email atau Password Salah')),
        );
      } else {
        // Kesalahan server
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan pada server')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Login'),
      // ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Judul
              Text(
                "Login",
                style: TextStyle(
                  color: Color(0xFF1E3190),
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              // Deskripsi
              Text(
                "Login To Your Account",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 15),
              // Input Email
              Container(
                width: double.infinity,
                height: 55,
                padding: const EdgeInsets.only(top: 3, left: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 7,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Email",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(0),
                    hintStyle: TextStyle(height: 1),
                  ),
                ),
              ),
              SizedBox(height: 13),
              // Input Password
              // Input Password
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 3, left: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 7,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _isObscure,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: "Password",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(0),
                        hintStyle: TextStyle(height: 1),
                      ),
                    ),
                    IconButton(
                      iconSize: 20,
                      icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 13),
              // Tombol Login
              ElevatedButton(
                onPressed: () async {
                  await _login(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF1E3190),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  shadowColor: Colors.black.withOpacity(0.1),
                  elevation: 10,
                ),
                child: Container(
                  alignment: Alignment.center,
                  height: 55,
                  child: Text(
                    'Log in',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              // Teks "Don't have an account ?" dan "Register"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/regis');
                    },
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Don\'t have an account ? ',
                        style: TextStyle(color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Register',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
