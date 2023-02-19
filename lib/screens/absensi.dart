import 'package:flutter/material.dart';
import 'package:absensi/screens/dashboard.dart';
import 'package:absensi/widget/profil.dart';
import 'package:absensi/widget/button_absen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AbsenPage extends StatefulWidget {
  @override
  _AbsenPage createState() => _AbsenPage();
}

class _AbsenPage extends State<AbsenPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf0f6ff),
      appBar: AppBar(
        title: const Text('Absensi'),
        actions: <Widget>[
          IconButton(
            iconSize: 20,
            icon: const Icon(FontAwesomeIcons.home),
            tooltip: 'Dashboard',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => DashboardPage()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              ProfilWidget(),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                  ),
                  elevation: 10,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: ButtonAbsenWidget(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}