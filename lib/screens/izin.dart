import 'package:flutter/material.dart';
import 'package:absensi/screens/dashboard.dart';
import 'package:absensi/screens/list_izin.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:absensi/widget/profil.dart';

import 'package:absensi/animation/slide_up.dart';

import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

import 'package:async/async.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Img;

import 'package:shared_preferences/shared_preferences.dart';

import 'package:progress_dialog/progress_dialog.dart';

class IzinPage extends StatefulWidget {
  @override
  _IzinPage createState() => _IzinPage();
}

class _IzinPage extends State<IzinPage> {

  //datetime
  final format = DateFormat("yyyy-MM-dd HH:mm:ss");

  //getPermissions
  List data = List(); //edited line
  Future<String> getIzin() async {
    var res = await http
        .get(Uri.encodeFull("http://202.137.6.90:8084/cbni-intranet/attendance/getallpermissions"),
      headers: {"Accept": "application/json"},
    );

    var resBody = json.decode(res.body);

    setState(() {
      data = resBody["data"];
    });

    print(resBody);

    return "Sucess";
  }

  //file & upload
  File _image;
  String _filename;
  bool validate1, validate2, validate3, validate4 = false;
  String _mySelection;
  final awalControl = new TextEditingController();
  final selesaiControl = new TextEditingController();
  final keteranganControl = new TextEditingController();
  ProgressDialog pr;

