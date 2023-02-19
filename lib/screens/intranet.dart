import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class IntranetPage extends StatefulWidget {
  @override
  _IntranetPage createState() => _IntranetPage();
}

class _IntranetPage extends State<IntranetPage> {

  Completer<WebViewController> _completer = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('CBNI Intranet'),
      ),
      body: WebviewScaffold(
        url: 'http://202.137.6.90:8084/cbni-intranet/home',
        withJavascript: true,
        withLocalStorage: true,
        allowFileURLs: true,
        resizeToAvoidBottomInset: true,
      ),
    );

  }

}