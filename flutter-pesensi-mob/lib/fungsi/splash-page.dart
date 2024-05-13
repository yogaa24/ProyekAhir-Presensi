import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF0C2D57), // Menggunakan Color dengan kode hex
        body: Center(
          child: Container(
            width: 100, // Sesuaikan ukuran gambar sesuai kebutuhan
            height: 100,
            child: Image.asset('images/ags.png'),
          ), // Container
        ), // Center
      ), // Scaffold
    ); // MaterialApp
  }
}
