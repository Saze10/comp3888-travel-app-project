import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/textfield_widget.dart';
import 'package:flutter_app/widgets/button_widget.dart';
import 'package:flutter_app/firebase_services/authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/screens/BottomNavigation.dart';

class ResetPage extends StatefulWidget {
  const ResetPage({Key? key}) : super(key: key);

  @override
  _ResetPageState createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage> {
  String email = '';
  String error = '';
  User? user;
  final AuthenticationService _auth = AuthenticationService(FirebaseAuth.instance);

  User? getUser() {
    return this.user;
  }

  bool userLoggedIn() {
    if(this.user == null) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child:
        Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          TextFieldWidget(
              labelText: 'Email',
              obscureText: false,
              prefixIconData: Icons.mail_outline,
              textChanged: (val) {
                setState(() => email = val);
              }),
          SizedBox(
            height: 5.0,
          ),
          SizedBox(
            height: 10.0,
          ),
          SizedBox(height: 20.0),
          ButtonWidget(
            text: 'Send Reset Email',
            onPressed: () async {
              dynamic result = await _auth.sendPasswordResetEmail(email: email);
              if(result == "[firebase_auth/invalid-email] The email address is badly formatted.") {
                setState(() => error = 'invalid email address');
              } else if (result == "[firebase_auth/unknown] Given String is empty or null") {
                setState(() => error = 'enter your email address');
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BottomNavigatorBar(data : 3)),
                );
              }
            },
          ),
          SizedBox(height: 10.0),
          Text(
            error,
            style: TextStyle(color: Colors.red, fontSize: 14.0),
          ),
          SizedBox(height: 150.0),
        ]),
      ),
    );
  }
}
