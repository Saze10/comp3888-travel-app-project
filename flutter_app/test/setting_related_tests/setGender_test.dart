import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/objects/user.dart';
import 'package:flutter_app/services/user_services.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_app/screens/setting_related/setGender.dart';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // if (USE_FIRESTORE_EMULATOR) {
  //   FirebaseFirestore.instance.settings = const Settings(
  //       host: 'localhost:8080', sslEnabled: false, persistenceEnabled: false);
  // }
  //final AuthenticationService _auth = AuthenticationService(FirebaseAuth.instance);
  //await _auth.signIn(email: "tt@gmail.com", password: "123456");
  //
  testWidgets(
    'set gender test',
    (WidgetTester tester) async {
      final firebase = FakeFirebaseFirestore();
      await firebase.collection("user_data").doc("123456789").set({
        'name': "test",
        'email': "t@gmail.com",
        'uid': "123456789",
        'gender': "male",
        'preference': {"Accommodation": [], "Food": []},
        'trips': [],
        'saved': [],
        'photoURL':
            "https://assets.atdw-online.com.au/images/082abec166a817adfae646daff53ad70.jpeg?rect=0%2C0%2C2048%2C1536&w=800&h=800&rot=360",
      });
      await tester.pumpWidget(ScreenUtilInit(
        designSize: Size(1080, 1920),
        builder: () => MaterialApp(home: SetGender(firebase: firebase)),
      ));
      await tester.idle();
      await tester.pump();

      expect(find.text("male"), findsOneWidget);
      expect(find.text('female'), findsOneWidget);
      expect(find.text('secrecy'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.female));
      await tester.pump();

      await firebase
          .collection("user_data")
          .doc("123456789")
          .get()
          .then((snapshot) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        LocalUser lu = LocalUser(
          name: data['name'] ?? "default username",
          email: data['email'],
          uid: data['uid'],
          gender: data['gender'],
          preference: data['preference'],
          trips: data["trips"],
          saved: data['saved'],
          photoURL: data["photoURL"],
        );
        expect(lu.gender, "female");
      });

      await tester.tap(find.byIcon(Icons.security));
      await tester.pump();

      await firebase
          .collection("user_data")
          .doc("123456789")
          .get()
          .then((snapshot) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        LocalUser lu = LocalUser(
          name: data['name'] ?? "default username",
          email: data['email'],
          uid: data['uid'],
          gender: data['gender'],
          preference: data['preference'],
          trips: data["trips"],
          saved: data['saved'],
          photoURL: data["photoURL"],
        );
        expect(lu.gender, "secrecy");
      });

      await tester.tap(find.byIcon(Icons.male));
      await tester.pump();

      await firebase.collection("user_data").doc("123456789").get().then(
        (snapshot) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          LocalUser lu = LocalUser(
            name: data['name'] ?? "default username",
            email: data['email'],
            uid: data['uid'],
            gender: data['gender'],
            preference: data['preference'],
            trips: data["trips"],
            saved: data['saved'],
            photoURL: data["photoURL"],
          );
          expect(lu.gender, "male");
        },
      );
    },
  );
}
