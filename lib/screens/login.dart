import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:absensi/animation/slide_down.dart';

import 'package:absensi/screens/dashboard.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  //sharedPref
  final userController = new TextEditingController();
  final passController = new TextEditingController();
  String isLogin = "-1";

  getLogin() async {
    final response = await http.post(
      "http://202.137.6.90:8084/cbni-intranet/attendance/login",
      body: {
        "username": userController.text,
        "password": passController.text,
      },
    );

    if (response.statusCode == 200) {
      final content = json.decode(response.body);

      if (content['status'] == 'true') {
        String id = content['data'][0]['emp_id'];
        String employeeName = content['data'][0]['f_name'];
        String division = content['data'][0]['positions'];
        String username = content['data'][0]['username'];

        await savePref(id, username, employeeName, division, true);

        setState(() {
          isLogin = "1";
        });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
          (Route<dynamic> route) => false,
        );
      } else {
        setState(() {
          isLogin = "0";
        });
      }
    } else {
      setState(() {
        isLogin = "0";
      });
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  savePref(String id, String username, String employeeName, String division,
      bool isLogin) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setString("id", id);
      preferences.setString("username", username);
      preferences.setString("name", employeeName);
      preferences.setString("division", division);
      preferences.setBool("login", isLogin);
    });
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      if (preferences.getBool("login") == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
          (Route<dynamic> route) => false,
        );
      }
    });
  }

  //password input
  bool _isHidePassword = true;

  void _togglePasswordVisibilty() {
    setState(() {
      _isHidePassword = !_isHidePassword;
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFF248afd),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 100,
            ),
            SlideDown(
              1,
              Image(
                image: AssetImage('assets/images/cbn.png'),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            SlideDown(
              1.25,
              (isLogin == "-1")
                  ? Text(
                      "Silahkan Login",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  : (isLogin != "1")
                      ? Text(
                          "Gagal Login",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        )
                      : Text(
                          "Berhasil Login",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
            ),
            SizedBox(
              height: 10,
            ),
            SlideDown(
              1.5,
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 5.0),
                    child: SlideDown(
                      3,
                      TextField(
                        controller: userController,
                        obscureText: false,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(
                            Icons.nature_people,
                            color: Colors.blue[500],
                          ),
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                          labelText: 'Username',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
                    child: SlideDown(
                      3,
                      TextField(
                        controller: passController,
                        obscureText: _isHidePassword,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(
                            Icons.security,
                            color: Colors.blue[500],
                          ),
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                          labelText: 'Password',
                          suffixIcon: GestureDetector(
                            onTap: () {
                              _togglePasswordVisibilty();
                            },
                            child: Icon(
                              _isHidePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: _isHidePassword
                                  ? Colors.grey
                                  : Colors.blue[500],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    child: SlideDown(
                      4,
                      MaterialButton(
                        elevation: 10.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          "MASUK",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 5.0,
                          ),
                        ),
                        onPressed: () {
                          getLogin();
                        },
                        color: Colors.amber[500],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SlideDown(
              2,
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  "Versi 1.0",
                  style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
