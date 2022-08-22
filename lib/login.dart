import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:presensi/main.dart';
import 'package:presensi/models/login-model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as myHttp;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late Future<String> _name, _token;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });
    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });

    checkToken(_token, _name);
  }

  checkToken(token, name) async {
    String tokenStr = await token;
    String nameStr = await name;
    if (tokenStr != "" && nameStr != "") {
      Future.delayed(Duration(seconds: 1), () async {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => HomePage()))
            .then((value) {
          // setState(() {});
        });
      });
    }
  }

  Future login(email, password) async {
    LoginModel? loginModel;
    Map<String, String> body = {"email": email, "password": password};
    final headers = {'Content-Type': 'application/json'};
    var response = await myHttp.post(
        Uri.parse("https://punyawa.com/presensi/public/api/login"),
        body: body);
    if (response.statusCode == 401) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Email atau password salah"),
      ));
    } else {
      loginModel = LoginModel.fromJson(json.decode(response.body));
    }
    saveUser(loginModel?.data.token, loginModel?.data.name);
  }

  Future saveUser(token, name) async {
    final SharedPreferences pref = await _prefs;
    pref.setString("name", name);
    pref.setString("token", token);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => HomePage()))
        .then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Email"),
                TextField(controller: emailController),
                SizedBox(
                  height: 30,
                ),
                Text("Password"),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                    onPressed: () {
                      login(emailController.text, passwordController.text);
                    },
                    child: Text("Login"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
