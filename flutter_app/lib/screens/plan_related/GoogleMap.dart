import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_app/objects/savedPlan.dart';

import 'package:google_directions_api/google_directions_api.dart'
    as direction_api;
import 'package:flutter_polyline_points/flutter_polyline_points.dart'
    as polyline_points;

const LatLng DEFAULT_SOURCE_LOCATION = LatLng(-33.8773941, 151.1036621);
// const LatLng DEST_LOCATION = LatLng(42.744521, -71.1698939);
const double CAMERA_ZOOM = 15;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;

class Mapdisplay extends StatefulWidget {
  final List<List<polyline_points.PointLatLng>>? polylinePoints;
  // final List<polyline_points.PointLatLng>? polylinePoints;
  final SavedPlan? savedPlan;

  const Mapdisplay({Key? key, this.polylinePoints, this.savedPlan})
      : super(key: key);

  @override
  _MapdisplayState createState() =>
      _MapdisplayState(this.polylinePoints, this.savedPlan);
}

class _MapdisplayState extends State<Mapdisplay> {
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController _mapController;
  Set<Marker> _markers = Set<Marker>();

  List<List<polyline_points.PointLatLng>>? polylinePoints;
  // List<polyline_points.PointLatLng>? polylinePoints;
  SavedPlan? savedPlan;
  late LatLng currentLocation;
  late LatLng destinationLocation;

  int day = 0;
  String dropdownValue = 'Day 1';
  List<String> dropdownList = [];

  @override
  void initState() {
    super.initState();
    int dropdownList_length = 0;
    savedPlan!.tripInterests.forEach((key, value) {
      print("key");
      print(key);
      print(value.length);
      if (value['origin'] != null && value['destination'] != null) {
        if (value['origin'].length > 2 && value['destination'].length > 2) {
          dropdownList_length += 1;
        }
      }
    });
    dropdownList = [
      for (var i = 1; i <= dropdownList_length; i++) 'Day ' + i.toString()
    ];
    print("polylinePoints.length");
    print(polylinePoints?.length);
    print(polylinePoints);
  }

  _MapdisplayState(this.polylinePoints, this.savedPlan);

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    _mapController = controller;
    setState(
        // _mapController = controller;
        () {
      add_marker();
    });
  }

  add_marker() {
    Map waypoints = {...savedPlan?.tripInterests[dropdownValue]};
    waypoints.remove("origin");
    waypoints.remove("destination");
    _markers.add(
      Marker(
        markerId:
            MarkerId(savedPlan?.tripInterests[dropdownValue]["origin"][1]),
        position: LatLng(savedPlan?.tripInterests[dropdownValue]["origin"][2],
            savedPlan?.tripInterests[dropdownValue]["origin"][3]),
        infoWindow: InfoWindow(
            title: 'Source',
            snippet: savedPlan?.tripInterests[dropdownValue]["origin"][0]),
      ),
    );
    _markers.add(
      Marker(
        markerId:
            MarkerId(savedPlan?.tripInterests[dropdownValue]["destination"][1]),
        position: LatLng(
            savedPlan?.tripInterests[dropdownValue]["destination"][2],
            savedPlan?.tripInterests[dropdownValue]["destination"][3]),
        infoWindow: InfoWindow(
            title: 'Destination',
            snippet: savedPlan?.tripInterests[dropdownValue]["destination"][0]),
      ),
    );

    waypoints.forEach((key, value) {
      print("waypoints key");
      print(key);
      print(value);
      if (value != null && value.length > 2) {
        _markers.add(
          Marker(
            markerId: MarkerId(value[1]),
            position: LatLng(value[2], value[3]),
            infoWindow: InfoWindow(title: 'waypoint', snippet: value[0]),
          ),
        );
      }
    });
  }

  // void setInitialLocation() {
  //   currentLocation =
  //       LatLng(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude);
  //   destinationLocation =
  //       LatLng(DEST_LOCATION.latitude, DEST_LOCATION.longitude);
  // }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition;
    if (savedPlan?.tripInterests[dropdownValue]["origin"].length <= 2) {
      initialCameraPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        target: DEFAULT_SOURCE_LOCATION,
      );
    } else {
      initialCameraPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        target: LatLng(savedPlan?.tripInterests[dropdownValue]["origin"][2],
            savedPlan?.tripInterests[dropdownValue]["origin"][3]),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Map',
          style: const TextStyle(
            color: Color.fromRGBO(20, 41, 82, 1),
            fontSize: 24.0,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        actions: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: DropdownButton(
              value: dropdownValue,
              style: const TextStyle(color: Colors.black),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                  day = int.parse(
                          dropdownValue.substring(dropdownValue.length - 1)) -
                      1;
                  print("day");
                  print(day);

                  _markers.clear();

                  _mapController.animateCamera(CameraUpdate.newLatLngZoom(
                      LatLng(
                          savedPlan?.tripInterests[dropdownValue]["origin"][2],
                          savedPlan?.tripInterests[dropdownValue]["origin"][3]),
                      16));
                  add_marker();
                });
              },
              items: dropdownList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: Container(
        child: GoogleMap(
          myLocationButtonEnabled: true,
          compassEnabled: false,
          tiltGesturesEnabled: false,
          markers: _markers,
          polylines: {
            if (polylinePoints != Null)
              if (polylinePoints?.length != 0)
                Polyline(
                  polylineId: const PolylineId('overview_polyline'),
                  color: Colors.blue,
                  width: 5,
                  points: polylinePoints![day]
                      .map((e) => LatLng(e.latitude, e.longitude))
                      .toList(),
                )
          },
          initialCameraPosition: initialCameraPosition,
          onMapCreated: _onMapCreated,
        ),
      ),
    );
  }
}