  //getUser
  String userID;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      userID = preferences.getString("id");
    });
  }

  Future getImageGallery() async{
    var imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    final tempDir =await getTemporaryDirectory();
    final path = tempDir.path;

    int rand = new DateTime.now().millisecondsSinceEpoch;

    if(imageFile != null){
      Img.Image image= Img.decodeImage(imageFile.readAsBytesSync());
      Img.Image smallerImg = Img.copyResize(image, width: 500);

      var compressImg= new File("$path/izin_$rand.jpg")
        ..writeAsBytesSync(Img.encodeJpg(smallerImg, quality: 100));


      setState(() {
        _filename = basename(compressImg.path);
        _image = compressImg;
      });
    }else{
      print("No image selected!");
    }
  }

  Future getImageCamera() async{
    var imageFile = await ImagePicker.pickImage(source: ImageSource.camera);

    final tempDir =await getTemporaryDirectory();
    final path = tempDir.path;

    int rand = new DateTime.now().millisecondsSinceEpoch;

    if(imageFile != null){
      Img.Image image= Img.decodeImage(imageFile.readAsBytesSync());
      Img.Image smallerImg = Img.copyResize(image, width: 500);

      var compressImg= new File("$path/izin_$rand.jpg")
        ..writeAsBytesSync(Img.encodeJpg(smallerImg, quality: 100));


      setState(() {
        _filename = basename(compressImg.path);
        _image = compressImg;
      });
    }else{
      print("No image selected!");
    }
  }

  //post with image
  Future upload(File imageFile, BuildContext context) async{
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

    var stream= new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length= await imageFile.length();
    var uri = Uri.parse("http://202.137.6.90:8084/cbni-intranet/attendance/postpermission");

    var request = new http.MultipartRequest("POST", uri);

    var multipartFile = new http.MultipartFile(
        "file", stream, length, filename: basename(imageFile.path));
    request.files.add(multipartFile);
    request.fields['permission'] = _mySelection;
    request.fields['emp_id'] = userID;
    request.fields['start_date'] = awalControl.text;
    request.fields['end_date'] = selesaiControl.text;
    request.fields['detail'] = keteranganControl.text;

    var response = await request.send();

    if(response.statusCode==200){
      await pr.update(
        message: "Berhasil...",
        progressWidget: Container(
            padding: EdgeInsets.all(8.0), child: Icon(FontAwesomeIcons.checkCircle)),
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
          color: Colors.green[800],
        ),
        messageTextStyle: TextStyle(
          color: Colors.green[800],
          fontSize: 15,
        ),
      );
      pr.dismiss();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
            (Route<dynamic> route) => false,
      );
    }else{
      pr.update(
        message: "Gagal...",
        progressWidget: Container(
            padding: EdgeInsets.all(8.0), child: Icon(FontAwesomeIcons.timesCircle)),
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
          color: Colors.red[900],
        ),
        messageTextStyle: TextStyle(
          color: Colors.red[900],
          fontSize: 15,
        ),
      );
      pr.dismiss();
    }
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
  }

  //post without image
  Future upload2(BuildContext context) async{
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

    final response = await http.post(
      "http://202.137.6.90:8084/cbni-intranet/attendance/postpermission",
      body: {
        "permission":_mySelection,
        "emp_id":userID,
        "start_date":awalControl.text,
        "end_date":selesaiControl.text,
        "detail":keteranganControl.text,
      },
    );

    if(response.statusCode==200){

      final content = json.decode(response.body);

      if(content['status'] == 'true'){
        pr.update(
          message: "Berhasil...",
          progressWidget: Container(
              padding: EdgeInsets.all(8.0), child: Icon(FontAwesomeIcons.checkCircle)),
          maxProgress: 100.0,
          progressTextStyle: TextStyle(
            color: Colors.green[800],
          ),
          messageTextStyle: TextStyle(
            color: Colors.green[800],
            fontSize: 15,
          ),
        );
        pr.dismiss();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
              (Route<dynamic> route) => false,
        );
      }else{
        pr.update(
          message: "Gagal...",
          progressWidget: Container(
              padding: EdgeInsets.all(8.0), child: Icon(FontAwesomeIcons.timesCircle)),
          maxProgress: 100.0,
          progressTextStyle: TextStyle(
            color: Colors.red[900],
          ),
          messageTextStyle: TextStyle(
            color: Colors.red[900],
            fontSize: 15,
          ),
        );
        pr.dismiss();
      }
    }else{
      pr.update(
        message: "Gagal...",
        progressWidget: Container(
            padding: EdgeInsets.all(8.0), child: Icon(FontAwesomeIcons.timesCircle)),
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
          color: Colors.red[900],
        ),
        messageTextStyle: TextStyle(
          color: Colors.red[900],
          fontSize: 15,
        ),
      );
      pr.dismiss();
    }
  }

  @override
  void initState() {
    super.initState();
    this.getIzin();
    this.getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf0f6ff),
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: const Text('Izin'),
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
            icon: const Icon(FontAwesomeIcons.listAlt),
            tooltip: 'List Izin',
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListIzinPage())
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SlideUp(
                            1,
                            Text(
                              "Jenis Izin",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF248afd),
                              ),
                            ),
                          ),
                          SlideUp(
                            1,
                            DropdownButton(
                              isExpanded: true,
                              underline: validate1 == true ? Container(
                                decoration: const BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Color(0xffE53935)))
                                ),
                              ) : null,
                              iconEnabledColor: Color(0xFF248afd),
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
                          ),
                          validate1 == true ? Text("Pilih salah satu jenis izin", style: TextStyle(color: Colors.red[600], fontSize: 12),) : Text(""),
                          SizedBox(height: 10,),
                          SlideUp(
                            1,
                            Text(
                              "Mulai Izin",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF248afd),
                              ),
                            ),
                          ),
                          SlideUp(
                            1,
                            DateTimeField(
                              controller: awalControl,
                              format: format,
                              onShowPicker: (context, currentValue) async {
                                final date = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(1900),
                                    initialDate: currentValue ?? DateTime.now(),
                                    lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime:
                                    TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                                  );
                                  return DateTimeField.combine(date, time);
                                } else {
                                  return currentValue;
                                }
                              },
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                suffixIcon: Icon(
                                  FontAwesomeIcons.calendarAlt, color: Color(0xFF248afd),),
                                helperText: "Waktu Mulai Izin",
                                errorText: validate2 == true ? "Harap isi bagian ini" : null,
                              ),
                            ),
                          ),
                          SizedBox(height: 20,),
                          SlideUp(
                            1,
                            Text(
                              "Selesai Izin",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF248afd),
                              ),
                            ),
                          ),
                          SlideUp(
                            1,
                            DateTimeField(
                              controller: selesaiControl,
                              format: format,
                              onShowPicker: (context, currentValue) async {
                                final date = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(1900),
                                    initialDate: currentValue ?? DateTime.now(),
                                    lastDate: DateTime(2100));
                                if (date != null) {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime:
                                    TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                                  );
                                  return DateTimeField.combine(date, time);
                                } else {
                                  return currentValue;
                                }
                              },
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                suffixIcon: Icon(
                                  FontAwesomeIcons.calendarAlt, color: Color(0xFF248afd),),
                                helperText: "Waktu Selesai Izin",
                                errorText: validate3 == true ? "Harap isi bagian ini" : null,
                              ),
                            ),
                          ),
                          SizedBox(height: 20,),
                          SlideUp(
                            1,
                            Text(
                              "Keterangan",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF248afd),
                              ),
                            ),
                          ),
                          SlideUp(
                            1,
                            TextField(
                              controller: keteranganControl,
                              obscureText: false,
                              maxLines: 5,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                helperText: "Alasan pengajuan izin",
                                errorText: validate4 == true ? "Harap isi bagian ini" : null,
                              ),
                            ),
                          ),
                          SizedBox(height: 20,),
                          SlideUp(
                            1,
                            Text(
                              "Unggah file izin",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF248afd),
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
                          SlideUp(
                            1,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                OutlineButton.icon(
                                  label: Text('Gallery', style: TextStyle(color: Color(0xFF248afd)),),
                                  icon: Icon(FontAwesomeIcons.images, color: Color(0xFF248afd),),
                                  onPressed: getImageGallery, //callback when button is clicked
                                  borderSide: BorderSide(
                                    color: Color(0xFF248afd), //Color of the border
                                    style: BorderStyle.solid, //Style of the border
                                    width: 1, //width of the border
                                  ),
                                ),
                                OutlineButton.icon(
                                  label: Text('Camera', style: TextStyle(color: Color(0xFF248afd)),),
                                  icon: Icon(FontAwesomeIcons.camera, color: Color(0xFF248afd),),
                                  onPressed: getImageCamera, //callback when button is clicked
                                  borderSide: BorderSide(
                                    color: Color(0xFF248afd), //Color of the border
                                    style: BorderStyle.solid, //Style of the border
                                    width: 1, //width of the border
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _image == null
                              ? new Text("Tidak ada file yang dipilih.")
                              : new Text("File telah dipilih!"),
                          Divider(
                            color: Color(0xFF248afd),
                            thickness: 2.5,
                            height: 30,
                          ),
                          SlideUp(
                            1,
                            SizedBox(
                              width: double.infinity,
                              child: FlatButton(
                                color: Color(0xFF248afd),
                                child: Text('Ajukan Permohonan', style: TextStyle(color: Colors.white),),
                                onPressed: () {
                                  if(_mySelection == null){
                                    setState(() {
                                      validate1 = true;
                                    });
                                  }else{
                                    setState(() {
                                      validate1 = false;
                                    });
                                  }

                                  if(awalControl.text.isEmpty){
                                    setState(() {
                                      validate2 = true;
                                    });
                                  }else{
                                    setState(() {
                                      validate2 = false;
                                    });
                                  }

                                  if(selesaiControl.text.isEmpty){
                                    setState(() {
                                      validate3 = true;
                                    });
                                  }else{
                                    setState(() {
                                      validate3 = false;
                                    });
                                  }

                                  if(keteranganControl.text.isEmpty){
                                    setState(() {
                                      validate4 = true;
                                    });
                                  }else{
                                    setState(() {
                                      validate4 = false;
                                    });
                                  }

                                  if(_mySelection != null && awalControl.text.isNotEmpty && selesaiControl.text.isNotEmpty && keteranganControl.text.isNotEmpty){
                                    _image == null ? upload2(context) : upload(_image, context);
                                  }
                                }, //callback when button is clicked
                              ),
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

  @override
  void dispose() {
    awalControl.dispose();
    selesaiControl.dispose();
    keteranganControl.dispose();
    super.dispose();
  }

}