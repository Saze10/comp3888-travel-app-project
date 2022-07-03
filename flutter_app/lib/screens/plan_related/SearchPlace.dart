import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/firebase_services/database_savedPlan.dart';
import 'package:flutter_app/objects/savedPlan.dart';
import 'package:flutter_app/screens/TripRecommendations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_app/firebase_services/database_service.dart';
import 'package:flutter_app/screens/MakeTrip.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_app/firebase_services/database_makePlan.dart';
import 'package:flutter_app/objects/personalPlan.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchPlace extends StatefulWidget {
  final GooglePlace? googlePlace;
  final String? searchDay;
  final String? searchInterest;
  final FirebaseFirestore? firebase;
  final String? whichPlan;
  final String? targetId;
  final String? targetUser;

  const SearchPlace(
      {Key? key,
        this.googlePlace,
        this.searchDay,
        this.searchInterest,
        this.firebase,
        this.whichPlan,
        this.targetId,
        this.targetUser,
      })
      : super(key: key);

  @override
  _SearchPlaceState createState() =>
      _SearchPlaceState(this.googlePlace, this.searchDay, this.searchInterest, this.whichPlan, this.targetId, this.targetUser);
}

class _SearchPlaceState extends State<SearchPlace> {
  final GooglePlace? googlePlace;
  String? searchDay;
  String? searchInterest;
  String? whichPlan;
  String? targetId;
  String? targetUser;
  FirebaseFirestore? firebase;

  DayPlan? dayPlan;
  SavedPlan? savedPlan;
  Map addPlacesList = {};
  List allTrip = [];
  int planIndex = 0;

  int IsPred = 0;

  _SearchPlaceState(this.googlePlace, this.searchDay, this.searchInterest, this.whichPlan, this.targetId, this.targetUser);

  final TextEditingController _textcontroller = TextEditingController();
  List? predictions = [];
  List<SearchResult>? places;

  double _mapPadding = 0;

  Completer<GoogleMapController> _mapController = Completer();
  late GoogleMapController _newMapController;

  late Position _currentPosition;
  var geoLocator = Geolocator();

  Position? currentUserLocation;

  void initState() {
    super.initState();
    searchDay = widget.searchDay;
    searchInterest = widget.searchInterest;
    firebase = widget.firebase;
    whichPlan = widget.whichPlan;
    if(whichPlan == 'Saved'){
      targetId = widget.targetId;
    }
    if(widget.targetUser != null){
      targetUser = widget.targetUser;
    }

  }

  void _locatePosition() async {
    Position _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _currentPosition = _position;

    LatLng _latLngPosition = LatLng(_position.latitude, _position.longitude);
    CameraPosition _cameraPosition =
    new CameraPosition(target: _latLngPosition, zoom: 14);
    _newMapController
        .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
  }

  static final CameraPosition _cameraPlace = CameraPosition(
    target: LatLng(42.7477863, -71.1699932),
    zoom: 14.4746,
  );

