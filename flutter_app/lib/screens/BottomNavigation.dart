import 'package:flutter/material.dart';
import 'package:flutter_app/firebase_services/database_service.dart';
import 'package:flutter_app/objects/user.dart';
import 'package:flutter_app/screens/Dashboard.dart';
import 'package:flutter_app/screens/MessageNotification.dart';
import 'package:flutter_app/screens/Profile.dart';
import 'package:flutter_app/screens/Plan.dart';
import 'package:flutter_app/screens/Login.dart';
import 'package:flutter_app/screens/ResetPassword.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:provider/provider.dart';
import 'package:google_place/google_place.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BottomNavigatorBar extends StatefulWidget {
  GooglePlace? googlePlace;

  int data;
  bool? isLogin;
  BottomNavigatorBar({Key? key, this.data = 0, this.isLogin}) : super(key: key);
  @override
  _BottomNavigatorBarState createState() => _BottomNavigatorBarState();
}

class _BottomNavigatorBarState extends State<BottomNavigatorBar> {
  GooglePlace? googlePlace;
  List<Widget> widgets = [];

  late int _index;
  late bool _isLogin;
  @override
  void initState() {
    super.initState();
    _index = widget.data;
    _isLogin = widget.isLogin == null
        ? UserServices.getUserLoginState()
        : widget.isLogin;
    String apiKey = dotenv.env['APIKEY'] ?? "";
    if (apiKey == "") {
      print("lack of API key");
      return;
    }
    googlePlace = GooglePlace(apiKey);
  }

  List<Widget> _widgets() => [
        Dashboard(googlePlace: googlePlace),
        MessageNotification(),
        Plan(googlePlace: googlePlace),
        LoginPage(),
        Profile(),
        ResetPage(),
      ];

  @override
  Widget build(BuildContext context) {
    widgets = _widgets();

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            label: "Notification",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wysiwyg),
            label: "Plan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "Profile",
          ),
        ],
        currentIndex: _index,
        onTap: (v) {
          setState(() {
            _index = v;
          });
        },
      ),
      body: widgets[(_isLogin && _index == 3) ? _index + 1 : _index],
    );
  }
}
