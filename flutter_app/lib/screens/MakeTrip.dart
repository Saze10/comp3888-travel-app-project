import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/InvitedFriend.dart';
import 'package:flutter_app/screens/plan_related/SearchPlace.dart';
import 'package:flutter_app/screens/plan_related/SamplePlan.dart';
import 'package:flutter_app/screens/models/InterestsCell.dart' as allInterests;
import 'package:flutter_app/screens/Calendar.dart';
import 'package:flutter_app/screens/AddInterests.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_app/screens/models/ListofInterests.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_place/google_place.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/firebase_services/database_service.dart';
import 'package:flutter_app/objects/user.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_app/firebase_services/database_makePlan.dart';
import 'package:flutter_app/firebase_services/database_savedPlan.dart';
import 'package:flutter_app/objects/personalPlan.dart';
import 'package:flutter_app/objects/savedPlan.dart';
import 'package:flutter_app/widgets/white_text_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/objects/user.dart';
import 'package:flutter_app/screens/recommendations_related/RecommendationsMap.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'display_plan_related/DisplayTrip.dart';

class MakeTrip extends StatefulWidget {
  final GooglePlace? googlePlace;
  final FirebaseFirestore? firebase;

  const MakeTrip({Key? key, this.googlePlace, this.firebase}) : super(key: key);

  @override
  _MakeTripState createState() => _MakeTripState(this.googlePlace);
}

class _MakeTripState extends State<MakeTrip> {
  GooglePlace? googlePlace;
  FirebaseFirestore? firebase;
  late int num;
  User? user = UserServices.getUserInfo();
  LocalUser? localUser;
  DayPlan? dayPlan;
  SavedPlan? savedPlan;

  //Map<String, List<dynamic>> tripInterests = {'day1':[]};
  //List dailyInterests = ['Origin'];
  bool isLogin = false;
  bool ableToGetBack = true;
  bool titleSetted = false;

  String startDate = '';
  String tripId = '';
  //bool newDay = true;
  //late String currentDay;

  _MakeTripState(this.googlePlace);

  int _dayCounter = 1;

  late String title;

  Map addDayList = {};

  //Map<String , List<dynamic>?> addDayList = {};

