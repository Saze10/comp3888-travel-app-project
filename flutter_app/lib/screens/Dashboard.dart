import 'package:flutter/material.dart';
import 'package:flutter_app/screens/BottomNavigation.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:google_place/google_place.dart';
import 'package:flutter_app/screens/MakeTrip.dart';
import 'package:flutter_app/screens/TripRecommendations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/firebase_services/database_makePlan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_app/objects/user.dart';
import 'dart:typed_data';

class Place_detail {
  final String? name;
  final double? rating;
  final String? place_id;
  List<Uint8List>? images;

  Place_detail(this.name, this.rating, this.place_id, this.images) {}
}

class Image_data {
  String place_id;
  Uint8List image;
  Image_data(this.place_id, this.image) {}
}

class Dashboard extends StatefulWidget {
  final GooglePlace? googlePlace;

  const Dashboard({Key? key, this.googlePlace}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState(this.googlePlace);
}

class _DashboardState extends State<Dashboard> {
  final GooglePlace? googlePlace;

  final favourite = {};

  bool isLogin = false;
  bool isLiked = false;

  _DashboardState(this.googlePlace);

  var geoLocator = Geolocator();
  List<Place_detail> places = [];
  List<Image_data> image_data = [];
  User? user;
  LocalUser? localUser;
  Location? curr_location;
  Location default_location = Location(
      lat: -33.8670522,
      lng:
          151.1957362); //need adjust after we can access the current location of user.


