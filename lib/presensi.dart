import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:location/location.dart';
import 'package:presensi/models/save-presensi-model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:http/http.dart' as myHttp;

class PresensiPage extends StatefulWidget {
  const PresensiPage({Key? key}) : super(key: key);

  @override
  State<PresensiPage> createState() => _PresensiPageState();
}

class _PresensiPageState extends State<PresensiPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<LocationData?> _currentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    Location location = new Location();

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

  Future savePresensi(latitude, longitude) async {
    SavePresensiModel savePresensiModel;
    Map<String, String> body = {
      "latitude": latitude.toString(),
      "longitude": longitude.toString()
    };
    ;
    final Map<String, String> headers = {
      'Authorization': 'Bearer ' +
          await _prefs.then((SharedPreferences prefs) {
            return prefs.getString("token") ?? "";
          })
    };
    var response = await myHttp.post(
        Uri.parse("https://punyawa.com/presensi/public/api/save-presensi"),
        body: body,
        headers: headers);
    savePresensiModel = SavePresensiModel.fromJson(json.decode(response.body));

    if (savePresensiModel.success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Sukses simpan presensi"),
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Gagal simpan presensi"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: Text("Presensi"),
      ),
      body: FutureBuilder<LocationData?>(
        future: _currentLocation(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapchat) {
          if (snapchat.hasData) {
            final LocationData currentLocation = snapchat.data;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            markerBuilder: (BuildContext context, int index) {
                              return MapMarker(
                                latitude: currentLocation.latitude!,
                                longitude: currentLocation.longitude!,
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.red[800],
                                ),
                                size: Size(40, 40),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          savePresensi(currentLocation.latitude,
                              currentLocation.longitude);
                        },
                        child: Text('Simpan Presensi'))
                  ],
                ),
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
