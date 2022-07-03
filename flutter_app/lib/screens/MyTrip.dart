import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/firebase_services/database_savedPlan.dart';
import 'package:flutter_app/objects/savedPlan.dart';
import 'package:flutter_app/screens/display_plan_related/DisplayTrip.dart';
import 'package:flutter_app/screens/plan_related/SamplePlan.dart';
import 'package:flutter_app/firebase_services/database_makePlan.dart';
import 'package:flutter_app/objects/personalPlan.dart';
import 'package:flutter_app/objects/user.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_place/google_place.dart';

class MyTrip extends StatefulWidget {
  final LocalUser? user;
  final GooglePlace? googlePlace;
  const MyTrip({Key? key, this.googlePlace, required this.user}) : super(key: key);

  @override
  _MyTripState createState() => _MyTripState();
}

class _MyTripState extends State<MyTrip> {
  LocalUser? user;
  GooglePlace? googlePlace;
  List tripsData = [];

  @override
  void initState(){
    super.initState();
    user = widget.user;
    String apiKey = dotenv.env['APIKEY'] ?? "";
    if (apiKey == "") {
      print("lack of API key");
      return;
    }
    googlePlace = GooglePlace(apiKey);
  }

  Widget getCover(SavedPlan key){
    return Container(
      height: ScreenUtil().setHeight(380),
      child: Stack(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 20/9,
            child: Image.network(
              "https://assets.atdw-online.com.au/images/082abec166a817adfae646daff53ad70.jpeg?rect=0%2C0%2C2048%2C1536&w=800&h=800&rot=360",
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: ListTile(
              title: Text(key.title,
                  style: TextStyle(color: Colors.white)),
              subtitle: Text("${key.tripDuration}",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget getInfo(SavedPlan key){
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: ListTile(
            contentPadding: EdgeInsets.fromLTRB(15, 0, 90, 0),
            visualDensity: VisualDensity(horizontal: 0),
            leading: CircleAvatar(
              backgroundImage: user!.photoURL == null
                ? null
                : NetworkImage("${user!.photoURL}"),
              backgroundColor: Colors.grey,
            ),
            title: Text("${user!.name}", style: TextStyle(fontSize: 12)),
            trailing: user!.gender == "female" ? Icon(Icons.female, color: Colors.pink)
                      : user!.gender == "male"
                      ? Icon(Icons.male, color: Colors.blue)
                      : Icon(Icons.security, color: Colors.black),
          ),
        ),
        Expanded(
            flex: 1,
            child: Text("${key.startDate}")),
      ],
    );
  }

  Widget setContentFormat(SavedPlan key) {
    return Column(
      children: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DisplayTrip(googlePlace: googlePlace, targetId: key.id)),
            );
          },
          child: getCover(key)
        ),
        Container(
          height: ScreenUtil().setHeight(140),
          child: getInfo(key)
        ),
      ],
    );
  }

  List<Widget> getData(){
    List<Widget> data = tripsData.map((value) {
      return setContentFormat(value);
    }).toList();
    data.add(SizedBox(height: 15.0));
    data.add(Text(
      '---Ends---',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color.fromRGBO(20, 41, 82, 1),
        fontWeight: FontWeight.bold,
        fontSize: 24.0,
      ),
    ));
    return data;
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream : DatabaseSavedPlan().streamUserDataSnapshot,
      builder:  (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.data == null){
          return Text("Loading");
        }
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return Text("Loading");
        // }
        tripsData = UserServices.dayPlanListFromSnapshot(snapshot);
        return tripsData.isNotEmpty ? ListView(children: getData())
            : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'No Schedule',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color.fromRGBO(20, 41, 82, 1),
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              )
            ]
        );
      }
    );
  }
}
