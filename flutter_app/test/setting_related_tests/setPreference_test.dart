import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_app/screens/setting_related/setPreference.dart';

Future<void> main() async {
  testWidgets(
    'set preference test',
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
        builder: () => MaterialApp(home: SetPreference(firebase: firebase)),
      ));
      await tester.idle();
      await tester.pump();

      expect(find.text("Accommodation"), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);

      await tester.tap(find.text("Accommodation"));
      await tester.pump();

      await tester.tap(find.text('Food'));
      await tester.pump();


      await tester.tap(find.text('Submit'));
      await tester.pump();
    },
  );
}
