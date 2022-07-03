import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/screens/BottomNavigation.dart';
import 'package:flutter_app/screens/display_plan_related/DisplayTrip.dart';
import 'package:flutter_app/screens/Login.dart';
import 'package:flutter_app/screens/MakeTrip.dart';
import 'package:google_place/google_place.dart';
import 'package:flutter_app/firebase_services/database_savedPlan.dart';
import 'package:flutter_app/firebase_services/database_savedPlan.dart';
import 'package:flutter_app/objects/savedPlan.dart';
import 'package:flutter_app/screens/plan_related/SamplePlan.dart';
import 'package:flutter_app/firebase_services/database_makePlan.dart';
import 'package:flutter_app/objects/personalPlan.dart';
import 'package:flutter_app/objects/user.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_app/objects/user.dart';
import 'package:flutter_app/objects/personalPlan.dart';
import 'package:intl/intl.dart';

class Plan extends StatefulWidget {
  final GooglePlace? googlePlace;

  const Plan({Key? key, this.googlePlace}) : super(key: key);
  @override
  _PlanState createState() => _PlanState(this.googlePlace);
}

class _PlanState extends State<Plan> {
  final GooglePlace? googlePlace;
  bool isLogin = false;

  User? user;
  List tripsData = [];


  _PlanState(this.googlePlace);
  List id = [];

  @override
  void initState() {
    super.initState();
    this.isLogin = UserServices.getUserLoginState();
    user = UserServices.getUserInfo();


  }

  @override
  Widget build(BuildContext context) {
    if(isLogin == false){
      return Scaffold(
        key: Key('Plan-page'),
        appBar: AppBar(
          title: const Text(
            'Plans',
            style: const TextStyle(
              color: Color.fromRGBO(20, 41, 82, 1),
              fontSize: 24.0,
            ),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                _sampleImageButton(),
                SizedBox(height: 25),
                _addPlanButton(),
              ],
            ),
          ),
        ),
      );
    }
    return StreamBuilder(
      stream : DatabaseSavedPlan().streamUserDataSnapshot,
      builder:  (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.data == null){
          return Text("Loading");
        }
        tripsData = UserServices.dayPlanListFromSnapshot(snapshot);
        //print(tripsData);
        id = UserServices.getSavedPlanIdList(snapshot);
        print(id);

        return Scaffold(
          key: Key('Plan-page'),
          appBar: AppBar(
            title: const Text(
              'Plans',
              style: const TextStyle(
                color: Color.fromRGBO(20, 41, 82, 1),
                fontSize: 24.0,
              ),
            ),
            backgroundColor: Colors.white,
            centerTitle: true,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child:
                  ListView(children: getData()),

            ),
          ),
        );

      }
    );
  }

  //Detailed Plan page button
  Widget _imageButton(SavedPlan key) {
    return Container(
      //margin: EdgeInsets.fromLTRB(10, 10, 15, 15),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DisplayTrip(googlePlace: googlePlace, targetId:key.id)),
          );
        },
        child: Stack(
          children: [
            Container(
              width: 320,
              height: 180,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                //color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(15),
                //border: new Border.all(color:Colors.blueGrey, width:4,),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey,
                      offset: Offset(4.0, 4.0),
                      blurRadius: 4.0,
                      spreadRadius: 0.2)
                ],

                image: DecorationImage(
                  image: AssetImage('images/head.jpg'),
                  fit: BoxFit.cover,
                ),

                //color: Color.fromRGBO(Random().nextInt(256), Random().nextInt(256),Random().nextInt(256), 1),
              ),
              child: Container(
                //padding: const EdgeInsets.all(20.0),
                margin: EdgeInsets.fromLTRB(0, 145, 0, 0),
                alignment: Alignment.center,
                width: 320,
                height: 35,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(28, 52, 74, 80),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Text(
                  'Trip to ${key.title}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ),
            Positioned(
              right: 0,
              //bottom: 0,
              child: IconButton(
                onPressed: () async {
                  //_dayCounter means the maximum page number
                  //_currentDay means the currentpage number
                  await FirebaseFirestore.instance
                      .collection('saved_plan')
                      .doc(key.id)
                      .delete()
                      .then((_) {
                    print("wowowowow---------------success!");
                  });
                },
                icon: Icon(Icons.delete_forever_outlined, color: Colors.white,size: 30,),

              ),
            ),

          ],
        ),

        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          side: MaterialStateProperty.all(
              BorderSide(width: 1, color: Color(0xffffffff))),
          elevation: MaterialStateProperty.all(0),
        ),
      ),
    );
  }
  Widget _sampleImageButton() {
    return Container(
      //margin: EdgeInsets.fromLTRB(10, 10, 15, 15),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SamplePlan(googlePlace: googlePlace)),
          );

        },
        child: Container(
          width: 320,
          height: 180,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            //color: Colors.blueGrey,
            borderRadius: BorderRadius.circular(15),
            //border: new Border.all(color:Colors.blueGrey, width:4,),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey,
                  offset: Offset(4.0, 4.0),
                  blurRadius: 4.0,
                  spreadRadius: 0.2)
            ],
            image: DecorationImage(
              image: AssetImage('images/sydney.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            //padding: const EdgeInsets.all(20.0),
            margin: EdgeInsets.fromLTRB(0, 145, 0, 0),
            alignment: Alignment.center,
            width: 320,
            height: 35,
            decoration: BoxDecoration(
              color: Color.fromRGBO(28, 52, 74, 80),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Text(
              'Sample Plan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          side: MaterialStateProperty.all(
              BorderSide(width: 1, color: Color(0xffffffff))),
          elevation: MaterialStateProperty.all(0),
        ),
      ),
    );
  }
  //Add new plan Button
  Widget _addPlanButton() {
    return Container(
      height:40,
      child: ElevatedButton.icon(
        onPressed: () {
          if (isLogin) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MakeTrip()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      BottomNavigatorBar(data: 3, isLogin: false)),
            );
          }
        },
        icon: Icon(Icons.add),
        label: Text('Add a new trip plan!'),
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all(
            TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: MaterialStateProperty.all(Colors.white),
          foregroundColor: MaterialStateProperty.all(Colors.blueGrey),
          overlayColor: MaterialStateProperty.all(Colors.grey),
          elevation: MaterialStateProperty.all(7),
          shape: MaterialStateProperty.all(
            StadiumBorder(
              side: BorderSide(
                style: BorderStyle.solid,
                color: Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }
  List<Widget> getData(){
    List<Widget> data = tripsData.map((value) {
      return setContentFormat(value);
    }).toList();
    data.insert(0,_addPlanButton());
    data.insert(1, SizedBox(height: 15.0));
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
  Widget setContentFormat(SavedPlan key) {
    return Column(
      children: <Widget>[
        TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SamplePlan()),
              );
            },
            child: _imageButton(key)
        ),
        Container(
            height: ScreenUtil().setHeight(10),
            //child: _addPlanButton()
        ),
      ],
    );
  }
}
