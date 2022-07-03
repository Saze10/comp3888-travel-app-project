import 'package:flutter/material.dart';
import 'package:flutter_app/objects/savedPlan.dart';
import 'package:flutter_app/screens/models/InterestsCell.dart' as allInterests;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/firebase_services/database_service.dart';
import 'package:flutter_app/objects/user.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_app/widgets/button_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_app/firebase_services/database_makePlan.dart';
import 'package:flutter_app/firebase_services/database_savedPlan.dart';
import 'package:flutter_app/objects/personalPlan.dart';
import 'package:flutter_app/screens/MakeTrip.dart' as makeTrip;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ChangeInterests extends StatefulWidget {
  String currentDay;
  String targetId;
  final String? targetUser;
  ChangeInterests({Key? key, this.firebase, required this.currentDay, required this.targetId, this.targetUser})
      : super(key: key);
  var firebase;

  @override
  _ChangeInterestsState createState() => _ChangeInterestsState();
}

class _ChangeInterestsState extends State<ChangeInterests> {
  User? user;
  DayPlan? dayPlan;
  SavedPlan? savedPlan;
  Map interests = {};
  String? targetUser;

  Map selections = {
    "origin": false,
    "destination": false,
    "accounting": false,
    "airport": false,
    "amusement_park": false,
    "aquarium": false,
    "art_gallery": false,
    "atm": false,
    "bakery": false,
    "bank": false,
    "bar": false,
    "beauty_salon": false,
    "bicycle_store": false,
    "book_store": false,
    "bowling_alley": false,
    "bus_station": false,
    "cafe": false,
    "campground": false,
    "car_dealer": false,
    "car_rental": false,
    "car_repair": false,
    "car_wash": false,
    "casino": false,
    "cemetery": false,
    "church": false,
    "city_hall": false,
    "clothing_store": false,
    "convenience_store": false,
    "courthouse": false,
    "dentist": false,
    "department_store": false,
    "doctor": false,
    "drugstore": false,
    "electrician": false,
    "electronics_store": false,
    "embassy": false,
    "fire_station": false,
    "florist": false,
    "funeral_home": false,
    "furniture_store": false,
    "gas_station": false,
    "gym": false,
    "hair_care": false,
    "hardware_store": false,
    "hindu_temple": false,
    "home_goods_store": false,
    "hospital": false,
    "insurance_agency": false,
    "jewelry_store": false,
    "laundry": false,
    "lawyer": false,
    "library": false,
    "light_rail_station": false,
    "liquor_store": false,
    "local_government_office": false,
    "locksmith": false,
    "lodging": false,
    "meal_delivery": false,
    "meal_takeaway": false,
    "mosque": false,
    "movie_rental": false,
    "movie_theater": false,
    "moving_company": false,
    "museum": false,
    "night_club": false,
    "painter": false,
    "park": false,
    "parking": false,
    "pet_store": false,
    "pharmacy": false,
    "physiotherapist": false,
    "plumber": false,
    "police": false,
    "post_office": false,
    "primary_school": false,
    "real_estate_agency": false,
    "restaurant": false,
    "roofing_contractor": false,
    "rv_park": false,
    "school": false,
    "secondary_school": false,
    "shoe_store": false,
    "shopping_mall": false,
    "spa": false,
    "stadium": false,
    "storage": false,
    "store": false,
    "subway_station": false,
    "supermarket": false,
    "synagogue": false,
    "taxi_stand": false,
    "tourist_attraction": false,
    "train_station": false,
    "transit_station": false,
    "travel_agency": false,
    "university": false,
    "veterinary_care": false,
    "zoo": false,
  };

  int ifFirst = 0;

  //Map<String, List<dynamic>?> interests = {"Accommodation": [], "Food": []};
  bool ableToGetBack = true;
  var firebase;
  late String currentDay;
  late String targetId;
  List allTrip = [];
  int planIndex = 0;

