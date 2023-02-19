import 'dart:async';
import 'dart:convert';

import 'package:absensi/screens/list_permohonan2.dart';
import 'package:absensi/widget/chooserequest.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:http/http.dart' as http;
import 'package:absensi/screens/dashboard.dart';
import 'package:absensi/screens/list_izin.dart';
import 'package:absensi/screens/list_permohonan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:absensi/widget/profil.dart';

class DetailIzinPage2 extends StatefulWidget {
  final String idPermission;
  DetailIzinPage2(this.idPermission);

  @override
  _DetailIzinPage2State createState() => _DetailIzinPage2State();
}

class _DetailIzinPage2State extends State<DetailIzinPage2> {

  //getUser
  String userID;

  //getPermission
  var content;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      userID = preferences.getString("id");
    });
  }

  Future<String> getData() async {
    var response = await http.post(
      Uri.encodeFull("http://202.137.6.90:8084/test/getpermissionsdetail2.php"),
      headers: {
        "Accept": "application/json"
      },
      body:{
        "id":widget.idPermission,
      },
    );

    if(response.statusCode==200){

      content = json.decode(response.body);

    }else{
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ChooseRequestWidget()),
            (Route<dynamic> route) => false,
      );
    }

    return "Success!";
  }

  acceptPermission() async {

    Navigator.pop(context);

    var response = await http.post(
      Uri.encodeFull("http://202.137.6.90:8084/test/acceptremote.php"),
      headers: {
        "Accept": "application/json"
      },
      body:{
        "id":widget.idPermission,
        "update_by":userID,
      },
    );

    if(response.statusCode==200){

      content = json.decode(response.body);

      if(content["status"] == "true"){
        Alert(
          style: AlertStyle(
            isCloseButton: false,
          ),
          context: context,
          title: "Berhasil",
          desc: "Remote berhasil disetujui.",
          buttons: [
            DialogButton(
              child: Text(
                "Oke",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: (){
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => ListPermohonanPage2()),
                      (Route<dynamic> route) => false,
                );
              },
              color: Color(0xFF248afd),
            ),
          ],
        ).show();
      }else{
        Alert(
          style: AlertStyle(
            isCloseButton: false,
          ),
          context: context,
          title: "Gagal",
          desc: "Remote gagal disetujui.",
          buttons: [
            DialogButton(
              child: Text(
                "Oke",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: (){
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => ListPermohonanPage2()),
                      (Route<dynamic> route) => false,
                );
              },
              color: Colors.red,
            ),
          ],
        ).show();
      }

    }else{
      Alert(
        style: AlertStyle(
          isCloseButton: false,
        ),
        context: context,
        title: "Gagal",
        desc: "Remote gagal disetujui.",
        buttons: [
          DialogButton(
            child: Text(
              "Oke",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: (){
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => ListPermohonanPage2()),
                    (Route<dynamic> route) => false,
              );
            },
            color: Colors.red,
          ),
        ],
      ).show();
    }

    return "Success!";
  }

  rejectPermission() async {

    Navigator.pop(context);

    var response = await http.post(
      Uri.encodeFull("http://202.137.6.90:8084/test/rejectremote.php"),
      headers: {
        "Accept": "application/json"
      },
      body:{
        "id":widget.idPermission,
        "update_by":userID,
      },
    );

    if(response.statusCode==200){

      content = json.decode(response.body);

      if(content["status"] == "true"){
        Alert(
          style: AlertStyle(
            isCloseButton: false,
          ),
          context: context,
          title: "Berhasil",
          desc: "Remote berhasil ditolak.",
          buttons: [
            DialogButton(
              child: Text(
                "Oke",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: (){
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => ListPermohonanPage2()),
                      (Route<dynamic> route) => false,
                );
              },
              color: Color(0xFF248afd),
            ),
          ],
        ).show();
      }else{
        Alert(
          style: AlertStyle(
            isCloseButton: false,
          ),
          context: context,
          title: "Gagal",
          desc: "Remote gagal ditolak.",
          buttons: [
            DialogButton(
              child: Text(
                "Oke",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: (){
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => ListPermohonanPage2()),
                      (Route<dynamic> route) => false,
                );
              },
              color: Colors.red,
            ),
          ],
        ).show();
      }

    }else{
      Alert(
        style: AlertStyle(
          isCloseButton: false,
        ),
        context: context,
        title: "Gagal",
        desc: "Remote gagal ditolak.",
        buttons: [
          DialogButton(
            child: Text(
              "Oke",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: (){
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => ListPermohonanPage2()),
                    (Route<dynamic> route) => false,
              );
            },
            color: Colors.red,
          ),
        ],
      ).show();
    }

    return "Success!";
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd MMMM yyyy HH:mm:ss').format(dateTime);
  }

  String _formatDate2(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy HH:mm:ss').format(dateTime);
  }

  @override
  void initState(){
    super.initState();
    getPref();
    getData();
    Intl.defaultLocale = 'id_ID';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf0f6ff),
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Detail Remote Absen'),
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
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: FutureBuilder<String>(
                        future: getData(),
                        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                          if(snapshot.hasData){
                            if(content["status"] == "true"){
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("Detail Remote Absen", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                                      (content["data"][0]["is_active"] == "0")
                                          ? Text("Canceled", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),)
                                          : (content["data"][0]["is_pending"] == "0")
                                          ? Text("Open", style: TextStyle(color: Color(0xFF248afd), fontWeight: FontWeight.bold, fontSize: 15),)
                                          : (content["data"][0]["is_pending"] == "1")
                                          ? Text("Approved", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),)
                                          : Text("Rejected", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),),
                                    ],
                                  ),
                                  SizedBox(height: 20,),

                                  Text("Pemohon", style: TextStyle(fontWeight: FontWeight.bold),),
                                  SizedBox(height: 5,),
                                  Text(content["data"][0]["employee_name"]),
                                  SizedBox(height: 10,),

                                  Text("Jenis Izin", style: TextStyle(fontWeight: FontWeight.bold),),
                                  SizedBox(height: 5,),
                                  Text("Remote Absen"),
                                  SizedBox(height: 10,),

                                  Text("Jam Masuk", style: TextStyle(fontWeight: FontWeight.bold),),
                                  SizedBox(height: 5,),
                                  Text(_formatDate(DateTime.parse(content["data"][0]["clock_in"]))),
                                  SizedBox(height: 10,),

                                  Text("Proses Remote Absen", style: TextStyle(fontWeight: FontWeight.bold),),
                                  SizedBox(height: 5,),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text("1. "+_formatDate2(DateTime.parse(content["data"][0]["clock_in"]))),
                                      ),
                                      Expanded(
                                        child: Text("Jam Masuk", style: TextStyle(fontStyle: FontStyle.italic),),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    height: 10,
                                    thickness: 1,
                                  ),
                                  (content["data"][0]["is_pending"] == "1")
                                      ?
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text("2. "+_formatDate2(DateTime.parse(content["data"][0]["update_date"]))),
                                      ),
                                      Expanded(
                                        child: Text("Remote Absen Disetujui oleh "+content["data"][0]["superior_name"], style: TextStyle(fontStyle: FontStyle.italic),),
                                      ),
                                    ],
                                  ) : (content["data"][0]["is_pending"] == "-1")
                                      ?
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text("2. "+_formatDate2(DateTime.parse(content["data"][0]["update_date"]))),
                                      ),
                                      Expanded(
                                        child: Text("Remote Absen Ditolak oleh "+content["data"][0]["superior_name"], style: TextStyle(fontStyle: FontStyle.italic),),
                                      ),
                                    ],
                                  ) : SizedBox(),
                                  (userID == content["data"][0]["pending_at"] && content["data"][0]["is_pending"] == "0" && content["data"][0]["is_active"] == "1")
                                  ? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      FlatButton(
                                        color: Color(0xFF248afd),
                                        child: Text('Menyetujui', style: TextStyle(color: Colors.white),),
                                        onPressed: () {
                                          Alert(
                                            style: AlertStyle(
                                              isCloseButton: false,
                                            ),
                                            context: context,
                                            type: AlertType.warning,
                                            title: "Approval",
                                            desc: "Menerima remote absen ini?",
                                            buttons: [
                                              DialogButton(
                                                child: Text(
                                                  "Ya",
                                                  style: TextStyle(color: Colors.white, fontSize: 15),
                                                ),
                                                onPressed: () => acceptPermission(),
                                                color: Color(0xFF248afd),
                                              ),
                                              DialogButton(
                                                child: Text(
                                                  "Tidak",
                                                  style: TextStyle(color: Colors.white, fontSize: 15),
                                                ),
                                                onPressed: () => Navigator.pop(context),
                                                color: Colors.red[900],
                                              )
                                            ],
                                          ).show();
                                        }, //callback when button is clicked
                                      ),
                                      FlatButton(
                                        color: Colors.red[900],
                                        child: Text('Menolak', style: TextStyle(color: Colors.white),),
                                        onPressed: () {
                                          Alert(
                                            style: AlertStyle(
                                              isCloseButton: false,
                                            ),
                                            context: context,
                                            type: AlertType.warning,
                                            title: "Rejection",
                                            desc: "Menolak remote absen ini?",
                                            buttons: [
                                              DialogButton(
                                                child: Text(
                                                  "Ya",
                                                  style: TextStyle(color: Colors.white, fontSize: 15),
                                                ),
                                                onPressed: () => rejectPermission(),
                                                color: Colors.red[900],
                                              ),
                                              DialogButton(
                                                child: Text(
                                                  "Tidak",
                                                  style: TextStyle(color: Colors.white, fontSize: 15),
                                                ),
                                                onPressed: () => Navigator.pop(context),
                                                color: Color(0xFF248afd),
                                              )
                                            ],
                                          ).show();
                                        }, //callback when button is clicked
                                      ),
                                    ],
                                  ) : SizedBox(),
                                ],
                              );
                            }else{
                              return ListIzinPage();
                            }
                          }else if(snapshot.hasError){
                            return Text("Error");
                          }else {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF248afd)),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}