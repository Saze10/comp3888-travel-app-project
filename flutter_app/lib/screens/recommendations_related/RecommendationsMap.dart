import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/TripRecommendations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_app/firebase_services/database_service.dart';

class RecommendationsMap extends StatefulWidget {
  final GooglePlace? googlePlace;

  const RecommendationsMap({Key? key, this.googlePlace}) : super(key: key);

  @override
  _RecommendationsMapState createState() => _RecommendationsMapState(this.googlePlace);
}

class _RecommendationsMapState extends State<RecommendationsMap> {
  final GooglePlace? googlePlace;

  _RecommendationsMapState(this.googlePlace);

  List? predictions = [];

  double _mapPadding = 0;

  Completer<GoogleMapController> _mapController = Completer();
  late GoogleMapController _newMapController;

  late Position _currentPosition;
  var geoLocator = Geolocator();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   // title: getSearchBarUI(),
      //   // title: const Text(
      //   //   'Search for Places',
      //   //   style: const TextStyle(
      //   //     color: Color.fromRGBO(20, 41, 82, 1),
      //   //     fontSize: 24.0,
      //   //   ),

      //   // ),
      //   backgroundColor: Colors.white,
      //   centerTitle: true,
      //   iconTheme: IconThemeData(
      //     color: Colors.black, //change your color here
      //   ),
      // ),
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
                        child: Icon(Icons.search, color: Colors.grey[450]),
                      ),
                    ],
                  ),
                ),
                if (predictions?.length != 0) ...[
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RecommendationsPage(userDestinationId:
                                    predictions![index].placeId.toString(),)),
                              );
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
      ),
    );
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace?.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions;
      });
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
                height: 10,
                child: Center(
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: Colors.black54,
                      size: 20,
                    ),
                  ),
                  //child: Icon(Icons.keyboard_arrow_down_outlined, color: Colors.black54,size: 30,),
                ),
              ),
            ],
          ),
          Container(
            height: 50,
            color: Colors.white,
            alignment: Alignment.center,
            //padding: const EdgeInsets.fromLTRB(0, 5, 5, 0),
            child: _getAddbutton(),
          ),
          _getPlacecard(),
        ],
      ),
    );
  }

  Widget _getPlacecard() {
    return Container(
      height: 150,
      color: Colors.grey,
      child: Column(
        children: <Widget>[
          SizedBox(height: 10),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                  child: Text(
                    '1.2KM',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            //child: Row(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(width: 20),
                    Column(
                      children: <Widget>[
                        Text(
                          'Detailed Address ',
                          style: TextStyle(
                            //fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Title of the place',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getAddbutton() {
    return ElevatedButton(
      onPressed: () {},
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
        padding: const EdgeInsets.symmetric(horizontal: 100),
        child: Text(
          'Add',
          style: TextStyle(
            color: Colors.black,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
