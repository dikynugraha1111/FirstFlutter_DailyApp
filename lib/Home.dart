import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:test9/editData.dart';

import 'package:test9/main.dart';

import 'addDataTask.dart';

class Home extends StatefulWidget {
  Home({this.user, this.googleSignIn});
  final FirebaseUser user;
  final GoogleSignIn googleSignIn;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void signOutGoogle() {
    widget.googleSignIn.signOut();
    print("User Sign Out");
    Navigator.pushReplacementNamed(this.context, '/Home');
  }

  void sign_out() {
    AlertDialog alertDialog = new AlertDialog(
      content: new Container(
        height: 250.0,
        padding: EdgeInsets.all(15.0),
        child: new Column(
          children: [
            new ClipOval(
              child: new Image.network(widget.user.photoUrl),
            ),
            new Padding(padding: EdgeInsets.only(top: 10.0)),
            new Divider(
              color: Colors.black87,
            ),
            new Padding(padding: EdgeInsets.only(top: 10.0)),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () => signOutGoogle(),
                  child: new Icon(
                    Icons.check,
                    color: Colors.blue,
                    size: 50.0,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: new Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 50.0,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
    showDialog(context: context, child: alertDialog);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: new Padding(
          padding: EdgeInsets.all(7.0),
          child: new FloatingActionButton(
            onPressed: () {
              Navigator.of(context)
                  .push(new MaterialPageRoute(builder: (BuildContext context) {
                return new AddDataTask(
                  userAdd: widget.user,
                  googleSignInAdd: widget.googleSignIn,
                );
              }));
            },
            child: new Icon(
              Icons.add,
              color: Colors.white,
            ),
            backgroundColor: Colors.blue,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: new BottomAppBar(
          elevation: 20.0,
          color: Colors.blue,
          child: ButtonBar(
            children: [new Padding(padding: EdgeInsets.only(top: 15.0))],
          ),
        ),
        appBar: new AppBar(
          title: new Text("Home"),
          leading: Icon(Icons.home),
          centerTitle: true,
        ),
        body: new Stack(children: [
          new Container(
            height: 170.0,
            width: double.infinity,
            decoration: new BoxDecoration(
                image: new DecorationImage(
                    image: new AssetImage("img/background.jpg"),
                    fit: BoxFit.cover)),
            child: new Padding(
              padding: EdgeInsets.all(15.0),
              child: new Row(
                children: [
                  new Container(
                    width: 60.0,
                    height: 60.0,
                    decoration: new BoxDecoration(
                        image: new DecorationImage(
                            image: new NetworkImage(widget.user.photoUrl),
                            fit: BoxFit.cover)),
                  ),
                  new Padding(padding: EdgeInsets.only(left: 10.0)),
                  new Expanded(
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new Text(
                          "Selamat Datang...",
                          style: new TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 20.0),
                        ),
                        new Text(
                          widget.user.displayName,
                          style: new TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              letterSpacing: 5.0),
                        )
                      ],
                    ),
                  ),
                  new IconButton(
                    icon: Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 35.0,
                    ),
                    onPressed: () => sign_out(),
                  )
                ],
              ),
            ),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 190.0),
            child: new StreamBuilder(
              stream: Firestore.instance
                  .collection("task")
                  .where("email", isEqualTo: widget.user.email)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return new Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return new TaskList(document: snapshot.data.documents);
              },
            ),
          )
        ]));
  }
}

class TaskList extends StatelessWidget {
  TaskList({this.document});
  final List<DocumentSnapshot> document;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: document.length,
      itemBuilder: (BuildContext context, int i) {
        String judul = document[i].data['judul'].toString();
        DateTime _date = document[i].data['tanggal'].toDate();
        String tanggal = "${_date.day}/${_date.month}/${_date.year}";
        String catatan = document[i].data['note'].toString();
        String urlGambar = document[i].data['urlGambar'].toString();

        return new Dismissible(
          key: new Key(document[i].documentID),
          onDismissed: (direction) {
            Firestore.instance.runTransaction((Transaction transaction) async {
              DocumentSnapshot snapshot =
                  await transaction.get(document[i].reference);
              await transaction.delete(snapshot.reference);
            });
            Scaffold.of(context)
                .showSnackBar(new SnackBar(content: new Text("Data Deleted")));
          },
          child: new Padding(
            padding: EdgeInsets.all(5.0),
            child: new Container(
              child: new Card(
                elevation: 7.0,
                child: new Padding(
                  padding: EdgeInsets.all(10.0),
                  child: new Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        new Expanded(
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              new Text(
                                judul,
                                style: new TextStyle(
                                    color: Colors.black,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w500),
                              ),
                              new Padding(
                                padding: EdgeInsets.only(top: 5.0),
                                child: new Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    new Padding(
                                        padding: EdgeInsets.only(right: 10.0),
                                        child: new Icon(Icons.schedule,
                                            color: Colors.blue)),
                                    new Expanded(
                                      child: new Text(tanggal,
                                          style: new TextStyle(
                                              color: Colors.black,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w300)),
                                    ),
                                  ],
                                ),
                              ),
                              new Padding(
                                padding: EdgeInsets.only(top: 5.0),
                                child: new Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    new Padding(
                                        padding: EdgeInsets.only(right: 10.0),
                                        child: new Icon(Icons.note,
                                            color: Colors.blue)),
                                    new Expanded(
                                      child: new Text(catatan,
                                          style: new TextStyle(
                                              color: Colors.black,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w300)),
                                    ),
                                  ],
                                ),
                              ),
                              new Padding(
                                padding: EdgeInsets.only(top: 5.0),
                                child: new Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    new Padding(
                                        padding: EdgeInsets.only(right: 10.0),
                                        child: new Icon(Icons.image,
                                            color: Colors.blue)),
                                    new Image.network(
                                      "$urlGambar",
                                      width: 50.0,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        new IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return new EditDataTask(
                                  judul: judul,
                                  catatan: catatan,
                                  tanggal: _date,
                                  urlGambar: urlGambar,
                                  index: document[i].reference,
                                );
                              }));
                            })
                      ]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
