import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:location/location.dart';
import 'package:flutter_pesensimob/models/save-presensi-response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:http/http.dart' as myHttp;
import 'dart:math' as Math;

class AbsenPage extends StatefulWidget {
  const AbsenPage({Key? key}) : super(key: key);

  @override
  State<AbsenPage> createState() => _AbsenPageState();
}

class _AbsenPageState extends State<AbsenPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> token;

  @override
  void initState() {
    super.initState();
    token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });
  }

  Future<LocationData?> _getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    Location location = Location();

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    return await location.getLocation();
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    const c = Math.cos;
    final a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * Math.asin(Math.sqrt(a)) * 1000;
  }

  Future<void> _savePresensi(double latitude, double longitude) async {
    SavePresensiResponseModel savePresensiResponseModel;
    //ARSENET
    // final double companyLatitude = -8.1599498; // Latitude perusahaan
    // final double companyLongitude = 113.7204984; // Longitude perusahaan

    // KOS ABANG
    final double companyLatitude = -8.1636542; // Latitude perusahaan
    final double companyLongitude = 113.7082543; // Longitude perusahaan

    //KOS HUSNUL CANTIKS
    // final double companyLatitude = -8.1593229; // Latitude perusahaan
    // final double companyLongitude = 113.7238852; // Longitude perusahaan

    final double radius = 1000; // Radius dalam meter (1 km)

    double distance = _calculateDistance(
        latitude, longitude, companyLatitude, companyLongitude);

    if (distance > radius) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Anda berada di luar radius perusahaan')));
      return; // Tidak menyimpan presensi jika berada di luar radius
    }

    Map<String, String> body = {
      "latitude": latitude.toString(),
      "longitude": longitude.toString()
    };

    Map<String, String> headers = {'Authorization': 'Bearer ' + await token};

    var response = await myHttp.post(
        Uri.parse("https://agspresensi.framework-tif.com/api/save-presensi"),
        body: body,
        headers: headers);

    savePresensiResponseModel =
        SavePresensiResponseModel.fromJson(json.decode(response.body));

    if (savePresensiResponseModel.success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sukses simpan Presensi')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal simpan Presensi')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Presensi"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: FutureBuilder<LocationData?>(
          future: _getCurrentLocation(),
          builder:
              (BuildContext context, AsyncSnapshot<LocationData?> snapshot) {
            if (snapshot.hasData) {
              final LocationData currentLocation = snapshot.data!;
              print("KODING : " +
                  currentLocation.latitude.toString() +
                  " | " +
                  currentLocation.longitude.toString());
              return SafeArea(
                  child: Column(
                children: [
                  Container(
                    height: 300,
                    child: SfMaps(
                      layers: [
                        MapTileLayer(
                          initialFocalLatLng: MapLatLng(
                              currentLocation.latitude!,
                              currentLocation.longitude!),
                          initialZoomLevel: 15,
                          initialMarkersCount: 1,
                          urlTemplate:
                              "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          markerBuilder: (BuildContext context, int index) {
                            return MapMarker(
                              latitude: currentLocation.latitude!,
                              longitude: currentLocation.longitude!,
                              child: Icon(
                                Icons.location_on,
                                color: Colors.red,
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        _savePresensi(currentLocation.latitude!,
                            currentLocation.longitude!);
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      child: Text("Simpan Presensi"))
                ],
              ));
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
