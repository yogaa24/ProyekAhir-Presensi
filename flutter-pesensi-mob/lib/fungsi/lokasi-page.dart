import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationPage extends StatelessWidget {
  final double latitude;
  final double longitude;

  LocationPage({required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lokasi Perusahaan'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _launchMaps(latitude, longitude);
          },
          child: Text('Buka Lokasi di Peta'),
        ),
      ),
    );
  }

  void _launchMaps(double latitude, double longitude) async {
    String url =
        'https://www.google.com/maps/place/PT+Arsenet+Global+Solusi/@-8.1763075,113.7179421,17z/data=!3m1!4b1!4m6!3m5!1s0x2dd6977bd9b175dd:0xcc4ff138e7ca2138!8m2!3d-8.1763128!4d113.720517!16s%2Fg%2F11qyrmh9j1?entry=ttu';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class LokasiPage extends StatelessWidget {
  const LokasiPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double latitude =
        -8.163732; // Ganti dengan latitude perusahaan-8.163732 | 113.711073
    double longitude = 113.711073; // Ganti dengan longitude perusahaan

    return Scaffold(
      appBar: AppBar(
        title: Text('Presensi'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocationPage(
                  latitude: latitude,
                  longitude: longitude,
                ),
              ),
            );
          },
          child: Text('Buka Lokasi Perusahaan'),
        ),
      ),
    );
  }
}
