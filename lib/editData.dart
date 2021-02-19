import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditDataTask extends StatefulWidget {
  EditDataTask(
      {this.judul, this.catatan, this.tanggal, this.urlGambar, this.index});
  final String judul;
  final String catatan;
  final DateTime tanggal;
  final String urlGambar;
  final index;

  @override
  _EditDataTaskState createState() => _EditDataTaskState();
}

class _EditDataTaskState extends State<EditDataTask> {
  DateTime _dueDate;
  String _dateText = '';
  String judul;
  String catatan;
  String urlGambar;
  File gambar;
  String fileName;

  TextEditingController textEditingControllerJudul;
  TextEditingController textEditingControllerCatatan;

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
    _dueDate = widget.tanggal;
    _dateText = "${_dueDate.day}/${_dueDate.month}/${_dueDate.year}";

    judul = widget.judul;
    catatan = widget.catatan;
    urlGambar = widget.urlGambar;

    textEditingControllerJudul = new TextEditingController(text: widget.judul);
    textEditingControllerCatatan =
        new TextEditingController(text: widget.catatan);
  }

  Future _getImage() async {
    var selectedImage =
        await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      gambar = selectedImage;
      fileName = basename(gambar.path);
    });
  }

  void editTask() async {
    if (gambar != null) {
      StorageReference reference =
          FirebaseStorage.instance.ref().child(fileName);
      StorageUploadTask uploadTask = reference.putFile(gambar);

      var downurl = await (await uploadTask.onComplete).ref.getDownloadURL();
      setState(() {
        urlGambar = downurl.toString();
      });
    }

    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot snapshot = await transaction.get(widget.index);
      await transaction.update(snapshot.reference, {
        "judul": judul,
        "note": catatan,
        "tanggal": _dueDate,
        "urlGambar": urlGambar
      });
    });
    Navigator.pop(this.context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Edit Data"),
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
                controller: textEditingControllerJudul,
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
                controller: textEditingControllerCatatan,
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
                        ? new Row(
                            children: [
                              new Image.network(
                                "$urlGambar",
                                width: 50.0,
                              ),
                              new RaisedButton(
                                onPressed: () {
                                  _getImage();
                                },
                                child: new Text("Change"),
                              ),
                            ],
                          )
                        : Image.file(
                            gambar,
                            width: 50.0,
                          ),
                  ],
                )),
            new Padding(padding: EdgeInsets.only(top: 15.0)),
            new Center(
                child: new RaisedButton(
                    color: Colors.blue[400],
                    splashColor: Colors.blue,
                    focusColor: Colors.blue,
                    onPressed: () {
                      editTask();
                    },
                    child: new Text("Edit",
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
