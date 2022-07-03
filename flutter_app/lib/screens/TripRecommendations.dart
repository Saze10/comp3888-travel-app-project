import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/firebase_services/database_service.dart';
import 'package:flutter_app/objects/user.dart';
import 'package:flutter_app/screens/recommendations_related/ShowRecommendations.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_app/widgets/button_widget.dart';
import 'package:google_place/google_place.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_app/screens/recommendations_related/RecommendationsMap.dart';
import 'package:flutter_app/services/geocoding_services.dart';
import 'package:flutter_app/services/places_services.dart';
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:google_directions_api/google_directions_api.dart'
    as direction_api;
import 'package:flutter_polyline_points/flutter_polyline_points.dart'
    as polyline_points;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'BottomNavigation.dart';


class RecommendationsPage extends StatefulWidget {
  final GooglePlace? googlePlace;
  final userDestinationId;
  final FirebaseFirestore? firebase;
  final FirebaseAuth? auth;
  const RecommendationsPage(
      {Key? key, this.googlePlace, this.userDestinationId, this.firebase, this.auth})
      : super(key: key);

  @override
  _RecommendationsPageState createState() =>
      _RecommendationsPageState(this.googlePlace, this.userDestinationId, this.firebase, this.auth);
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  Function eq = const ListEquality().equals;

  //TripRecommendationService tripRecommender = TripRecommendationService();
  GooglePlace? googlePlace;
  _RecommendationsPageState(this.googlePlace, this.userDestinationId, this.firebase, this.auth);

  final String apiKey = dotenv.env['APIKEY'] ?? "";
  bool isSelected = true;
  String userInformation = "Information about the user";
  //bool isNotFollowed = false;
  bool isLogin = false;
  List trip =
      []; //the list containing each location in sequence for the current trip
  List finalTrip = []; //addresses for each location in the trip in sequence
  User? user;
  LocalUser? localUser;
  Position? currentUserLocation;
  var userDestination;
  String userDestinationId = 'default'; //user destination placeId as string
  Completer<GoogleMapController> _mapController = Completer();
  late GoogleMapController _newMapController;
  var geoLocator = Geolocator();
  var googlePlaceResult;
  Geocoding geocoding = Geocoding();
  direction_api.DirectionsService? directionService;
  Place place = Place();
  List<List<polyline_points.PointLatLng>> polylinePoints = [];
  FirebaseFirestore? firebase;
  FirebaseAuth? auth;

