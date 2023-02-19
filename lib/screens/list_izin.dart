import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:http/http.dart' as http;
import 'package:absensi/screens/dashboard.dart';
import 'package:absensi/screens/detail_izin.dart';
import 'package:absensi/screens/izin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'package:absensi/widget/profil.dart';

class ListIzinPage extends StatefulWidget {
  @override
  _ListIzinPageState createState() => _ListIzinPageState();
}

class _ListIzinPageState extends State<ListIzinPage> {

  List data;
  TextEditingController controller = new TextEditingController();
  String filter;

  //getUser
  String userID;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      userID = preferences.getString("id");
    });
  }

  Future<String> getData() async {
    await getPref();

    var response = await http.post(
      Uri.encodeFull("http://202.137.6.90:8084/cbni-intranet/attendance/getpermissions"),
      headers: {
        "Accept": "application/json"
      },
      body:{
        "emp_id":userID
      },
    );

    if(response.statusCode==200){
      this.setState(() {
        data = json.decode(response.body)["data"];
      });
    }else{
      print("Error");
    }

    return "Success!";
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd MMMM yyyy HH:mm:ss').format(dateTime);
  }

  @override
  void initState(){
    super.initState();
    this.getData();
    Intl.defaultLocale = 'id_ID';
    controller.addListener(() {
      setState(() {
        filter = controller.text;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf0f6ff),
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: const Text('List Izin'),
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
          IconButton(
            iconSize: 20,
            icon: const Icon(FontAwesomeIcons.syncAlt),
            tooltip: 'Refresh List',
            onPressed: getData,
          ),
          IconButton(
            iconSize: 20,
            icon: const Icon(FontAwesomeIcons.plus),
            tooltip: 'Ajukan Izin',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => IzinPage())
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
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Column(
                        children: <Widget>[
                          TextField(
                            decoration: new InputDecoration(
                                isDense: true,
                                labelText: "Cari Izin / Cuti",
                                suffixIcon: Icon(FontAwesomeIcons.search, color: Color(0xFF248afd), size: 15,),
                            ),
                            controller: controller,
                          ),
                          SizedBox(height: 10,),
                          Expanded(
                            child: ListView.builder(
                              itemCount: data == null ? 0 : data.length,
                              itemBuilder: (BuildContext context, int index){
                                return
                                  filter == null || filter == ""
                                      ? InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    splashColor: Colors.blue.withAlpha(30),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => DetailIzinPage(data[index]["id"])),
                                      );
                                    },
                                    child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          side: BorderSide(color: (data[index]["is_active"] == "0")
                                              ? Colors.red
                                              : (data[index]["is_pending"] == "0")
                                              ? Color(0xFF248afd)
                                              : (data[index]["is_pending"] == "1")
                                              ? Colors.green
                                              : Colors.red, width: 1),
                                        ),
                                        elevation: 2,
                                        child: Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(data[index]["emp_name"], style: TextStyle(fontWeight: FontWeight.bold),),
                                                  Text(data[index]["name"], style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),),
                                                  Text(_formatDate(DateTime.parse(data[index]["insert_date"]))),
                                                ],
                                              ),
                                              (data[index]["is_active"] == "0")
                                                  ? Text("Canceled", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),)
                                                  : (data[index]["is_pending"] == "0")
                                                  ? Text("Open", style: TextStyle(color: Color(0xFF248afd), fontWeight: FontWeight.bold, fontSize: 15),)
                                                  : (data[index]["is_pending"] == "1")
                                                  ? Text("Approved", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),)
                                                  : Text("Rejected", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),),
                                            ],
                                          ),
                                        ),
                                    ),
                                  )
                                      : data[index]["name"].toLowerCase().contains(filter.toLowerCase())
                                      ? InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    splashColor: Colors.blue.withAlpha(30),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => DetailIzinPage(data[index]["id"])),
                                      );
                                    },
                                    child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          side: BorderSide(color: (data[index]["is_active"] == "0")
                                              ? Colors.red
                                              : (data[index]["is_pending"] == "0")
                                              ? Color(0xFF248afd)
                                              : (data[index]["is_pending"] == "1")
                                              ? Colors.green
                                              : Colors.red, width: 1),
                                        ),
                                        elevation: 2,
                                        child: Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(data[index]["emp_name"], style: TextStyle(fontWeight: FontWeight.bold),),
                                                  Text(data[index]["name"], style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),),
                                                  Text(_formatDate(DateTime.parse(data[index]["insert_date"]))),
                                                ],
                                              ),
                                              (data[index]["is_active"] == "0")
                                                  ? Text("Canceled", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),)
                                                  : (data[index]["is_pending"] == "0")
                                                  ? Text("Open", style: TextStyle(color: Color(0xFF248afd), fontWeight: FontWeight.bold, fontSize: 15),)
                                                  : (data[index]["is_pending"] == "1")
                                                  ? Text("Approved", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),)
                                                  : Text("Rejected", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),),
                                            ],
                                          ),
                                        )
                                    ),
                                  )
                                      : Container();
                              },
                            ),
                          ),
                        ],
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