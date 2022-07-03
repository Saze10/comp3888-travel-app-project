import 'package:flutter/material.dart';
import 'package:flutter_app/screens/setting_related/uploadPicture.dart';
import 'package:flutter_app/widgets/button_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  testWidgets('changing profile picture test', (WidgetTester tester) async {
    await tester.pumpWidget(
        ScreenUtilInit(
          designSize: Size(1080, 1920),
          builder: () =>
              MaterialApp(
                  home: ImagePickerPage()
              ),
        )
    );
    await tester.idle();
    await tester.pump();

    expect(find.text("Please select an image"), findsOneWidget);
    expect(find.widgetWithText(ButtonWidget,'Select'), findsOneWidget);
    expect(find.widgetWithText(ButtonWidget,'Upload'), findsOneWidget);

    await tester.tap(find.widgetWithText(ButtonWidget,'Upload'));
    await tester.pump();

    //expect(find.text("Camera"), );
  });
}