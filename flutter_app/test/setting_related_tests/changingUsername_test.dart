import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/setting_related/changingUsername.dart';
import 'package:flutter_app/widgets/button_widget.dart';
import 'package:flutter_app/widgets/text_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  final MockGoogleSignIn googleSignIn = MockGoogleSignIn();
  final signinAccount = await googleSignIn.signIn();
  final googleAuth = await signinAccount!.authentication;
  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  final user = MockUser(
    isAnonymous: false,
    uid: '123456789',
    email: 'test@gmail.com',
    displayName: 'test',
  );
  final auth = MockFirebaseAuth(mockUser: user);
  final result = await auth.signInWithCredential(credential);
  testWidgets('changing username test', (WidgetTester tester) async {
    await tester.pumpWidget(
        ScreenUtilInit(
          designSize: Size(1080, 1920),
          builder: () =>
              MaterialApp(
                  home: UserName(auth: auth)
              ),
        )
    );
    await tester.idle();
    await tester.pump();

    expect(find.text("Username"), findsOneWidget);
    expect(find.widgetWithText(ButtonWidget,'Submit'), findsOneWidget);

    await tester.enterText(find.byType(TextWidget), "ttt");
    await tester.tap(find.widgetWithText(ButtonWidget,'Submit'));
    await tester.pump();

    expect(find.text("ttt"), findsOneWidget);
  });
}