  @override
  void initState() {
    super.initState();
    firebase = widget.firebase;
    currentDay = widget.currentDay;
    targetId = widget.targetId;
    if(widget.targetUser != null){
      targetUser = widget.targetUser!;
    }
    else{
      targetUser = null;
    }
  }


  void _setSelected(String selection) {
    setState(() {
      selections[selection] = !selections[selection];
    });
  }

  void _resetInterests() {
    ifFirst++;
    //print(b);
    String _dayCounter = currentDay.substring(4);
    int dayCounter = int.parse(_dayCounter);
    interests.clear();

    savedPlan!.tripInterests.forEach((key, value) {
      interests[key] = savedPlan!.tripInterests[key];
    });
  }

  void _addToInterests(String interest) {
    String _dayCounter = currentDay.substring(4);
    int dayCounter = int.parse(_dayCounter);
    //print("check!!!!!!!!!!!!!!!!!!!!!!!!!");
    //print(interests);
    Map temp = {};
    Map oldInterests = interests["Day $_dayCounter"];


    Map newInterests = {
      interest: [""]
    };


    temp = {
      ...oldInterests,
      ...newInterests,
    };
    interests["Day $_dayCounter"] = temp;

    print(interests);
    //dayPlan!.tripInterests["DAY$day"].add(interest);
  }
  void _deleteFromInterests(String interest) {
    String _dayCounter = currentDay.substring(4);
    int dayCounter = int.parse(_dayCounter);
    Map temp = {};

    Map oldInterests = interests["Day $_dayCounter"];

    oldInterests.forEach((key, value) {
      if (key != interest) {
        temp[key] = value;
      }
    });
    interests["Day $_dayCounter"] = temp;
  }

