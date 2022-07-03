import 'package:flutter/material.dart';
import 'package:flutter_app/screens/Dashboard.dart';
import 'package:flutter_app/screens/plan_related/SearchPlace.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_place/google_place.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  testWidgets('test Dashboard page widget', (WidgetTester tester) async {
    Widget dashboard = MaterialApp(
      home: Dashboard(),
    );

    // const itembuilderKey = Key('list-itembuilder');
    // const getRecommendListKey = Key('getRecommendList');
    // const getrecommendTextKey = Key('getrecommendText');
    const getMakeTripbuttonKey = Key('getMakeTripbutton');
    const getTripRecommendationButtonKey = Key('getTripRecommendationButton');
    const getImage = Key('getImage');

    await tester.pumpWidget(dashboard);

    final dashboard_scaffold_Finder = find.descendant(
        of: find.byWidget(dashboard), matching: find.byType(Scaffold));

    expect(dashboard_scaffold_Finder, findsOneWidget);

    final dashboard_MakeTripbutton_Finder = find.descendant(
        of: find.byWidget(dashboard),
        matching: find.byKey(getMakeTripbuttonKey));
    expect(dashboard_MakeTripbutton_Finder, findsOneWidget);

    final dashboard_getTripRecommendation_Finder = find.descendant(
        of: find.byWidget(dashboard),
        matching: find.byKey(getTripRecommendationButtonKey));
    expect(dashboard_getTripRecommendation_Finder, findsOneWidget);

    final dashboard_image_Finder = find.descendant(
        of: find.byWidget(dashboard), matching: find.byKey(getImage));
    expect(dashboard_image_Finder, findsOneWidget);

    final dashboard_button_Finder = find.descendant(
        of: find.byWidget(dashboard), matching: find.byType(ElevatedButton));
    expect(dashboard_button_Finder, findsWidgets);
  });
  testWidgets('Test search page widget', (WidgetTester tester) async {
    Widget search_place = MaterialApp(
      home: SearchPlace(),
    );
    await tester.pumpWidget(search_place);

    final search_place_scaffold_Finder = find.descendant(
        of: find.byWidget(search_place), matching: find.byType(Scaffold));

    expect(search_place_scaffold_Finder, findsOneWidget);
  });
}
