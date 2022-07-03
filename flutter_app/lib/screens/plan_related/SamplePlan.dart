import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/screens/plan_related/SearchPlace.dart';
import 'package:flutter_app/screens/plan_related/GoogleMap.dart';
import 'package:flutter_app/screens/Plan.dart';
import 'package:flutter_app/screens/AddInterests.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_place/google_place.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_app/firebase_services/database_makePlan.dart';
import 'package:flutter_app/objects/personalPlan.dart';
import 'package:google_directions_api/google_directions_api.dart'
    as direction_api;
import 'package:flutter_polyline_points/flutter_polyline_points.dart'
    as polyline_points;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../BottomNavigation.dart';

class SamplePlan extends StatefulWidget {
  final GooglePlace? googlePlace;

  const SamplePlan({Key? key, this.googlePlace}) : super(key: key);

  @override
  _SamplePlanState createState() => _SamplePlanState(this.googlePlace);
}

class _SamplePlanState extends State<SamplePlan> {
  final GooglePlace? googlePlace;
  final _dayController = StreamController();
  final _scrollController = ScrollController();
  int _dayCounter = 0;
  direction_api.DirectionsService? directinosService;
  List<polyline_points.PointLatLng> polylinePoints = [];
  DayPlan? dayPlan;

  @override
  void initState() {
    super.initState();
    String apiKey = dotenv.env['APIKEY'] ?? "";
    if (apiKey == "") {
      print("lack of API key");
      return;
    }
    direction_api.DirectionsService.init(apiKey);
    directinosService = direction_api.DirectionsService();

    var request = direction_api.DirectionsRequest(
      origin: '42.7477863,-71.1699932',
      destination: '42.744521,-71.1698939',
      travelMode: direction_api.TravelMode.driving,
    );

    directinosService?.route(request, (direction_api.DirectionsResult response,
        direction_api.DirectionsStatus? status) {
      if (status == direction_api.DirectionsStatus.ok) {
        polylinePoints = polyline_points.PolylinePoints()
            .decodePolyline(response.routes?[0].overviewPolyline?.points ?? "");
        print(polylinePoints);
      } else {
        print("direction request fail");
      }
    });
  }