  @override
  Widget build(BuildContext context) {
    // Using Stream Builder instead of global Stream Provider to avoid getting a null user id before user login
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
            if (savedPlan == null) {
              print("null");
            }
            if (ifFirst == 0) {
              _resetInterests();
            }
            return _interestMain();
          });
    }
    else{

    }
    return StreamBuilder<QuerySnapshot>(
        stream: firebase == null
            ? DatabaseSavedPlan().streamSavedPlanDataSnapshot
            : firebase?.collection('saved_plan').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data == null) {
            return Text('${snapshot.error}');
          }
          if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          allTrip = UserServices.dayPlanListFromSnapshot(snapshot);
          planIndex = allTrip.indexWhere((element) => element.id == targetId);
          savedPlan = allTrip[planIndex];
          if (savedPlan == null) {
            print("null");
          }
          if (ifFirst == 0) {
            _resetInterests();
          }
          return _interestMain();


        });
  }

  Widget _interestMain(){
    return Scaffold(
      appBar: getAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              _getInterests(),
              _clickableButton("Submit"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getInterests() {
    return Container(
      height: ScreenUtil().setHeight(1350),
      child: ListView(
        children: <Widget>[
          SizedBox(height: 25),
          ElevatedButtonTheme(
            data: ElevatedButtonThemeData(
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all(
                  TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                ),
              ),
            ),
            child: Wrap(
              spacing: 8.0, // 主轴(水平)方向间距
              runSpacing: 8.0, // 纵轴（垂直）方向间距
              alignment: WrapAlignment.spaceAround,
              children: <Widget>[
                getButton("origin"),
                getButton("destination"),
                getButton("accounting"),
                getButton("airport"),
                getButton("amusement_park"),
                getButton("aquarium"),
                getButton("art_gallery"),
                getButton("atm"),
                getButton("bakery"),
                getButton("bank"),
                getButton("bar"),
                getButton("beauty_salon"),
                getButton("bicycle_store"),
                getButton("book_store"),
                getButton("bowling_alley"),
                getButton("bus_station"),
                getButton("cafe"),
                getButton("campground"),
                getButton("car_dealer"),
                getButton("car_rental"),
                getButton("car_repair"),
                getButton("car_wash"),
                getButton("casino"),
                getButton("cemetery"),
                getButton("church"),
                getButton("city_hall"),
                getButton("clothing_store"),
                getButton("convenience_store"),
                getButton("courthouse"),
                getButton("dentist"),
                getButton("department_store"),
                getButton("doctor"),
                getButton("drugstore"),
                getButton("electrician"),
                getButton("electronics_store"),
                getButton("embassy"),
                getButton("fire_station"),
                getButton("florist"),
                getButton("funeral_home"),
                getButton("furniture_store"),
                getButton("gas_station"),
                getButton("gym"),
                getButton("hair_care"),
                getButton("hardware_store"),
                getButton("hindu_temple"),
                getButton("home_goods_store"),
                getButton("hospital"),
                getButton("insurance_agency"),
                getButton("jewelry_store"),
                getButton("laundry"),
                getButton("lawyer"),
                getButton("library"),
                getButton("light_rail_station"),
                getButton("liquor_store"),
                getButton("local_government_office"),
                getButton("locksmith"),
                getButton("lodging"),
                getButton("meal_delivery"),
                getButton("meal_takeaway"),
                getButton("mosque"),
                getButton("movie_rental"),
                getButton("movie_theater"),
                getButton("moving_company"),
                getButton("museum"),
                getButton("night_club"),
                getButton("painter"),
                getButton("park"),
                getButton("parking"),
                getButton("pet_store"),
                getButton("pharmacy"),
                getButton("physiotherapist"),
                getButton("plumber"),
                getButton("police"),
                getButton("post_office"),
                getButton("primary_school"),
                getButton("real_estate_agency"),
                getButton("restaurant"),
                getButton("roofing_contractor"),
                getButton("rv_park"),
                getButton("school"),
                getButton("secondary_school"),
                getButton("shoe_store"),
                getButton("shopping_mall"),
                getButton("spa"),
                getButton("stadium"),
                getButton("storage"),
                getButton("store"),
                getButton("subway_station"),
                getButton("supermarket"),
                getButton("synagogue"),
                getButton("taxi_stand"),
                getButton("tourist_attraction"),
                getButton("train_station"),
                getButton("transit_station"),
                getButton("travel_agency"),
                getButton("university"),
                getButton("veterinary_care"),
                getButton("zoo"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getButton(String text) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setHeight(5)),
      height: ScreenUtil().setHeight(320),
      width: ScreenUtil().setWidth(450),
      child: ElevatedButton(
        onPressed: () {
          _setSelected(text);
          if (selections[text] == true) {
            _addToInterests(text);
          }
          if(selections[text] == false){
            _deleteFromInterests(text);
          }
        },
        child: Padding(
          padding: EdgeInsets.all(ScreenUtil().setHeight(5)),
          child: Text(text),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            return selections[text] ? Colors.blue[200] : Colors.blue;
          }),
        ),
      ),
    );
  }

  Widget _clickableButton(String name) {
    return ElevatedButton(
      onPressed: () async {
        if (name == "Submit") {
          Map _tempMap = {};
          //int _tempCounter = 1;
          interests.forEach((key, value) {
            //print(key);
            //print(value);
            _tempMap[key] = value;
            //_tempCounter ++;
          });
          ableToGetBack = false;
          //print("!！！！！！！！！！！here I am!!!!!!!!!");
          //print(_tempMap);
          DatabaseSavedPlan _databaseSavedPlan = DatabaseSavedPlan();
          _databaseSavedPlan.setupCurrentData(targetId);
          await UserServices.updateSavedPlanTripInterests(_tempMap);
          interests.clear;
          interests.addAll(_tempMap);
          _resetInterests();
          Fluttertoast.showToast(
            msg: 'Interests Submitted',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
          ableToGetBack = true;
        }
        Navigator.pop(context);
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
          name,
          style: TextStyle(
            color: Colors.black,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  AppBar getAppBar() {
    return AppBar(
      title: const Text(
        'Add Interests',
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
          if (ableToGetBack) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}
