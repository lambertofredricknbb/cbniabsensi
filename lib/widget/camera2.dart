import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:absensi/screens/dashboard.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:latlong/latlong.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TakePicturePage2 extends StatefulWidget {
  final CameraDescription camera;
  final String title;
  TakePicturePage2({@required this.camera, this.title});

  @override
  _TakePicturePage2State createState() => _TakePicturePage2State();
}

final Distance distance = new Distance();
// meter
LatLng cikarang = new LatLng(-6.338048, 107.154572);
LatLng staco = new LatLng(-6.224545, 106.840375);
LatLng tanahmerah = new LatLng(-6.156676, 106.875260);
LatLng nias = new LatLng(1.246114, 97.643914);

class _TakePicturePage2State extends State<TakePicturePage2> {
  //Button Counter
  int _counter = 0;

  void _incrementCounter(){
    setState(() {
      _counter++;
    });
  }

  //timer
  String _timeString, _dateString;
  Timer _timer;

  //location
  Location location = new Location();
  LocationData _location;
  StreamSubscription<LocationData> _locationSubscription;
  String _error;

  Future<void> _getLocation() async {
    setState(() {
      _error = null;
    });
    try {
      final LocationData _locationResult = await location.getLocation();
      setState(() {
        _location = _locationResult;
      });
    } on PlatformException catch (err) {
      setState(() {
        _error = err.code;
      });
    }
  }

  //permission location
  PermissionStatus _permissionGranted;

  _checkPermissions() async {
    PermissionStatus permissionGrantedResult = await location.hasPermission();
    setState(() {
      _permissionGranted = permissionGrantedResult;
    });
  }

  _requestPermission() async {
    if (_permissionGranted != PermissionStatus.GRANTED) {
      PermissionStatus permissionRequestedResult =
      await location.requestPermission();
      setState(() {
        _permissionGranted = permissionRequestedResult;
      });
      if (permissionRequestedResult != PermissionStatus.GRANTED) {
        return;
      }
    }
  }

  //service location
  bool _serviceEnabled;

  _checkService() async {
    bool serviceEnabledResult = await location.serviceEnabled();
    setState(() {
      _serviceEnabled = serviceEnabledResult;
    });
  }

  _requestService() async {
    if (_serviceEnabled == null || !_serviceEnabled) {
      bool serviceRequestedResult = await location.requestService();
      setState(() {
        _serviceEnabled = serviceRequestedResult;
      });
      if (!serviceRequestedResult) {
        return;
      }
    }
  }

  _checkbothloc(BuildContext context) async {
    if(_permissionGranted != PermissionStatus.GRANTED){
      await _requestPermission();
    }

    if(_permissionGranted == PermissionStatus.DENIED_FOREVER){
      Navigator.pop(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(),
        ),
      );
    }

    if(_serviceEnabled != true){
      await _requestService();
    }

    if(_permissionGranted == PermissionStatus.GRANTED && _serviceEnabled == true){
      _takePicture(context);
    }
  }

  ProgressDialog pr;

  CameraController _cameraController;
  Future<void> _initializeCameraControllerFuture;

  //timer
  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd MMMM yyyy (E)').format(dateTime);
  }

  Future _takePicture(BuildContext context) async {

    try {
      // Ensure that the camera is initialized.
      await _initializeCameraControllerFuture;

      // Construct the path where the image should be saved using the path
      // package.
      final pathQu = join(
        // Store the picture in the temp directory.
        // Find the temp directory using the `path_provider` plugin.
        (await getTemporaryDirectory()).path,
        '${DateTime.now().millisecondsSinceEpoch}.png',
      );

      // Attempt to take a picture and log where it's been saved.
      await _cameraController.takePicture(pathQu);
      await upload(File(pathQu), context);
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }

  //getUser
  String userID;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      userID = preferences.getString("id");
    });
  }

  Future upload(File imageFile, BuildContext context) async {
    await _getLocation();

    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
      message: "Menunggu...",
      progressWidget: Container(
          padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
        color: Color(0xFF248afd),
      ),
      messageTextStyle: TextStyle(
        color: Color(0xFF248afd),
        fontSize: 15,
      ),
    );
    pr.show();

    var stream =
    new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();
    //var uri = Uri.parse("https://testbeto.000webhostapp.com/upload.php");
    var uri = Uri.parse("http://202.137.6.90:8084/cbni-intranet/attendance/postabsen2");

    var request = new http.MultipartRequest("POST", uri);

    var multipartFile = new http.MultipartFile("file", stream, length,
        filename: basename(imageFile.path));
    request.fields['emp_id'] = userID;
    request.fields['location_in'] =
    "${_location.latitude}, ${_location.longitude}";
    request.files.add(multipartFile);

    var response = await request.send();

    if (response.statusCode == 200) {
      print("Berhasil");
      pr.dismiss();
      _cameraController.dispose();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
            (Route<dynamic> route) => false,
      );
    } else {
      print("Gagal");
      pr.dismiss();
    }
    /*response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });*/

  }

  @override
  void initState() {
    super.initState();

    //userID
    this.getPref();

    //camera
    _cameraController =
        CameraController(widget.camera, ResolutionPreset.medium);
    _initializeCameraControllerFuture = _cameraController.initialize();

    //timer
    Intl.defaultLocale = 'id_ID';
    _timeString = _formatDateTime(DateTime.now());
    _dateString = _formatDate(DateTime.now());
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
      body: Stack(/*fit: StackFit.expand,*/ children: <Widget>[
        FutureBuilder(
          future: _initializeCameraControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Center(
                child: Transform.scale(
                  scale: _cameraController.value.aspectRatio / deviceRatio,
                  child: AspectRatio(
                    aspectRatio: _cameraController.value.aspectRatio,
                    child: CameraPreview(_cameraController),
                  ),
                ),
              );
            } else {
              return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[500]),
                  ));
            }
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: Container(
              width: 90.0,
              height: 90.0,
              child: FloatingActionButton(
                backgroundColor: Color(0xFF248afd),
                onPressed: (){
                  if(_counter < 1){
                    _checkbothloc(context);
                    _incrementCounter();
                  }else{
                    null;
                  }
                },
                child: Icon(
                  Icons.camera,
                  size: 45.0,
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 100,
            width: double.infinity,
            color: Color(0xFF248afd),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 10,),
                Text(
                  _timeString,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _dateString,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _timer.cancel();
    super.dispose();
  }
}
