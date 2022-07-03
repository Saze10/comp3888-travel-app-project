import 'package:flutter_app/screens/Login.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_app/widgets/button_widget.dart';
import 'package:flutter_app/widgets/text_widget.dart';
import 'package:flutter_app/widgets/textfield_widget.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

bool USE_FIRESTORE_EMULATOR = true;

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

  testWidgets('login test', (WidgetTester tester) async {
    final firebase = FakeFirebaseFirestore();
    await tester.pumpWidget(
        ScreenUtilInit(
          designSize: Size(1080, 1920),
          builder: () =>
              MaterialApp(
                  home: LoginPage(),
              ),
        )
    );
    await tester.idle();
    await tester.pump();

    // expect(find.widgetWithText(ButtonWidget,"Login"), findsOneWidget);
    // expect(find.widgetWithText(ButtonWidget,"Sign Up"), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFieldWidget,"Email"), "test@mememail.com");
    await tester.enterText(find.widgetWithText(TextFieldWidget,"Password"), "123456");
    await tester.tap(find.widgetWithText(ButtonWidget,'Login'));
    await tester.pump();

    expect(find.text("invalid sign in"), findsNothing);
  });
}














