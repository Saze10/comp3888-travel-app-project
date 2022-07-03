import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/firebase_services/database_message.dart';
import 'package:flutter_app/screens/display_plan_related/DisplayTrip.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'BottomNavigation.dart';

class MessageNotification extends StatefulWidget {
  const MessageNotification({Key? key, this.firebase, this.auth}) : super(key: key);
  final FirebaseFirestore? firebase;
  final FirebaseAuth? auth;

  @override
  _MessageNotificationState createState() => _MessageNotificationState();
}

class _MessageNotificationState extends State<MessageNotification> {
  User ? user;
  FirebaseFirestore? firebase;
  FirebaseAuth? auth;
  List message = [];

  @override
  void initState() {
    super.initState();
    firebase = widget.firebase;
    auth = widget.auth;
  }

  @override
  Widget build(BuildContext context) {
    if (auth != null){
      if (auth!.currentUser == null){
        return getNotLogin();
      }else{
        user = auth!.currentUser;
        return getMessage();
      }
    }else{
      if(UserServices.getUserLoginState()){
        user = UserServices.getUserInfo();
        return getMessage();
      }else{
        return getNotLogin();
      }
    }
  }

  Widget getMessage(){
    return Scaffold(
        appBar: getAppBar(),
        backgroundColor: Colors.white,
        body:StreamBuilder<QuerySnapshot>(
          stream: firebase == null ? DatabaseMessage().streamUserDataSnapshot :  firebase?.collection('user_message').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }
            if (snapshot.data == null){
              return Text("Loading");
            }
            message = UserServices.getUserMessage(snapshot);
            return message.isEmpty ? getNoMessage()
                : getAllMessage();
          }
        )
    );
  }

  List<Widget> getMessageLst(){
    List<Widget> messageList = [];
    for (Map<String, dynamic> n in message){
      if(n["isRequest"]){
        messageList.add(getRequestListTile(n));
      }else{
        messageList.add(getNormalListTile(n));
      }
    }return messageList;
  }

  Widget getNormalListTile(Map<String, dynamic> n){
    return ListTile(
      title: Text("Send From "+n["sendBy"]),
      subtitle: Text(n["subString"]),
      trailing: IconButton(
        icon: Icon(Icons.delete_outline_outlined),
        onPressed: () async {
          message.remove(n);
          await UserServices.updateUserMessage(message, firebase);
          setMSG("success");
        },
      ),
    );
  }

  setMSG(String msg){
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }

  Widget getRequestListTile(Map<String, dynamic> n){
    String text = n["subString"];
    String id = text.split(" ").last;
    return Row(
        children: <Widget>[
          Expanded(
            flex : 7,
            child: ListTile(
              title: Text("Send From "+n["sendBy"]),
              subtitle: Text(n["subString"]),
              // onTap: (){
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) => DisplayTrip(id: id)),
              //   );
              // },
            )
          ),
          Expanded(
            flex : 1,
            child: IconButton(
              icon: Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
              onPressed: () async {
                await UserServices.reply(n["sendBy"], true, id, user!.uid, firebase);
                message.remove(n);
                await UserServices.updateUserMessage(message, firebase);
                setMSG("success");
              },
            ),
          ),
          Expanded(
            flex : 1,
            child: IconButton(
              icon: Icon(Icons.cancel, color: Colors.redAccent,),
              onPressed: () async {
                await UserServices.reply(n["sendBy"], false, id, user!.uid, firebase);
                message.remove(n);
                await UserServices.updateUserMessage(message, firebase);
                setMSG("success");
              },
            ),
          ),
        ]
    );
  }

  Widget getAllMessage(){
    return ListView(
      children: getMessageLst(),
    );
  }

  Widget getNoMessage(){
    return Padding(
        padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(300),0,0,0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'No Notification!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color.fromRGBO(20, 41, 82, 1),
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
            ]
        )
    );
  }

  Widget getNotLogin(){
    return Scaffold(
      appBar: getAppBar(),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(280),0,0,0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Please Login first!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color.fromRGBO(20, 41, 82, 1),
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
            TextButton(
              child: Text(
                'Go to Login',
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
              onPressed: () => Navigator.push(
                  context,
                MaterialPageRoute(builder: (context) => BottomNavigatorBar(data : 3, isLogin : false)),
              ),
            ),
          ]
        )
      )
    );
  }
  AppBar getAppBar() {
    return AppBar(
        title: const Text(
          'Notification',
          style: const TextStyle(
            color: Color.fromRGBO(20, 41, 82, 1),
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
    );
  }
}
