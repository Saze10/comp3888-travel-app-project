import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_app/main.dart' as app;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/objects/user.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

bool USE_FIRESTORE_EMULATOR = false;
void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    // testWidgets('Register', (WidgetTester tester) async {
    //   app.main();
    //   await tester.pumpAndSettle();

    //   //go to register page
    //   // final Finder profileIcon = find.byIcon(Icons.home);
    //   // final Finder dasboardIcon = find.byIcon(Icons.account_circle);
    // final Finder planIcon = find.byIcon(Icons.wysiwyg);
    //   final Finder loginIcon = find.byIcon(Icons.account_circle);

    //   await tester.tap(loginIcon);
    //   // Trigger a frame.
    //   await tester.pumpAndSettle();

    //   // final Finder Login = find.byKey(Key('Login-page'));

    //   // expect(Login, findsOneWidget);
    //   expect(find.text('Email'), findsOneWidget);
    //   expect(find.text('Password'), findsOneWidget);

    //   await tester.enterText(
    //       find.byKey(Key('email-textfile')), "testaccount@gmail.com");
    //   await tester.enterText(find.byKey(Key('password-textfile')), "testing");

    //   await tester.pumpAndSettle();

    //   final Finder registerButton = find.byKey(Key('register-button'));
    //   await tester.tap(registerButton);

    //   await tester.pumpAndSettle();

    //   // expect(find.byKey(Key('Profile-page')), findsOneWidget);
    //   await tester.tap(find.byIcon(Icons.logout));
    //   await tester.pumpAndSettle();
    // });

    testWidgets('Profile', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      //go to Login page
      final Finder loginIcon = find.byIcon(Icons.account_circle);

      await tester.tap(loginIcon);
      // Trigger a frame.
      await tester.pumpAndSettle(new Duration(milliseconds: 500));

      // final Finder Login = find.byKey(Key('Login-page'));

      // expect(Login, findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      await tester.enterText(
          find.byKey(Key('email-textfile')), "testaccount@gmail.com");
      await tester.enterText(find.byKey(Key('password-textfile')), "testing");
      await tester.pumpAndSettle();

      final Finder loginButton = find.byKey(Key('login-button'));
      await tester.tap(loginButton);

      await tester.pumpAndSettle(new Duration(milliseconds: 1000));

      expect(find.byKey(Key('Profile-page')), findsOneWidget);

      //go to setting page
      final Finder settingIcon = find.byIcon(Icons.settings);
      await tester.tap(settingIcon);
      // Trigger a frame.
      await tester.pumpAndSettle();

      //go to change name page
      await tester.tap(find.text("User Name"));
      await tester.pumpAndSettle();

      tester.enterText(find.byType(TextField), "test@gmail.com");
      final Finder submit = find.byTooltip('Submit');
      await tester.tap(submit);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text("test@gmail.com"), findsOneWidget);
      //change name back
      await tester.tap(settingIcon);
      await tester.tap(find.text("User Name"));
      await tester.pumpAndSettle();

      tester.enterText(find.byType(TextField), "testaccount@gmail.com");
      await tester.tap(submit);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text("testaccount@gmail.com"), findsOneWidget);

      //change gender
      await tester.tap(settingIcon);
      await tester.tap(find.text("Gender"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("male"));
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.male), findsOneWidget);

      //change gneder back
      await tester.tap(settingIcon);
      await tester.tap(find.text("Gender"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("secrecy"));
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.security), findsOneWidget);

      //set perference
      await tester.tap(find.byKey(Key('list-perference')));
      await tester.tap(find.byTooltip('Food'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Fast Food'));
      await tester.tap(find.byTooltip('Food'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Submit'));
      await tester.tap(find.byIcon(Icons.arrow_back));

      await tester.pumpAndSettle();
      expect(find.text('Fast Food'), findsOneWidget);

      //change back
      await tester.tap(find.byKey(Key('list-perference')));
      await tester.tap(find.byTooltip('Food'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Fast Food'));
      await tester.tap(find.byTooltip('Food'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Submit'));
      await tester.tap(find.byIcon(Icons.arrow_back));

      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();
    });
    testWidgets('Dashboard', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(Duration(milliseconds: 1000));
      expect(find.text("Start Planning!"), findsOneWidget);


      //recommendations
      await tester.tap(find.text("Start Planning!"));
      await tester.pumpAndSettle(new Duration(milliseconds: 500));
      expect(find.byKey(Key('destination_button')), findsOneWidget);
      expect(find.byKey(Key('get_recommendations_button')), findsOneWidget);
      expect(find.byKey(Key('show_recommendations_button')), findsOneWidget);

      //user should able to see a list of place
      final Finder getRecommendList = find.byKey(Key('getRecommendList'));
      expect(getRecommendList, findsOneWidget);

      //make a plan
      await tester.tap(find.text("Start Planning!"));
      await tester.pumpAndSettle(new Duration(milliseconds: 500));
      expect(find.text("Make a Plan"), findsOneWidget);
      expect(find.text("Please enter the title"), findsOneWidget);

      await tester.enterText(
          find.text("Please enter the title"), "Sample plan");

      //add origin place by search
      expect(find.text("origin"), findsOneWidget);
      await tester.tap(find.byTooltip('current place'));
      await tester.pumpAndSettle();

      expect(find.text("Search"), findsOneWidget);
      await tester.enterText(find.text("Search"), "USYD");
      await tester.pumpAndSettle();

      final Finder searchButton = find.byIcon(Icons.search);
      await tester.tap(searchButton);
      await tester.pumpAndSettle();

      //after search, app should displace a place card
      //add this place to plan by tap add button
      expect(find.text("add"), findsOneWidget);
      await tester.tap(find.byTooltip('add'));
      await tester.pumpAndSettle();

      //success add place "USYD" to this plan
      expect(find.text("add"), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text("The University of Sydney"), findsOneWidget);

      //add destination
      await tester.tap(find.byTooltip('...'));
      await tester.pumpAndSettle();

      expect(find.text("Search"), findsOneWidget);
      await tester.enterText(find.text("Search"), "Darling harbour");
      await tester.pumpAndSettle();

      await tester.tap(searchButton);
      await tester.pumpAndSettle();

      expect(find.text("add"), findsOneWidget);
      await tester.pumpAndSettle();
      //success add destination
      expect(find.text("Darling Harbour"), findsOneWidget);

      //add a new place
      expect(find.text("add"), findsOneWidget);
      await tester.tap(find.byTooltip('add'));

      //drag item list
      await tester.drag(find.byType(Dismissible), const Offset(0.0, 500.0));
      await tester.pumpAndSettle();

      expect(find.text("cafe"), findsOneWidget);
      expect(find.text("car_wash"), findsOneWidget);

      //select interests
      await tester.tap(find.byTooltip('cafe'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('car_wash'));
      await tester.pumpAndSettle();

      expect(find.text("submit"), findsOneWidget);
      await tester.tap(find.byTooltip('submit'));
      await tester.pumpAndSettle();

      //save plan
      expect(find.byIcon(Icons.vertical_align_bottom), findsOneWidget);
      await tester.tap(find.byIcon(Icons.vertical_align_bottom));

      expect(find.text("DONE"), findsOneWidget);
      await tester.tap(find.byTooltip('DONE'));
      await tester.pumpAndSettle(new Duration(milliseconds: 500));
    });
    testWidgets('Plan', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(Duration(milliseconds: 1000));

      //go to plan page
      final Finder planIcon = find.byIcon(Icons.wysiwyg);
      expect(planIcon, findsOneWidget);
      await tester.tap(planIcon);

      expect(find.text("Plans"), findsOneWidget);

      //open Sample plan
      expect(find.text("Trip to Sample plan"), findsOneWidget);
      await tester.tap(find.byTooltip('Trip to Sample plan'));
      await tester.pumpAndSettle(Duration(milliseconds: 1000));

      expect(find.text("Display Plan"), findsOneWidget);
      expect(find.text("Sample plan"), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.map), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);

      await tester.tap(find.byIcon(Icons.map));
      await tester.pumpAndSettle(Duration(milliseconds: 1000));
      expect(find.byType(GoogleMap), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle(Duration(milliseconds: 1000));

      //test notification and share button
      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.text("Please Enter an Email"), "testaccount1@gmail.com");

      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Invited'));
      await tester.pumpAndSettle();
      //back to sample plan page
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      //back to user plan page
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      //delete plan
      await tester.tap(find.byIcon(Icons.delete_forever_outlined));
      expect(find.text("Trip to Sample plan"), findsNothing);

      //logout
      final Finder loginIcon = find.byIcon(Icons.account_circle);

      await tester.tap(loginIcon);
      await tester.pumpAndSettle(Duration(milliseconds: 500));
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();
    });

    testWidgets('Notification', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      //go to Login page
      final Finder loginIcon = find.byIcon(Icons.account_circle);

      await tester.tap(loginIcon);
      await tester.pumpAndSettle(new Duration(milliseconds: 500));

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      //login other account
      await tester.enterText(
          find.byKey(Key('email-textfile')), "testaccount1@gmail.com");
      await tester.enterText(find.byKey(Key('password-textfile')), "testing");
      await tester.pumpAndSettle();

      final Finder loginButton = find.byKey(Key('login-button'));
      await tester.tap(loginButton);

      await tester.pumpAndSettle();

      expect(find.byKey(Key('Profile-page')), findsOneWidget);

      final Finder notificationIcon = find.byIcon(Icons.mail_outline);
      await tester.tap(notificationIcon);
      await tester.pumpAndSettle();

      //check notification recieved
      expect(find.text("Send From testaccount@gmail.com"), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);

      //accept invite message
      await tester.tap(find.byIcon(Icons.check_circle_rounded));
      await tester.pumpAndSettle();

      //check whether plan has added
      //go to plan page  first
      final Finder planIcon = find.byIcon(Icons.wysiwyg);

      await tester.tap(planIcon);
      await tester.pumpAndSettle();

      //found plan
      expect(find.text("Sample plan"), findsOneWidget);

      //logout
      await tester.tap(loginIcon);
      await tester.pumpAndSettle(Duration(milliseconds: 500));
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();
    });
  });
}
