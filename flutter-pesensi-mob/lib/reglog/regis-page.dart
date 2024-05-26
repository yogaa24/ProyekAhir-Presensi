import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isObscure = true;

  Future<void> _register() async {
    final String url = 'https://agspresensi.framework-tif.com/api/register';

    final response = await http.post(
      Uri.parse(url),
      body: {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'phone_number': _phoneNumberController.text,
        'job_title': _jobTitleController.text,
        'address': _addressController.text,
      },
    );

    if (response.statusCode == 201) {
      // Registration successful
      print('Registration successful: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // Registration failed
      print('Registration failed: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              height: 100, // Sesuaikan dengan tinggi gambar Anda
              child: Image.asset(
                'image/ags.png', // Ubah dengan path gambar Anda
                fit: BoxFit.contain, // Sesuaikan dengan kebutuhan
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Register Your Account",
              style: TextStyle(
                color: Color(0xFF0C2D57),
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 15),
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
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Name",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(0),
                  hintStyle: TextStyle(
                    height: 1,
                    color: Color(0xFF0C2D57),
                  ),
                ),
              ),
            ),
            SizedBox(height: 13),
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
                decoration: InputDecoration(
                  hintText: "Email",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(0),
                  hintStyle: TextStyle(
                    height: 1,
                    color: Color(0xFF0C2D57),
                  ),
                ),
              ),
            ),
            SizedBox(height: 13),
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
                  TextField(
                    controller: _passwordController,
                    obscureText: _isObscure, // Menggunakan nilai _isObscure
                    decoration: InputDecoration(
                      hintText: "Password",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(0),
                      hintStyle: TextStyle(height: 1, color: Color(0xFF0C2D57)),
                    ),
                  ),
                  IconButton(
                    iconSize: 20,
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                      color: Color(0xFF0C2D57),
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
                controller: _phoneNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  hintText: "Phone Number",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(0),
                  hintStyle: TextStyle(height: 1, color: Color(0xFF0C2D57)),
                ),
              ),
            ),
            SizedBox(height: 13),
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
                controller: _jobTitleController,
                decoration: InputDecoration(
                  hintText: "Job Title",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(0),
                  hintStyle: TextStyle(height: 1, color: Color(0xFF0C2D57)),
                ),
              ),
            ),
            SizedBox(height: 13),
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
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: "Address",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(0),
                  hintStyle: TextStyle(height: 1, color: Color(0xFF0C2D57)),
                ),
              ),
            ),
            SizedBox(height: 13),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF0C2D57),
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
                  'Register',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Login',
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
    );
  }
}
