import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/firebase_services/database_service.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_app/objects/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
class SetGender extends StatefulWidget {
  SetGender({Key? key, this.firebase}) : super(key: key);
  final FirebaseFirestore? firebase;

  @override
  _SetGenderState createState() => _SetGenderState();
}

class _SetGenderState extends State<SetGender> {
  LocalUser ? localUser;
  FirebaseFirestore? firebase;

  @override
  void initState() {
    super.initState();
    firebase = widget.firebase;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: firebase == null ? DatabaseService().streamUserDataSnapshot :  firebase?.collection('user_data').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.data == null){
            return Text("Loading");
          }
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Text("Loading");
          // }
          localUser = UserServices.getLocalUserBySnapshot(snapshot);
          return Scaffold(
              appBar: getAppBar(),
              body: Container(
                padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                child: ListView(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.male, color: Colors.blue),
                      title: Text("male"),
                      trailing: localUser!.gender == "male"
                          ? Icon(Icons.check, color: Colors.green)
                          : null,
                      selected: localUser!.gender == "male",
                      selectedTileColor: Color.fromRGBO(208, 208, 208, 1.0),
                      onTap: () async {
                        if (localUser!.gender != "male") {
                          await UserServices.updateGender("male", firebase);
                        }
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.female, color: Colors.pink),
                      title: Text("female"),
                      trailing: localUser!.gender == "female"
                          ? Icon(Icons.check, color: Colors.green)
                          : null,
                      selected: localUser!.gender == "female",
                      selectedTileColor: Color.fromRGBO(208, 208, 208, 1.0),
                      onTap: () async {
                        if (localUser!.gender != "female") {
                          await UserServices.updateGender("female", firebase);
                        }
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.security, color: Colors.black),
                      title: Text("secrecy"),
                      trailing: localUser!.gender == "secrecy"
                          ? Icon(Icons.check, color: Colors.green)
                          : null,
                      selected: localUser!.gender == "secrecy",
                      selectedTileColor: Color.fromRGBO(208, 208, 208, 1.0),
                      onTap: () async {
                        if (localUser!.gender != "secrecy") {
                          await UserServices.updateGender("secrecy", firebase);
                        }
                      },
                    ),

                  ],
                ),
              )
          );
        }
    );
  }

  AppBar getAppBar() {
    return AppBar(
        title: const Text(
          'Set Gender',
          style: const TextStyle(
            color: Color.fromRGBO(20, 41, 82, 1),
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        )
    );
  }
}

