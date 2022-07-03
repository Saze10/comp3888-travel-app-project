import 'package:flutter/material.dart';
import 'package:flutter_app/firebase_services/database_makePlan.dart';
import 'package:flutter_app/firebase_services/database_message.dart';
import 'package:flutter_app/firebase_services/database_savedPlan.dart';
import 'package:flutter_app/screens/Profile.dart';
import 'package:flutter_app/widgets/textfield_widget.dart';
import 'package:flutter_app/widgets/button_widget.dart';
import 'package:flutter_app/firebase_services/authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/screens/BottomNavigation.dart';
import 'package:flutter_app/screens/ResetPassword.dart';
import 'package:flutter_app/firebase_services/database_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_core/firebase_core.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = '';
  String password = '';
  User? user;
  String error = '';
  final AuthenticationService _auth =
      AuthenticationService(FirebaseAuth.instance);

  User? getUser() {
    return this.user;
  }

  bool userLoggedIn() {
    if (this.user == null) {
      return false;
    } else {
      return true;
    }
  }

  setMSG(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key('Login-page'),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          TextFieldWidget(
              key: Key('email-textfile'),
              labelText: 'Email',
              obscureText: false,
              prefixIconData: Icons.mail_outline,
              textChanged: (val) {
                setState(() => email = val);
              }),
          SizedBox(
            height: 5.0,
          ),
          TextFieldWidget(
              key: Key('password-textfile'),
              labelText: 'Password',
              obscureText: true,
              prefixIconData: Icons.lock_outline,
              textChanged: (val) {
                setState(() => password = val);
              }),
          SizedBox(
            height: 10.0,
          ),
          TextButton(
            child: Text(
              'Forgot password?',
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => ResetPage())),
          ),
          SizedBox(height: 10.0),
          ButtonWidget(
            key: Key('login-button'),
            text: 'Login',
            onPressed: () async {
              dynamic result =
                  await _auth.signIn(email: email, password: password);
              if (result ==
                  "[firebase_auth/wrong-password] The password is invalid or the user does not have a password.") {
                error = 'invalid sign in details';
                setMSG(error);
              } else if (result ==
                  "[firebase_auth/unknown] Given String is empty or null") {
                error = 'email address and/or password empty';
                setMSG(error);
              } else {
                user = result;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          BottomNavigatorBar(data: 3, isLogin: true)),
                );
              }
            },
          ),
          SizedBox(height: 8.0),
          ButtonWidget(
            key: Key('register-button'),
            text: 'Sign Up',
            hasBorder: true,
            onPressed: () async {
              dynamic result =
                  await _auth.signUp(email: email, password: password);
              if (result ==
                  "[firebase_auth/invalid-email] The email address is badly formatted.") {
                error = 'invalid sign up email';
                setMSG(error);
              } else if (result ==
                  "[firebase_auth/weak-password] Password should be at least 6 characters") {
                error = 'password must be at least 6 characters';
                setMSG(error);
              } else if (result ==
                  "[firebase_auth/email-already-in-use] The email address is already in use by another account.") {
                error = 'email address already in use';
                setMSG(error);
              } else if (result ==
                  "[firebase_auth/unknown] Given String is empty or null") {
                error = 'email address and/or password empty';
                setMSG(error);
              } else {
                user = result;
                //set up user data in firestore on signup
                DatabaseService _databaseService = DatabaseService();
                _databaseService.setupUserData();
                DatabaseMessage _databaseMessage = DatabaseMessage();
                _databaseMessage.setupUserData();
                DatabaseMakePlan _databaseMakePlan = DatabaseMakePlan();
                _databaseMakePlan.setupMakePlanData();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          BottomNavigatorBar(data: 3, isLogin: true)),
                );
              }
            },
          ),
        ]),
      ),
    );
  }
}

class LoginPageValidator {
  String email = '';
  String password = '';
  User? user;
  final AuthenticationService _auth =
      AuthenticationService(FirebaseAuth.instance);

  User? getUser() {
    return this.user;
  }

  bool userLoggedIn() {
    if (this.user == null) {
      return false;
    } else {
      return true;
    }
  }

  Future<String> validateSignIn(String email, String password) async {
    dynamic result = await _auth.signIn(email: email, password: password);
    String error = 'no error';
    if (result ==
        "[firebase_auth/wrong-password] The password is invalid or the user does not have a password.") {
      error = 'invalid sign in details';
    } else if (result ==
        "[firebase_auth/unknown] Given String is empty or null") {
      error = 'enter your email address';
    }
    return (error);
  }

  Future<String> validateSignUp(String email, String password) async {
    String error = 'no error';
    dynamic result = await _auth.signUp(email: email, password: password);
    if (result ==
        "[firebase_auth/invalid-email] The email address is badly formatted.") {
      error = 'invalid sign up email';
    } else if (result ==
        "[firebase_auth/weak-password] Password should be at least 6 characters") {
      error = 'password must be at least 6 characters';
    } else if (result ==
        "[firebase_auth/email-already-in-use] The email address is already in use by another account.") {
      error = 'email address already in use';
    } else if (result ==
        "[firebase_auth/unknown] Given String is empty or null") {
      error = 'enter your email address';
    }
    return (error);
  }
}
