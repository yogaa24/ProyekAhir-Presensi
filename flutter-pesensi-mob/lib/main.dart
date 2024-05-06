import 'package:flutter/material.dart';
import 'package:flutter_pesensimob/dashboard/absen-page.dart';
import 'package:flutter_pesensimob/dashboard/edit-prof.dart';
import 'package:flutter_pesensimob/dashboard/history-page.dart';
import 'package:flutter_pesensimob/dashboard/home-page.dart';
import 'package:flutter_pesensimob/dashboard/ijin-page.dart';
import 'package:flutter_pesensimob/dashboard/profile-page.dart';
import 'package:flutter_pesensimob/fungsi/lokasi-page.dart';
import 'package:flutter_pesensimob/fungsi/splash-page.dart';
import 'package:flutter_pesensimob/reglog/login-page.dart';
import 'package:flutter_pesensimob/reglog/regis-page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 3)),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        } else {
          return MaterialApp(
            routes: {
              '/login': (context) => LoginPage(),
              '/regis': (context) => RegistrationPage(),
              // route dashboard
              '/home': (context) => HomePage(),
              '/absen': (context) => AbsenPage(), // menggunakan alias "absen"
              '/izin': (context) => IzinPage(),
              '/history': (context) => HistoryPage(),
              '/profile': (context) => ProfilePage(),
              '/editprof': (context) => EditProfilePage(),
              '/lokasi': (context) =>
                  LocationPage(latitude: -8.1599498, longitude: 113.7204984)
            },
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: LoginPage(),
          );
        }
      },
    );
  }
}
