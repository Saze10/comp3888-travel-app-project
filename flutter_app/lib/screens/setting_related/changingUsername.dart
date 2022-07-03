import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_app/widgets/button_widget.dart';
import 'package:flutter_app/widgets/text_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
class UserName extends StatefulWidget {
  const UserName({Key? key, this.auth}) : super(key: key);
  final FirebaseAuth? auth;

  @override
  _UserNameState createState() => _UserNameState();
}

class _UserNameState extends State<UserName> {
  late String username;
  User? user;
  FirebaseAuth? auth;

  @override
  void initState() {
    super.initState();
    auth = widget.auth;
    user = auth == null ? UserServices.getUserInfo() : auth!.currentUser;
    this.username = ((user!.displayName == null)? "username" : user!.displayName)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:getAppBar(),
      body: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        child: ListView(
          children: <Widget>[
            SizedBox(height: 50),
            Container(
              child: TextWidget(
                  text: 'Username',
                  onChanged: (value) {
                    setState(() => username = value);
                  },
              ),
            ),
            SizedBox(height: 20),
            ButtonWidget(
              text: 'Submit',
              onPressed: (){
                if (username == ""){
                  Fluttertoast.showToast(
                    msg: 'Invalid Username',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                  );
                }else{
                  UserServices.changingUsername(username, auth);
                  Fluttertoast.showToast(
                    msg: 'Succeed',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                  );
                }
              },
            ),
          ],
        ),
      )
    );
  }

  AppBar getAppBar() {
    return AppBar(
        title: const Text(
          'Changing Username',
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

