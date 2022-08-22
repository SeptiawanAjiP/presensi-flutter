import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:presensi/login.dart';
import 'package:presensi/models/home-model.dart';
import 'package:presensi/presensi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as myHttp;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _name, _token;
  HomeModel? homeModel;
  Datum? hariIni;
  List<Datum> riwayat = [];

  @override
  void initState() {
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });
    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });
  }

  Future getData() async {
    final Map<String, String> headers = {
      'Authorization': 'Bearer ' + await _token
    };
    var response = await myHttp.get(
        Uri.parse('https://punyawa.com/presensi/public/api/get-presensi'),
        headers: headers);
    print('DATA : ' + response.body);
    homeModel = HomeModel.fromJson(json.decode(response.body));
    riwayat.clear();
    homeModel!.data.forEach((element) {
      if (!element.isHariIni) {
        riwayat.add(element);
      } else {
        hariIni = element;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: getData(),
          builder: (context, snapshotData) {
            if (snapshotData.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              return SafeArea(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder(
                      future: _name,
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else {
                          print(snapshot.data);
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              snapshot.data!,
                              style: TextStyle(fontSize: 18),
                            ),
                          );
                        }
                      }),
                  Center(
                    child: Container(
                        width: 360,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: Colors.blue[800],
                            borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(hariIni?.tanggal ?? '-',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      hariIni?.masuk ?? '-',
                                      style: TextStyle(
                                          fontSize: 24, color: Colors.white),
                                    ),
                                    Text(
                                      'Masuk',
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      hariIni?.pulang ?? '-',
                                      style: TextStyle(
                                          fontSize: 24, color: Colors.white),
                                    ),
                                    Text(
                                      'Pulang',
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              ],
                            )
                          ],
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text("Riwayat Presensi"),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: riwayat.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: Card(
                          child: ListTile(
                            leading: Text(riwayat[index].tanggal,
                                style: TextStyle(fontSize: 12)),
                            title: Row(children: [
                              Column(
                                children: [
                                  Text(
                                    riwayat[index].masuk ?? '-',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                  Text(
                                    'Masuk',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    riwayat[index].pulang ?? '-',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                  Text(
                                    'Pulang',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              ),
                            ]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ));
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => PresensiPage()))
              .then((value) {
            setState(() {});
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
