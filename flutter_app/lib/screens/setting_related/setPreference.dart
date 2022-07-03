import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/firebase_services/database_service.dart';
import 'package:flutter_app/objects/user.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_app/widgets/button_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';


class SetPreference extends StatefulWidget {
  const SetPreference({Key? key, this.firebase}) : super(key: key);
  final FirebaseFirestore? firebase;

  @override
  _SetPreferenceState createState() => _SetPreferenceState();
}

class _SetPreferenceState extends State<SetPreference> {
  User? user;
  LocalUser ? localUser;
  Map<String , List<dynamic>?> preference = {"Accommodation" : [], "Food" : []};
  bool ableToGetBack = true;
  FirebaseFirestore? firebase;

  @override
  void initState() {
    super.initState();
    //user = UserServices.getUserInfo();
    firebase = widget.firebase;
  }

  @override
  Widget build(BuildContext context) {
    // Using Stream Builder instead of global Stream Provider to avoid getting a null user id before user login
    return StreamBuilder<QuerySnapshot>(
        stream: firebase == null ? DatabaseService().streamUserDataSnapshot :  firebase?.collection('user_data').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.data == null){
            return Text("Loading");
          }
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Text("Loading");
          // }
          localUser = UserServices.getLocalUserBySnapshot(snapshot);
          _resetPreference();
          return Scaffold(
            appBar: getAppBar(),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                child: ListView(
                    children: <Widget>[
                      getContent(),
                      SizedBox(height: 5),
                      submit(),
                    ]
                ),
              ),
            ),
          );
        }
    );
  }

  Future _getAccommodationBottomSheet(BuildContext context){
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context){
          return StatefulBuilder(
            builder:(context, state){
              Widget getListTile(String key, String selection){
                return ListTile(
                  title: Text(selection),
                  trailing: preference[key]!.contains(selection)
                      ? Icon(Icons.check, color: Colors.green)
                      : null,
                  selected: preference[key]!.contains(selection) ,
                  selectedTileColor: Color.fromRGBO(208, 208, 208, 1.0),
                  onTap: (){
                    state(() {
                      if(preference[key]!.contains(selection)){
                        preference[key]!.remove(selection);
                      }else if(!preference[key]!.contains(selection)) {
                        preference[key]!.add(selection);
                      }
                    });
                    // Navigator.pop(context);
                  },
                );
              }
              return ListView(
                children: <Widget>[
                getListTile("Accommodation", "B&B"),
                getListTile("Accommodation", "Lodge"),
                getListTile("Accommodation", "Hotel"),
                ]
              );
            }
          );
        }
    );
  }

  Future _getFoodBottomSheet(BuildContext context){
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context){
          return StatefulBuilder(
              builder:(context, state) {
                Widget getListTile(String key, String selection){
                  return ListTile(
                    title: Text(selection),
                    trailing: preference[key]!.contains(selection)
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
                    selected: preference[key]!.contains(selection) ,
                    selectedTileColor: Color.fromRGBO(208, 208, 208, 1.0),
                    onTap: (){
                      state(() {
                        if(preference[key]!.contains(selection)){
                          preference[key]!.remove(selection);
                        }else if(!preference[key]!.contains(selection)){
                          preference[key]!.add(selection);
                        }
                      });
                      // Navigator.pop(context);
                    },
                  );
                }
                return ListView(
                    children: <Widget>[
                      getListTile("Food", "Asian Food"),
                      getListTile("Food", "French Cuisine"),
                      getListTile("Food", "Fast Food"),
                    ]
                );
              }
          );
        }
    );
  }

  _resetPreference(){

    for (String s in localUser!.preference["Accommodation"]){
      preference["Accommodation"]!.add(s);
    }
    for (String s in localUser!.preference["Food"]){
      preference["Food"]!.add(s);
    }
  }

  Widget getButton(String text, var onPress){
    return Container(
      height : ScreenUtil().setHeight(320),
      width: ScreenUtil().setWidth(450),
      child: ElevatedButton(
        onPressed: (){
          onPress(context);
        },
        child: Padding(
          padding: EdgeInsets.all(ScreenUtil().setHeight(5)),
          child: Text(text),
        ),
      ),
    );
  }

  Widget getContent(){
    return Container(
      height: ScreenUtil().setHeight(1350),
      child: ListView(
        children: <Widget>[
          SizedBox(height: 25),
          ElevatedButtonTheme(
            data: ElevatedButtonThemeData(
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all(TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
                backgroundColor: MaterialStateProperty.all(Colors.lightBlueAccent),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                ),
              ),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              children: <Widget>[
                getButton("Accommodation", _getAccommodationBottomSheet),
                getButton("Food", _getFoodBottomSheet),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget submit(){
    return ButtonWidget(
      text: 'Submit',
      onPressed: () async {
        List<String> keys = preference.keys.toList();
        for(int i = 0; i < keys.length; i ++) {
          String key = keys[i];
          preference[key] = preference[key]?.toSet().toList();
        }
        ableToGetBack = false;
        await UserServices.updatePreference(preference, firebase);
        Fluttertoast.showToast(
          msg: 'Preferences Submitted',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        ableToGetBack = true;
      },
    );
  }

  AppBar getAppBar() {
    return AppBar(
      title: const Text(
        'Set Preference',
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
          if (ableToGetBack){
            _resetPreference();
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}
