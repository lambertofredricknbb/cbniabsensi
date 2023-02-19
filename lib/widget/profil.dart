import 'package:flutter/material.dart';
import 'package:absensi/animation/slide_down.dart';

import 'package:absensi/screens/login.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ProfilWidget extends StatefulWidget {
  @override
  _ProfilWidget createState() => _ProfilWidget();
}

class _ProfilWidget extends State<ProfilWidget> {

  String name, division;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      if(preferences.getBool("login") != true){
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false,
        );
      }
      name = preferences.getString("name");
      division = preferences.getString("division");
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {

    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Color(0xFF248afd), width: 1),
      ),
      elevation: 10,
      color: Color(0xFF248afd),
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SlideDown(
              1,
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fitWidth,
                    image: AssetImage("assets/images/avatar.jpg"),
                  ),
                ),
              ),
            ),
            SizedBox(width: 20,),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SlideDown(
                    1.5,
                    Text(
                      'Hi, ${name}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SlideDown(
                    2,
                    Text(
                      '${division}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }

}