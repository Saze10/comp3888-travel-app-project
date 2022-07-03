import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/InvitedFriend.dart';
import 'package:flutter_app/widgets/button_widget.dart';
import 'package:flutter_app/widgets/text_widget.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


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
  testWidgets('invited  friend test', (WidgetTester tester) async {
    await tester.pumpWidget(
        ScreenUtilInit(
          designSize: Size(1080, 1920),
          builder: () =>
              MaterialApp(
                  home: InvitedFriend(id: "1234567890", auth: auth)
              ),
        )
    );
    await tester.idle();
    await tester.pump();

    expect(find.text("Please Enter an Email"), findsOneWidget);
    expect(find.widgetWithText(ButtonWidget,'Invited'), findsOneWidget);

    await tester.enterText(find.byType(TextWidget), "qq@gmail.com");
    await tester.tap(find.widgetWithText(ButtonWidget,'Invited'));
    await tester.pump();

    expect(find.text("qq@gmail.com"), findsOneWidget);
  });
}
