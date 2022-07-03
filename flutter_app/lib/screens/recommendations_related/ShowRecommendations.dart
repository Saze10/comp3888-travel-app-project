import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_directions_api/google_directions_api.dart'
    as direction_api;
import 'package:flutter_polyline_points/flutter_polyline_points.dart'
    as polyline_points;
import 'package:flutter_dotenv/flutter_dotenv.dart';

const LatLng SOURCE_LOCATION = LatLng(42.7477863, -71.1699932);
const LatLng DEST_LOCATION = LatLng(42.744521, -71.1698939);
const double CAMERA_ZOOM = 15;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;

class ShowRecommendations extends StatefulWidget {
  final String? recommendations;
  final List? trip;
  final List<List<polyline_points.PointLatLng>>? polylinePoints;

  const ShowRecommendations(
      {Key? key, this.recommendations, this.trip, this.polylinePoints})
      : super(key: key);

  @override
  _ShowRecommendationsState createState() => _ShowRecommendationsState(
      this.recommendations, this.trip, this.polylinePoints);
}

class _ShowRecommendationsState extends State<ShowRecommendations> {
  String apiKey = dotenv.env['APIKEY'] ?? "";
  List<List<polyline_points.PointLatLng>>? polylinePoints;
  late LatLng currentLocation;
  late LatLng destinationLocation;
  LatLng? originLocation;
  LatLng? destLocation;
  String? recommendations;
  List? trip;
  direction_api.DirectionsService? directionService;
  Set<Marker> _markers = Set<Marker>();
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController _mapController;

  _ShowRecommendationsState(
      this.recommendations, this.trip, this.polylinePoints);

  add_marker() {
      List waypoints = trip!.sublist(1, trip!.length-1);
      _markers.add(
        Marker(
          markerId:
          MarkerId("origin"),
          position: LatLng(trip![0][0],
              trip![0][1]),
          infoWindow: InfoWindow(
              title: 'Origin',
              snippet: "origin"),
        ),
      );
      _markers.add(
        Marker(
          markerId:
          MarkerId("destination"),
          position: LatLng(
              trip!.last[0],
              trip!.last[1]),
          infoWindow: InfoWindow(
              title: 'Destination',
              snippet: "dest"),
        ),
      );

      for(var i = 0; i < waypoints.length; i++) {
        _markers.add(
          Marker(
            markerId: MarkerId("trip_waypoint_$i"),
            position: LatLng(waypoints[i][0], waypoints[i][1]),
            infoWindow: InfoWindow(
                title: 'Waypoint $i',
                snippet: "waypoint_$i"),
          ),
        );
      }
    }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    _mapController = controller;
    setState(
      // _mapController = controller;
            () {
          add_marker();
        });
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
        zoom: CAMERA_ZOOM, target: LatLng(trip![0][0], trip![0][1]));
    print("polyline length :)");
    print(polylinePoints!.length);
    print(polylinePoints);
    add_marker();

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
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: ListView(
              children: <Widget>[
                SizedBox(
                    height: 350,
                    child: GoogleMap(
                      myLocationButtonEnabled: true,
                      compassEnabled: false,
                      tiltGesturesEnabled: false,
                      markers: _markers,
                      polylines: {
                        if (polylinePoints != Null)
                          Polyline(
                            polylineId: const PolylineId('overview_polyline'),
                            color: Colors.blue,
                            width: 5,
                            points: polylinePoints![0]
                                .map((e) => LatLng(e.latitude, e.longitude))
                                .toList(),
                          )
                      },
                      initialCameraPosition: initialCameraPosition,
                      onMapCreated: _onMapCreated,
                      gestureRecognizers: Set()
                        ..add(Factory<EagerGestureRecognizer>(
                            () => EagerGestureRecognizer())),
                    )),
                Text(
                  'Trip with recommendations\n',
                  style: const TextStyle(
                    color: Color.fromRGBO(40, 40, 82, 1),
                    fontSize: 24.0,
                  ),
                ),
                Text(
                  recommendations!,
                  style: const TextStyle(
                    color: Color.fromRGBO(40, 40, 82, 1),
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
