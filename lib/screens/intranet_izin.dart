import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntranetIzinPage extends StatefulWidget {
  @override
  _IntranetIzinPage createState() => _IntranetIzinPage();
}

class _IntranetIzinPage extends State<IntranetIzinPage> {

  Completer<WebViewController> _completer = Completer<WebViewController>();

  String empID;

  //getUser
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userID = preferences.getString("id");
    setState(() {
      empID = userID;
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
      appBar: AppBar(
        title: const Text('Cuti & Izin'),
      ),
      body: WebviewScaffold(
        url: 'http://202.137.6.90:8084/cbni-intranet/permission/index/'+empID,
        withJavascript: true,
        withLocalStorage: true,
        allowFileURLs: true,
        resizeToAvoidBottomInset: true,
      ),
    );

  }

}