  void getCurrentLocation() async {
    Position res = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentUserLocation = res;
    });
    //print(currentUserLocation);
  }

  bool containsList(List element, List list) {
    for (List e in list) {
      if (eq(e, element)) return true;
    }
    return false;
  }

  void getNearbyPlaces(latitude, longitude, String type) async {
    var result =
        await place.getNearByLocations(latitude, longitude, 5000, type);

    if (result == null) {
      print("Error with google places nearby search");
    }
    setState(() {
      googlePlaceResult = result;
    });
  }

  get_polylines() async {
    directionService = await direction_api.DirectionsService();
    polylinePoints = [];
    if (apiKey == "") {
      print("lack of api key");
      return;
    }
    direction_api.DirectionsService.init(apiKey);
    directionService = await direction_api.DirectionsService();
    int length = trip.length;
    List<direction_api.DirectionsWaypoint> waypoints = [];

    for (var j = 1; j < length - 1; j++) {
      String location = trip[j][0].toString() + ',' + trip[j][1].toString();
      waypoints.add(direction_api.DirectionsWaypoint(location: location));
    }
    print("waypoints :O");
    print(waypoints);
    String originLat = trip[0]![0].toString();
    String originLng = trip[0]![1].toString();
    String destLat = trip.last![0].toString();
    String destLng = trip.last![1].toString();

    String originLoc = '';
    originLoc = originLat + ',' + originLng;

    String destLoc = '';
    destLoc = destLat + ',' + destLng;

    List<polyline_points.PointLatLng> polylinePoint = [];

    var request = await direction_api.DirectionsRequest(
      origin: originLoc,
      destination: destLoc,
      travelMode: direction_api.TravelMode.driving,
      waypoints: waypoints,
    );

    await directionService?.route(request,
        (direction_api.DirectionsResult response,
            direction_api.DirectionsStatus? status) {
      if (status == direction_api.DirectionsStatus.ok) {
        polylinePoint = polyline_points.PolylinePoints()
            .decodePolyline(response.routes?[0].overviewPolyline?.points ?? "");
        print("polylinePoint");
        polylinePoints.add(polylinePoint);
      } else {
        print("direction request fail triprecommendations :)");
      }
    });
  }

  void getUser() {
    setState(() {
      this.isLogin = UserServices.getUserLoginState();
      this.user = UserServices.getUserInfo();
    });
  }

  String? getTripAsString() {
    return finalTrip.join(" \n\n ");
  }

  @override
  void initState() {
    super.initState();
    this.getUser();
    String apiKey = dotenv.env['APIKEY'] ?? "";
    if (apiKey == "") {
      print("lack of api key");
      return;
    }
    googlePlace = GooglePlace(apiKey);
    firebase = widget.firebase;
    auth = widget.auth;
  }

  @override
  Widget build(BuildContext context) {
    if (auth != null){
      if (auth!.currentUser == null){
        return getNotLogin();
      }else{
        user = auth!.currentUser;
        return Recommendation();
      }
    }else{
      if(UserServices.getUserLoginState()){
        user = UserServices.getUserInfo();
        return Recommendation();
      }else{
        return getNotLogin();
      }
    }
  }


  AppBar getAppBar() {
    return AppBar(
      title: const Text(
        'Trip Recommendations',
        style: const TextStyle(
          color: Color.fromRGBO(20, 41, 82, 1),
          fontWeight: FontWeight.bold,
          fontSize: 24.0,
        ),
      ),
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        color: Color.fromRGBO(20, 41, 82, 1),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget Recommendation() {
    return StreamBuilder<List<LocalUser>>(
        stream: DatabaseService().streamUserData,
        builder:
            (BuildContext context, AsyncSnapshot<List<LocalUser>> snapshot) {
          if (snapshot.hasError) {
            return Text('Data retrieval error');
          }
          if (snapshot.data == null) {
            return Text("Loading");
          }
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Text("Loading");
          // }
          localUser = snapshot.data!.first;
          Map preferences = localUser!.preference;
          return Scaffold(
            appBar: getAppBar(),
            body: Container(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: ListView(children: <Widget>[
                  SizedBox(
                    height: 50.0,
                  ),
                  ButtonWidget(
                    key: Key('destination_button'),
                    text: 'Pick destination',
                    onPressed: () async {
                      print(preferences["Accommodation"]);
                      getCurrentLocation();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                RecommendationsMap(googlePlace: googlePlace)),
                      );
                    },
                  ),
                  SizedBox(
                    height: 100.0,
                  ),
                  // ButtonWidget(
                  //   text: 'Pick number of places to visit',
                  //   onPressed: () async {
                  //     print(preferences["Accommodation"]);
                  //     getCurrentLocation();
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => PickNumber()),
                  //     );
                  //   },
                  // ),
                  // SizedBox(
                  //   height: 100.0,
                  // ),
                  ButtonWidget(
                    key: Key('get_recommendations_button'),
                    text: 'Get recommendations',
                    onPressed: () async {
                      //categories of places to visit
                      trip = [];
                      finalTrip = [];

                      List<String> search_types = [
                        "restaurant",
                        "tourist_attraction",
                        "lodging"
                      ];

                      //get current user location
                      getCurrentLocation();
                      double lat = currentUserLocation!.latitude;
                      double lng = currentUserLocation!.longitude;
                      trip.add([lat, lng]);

                      //gets places matching the categories of places to visit within the radius
                      //and adds them to the trip list
                      for (var i = 0; i < search_types.length; i++) {
                        String type = search_types[i];
                        getNearbyPlaces(lat, lng, type);
                        lat =
                            googlePlaceResult.results[0].geometry.location.lat;
                        lng =
                            googlePlaceResult.results[0].geometry.location.lng;
                        if (containsList([lat, lng], trip)) {
                          for (var k = 0;
                          k < googlePlaceResult.results.length;
                          k++) {
                            lat = googlePlaceResult
                                .results[k].geometry.location.lat;
                            lng = googlePlaceResult
                                .results[k].geometry.location.lng;
                            if (!containsList([lat, lng], trip)) {
                              trip.add([lat, lng]);
                              break;
                            }
                          }
                        } else {
                          trip.add([lat, lng]);
                        }
                      }

                      // printing all returned locations
                      // for(var i = 0; i < googlePlaceResult.results.length; i++) {
                      //   print(googlePlaceResult.results[i].name);
                      //   print(googlePlaceResult.results[i].geometry.location.lat);
                      //   print(googlePlaceResult.results[i].geometry.location.lng);
                      // }

                      //get user-defined destination
                      print(userDestinationId);
                      var result =
                      await geocoding.getPlaceById(userDestinationId);
                      setState(() {
                        userDestination = result;
                      });
                      print(userDestination.results[0].formattedAddress);
                      lat = userDestination.results[0].geometry.location.lat;
                      lng = userDestination.results[0].geometry.location.lng;
                      trip.add([lat, lng]);

                      //get human-readable addresses of each place in the trip
                      //might get names of places later
                      for (var i = 0; i < trip.length; i++) {
                        lat = trip[i][0];
                        lng = trip[i][1];

                        var geocodingResult =
                        await geocoding.getPlaceByLocation(lat, lng);
                        String? formattedAddress =
                            geocodingResult?.results[0].formattedAddress;
                        String address = '';
                        if (formattedAddress != null) {
                          address = formattedAddress;
                        }
                        //get name of place
                        var placeResult = await place.getPlaceByText(address);
                        String? placeName = placeResult?.results[0].name;

                        //get
                        finalTrip.add([
                          [placeName],
                          [address]
                        ]);
                      }
                      print(trip);
                      print(finalTrip);
                    },
                  ),
                  SizedBox(
                    height: 100.0,
                  ),
                  ButtonWidget(
                    key: Key('show_recommendations_button'),
                    text: 'Show recommendations',
                    onPressed: () async {
                      await get_polylines();
                      getCurrentLocation();
                      String? tripString = getTripAsString();
                      print("polyline length :)");
                      print(polylinePoints.length);
                      print(polylinePoints);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShowRecommendations(
                              recommendations: tripString,
                              trip: trip,
                              polylinePoints: polylinePoints,
                            )),
                      );
                    },
                  ),
                ]),
              ),
            ),
          );
        });
  }

  Widget getNotLogin(){
    return Scaffold(
        appBar: getAppBar(),
        backgroundColor: Colors.white,
        body: Padding(
            padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(280),0,0,0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Please Login first!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color.fromRGBO(20, 41, 82, 1),
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                  TextButton(
                    child: Text(
                      'Go to Login',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BottomNavigatorBar(data : 3, isLogin : false)),
                    ),
                  ),
                ]
            )
        )
    );
  }

}


