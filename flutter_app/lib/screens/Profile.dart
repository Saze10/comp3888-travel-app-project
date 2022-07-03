import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/screens/SharedWithMe.dart';
import 'package:flutter_app/screens/setting_related/setPreference.dart';
import 'package:flutter_app/firebase_services/database_service.dart';
import 'package:flutter_app/objects/user.dart';
import 'package:flutter_app/screens/Setting.dart';
import 'package:flutter_app/screens/plan_related/SamplePlan.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'BottomNavigation.dart';
import 'MyTrip.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isSelected = true;
  String userInformation = "Information about the user";
  //bool isNotFollowed = false;
  bool isLogin = false;
  User? user;
  LocalUser? localUser;

  getUser() {
    setState(() {
      this.isLogin = UserServices.getUserLoginState();
      this.user = UserServices.getUserInfo();
    });
  }

  @override
  void initState() {
    super.initState();
    this.getUser();
  }

  @override
  Widget build(BuildContext context) {
    // Using Stream Builder instead of global Stream Provider to avoid getting a null user id before user login
    return StreamBuilder<List<LocalUser>>(
        stream: DatabaseService().streamUserData,
        builder:
            (BuildContext context, AsyncSnapshot<List<LocalUser>> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.data == null) {
            return Text("Loading");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }
          localUser = snapshot.data!.first;
          return Scaffold(
            key: Key('Profile-page'),
            appBar: getAppBar(),
            body: Container(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListView(children: <Widget>[
                  getUserInfo(),
                  getTripSelection(),
                  Divider(
                      height: 0,
                      color: Color.fromRGBO(20, 41, 82, 1),
                      indent: 15.0,
                      endIndent: 15.0),
                  getContent(),
                ]),
              ),
            ),
          );
        });
  }

  AppBar getAppBar() {
    return AppBar(
        leading: IconButton(
          key: Key('logout-button'),
          icon: Icon(Icons.logout),
          color: Color.fromRGBO(20, 41, 82, 1),
          onPressed: () async {
            await UserServices.logOut();
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      BottomNavigatorBar(data: 3, isLogin: false)),
            );
            Fluttertoast.showToast(
              msg: 'Logout',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
            );
          },
        ),
        title: const Text(
          'Profile',
          style: const TextStyle(
            color: Color.fromRGBO(20, 41, 82, 1),
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            key: Key('setting-button'),
            icon: Icon(Icons.settings),
            color: Color.fromRGBO(20, 41, 82, 1),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Setting()))
                  .then((data) {
                setState(() {
                  user = UserServices.getUserInfo();
                });
              });
            },
          )
        ]);
  }

  Widget getUserInfo() {
    return Container(
      height: ScreenUtil().setHeight(420),
      color: Color.fromRGBO(238, 238, 238, 1.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    top: 5,
                    right: 20,
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => Setting()))
                          .then((data) {
                        setState(() {
                          user = UserServices.getUserInfo();
                        });
                      });
                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.fromLTRB(0, 0, 30, 0),
                      leading: CircleAvatar(
                        backgroundImage: localUser!.photoURL == null
                            ? null
                            : NetworkImage("${localUser!.photoURL}"),
                        backgroundColor: Colors.grey,
                        radius: 30,
                      ),
                      //title: Text((user!.displayName == null)?"new user" : "${user!.displayName}", style: TextStyle(fontSize: 18)),
                      title: Text("${localUser!.name}",
                          style: TextStyle(fontSize: 18)),
                      subtitle: Text("${localUser!.email}"),
                      trailing: localUser!.gender == "female"
                          ? Icon(Icons.female, color: Colors.pink)
                          : localUser!.gender == "male"
                              ? Icon(Icons.male, color: Colors.blue)
                              : Icon(Icons.security, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 0,
            ),
            child: Divider(
                height: 8,
                color: Color.fromRGBO(20, 41, 82, 1),
                indent: 15.0,
                endIndent: 15.0),
          ),
          Container(
            height: ScreenUtil().setHeight(150),
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
            ),
            child: ListView(
              children: <Widget>[
                // Wrap(alignment: WrapAlignment.spaceAround,
                //     children: setPreference(),),
                ListTile(
                  key: Key('list-perference'),
                  title: Wrap(
                    alignment: WrapAlignment.spaceAround,
                    children: setPreference(),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SetPreference()));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> setPreference() {
    List<Widget> preference = [];
    for (String s in localUser!.preference["Accommodation"]) {
      preference.add(
        Chip(label: Text(s, style: TextStyle(fontSize: 14))),
      );
    }
    for (String s in localUser!.preference["Food"]) {
      preference.add(
        Chip(label: Text(s, style: TextStyle(fontSize: 14))),
      );
    }
    return preference;
  }

  TextStyle pressedButton() {
    return TextStyle(
        fontSize: 18,
        color: Colors.lightBlue,
        decoration: TextDecoration.underline,
        decorationColor: Colors.lightBlue,
        decorationThickness: 2.5);
  }

  TextStyle releaseButton() {
    return TextStyle(
      fontSize: 18,
      color: Color.fromRGBO(20, 41, 82, 1),
    );
  }

  Widget getTripSelection() {
    return Container(
        height: ScreenUtil().setHeight(140),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TextButton(
                onPressed: () {
                  setState(() {
                    isSelected = true;
                  });
                },
                child: AnimatedDefaultTextStyle(
                  style: isSelected ? pressedButton() : releaseButton(),
                  child: Text("My Trips"),
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.bounceInOut,
                )),
            TextButton(
              onPressed: () {
                setState(() {
                  isSelected = false;
                });
              },
              child: AnimatedDefaultTextStyle(
                style: !isSelected ? pressedButton() : releaseButton(),
                child: Text("Shared With Me"),
                duration: const Duration(milliseconds: 100),
                curve: Curves.bounceInOut,
              ),
            ),
          ],
        ));
  }

  Widget getContent() {
    return Container(
        height: ScreenUtil().setHeight(970),
        // color:Colors.lightBlue,
        child: isSelected
            ? MyTrip(user: localUser)
            : SharedWithMe(user: localUser));
  }

  // void setTempTrip(){
  //   for (int i = 0; i < 5; i++) {
  //     tripsData.add({
  //       "days": "days",
  //       "city": "city",
  //       "title": "Trip title",
  //       "name": "My name is",
  //       "image":
  //       "https://assets.atdw-online.com.au/images/082abec166a817adfae646daff53ad70.jpeg?rect=0%2C0%2C2048%2C1536&w=800&h=800&rot=360",
  //       "profile picture": "null",
  //       "gender": Icon(Icons.male, color: Colors.blue),
  //       "praise": 12219,
  //       "isPraise": false,
  //       "like": 5000,
  //       "isLike": false,
  //       "comment": 12219,
  //       "date": DateTime.now(),
  //     });
  //     savedData.add({
  //       "days": "days",
  //       "city": "city",
  //       "title": "Trip title",
  //       "name": "My name is",
  //       "image":
  //       "https://assets.atdw-online.com.au/images/082abec166a817adfae646daff53ad70.jpeg?rect=0%2C0%2C2048%2C1536&w=800&h=800&rot=360",
  //       "profile picture": null,
  //       "gender": Icon(Icons.female, color: Colors.pink),
  //       "praise": 12219,
  //       "isPraise": false,
  //       "like": 5001,
  //       "isLike": true,
  //       "comment": 12219,
  //       "date": DateTime.now(),
  //     });
  //   }
  // }

  // Widget setContentFormat(key) {
  //   return Column(
  //     children: <Widget>[
  //       TextButton(
  //         onPressed: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => SamplePlan()),
  //           );
  //         },
  //         child: Container(
  //           height: ScreenUtil().setHeight(380),
  //           child: Stack(
  //             children: <Widget>[
  //               AspectRatio(
  //                 aspectRatio: 26/9,
  //                 child: Image.network(
  //                   key["image"],
  //                   fit: BoxFit.cover,
  //                 ),
  //               ),
  //               Align(
  //                 alignment: Alignment.bottomRight,
  //                 child: Container(
  //                   width: 300,
  //                   child: Row(
  //                     children: <Widget>[
  //                       Flexible(
  //                         flex: 1,
  //                         child: ListTile(
  //                           dense: true,
  //                           contentPadding: EdgeInsets.all(0),
  //                           selected: key["isPraise"],
  //                           visualDensity: VisualDensity(horizontal: -4),
  //                           leading: Icon(
  //                             Icons.thumb_up,
  //                             size: 16,
  //                             color: key["isPraise"]
  //                                 ? Colors.redAccent
  //                                 : Colors.white,
  //                           ),
  //                           title: Text(
  //                             "${key["praise"]}",
  //                             style: TextStyle(
  //                               fontSize: 12,
  //                               color: key["isPraise"]
  //                                   ? Colors.redAccent
  //                                   : Colors.white,
  //                             ),
  //                             maxLines: 1,
  //                             overflow: TextOverflow.ellipsis,
  //                           ),
  //                           onTap: () {
  //                             setState(() {
  //                               if (!key["isPraise"]) {
  //                                 key["praise"]++;
  //                               } else {
  //                                 key["praise"]--;
  //                               }
  //                               key["isPraise"] = !key["isPraise"];
  //                             });
  //                           },
  //                         ),
  //                       ),
  //                       Flexible(
  //                         flex: 1,
  //                         child: ListTile(
  //                           dense: true,
  //                           selected: key["isLike"],
  //                           visualDensity: VisualDensity(horizontal: -4),
  //                           contentPadding: EdgeInsets.all(0),
  //                           leading: Icon(
  //                             CupertinoIcons.heart_solid,
  //                             size: 16,
  //                             color: key["isLike"]
  //                                 ? Colors.redAccent
  //                                 : Colors.white,
  //                           ),
  //                           title: Text(
  //                             "${key["like"]}",
  //                             style: TextStyle(
  //                               fontSize: 12,
  //                               color: key["isLike"]
  //                                   ? Colors.redAccent
  //                                   : Colors.white,
  //                             ),
  //                             maxLines: 1,
  //                             overflow: TextOverflow.ellipsis,
  //                           ),
  //                           onTap: () {
  //                             setState(() {
  //                               if (!key["isLike"]) {
  //                                 key["like"]++;
  //                               } else {
  //                                 key["like"]--;
  //                               }
  //                               key["isLike"] = !key["isLike"];
  //                             });
  //                           },
  //                         ),
  //                       ),
  //                       Flexible(
  //                         flex: 1,
  //                         child: ListTile(
  //                           dense: true,
  //                           visualDensity: VisualDensity(horizontal: -4),
  //                           contentPadding: EdgeInsets.all(0),
  //                           leading: Icon(Icons.comment,
  //                               size: 16, color: Colors.white),
  //                           title: Text(
  //                             "${key["comment"]}",
  //                             style:
  //                             TextStyle(fontSize: 12, color: Colors.white),
  //                             maxLines: 1,
  //                             overflow: TextOverflow.ellipsis,
  //                           ),
  //                           onTap: () {},
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //               Align(
  //                 alignment: Alignment.topLeft,
  //                 child: ListTile(
  //                   title: Text("${key["title"]}",
  //                       style: TextStyle(color: Colors.white)),
  //                   subtitle: Text("${key["city"]}   ${key["days"]}",
  //                       style: TextStyle(color: Colors.white)),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       Container(
  //         height: ScreenUtil().setHeight(140),
  //         child: Row(
  //           children: <Widget>[
  //             Expanded(
  //               flex: 3,
  //               child: ListTile(
  //                 contentPadding: EdgeInsets.fromLTRB(15, 0, 90, 0),
  //                 visualDensity: VisualDensity(horizontal: 0),
  //                 leading: CircleAvatar(
  //                   //backgroundColor: key["profile picture"],
  //                   backgroundColor: Colors.grey,
  //                 ),
  //                 title: Text("${key["name"]}", style: TextStyle(fontSize: 12)),
  //                 trailing: key["gender"],
  //               ),
  //             ),
  //             Expanded(
  //                 flex: 1,
  //                 child: Text(
  //                     "${key["date"].day}/${key["date"].month}/${key["date"].year}")),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
