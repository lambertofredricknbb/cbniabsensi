import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Test2 extends StatefulWidget {
  @override
  Test2State createState() => new Test2State();
}

class Test2State extends State<Test2> {

  List data;
  TextEditingController controller = new TextEditingController();
  String filter;

  Future<String> getData() async {
    var response = await http.post(
        Uri.encodeFull("http://202.137.6.90:8084/test/getpermissions.php"),
        headers: {
          "Accept": "application/json"
        },
        body:{
          "user_id":"1197"
        },
    );

    this.setState(() {
      data = json.decode(response.body)["data"];
    });

    return "Success!";
  }

  @override
  void initState(){
    super.initState();
    this.getData();
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
  Widget build(BuildContext context){
    return new Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: new EdgeInsets.only(top: 20.0),
          ),
          TextField(
            decoration: new InputDecoration(
                labelText: "Search title"
            ),
            controller: controller,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: data == null ? 0 : data.length,
              itemBuilder: (BuildContext context, int index){
                return
                  filter == null || filter == ""
                      ? InkWell(
                        splashColor: Colors.blue.withAlpha(30),
                        onTap: () {
                          print(index);
                        },
                        child: Card(
                          child: new Text(data[index]["name"]),
                        ),
                      )
                      : data[index]["name"].contains(filter)
                      ? InkWell(
                        splashColor: Colors.blue.withAlpha(30),
                        onTap: () {
                          print(index);
                        },
                        child: Card(
                          child: new Text(data[index]["name"]),
                        ),
                      )
                      : Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}