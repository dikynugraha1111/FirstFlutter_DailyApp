import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';

class AddDataTask extends StatefulWidget {
  AddDataTask({this.userAdd, this.googleSignInAdd});
  final FirebaseUser userAdd;
  final GoogleSignIn googleSignInAdd;

  @override
  _AddDataTaskState createState() => _AddDataTaskState();
}

class _AddDataTaskState extends State<AddDataTask> {
  DateTime _dueDate = new DateTime.now();
  String _dateText = '';
  String judul = '';
  String catatan = '';
  String urlGambar;
  File gambar;
  String fileName;

  Future<Null> _selectDueDate(BuildContext context) async {
    final picked = await showDatePicker(
        context: context,
        initialDate: _dueDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2050));
    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _dateText = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dateText = "${_dueDate.day}/${_dueDate.month}/${_dueDate.year}";
  }

  Future _getImage() async {
    var selectedImage =
        await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      gambar = selectedImage;
      fileName = basename(gambar.path);
    });
  }

  Widget uploadGambar() {
    return Row(
      children: [
        new RaisedButton(
          onPressed: () {
            _getImage();
          },
          child: new Text("Pilih Gambar"),
        )
      ],
    );
  }

  void _addData() async {
    //uploadGambarToFirebase
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(gambar);

    var downurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    setState(() {
      urlGambar = downurl.toString();
    });

    Firestore.instance.runTransaction((Transaction transaction) async {
      CollectionReference reference = Firestore.instance.collection("task");
      await reference.add({
        "email": widget.userAdd.email,
        "judul": judul,
        "tanggal": _dueDate,
        "note": catatan,
        "urlGambar": urlGambar
      });
    });
    Navigator.pop(this.context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Add Data"),
      ),
      body: new SingleChildScrollView(
        child: new Column(
          children: [
            new Container(
                height: 170.0,
                width: double.infinity,
                decoration: new BoxDecoration(
                    image: new DecorationImage(
                        image: new AssetImage("img/background.jpg"),
                        fit: BoxFit.cover)),
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    new Text("Form Add Data",
                        style: new TextStyle(
                            color: Colors.white,
                            fontSize: 30.0,
                            fontWeight: FontWeight.w500)),
                    new Text(
                      "Buat data baru Anda",
                      style: new TextStyle(
                          color: Colors.white,
                          letterSpacing: 5.0,
                          fontSize: 10.0,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                )),
            new Padding(
              padding: EdgeInsets.all(15.0),
              child: new TextField(
                onChanged: (String str) {
                  setState(() {
                    judul = str;
                  });
                },
                decoration: new InputDecoration(
                  icon: Icon(Icons.dashboard),
                  hintText: "Judul Task",
                  border: InputBorder.none,
                ),
                style: new TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                ),
              ),
            ),
            new Padding(
              padding: EdgeInsets.all(15.0),
              child: new Row(
                children: [
                  new Icon(
                    Icons.calendar_today,
                    color: Colors.black54,
                    size: 27.0,
                  ),
                  new Padding(padding: EdgeInsets.only(left: 15.0)),
                  new Expanded(
                      child: new Text(
                    "Date Time :",
                    style: new TextStyle(color: Colors.black54, fontSize: 15.0),
                  )),
                  new FlatButton(
                      onPressed: () => _selectDueDate(context),
                      child: new Text(
                        _dateText,
                        style: new TextStyle(
                            color: Colors.black54, fontSize: 16.0),
                      )),
                ],
              ),
            ),
            new Padding(
              padding: EdgeInsets.all(15.0),
              child: new TextField(
                onChanged: (String str) {
                  catatan = str;
                },
                minLines: 1,
                decoration: new InputDecoration(
                  icon: Icon(
                    Icons.note_add_rounded,
                    size: 27.0,
                  ),
                  hintText: "Catatan",
                  border: InputBorder.none,
                ),
                style: new TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                ),
              ),
            ),
            new Padding(
                padding: EdgeInsets.all(15.0),
                child: new Row(
                  children: [
                    new Icon(
                      Icons.image,
                      size: 27.0,
                      color: Colors.black54,
                    ),
                    new Padding(padding: EdgeInsets.only(left: 15.0)),
                    gambar == null
                        ? uploadGambar()
                        : Image.file(
                            gambar,
                            width: 150.0,
                          )
                  ],
                )),
            new Padding(padding: EdgeInsets.only(top: 15.0)),
            new Center(
                child: new RaisedButton(
                    color: Colors.blue[400],
                    splashColor: Colors.blue,
                    focusColor: Colors.blue,
                    onPressed: () {
                      _addData();
                    },
                    child: new Text("Add",
                        style: new TextStyle(
                            color: Colors.white,
                            fontSize: 25.0,
                            fontWeight: FontWeight.w500))))
          ],
        ),
      ),
    );
  }
}