  void getCurrentLocation() async {
    Position res = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentUserLocation = res;
    });
    //print(currentUserLocation);
  }

  void _addToAddPlacesList(SearchResult place) async {
    //String _dayCounter = searchDay.substring(4);
    //int dayCounter = int.parse(_dayCounter);

    Map temp = {};
    Map oldInterests = addPlacesList[searchDay];
    Map newInterests = {
      searchInterest: [
        place.name,
        place.placeId,
        place.geometry?.location?.lat,
        place.geometry?.location?.lng
      ],
    };

    print(oldInterests);
    print(newInterests);
    temp = {
      ...oldInterests,
      ...newInterests,
    };
    print(temp);
    print("----------test--------------");
    addPlacesList[searchDay] = temp;
    print(addPlacesList);
    if (whichPlan == 'Saved'){
      DatabaseSavedPlan _databaseSavedPlan = DatabaseSavedPlan();
      _databaseSavedPlan.setupCurrentData(targetId!);
      await UserServices.updateSavedPlanTripInterests(addPlacesList);
    }
    else{
      await UserServices.updateTripInterests(addPlacesList);
    }

  }

  @override
  Widget build(BuildContext context) {
    if (whichPlan == 'Saved'){
      if(targetUser != null){
        return StreamBuilder(
            stream: DatabaseSavedPlan().streamShardPlan,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }
              if (snapshot.data == null) {
                return Text('Loading');
              }
              allTrip = UserServices.dayPlanListFromSnapshot(snapshot);
              planIndex = allTrip.indexWhere((element) => element.id == targetId);
              savedPlan = allTrip[planIndex];
              savedPlan!.tripInterests.forEach((key, value) {
                addPlacesList[key] = savedPlan!.tripInterests[key];
              });
              return _mapPage();


            });
      }
      else{
        return StreamBuilder<QuerySnapshot>(
            stream: firebase == null
                ? DatabaseSavedPlan().streamSavedPlanDataSnapshot
                : firebase?.collection('saved_plan').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }
              if (snapshot.data == null) {
                return Text('Loading');
              }
              allTrip = UserServices.dayPlanListFromSnapshot(snapshot);
              planIndex = allTrip.indexWhere((element) => element.id == targetId);
              savedPlan = allTrip[planIndex];
              savedPlan!.tripInterests.forEach((key, value) {
                addPlacesList[key] = savedPlan!.tripInterests[key];
              });

              return _mapPage();
            });
      }
    }
    else{
      return StreamBuilder<QuerySnapshot>(
          stream: firebase == null
              ? DatabaseMakePlan().streamDayPlanDataSnapshot
              : firebase?.collection('day_plan').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }
            if (snapshot.data == null) {
              return Text('Loading');
            }
            dayPlan = UserServices.getDayPlanBySnapshot(snapshot);
            dayPlan!.tripInterests.forEach((key, value) {
              addPlacesList[key] = dayPlan!.tripInterests[key];
            });

            return _mapPage();
          });

    }


  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace?.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions;
      });
      IsPred = 0;
    }
  }

  void textSearch(String value) async {
    print(value);
    var result = await googlePlace?.search.getTextSearch(value);
    if (result?.results != Null) {
      setState(() {
        places = result?.results;
        _textcontroller.clear();
        showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return _getBottompage(context);
            });
      });
      print(result?.results?.length);
      print(result?.results?[0].name);
    } else {
      print("search failed");
    }
  }

  Widget _getBottompage(BuildContext context) {
    return Container(
      //margin: const EdgeInsets.fromLTRB(0,100,0,0),
      height: 350,
      decoration: BoxDecoration(
        color: Color.fromRGBO(243, 245, 252, 1),
        boxShadow: [
          BoxShadow(
              color: Colors.grey,
              offset: Offset(1.0, 1.0),
              blurRadius: 5,
              spreadRadius: 1)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Stack(
            children: <Widget>[
              _getPlacecard(),
              Container(
                alignment: Alignment.center,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: Colors.black54,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getPlacecard() {
    return Container(
      color: Colors.grey,
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
      // color: Colors.white,
      height: 350,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
          itemCount: places?.length,
          // itemCount: 2,
          itemBuilder: (context, index) {
            return Card(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  _newMapController.animateCamera(CameraUpdate.newLatLngZoom(
                      LatLng(
                          places?[index].geometry?.location?.lat ??
                              _currentPosition.latitude,
                          places?[index].geometry?.location?.lng ??
                              _currentPosition.longitude),
                      16));
                },
                child: Container(
                  height: 200,
                  child: Stack(
                    children: [
                      Column(
                        children: <Widget>[
                          SizedBox(height: 20),
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.fromLTRB(15, 0, 5, 0),
                              child: Text(
                                // "test",
                                places?[index].name ?? "NULL",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.fromLTRB(15, 0, 5, 0),
                              child: Text(
                                // "test",
                                places?[index].formattedAddress ??
                                    "null address",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(height: 25),
                          ),
                          Expanded(
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: _getAddbutton(places?[index]),
                              )),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _mapPage(){
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: _mapPadding),
            mapType: MapType.normal,
            initialCameraPosition: _cameraPlace,
            // myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              getCurrentLocation();
              _mapController.complete(controller);
              _newMapController = controller;
              _locatePosition();
              setState(() {
                _mapPadding = 25;
              });
            },
          ),
          //search bar
          Positioned(
            top: MediaQuery.of(context).padding.top,
            right: 15,
            left: 15,
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        splashColor: Colors.grey,
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: _textcontroller,
                          cursorColor: Colors.black,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.go,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 15),
                              hintText: "Search"),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              autoCompleteSearch(value);
                            } else {
                              setState(() {
                                predictions = [];
                              });
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          icon:
                          Icon(Icons.cancel, color: Colors.grey[400]),
                          onPressed: () {
                            _textcontroller.clear();
                            setState(() {
                              predictions = [];
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          icon:
                          Icon(Icons.search, color: Colors.grey[450]),
                          onPressed: () {
                            textSearch(_textcontroller.value.text);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (_textcontroller.value.text.isNotEmpty) ...[
                  SizedBox(height: 10),
                  Container(
                    color: Colors.white,
                    height: 350,
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: ListView.builder(
                        itemCount: predictions!.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              child: Icon(
                                Icons.pin_drop,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(predictions![index].description!),
                            tileColor: Colors.white,
                            onTap: () {
                              debugPrint(predictions![index].placeId);
                              print(predictions);
                              print(
                                  predictions![index].placeId.toString());
                              _textcontroller.value = TextEditingValue(
                                  text: predictions![index].description);
                              print(predictions![index].description!);
                              //_addToAddPlacesList(predictions![index].description!);
                              //Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (places != null) ...[
            Positioned(
              bottom: 0,
              left: 3,
              right: 3,
              child: Container(
                height: 25,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey,
                        offset: Offset(1.0, 1.0),
                        blurRadius: 5,
                        spreadRadius: 1)
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return _getBottompage(context);
                        });
                  },
                  icon: Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.black54,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _getAddbutton(SearchResult? place) {
    return ElevatedButton(
      onPressed: () async {
        if (place != null) {
          _addToAddPlacesList(place);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white),
        overlayColor: MaterialStateProperty.all(Colors.blueGrey),
        side: MaterialStateProperty.all(
            BorderSide(width: 1, color: Colors.white)),
        shadowColor: MaterialStateProperty.all(Colors.grey),
        elevation: MaterialStateProperty.all(3),
        shape: MaterialStateProperty.all(StadiumBorder(
            side: BorderSide(
              style: BorderStyle.solid,
            ))),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Text(
          'Add',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
