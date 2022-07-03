import 'package:flutter/material.dart';
import 'package:flutter_app/screens/Dashboard.dart';
import 'package:flutter_app/screens/plan_related/SearchPlace.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_place/google_place.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  String apikey = dotenv.env['VAR_NAME'] ?? "";
  if (apikey == "") {
    print("lack of google api key");
    return;
  }
  GooglePlace googlePlace = GooglePlace(apikey);
  test('search nearby', () async {
    var result = await googlePlace.search.getNearBySearch(
        Location(lat: -33.8670522, lng: 151.1957362), 1500,
        type: "restaurant", keyword: "cruise");

    expect(result != Null, true);
    expect(result!.results != Null, true);
    //
    expect(result.results![0].name == "Cruise Bar", true);
    expect(result.results![1].name == "Sydney Harbour Dinner Cruises", true);
    expect(
        result.results![2].name == "Sydney Showboats - Dinner Cruise With Show",
        true);
    expect(result.results![3].name == "Junk Lounge", true);
    expect(result.results![4].name == "Sydney Harbour Lunch Cruise", true);
  });
  test('search find place', () async {
    var result = await googlePlace.search.getFindPlace(
        "Museum of Contemporary Art Australia", InputType.TextQuery,
        fields: "name,place_id,geometry");
    expect(result != Null, true);
    expect(result!.status == "OK", true);
    expect(result.candidates != Null, true);
    // expect(result.candidates![0].name == "Museum of Contemporary Art Australia",
    // true);
    // expect(result.candidates![0].placeId != Null, true);
  });
  test('search by using text', () async {
    var result = await googlePlace.search.getTextSearch("123 main street");
    expect(result != Null, true);
    // expect(result!.status == "ZERO_RESULTS", true);
  });

  test('autocomplete test', () async {
    var result = await googlePlace.autocomplete.get("Paris");
    expect(result != Null, true);
    expect(result?.status == "OK", true);
    expect(result!.predictions != Null, true);
    expect(result.predictions![0].description == "Paris, France", true);
    expect(
        result.predictions![1].description ==
            "Paris Las Vegas, South Las Vegas Boulevard, Las Vegas, NV, USA",
        true);
  });
}
