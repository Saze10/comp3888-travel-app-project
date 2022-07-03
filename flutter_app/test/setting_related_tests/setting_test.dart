import 'package:flutter/material.dart';
import 'package:flutter_app/screens/Setting.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


Future<void> main() async {
  testWidgets(
    'setting display test',
        (WidgetTester tester) async {
      await tester.pumpWidget(ScreenUtilInit(
        designSize: Size(1080, 1920),
        builder: () => MaterialApp(home: Setting()),
      ));
      await tester.idle();
      await tester.pump();

      expect(find.text("Logout"), findsOneWidget);
      expect(find.text('Gender'), findsOneWidget);
      expect(find.text('User Name'), findsOneWidget);
      expect(find.text('Profile Picture'), findsOneWidget);
      expect(find.text('Preference'), findsOneWidget);

    },
  );
}
