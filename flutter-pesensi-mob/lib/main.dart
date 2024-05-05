import 'package:flutter/material.dart';
import 'package:flutter_pesensimob/dashboard/absen-page.dart';
import 'package:flutter_pesensimob/dashboard/edit-prof.dart';
import 'package:flutter_pesensimob/dashboard/history-page.dart';
import 'package:flutter_pesensimob/dashboard/home-page.dart';
import 'package:flutter_pesensimob/dashboard/ijin-page.dart';
import 'package:flutter_pesensimob/dashboard/profile-page.dart';
import 'package:flutter_pesensimob/fungsi/lokasi-page.dart';
import 'package:flutter_pesensimob/reglog/login-page.dart';
import 'package:flutter_pesensimob/reglog/regis-page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/login': (context) => LoginPage(),
        '/regis': (context) => RegistrationPage(),
        // route dahsboard
        '/home': (context) => HomePage(),
        '/absen': (context) => AbsenPage(),
        '/izin': (context) => IzinPage(),
        '/history': (context) => HistoryPage(),
        '/profile': (context) => ProfilePage(),
        '/editprof': (context) => EditProfilePage(),
        '/lokasi': (context) => LocationPage()
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}