  final _dayController = StreamController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    firebase = widget.firebase;
    user = UserServices.getUserInfo();
    String apiKey = dotenv.env['APIKEY'] ?? "";
    if (apiKey == "") {
      print("lack of API key");
      return;
    }
    googlePlace = GooglePlace(apiKey);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: firebase == null
            ? DatabaseMakePlan().streamDayPlanDataSnapshot
            : firebase?.collection('day_plan').snapshots(),
        //stream: firebase == null ? DatabaseService().streamUserDataSnapshot :  firebase?.collection('user_data').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.data == null) {
            return Text('Loading');
          }

          dayPlan = UserServices.getDayPlanBySnapshot(snapshot);

          startDate = dayPlan!.startDate;
          dayPlan!.tripInterests.forEach((key, value) {
            addDayList[key] = dayPlan!.tripInterests[key];
          });

          return Scaffold(
            appBar: AppBar(
              title: GestureDetector(
                onTap: () {
                  _scrollController.animateTo(-10,
                      duration: Duration(milliseconds: 100),
                      curve: Curves.linear);
                },
                child: Text(
                  'Make a Plan',
                  style: const TextStyle(
                    color: Color.fromRGBO(20, 41, 82, 1),
                    fontSize: 24.0,
                  ),
                ),
              ),
              backgroundColor: Colors.white,
              centerTitle: true,
              iconTheme: IconThemeData(
                color: Colors.black, //change your color here
              ),
            ),
            body: Stack(
              children: [
                StreamBuilder(
                  stream: _dayController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (_dayCounter > 10) {
                        showAlterDialog();
                      }

                      return _dayListPage();
                    }
                    return _dayListPage();
                  },
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    onPressed: () {
                      _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: Duration(milliseconds: 100),
                          curve: Curves.linear);
                    },
                    tooltip: 'Press to bottom',
                    icon: Icon(
                      Icons.vertical_align_bottom,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
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
                    _clickableButton(
                      "ADD DAY",
                      MakeTrip(googlePlace: googlePlace),
                    ),
                    //SizedBox(height: 5),
                    _clickableButton(
                      "DONE",
                      //SamplePlan(googlePlace:googlePlace),
                      DisplayTrip(googlePlace: googlePlace, targetId: tripId),
                    ),
                  ],
                ),
              );
            }
            //currentDay = ;
            //if (index == _dayCounter)
            return _everydayInterests('Day $index');
          },
        ),
      ),
    );
  }

  Widget _titleImage() {
    num = getPlaceNum();
    return Container(
      height: 200,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        image: DecorationImage(
            fit: BoxFit.fill,
            image: NetworkImage(
              "https://assets.atdw-online.com.au/images/082abec166a817adfae646daff53ad70.jpeg?rect=0%2C0%2C2048%2C1536&w=800&h=800&rot=360",
            )),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey,
      ),
      child: Column(
        children: <Widget>[
          Container(
            //margin: EdgeInsets.fromLTRB(0,2,0,120),
            height: 20,
            //width:10,
            //color:Colors.blue,
            alignment: Alignment.center,
            /*
            child: Text(

              '${dayPlan!.title}',
              style: TextStyle(
                color: Color.fromRGBO(39, 78, 114, 1),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

             */
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
                  '${num} PLACES  ${(dayPlan!.friendsID).length + 1} PEOPLE',
                  style: TextStyle(
                    color: Colors.white,
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Calendar()),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              child: WhiteTextWidget(
                text: 'Please enter the title',
                onChanged: (value) {
                  titleSetted = true;
                  setState(() => title = value);
                },
              ),
            ),
            Container(
              //margin: EdgeInsets.fromLTRB(8, 100, 8, 0),
              height: 25,
              //width:120,
              //color:Colors.blue,
              alignment: FractionalOffset(0.2, 0.6),
              child: Text(
                '$startDate',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  //daily interests
  Widget _everydayInterests(String day) {
    String currentDay = day;
    int _currentDay = int.parse(currentDay.substring(4));
    List InterestList = _formInterestList(day, addDayList);

    return Container(
      height: 420,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: hexToColor("#eef1f5"),
        boxShadow: [
          BoxShadow(
              color: Colors.grey,
              offset: Offset(1.0, 1.0),
              blurRadius: 0.5,
              spreadRadius: 0.1)
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            child: IconButton(
              onPressed: () async {
                //_dayCounter means the maximum page number
                //_currentDay means the currentpage number

                _dayCounter--;
                _dayController.add(_dayCounter);

                addDayList.remove('Day $_currentDay');


                Map _tempMap = {};

                int _tempCounter = 1;
                addDayList.forEach((key, value) {
                  _tempMap['Day $_tempCounter'] = value;
                  _tempCounter++;
                });
                addDayList.clear();
                addDayList.addAll(_tempMap);
                await UserServices.updateTripInterests(addDayList);

                currentDay = "DAY $_currentDay";
              },
              icon: Icon(Icons.close),
            ),
          ),
          Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                alignment: Alignment.centerLeft,
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(
                color: Colors.black,
                height: 10,
                thickness: 2,
                indent: 10,
                endIndent: 10,
              ),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    ListTile(
                      title: Wrap(
                        alignment: WrapAlignment.spaceAround,
                        children: _generalInterests(InterestList, currentDay),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              _clickableButton(
                  "ADD",
                  AddInterests(
                    currentDay: currentDay,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  //list of days of ponit of interests
  Widget _daysInterestsList() {
    return Column(
      children: <Widget>[
        _everydayInterests('Day 1'),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget _clickableButton(String name, var route) {
    return ElevatedButton(
      onPressed: () async {
        if (name == 'ADD DAY') {
          _dayCounter++;
          _dayController.add(_dayCounter);

          addDayList['Day $_dayCounter'] = {
            'Origin': ['']
          };
          await UserServices.updateTripInterests(addDayList);
          //print(currentDay);
          //_scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        } else {
          if (name == 'DONE') {
            //String addTitle = prompts.get('Enter your trip title');
            if (!titleSetted) {
              Fluttertoast.showToast(
                msg: 'Please enter the title!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
              );
              return;
            } else {
              Fluttertoast.showToast(
                msg: 'Plan Saving...jump to display!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
              );
            }

            await UserServices.updateTitle(title);
            await UserServices.updateTripDuration(_dayCounter.toString());
            DatabaseSavedPlan _databaseSavedPlan = DatabaseSavedPlan();
            await _databaseSavedPlan.setupSavedPlanData();
            await UserServices.updateSavedPlanStartDate(dayPlan!.startDate);
            await UserServices.updateSavedPlanTripDuration(
                dayPlan!.tripDuration);
            await UserServices.updateSavedPlanTripInterests(
                dayPlan!.tripInterests);
            await UserServices.updateSavedPlanTitle(dayPlan!.title);
            await UserServices.updateSavedPlanFriendsID(dayPlan!.friendsID);
            tripId = await _databaseSavedPlan.getPlanId();
            print('hereeeeeee');
            print(tripId);
            print('hereeeeeee');

            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DisplayTrip(googlePlace: googlePlace, targetId: tripId),
                ));
          } else if (name == 'ADD') {
            //print(currentDay);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => route),
            ).then((data) {
              setState(() {
                addDayList = dayPlan!.tripInterests;
              });
            });
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => route),
            );
          }
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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

  Widget _getTextbutton(String currentDay, String interest, String detail) {
    return TextButton(
      onPressed: () {
        String searchInterest = interest;
        String searchDay = currentDay;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchPlace(
                googlePlace: googlePlace,
                searchDay: searchDay,
                searchInterest: searchInterest,
                whichPlan: 'Make',
            ),
          ),
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
        splitDetail(detail),
        style: TextStyle(
          color: Colors.grey,
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String splitDetail(String detail) {
    var detailArr = detail.split(',');

    return detailArr[0];
  }

  Widget singleInterestField(String general, String detail, String currentDay) {
    return ListTile(
      title: Text(
        general,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Container(
        child: Row(
          //crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(height: 65),
            Expanded(
              child: Container(
                //margin: const EdgeInsets.only(right: 20),
                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                alignment: Alignment.centerLeft,
                height: 50,
                width: MediaQuery.of(context).size.width,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(width: 5),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _getTextbutton(currentDay, general, detail),
                      ),
                    ),
                    //_getTextbutton(currentDay, general, detail),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 40.0,
              width: 40.0,
              child: IconButton(
                onPressed: () {
                  _deleteFromInterests(general, currentDay);
                },
                padding: new EdgeInsets.all(0.0),
                color: Colors.black,
                icon: new Icon(Icons.close, size: 20.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _generalInterests(List all, String currentDay) {
    List<Widget> interests = [];
    for (Map m in all) {
      String detail = '...';
      print(detail);
      if (m['title'][1] != '') {
        detail = m['title'][1];
      }
      print(detail);

      interests.add(
        //Chip(label: Text(m['title'][0], style:TextStyle(fontSize: 14))),
        singleInterestField(m['title'][0], detail, currentDay),
      );
    }
    return interests;
  }

  //parse hex code to integer
  Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  int getPlaceNum() {
    int n = 0;
    dayPlan!.tripInterests.forEach((key, value) {
      dayPlan!.tripInterests[key].forEach((key, value) {
        if (value != Null) {
          n += 1;
        }
      });
    });
    return n;
  }

  void showAlterDialog() async {
    //1.release a notification to user : The maximum duration allowed is 10 days
    if (_dayCounter > 10) {
      _dayCounter = 10;
      //await UserServices.updateTripDuration(_dayCounter.toString());
      Fluttertoast.showToast(
        msg: 'Exceed maximum day limit : \nNo more than 10 days!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
    //2. ask user if he want to delete the day when he click 'x'
    //3. ask user if the plan is done when he click 'done'
  }

  void _deleteFromInterests(String interest, String currentDay) async {
    String _dayCounter = currentDay.substring(4);
    int dayCounter = int.parse(_dayCounter);
    //print("check!!!!!!!!!!!!!!!!!!!!!!!!!");
    //print(interests);
    print(addDayList);
    Map temp = {};

    Map oldInterests = addDayList["Day $_dayCounter"];

    oldInterests.forEach((key, value) {
      if (key != interest) {
        temp[key] = value;
      }
    });

    addDayList["Day $_dayCounter"] = temp;
    print(addDayList);
    await UserServices.updateTripInterests(addDayList);
  }

  ///* Optional method
  List _formInterestList(String day, Map addDayList) {
    List returnList = [];
    //print('-----!!!!!-----');
    //print(day);
    if (addDayList[day] != {}) {
      addDayList[day].forEach((key, value) {
        Map partMap = {};
        partMap['title'] = [key, value[0]];
        returnList.add(partMap);
      });
    }
    return returnList;
  }
  //*/

/*  Future setTempPlan(String uid, String email) async{
    await DatabaseMakePlan().updateMakePlanData(email, {}, 1);
  }
*/
}