  void getCurrentLocation() async {
    Position res = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      curr_location = Location(lat: res.latitude, lng: res.longitude);
    });
    //print(currentUserLocation);
  }

  @override
  void initState() {
    getPlaces();
    getCurrentLocation();
    super.initState();
    this.isLogin = UserServices.getUserLoginState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),
          getImage(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getMakeTripbutton(),
              getTripRecommendationButton(),
            ],
          ),

          // listplace(context),
          // _getBottompage(context),
          Expanded(
            child: InkWell(
              child: getRecommendList(),
              onTap: () {
                print("listing");
                _openPlacelist();
              },
            ),
          )
        ],
      ),
    );
  }

  void getPlaces() async {
    var result = await this.googlePlace!.search.getNearBySearch(
          curr_location ?? default_location,
          1500,
          type: "tourist_attraction",
        );

    if (result == null) {
      print("null");
    }

    if (result != null && result.results != null && mounted) {
      // List<Place_detail> temp = [];
      for (var place in result.results!) {
        print(place.name);
        if (place.photos != null) {
          for (var photo in place.photos!) {
            getPhoto(photo.photoReference!, place.placeId!);
          }
          setState(() {
            places.add(
                Place_detail(place.name, place.rating, place.placeId, null));
          });
        }
      }
    }
  }

  listplace(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5, // half screen on load
          maxChildSize: 1, // full screen on scroll
          minChildSize: 0.25,
          builder: (BuildContext context, ScrollController scrollController) {
            return getRecommendList();
          },
        );
      },
    );
    //
  }

  Widget _listitembuilder(BuildContext context, int index) {
    //print(places.length);
    int i = 0;
    while (i <= places.length){
      if (!favourite.containsKey(i)){
        favourite[i] = false;
      }
      i += 1;
    }

    //print(favourite);
    //isLiked = favourite[index];
    return Container(
      key: Key('list-itembuilder'),
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
      alignment: Alignment.topLeft,
      height: 300,
      child: Card(
        child: Container(
          child: Stack(
            children: [
              Column(
                children: <Widget>[
                  if (places[index].images?.length == null) ...[
                    Container(
                      height: 200,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 40,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image(
                              image: AssetImage('images/quota.png'),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: places[index].images?.length ?? 0,
                        itemBuilder: (context, i) {
                          return Container(
                            width: MediaQuery.of(context).size.width - 40,
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.memory(
                                  places[index].images![i],
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.fromLTRB(15, 0, 5, 0),
                      child: Text(
                        places[index].name ?? "NULL",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.fromLTRB(15, 0, 5, 0),
                          child: Text(
                            // "test",p
                            "Rating: " + (places[index].rating.toString()),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.white),
                                overlayColor:
                                    MaterialStateProperty.all(Colors.blueGrey),
                                side: MaterialStateProperty.all(
                                    BorderSide(width: 1, color: Colors.white)),
                                shadowColor:
                                    MaterialStateProperty.all(Colors.grey),
                                elevation: MaterialStateProperty.all(3),
                                shape: MaterialStateProperty.all(StadiumBorder(
                                    side: BorderSide(
                                  style: BorderStyle.solid,
                                ))),
                              ),
                              child: Icon(
                                favourite[index]? Icons.favorite : Icons.favorite_border,
                                color: favourite[index]? Colors.blueAccent : Colors.lightBlueAccent,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (favourite[index]) {
                                    favourite[index] = false;
                                  } else {
                                    favourite[index] = true;
                                  }

                                });

                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //trip plan list view
  Widget getRecommendList() {
    return Container(
      key: Key('getRecommendList'),
      color: Colors.white,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: places.length,
        itemBuilder: _listitembuilder,
      ),
    );
  }

  _openPlacelist() {
    Navigator.of(context).push(new MaterialPageRoute<String>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: new AppBar(
              title: const Text('Tourist attraction'),
            ),
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: getRecommendList(),
            ),
          );
        },
        fullscreenDialog: true));
  }

  //Make a trip button
  Widget getMakeTripbutton() {
    return Container(
      key: Key('getMakeTripbutton'),
      margin: EdgeInsets.only(top: 12, bottom: 12, left: 5, right: 2),
      width: MediaQuery.of(context).size.width * 0.9/2,
      height: 60,
      child: ElevatedButton(
        child: Text("Start Planning!",
            textAlign: TextAlign.center,),
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all(TextStyle(fontSize: 18)),
          backgroundColor: MaterialStateProperty.all(Colors.green[300]),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          shape: MaterialStateProperty.all(
              BeveledRectangleBorder(borderRadius: BorderRadius.circular(5.0))),
        ),
        onPressed: () {
          DatabaseMakePlan _databaseMakePlan = DatabaseMakePlan();
          _databaseMakePlan.setupMakePlanData();
          if (isLogin) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MakeTrip()),
              //MaterialPageRoute(builder: (context) => BottomNavigatorBar(data : 3, isLogin : true)),
            );
          } else {
            Navigator.push(
              context,
              //MaterialPageRoute(builder: (context) => LoginPage()),
              MaterialPageRoute(
                  builder: (context) =>
                      BottomNavigatorBar(data: 3, isLogin: false)),
            );
          }
        },
      ),
    );
  }

  Widget getTripRecommendationButton() {
    //goes to the trip recommendations_related page
    return Container(
      key: Key('getTripRecommendationButton'),
      margin: EdgeInsets.only(top: 12, bottom: 12, left: 2, right: 5),
      width: MediaQuery.of(context).size.width * 1/2,
      height: 60,
      child: ElevatedButton(
        child: Text("Trip Recommendations",
          textAlign: TextAlign.center,),
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all(TextStyle(fontSize: 18)),
          backgroundColor: MaterialStateProperty.all(Colors.blueAccent[300]),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          shape: MaterialStateProperty.all(
              BeveledRectangleBorder(borderRadius: BorderRadius.circular(5.0))),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RecommendationsPage(
                      userDestinationId: 'default',
                    )),
          );
        },
      ),
    );
  }

//Dashboard image
  Widget getImage() {
    return Container(
      key: Key('getImage'),
      height: 250,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage('images/sydney_opera_house.jpeg'),
        ),
      ),
    );
  }

  Future getPhoto(String photoReference, String place_id) async {
    var result = await googlePlace?.photos.get(photoReference, 200, 200);
    if (result != null && mounted) {
      // print(photoReference);
      // print(place_id);
      // print(result);

      for (var i = 0; i < places.length; i++) {
        if (places[i].place_id == place_id) {
          setState(() {
            if (places[i].images == null) {
              places[i].images = [result];
            } else {
              places[i].images?.add(result);
            }
          });
        }
      }
    }
  }
}
