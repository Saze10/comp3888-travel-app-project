import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_app/widgets/button_widget.dart';
import 'package:flutter_app/widgets/text_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
class InvitedFriend extends StatefulWidget {
  const InvitedFriend({Key? key, required this.id, this.auth}) : super(key: key);
  final FirebaseAuth? auth;
  final String id;

  @override
  _InvitedFriendState createState() => _InvitedFriendState();
}

class _InvitedFriendState extends State<InvitedFriend> {
  late String id;
  String email = "Please Enter an Email";
  User? user;
  FirebaseAuth? auth;

  @override
  void initState() {
    super.initState();
    auth = widget.auth;
    user = auth == null ? UserServices.getUserInfo() : auth!.currentUser;
    id = widget.id;
  }

  Future<bool?> setMSG(String msg){
    return Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER
    );
  }

  static bool isEmail(String email) {
    return RegExp(
        r"^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$")
        .hasMatch(email);
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
                  text: 'Please Enter an Email',
                  onChanged: (value) {
                    setState(() => email = value);
                  },
                ),
              ),
              SizedBox(height: 20),
              ButtonWidget(
                text: 'Invited',
                onPressed: () async {
                  if (!isEmail(email)){
                    setMSG("Invalid Email Form");
                  }else if(email == user!.email){
                    setMSG("You cannot invited yourself");
                  }
                  else if(!await UserServices.isExists(email, auth)){
                    setMSG("User Not Found");
                  }else{
                    String uid = await UserServices.getUIDByEmail(email, auth);
                    if (await UserServices.userAlreadyAdd(id, uid, auth)){
                      setMSG("User Already Added");
                    }else if(await UserServices.isMailAlreadySend(email, id, auth)){
                      setMSG("You Already Invited He/She");
                    }
                    else{
                      await UserServices.invite(email, id, auth);
                      setMSG("Success");
                    }
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
          'Invited a Friend',
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