  _SamplePlanState(this.googlePlace);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Sample Plan',
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
        actions: [
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Mapdisplay(),
                ),
              );
            },
            color: Colors.black,
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareTrip,
            color: Colors.black,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('/day_plan')
            .doc('sample')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text("Loading");
          }
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          var sampleDoc = snapshot.data;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  //Text('${sampleDoc!["title"]}'),
                  _titleImage(),
                  SizedBox(height: 10),
                  _dayList(),
                ],
              ),
            ),
          );
        },
      ),
      /*
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              _titleImage(),
              SizedBox(height: 10),
              _dayList(),
            ],
          ),
        ),
      ),


           */
    );
  }

  Widget _dayListPage() {
    return Scrollbar(
      isAlwaysShown: true,
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
        child: ListView.separated(
          controller: _scrollController,
          itemCount: _dayCounter + 2,
          separatorBuilder: (context, index) {
            return SizedBox(height: 10);
          },
          itemBuilder: (context, index) {
            if (index == 0) {
              return _titleImage();
            }
            if (index == _dayCounter + 1) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _getEffectivebutton(
                      "Save to plan",
                      'plan page',
                    ),
                  ],
                ),
              );
            }
            //currentDay = ;
            return _everydayPlan('Day $index', '', '');
          },
        ),
      ),
    );
  }

  Widget _titleImage() {
    return Container(
      height: 153,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey,
        image: DecorationImage(
          image: AssetImage('images/sydney.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            //margin: EdgeInsets.fromLTRB(0,2,0,120),
            height: 22,
            //width:10,
            //color:Colors.blue,
            alignment: Alignment.center,
            child: Text(
              'Trip to Sydney',
              style: TextStyle(
                color: Color.fromRGBO(39, 78, 114, 1),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(8, 100, 8, 0),
                height: 30,
                //width:120,
                //color:Colors.blue,
                alignment: Alignment.centerLeft,
                child: Text(
                  '3PLACES  1PEOPLE',
                  style: TextStyle(
                    color: Color.fromRGBO(39, 78, 114, 1),
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(8, 100, 8, 0),
                alignment: Alignment.centerRight,
                height: 30,
                //width: 220,
                //color:Colors.blue,
                child: IconButton(
                  icon: Icon(Icons.date_range),
                  color: Colors.white,
                  alignment: Alignment.center,
                  onPressed: () {},
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _dayList() {
    return Column(
      children: <Widget>[
        _everydayPlan('Day 1', 'Central Park', 'ORIGIN'),
        SizedBox(height: 10),
        _everydayPlan('Day 2', 'USYD', 'SPOT'),
        SizedBox(height: 10),
        _everydayPlan('Day 3', 'OperaHouse', 'DESTINATION'),
        SizedBox(
          height: 10,
        ),
        _getEffectivebutton(
            'Save to plan',
            SamplePlan(
              googlePlace: googlePlace,
            )),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget _everydayPlan(String day, String place, String where) {
    return Container(
      height: 200,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color.fromRGBO(243, 245, 252, 1),
        boxShadow: [
          BoxShadow(
              color: Colors.grey,
              offset: Offset(1.0, 1.0),
              blurRadius: 0.5,
              spreadRadius: 0.1)
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(vertical: 6, horizontal: 15),
            alignment: Alignment.centerLeft,
            child: Text(
              day,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(
            color: Color.fromRGBO(39, 78, 114, 1),
            height: 10,
            thickness: 2,
            indent: 10,
            endIndent: 10,
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            alignment: Alignment.centerLeft,
            child: Text(
              where,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 1,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  //margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  height: 50,
                  width: 320,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: new Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey,
                          offset: Offset(1.0, 1.0),
                          blurRadius: 0.5,
                          spreadRadius: 0.1)
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(width: 5),
                      _getTextbutton(place),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 2),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.more_horiz,
                  size: 40,
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
          SizedBox(
            height: 11,
          ),
          _getEffectivebutton(
              'Add',
              AddInterests(
                currentDay: day,
              )),
        ],
      ),
    );
  }

  Widget _getTextbutton(String word) {
    return TextButton(
      onPressed: () {
        Fluttertoast.showToast(
          msg: 'Please Login first!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BottomNavigatorBar(data: 3, isLogin: false)),
        );
      },
      style: ButtonStyle(
        //backgroundColor: MaterialStateProperty.all(Colors.white),
        overlayColor:
            MaterialStateProperty.all(Color.fromRGBO(217, 230, 242, 80)),
        //side: MaterialStateProperty.all(BorderSide(width: 1,color: Colors.grey)),
        //shadowColor: MaterialStateProperty.all(Colors.grey),
        //elevation: MaterialStateProperty.all(3),
        shape: MaterialStateProperty.all(StadiumBorder(
          side: BorderSide.none,
        )),
      ),
      child: Text(
        word,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _getEffectivebutton(String word, var route) {
    return ElevatedButton(
      onPressed: () {
        Fluttertoast.showToast(
          msg: 'Please Login first!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        if (word == 'Save to plan') {

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    BottomNavigatorBar(data: 3, isLogin: false)),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BottomNavigatorBar(data: 3, isLogin: false)),
          );
        }
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white),
        overlayColor: MaterialStateProperty.all(Colors.blueGrey),
        side:
            MaterialStateProperty.all(BorderSide(width: 1, color: Colors.grey)),
        shadowColor: MaterialStateProperty.all(Colors.grey),
        elevation: MaterialStateProperty.all(3),
        shape: MaterialStateProperty.all(StadiumBorder(
            side: BorderSide(
          style: BorderStyle.solid,
        ))),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        child: Text(
          word,
          style: TextStyle(
            color: Colors.black,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  //sample plan page share trip
  void _shareTrip() {}
}
