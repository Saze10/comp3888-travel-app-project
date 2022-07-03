import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/screens/InvitedFriend.dart';
import 'package:flutter_app/screens/setting_related/setGender.dart';
import 'package:flutter_app/screens/setting_related/setPreference.dart';
import 'package:flutter_app/objects/user.dart';
import 'package:flutter_app/screens/setting_related/changingUsername.dart';
import 'package:flutter_app/screens/Login.dart';
import 'package:flutter_app/screens/BottomNavigation.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_app/screens/setting_related/uploadPicture.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Setting extends StatefulWidget {
  Setting({Key? key}) : super(key: key);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: getAppBar(),
      body: Container(
        child: Column(children: <Widget>[
          getList(context),
          getLogout(context),
        ]),
      ),
    );
  }

  AppBar getAppBar() {
    return AppBar(
        title: const Text(
          'Setting',
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
            Navigator.of(context).pop("xx");
          },
        ),
    );
  }
}

Widget getList(BuildContext context){
  return Container(
    height:470,
    child: ListTileTheme(
      selectedTileColor: Color.fromRGBO(208, 208, 208, 1.0),
      child: ListView(
        children: <Widget>[
          ListTile(
            title: Text("Profile Picture"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ImagePickerPage()),
              );
            },
          ),
          ListTile(
            title: Text("User Name"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserName()),
              );
            },
          ),
          ListTile(
            title: Text("Gender"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SetGender()),
              );
            },
          ),
          ListTile(
            title: Text("Preference"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SetPreference()),
              );
            },
          ),
          // ListTile(
          //   title: Text("Invited Friend Temp"),
          //   trailing: Icon(Icons.arrow_forward_ios),
          //   onTap: (){
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => InvitedFriend(id: "L7mVKFhsJZdvKPLhiD6AV7OPAej1242")),
          //     );
          //   },
          // ),
          // ListTile(
          //   title: Text("Help"),
          //   trailing: Icon(Icons.arrow_forward_ios),
          //   onTap: (){
          //     setState(){
          //     }
          //   },
          // ),
          // ListTile(
          //   title: Text("About"),
          //   trailing: Icon(Icons.arrow_forward_ios),
          //   onTap: (){
          //     setState(){
          //     }
          //   },
          // ),
        ],
      ),
    ),
  );
}

Widget getLogout(BuildContext context){

  return ElevatedButton(
    child: Text('Logout'),
    style: ButtonStyle(
      textStyle: MaterialStateProperty.all(TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
      backgroundColor: MaterialStateProperty.all(Colors.white),
      foregroundColor: MaterialStateProperty.all(Color.fromRGBO(20, 41, 82, 1)),
      overlayColor: MaterialStateProperty.all(Colors.blueAccent),
      elevation: MaterialStateProperty.all(5),
      shape: MaterialStateProperty.all(
        StadiumBorder(
          side: BorderSide(
            style: BorderStyle.solid,
            color: Colors.grey,
          ),
        ),
      ),
    ),
    onPressed: () async {
      await UserServices.logOut();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BottomNavigatorBar(data : 3, isLogin : false)),
      );
      Fluttertoast.showToast(
        msg: 'Logout',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    },
  );
}
