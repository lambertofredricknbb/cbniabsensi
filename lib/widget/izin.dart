import "package:flutter/material.dart";
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Test2 extends StatefulWidget {
  @override
  _Test2State createState() => _Test2State();
}

class _Test2State extends State<Test2> {
  String _mySelection;

  List data = List(); //edited line

  Future<String> getSWData() async {
    var res = await http
        .get(Uri.encodeFull("https://testbeto.000webhostapp.com/test/getallpermissions.php"),
        headers: {"Accept": "application/json"},
    );

    var resBody = json.decode(res.body);

    setState(() {
      data = resBody["data"];
    });

    print(resBody);

    return "Sucess";
  }

  @override
  void initState() {
    super.initState();
    this.getSWData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: DropdownButton(
        elevation: 10,
        isExpanded: true,
        items: data.map((item) {
          return new DropdownMenuItem(
            child: new Text(item['name']),
            value: item['id'].toString(),
          );
        }).toList(),
        onChanged: (newVal) {
          setState(() {
            _mySelection = newVal;
            print(_mySelection);
          });
        },
        value: _mySelection,
      ),
    );
  }
}