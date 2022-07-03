import 'package:flutter/cupertino.dart';
import 'package:flutter_app/firebase_services/database_savedPlan.dart';
import 'package:flutter_app/firebase_services/database_message.dart';
import 'package:flutter_app/firebase_services/database_service.dart';
import 'package:flutter_app/firebase_services/database_makePlan.dart';
import 'package:flutter_app/objects/personalPlan.dart';
import 'package:flutter_app/objects/personalPlan.dart';
import 'package:flutter_app/objects/personalPlan.dart';
import 'package:flutter_app/objects/user.dart';
import 'package:flutter_app/services/storage.dart';
import 'dart:convert';
import 'package:flutter_app/firebase_services/authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/objects/user.dart' as localUser;
import 'package:flutter_app/objects/personalPlan.dart' as dayPlan;
import 'package:flutter_app/objects/savedPlan.dart' as SavedPlan;

class UserServices{
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // static getUserInfo() async{
  //   String? userInfo = await Storage.getString('userInfo');
  //   if (userInfo != null) {
  //     List userInfoList = json.decode(userInfo);
  //     return userInfoList;
  //   }else{
  //     return [];
  //   }
  // }
  // static getUserLoginState() async{
  //   var userInfo=await UserServices.getUserInfo();
  //   if(userInfo.length>0&&userInfo[0]["username"]!=""){
  //     return true;
  //   }
  //   return false;
  // }

  static loginOut(){
    Storage.remove('userInfo');
  }

  static LocalUser getLocalUserBySnapshot(AsyncSnapshot<QuerySnapshot> snapshot){
    Map<String, dynamic> data = snapshot.data!.docs.first.data()! as Map<String, dynamic>;
    return LocalUser(
      name : data['name'] ?? "default username",
      email : data['email'],
      uid : data['uid'],
      gender: data['gender'],
      preference : data['preference'],
      trips : data["trips"],
      saved : data['saved'],
      photoURL: data["photoURL"],
    );
  }
  static DayPlan getDayPlanBySnapshot(AsyncSnapshot<QuerySnapshot> snapshot){
    Map<String, dynamic> data = snapshot.data!.docs.first.data()! as Map<String, dynamic>;
    return DayPlan(
      startDate: data['startDate'],
      tripDuration: data['tripDuration'],
      tripInterests : data['tripInterests'],
      uid: data['uid'],
      email: data['email'],
      title:data['title'],
      friendsID:data['friendsID'],
    );
  }

  static List<SavedPlan.SavedPlan> dayPlanListFromSnapshot(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data!.docs.map((doc) {
      Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
      return SavedPlan.SavedPlan(
        startDate: data['startDate'],
        tripDuration: data['tripDuration'],
        tripInterests : data['tripInterests'],
        uid: data['uid'],
        email: data['email'],
        title:data['title'],
        friendsID:data['friendsID'],
        id:data['id'],
      );
    }).toList();
  }

  static List getSavedPlanIdList(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<DocumentSnapshot> doc = snapshot.data!.docs;
    List returnList = [];
    int l = doc.length;
    int i = 0;
    while (i < l){
      returnList.add(doc[i]['id']);
      i += 1;
    }
    //print(returnList);
    return returnList;
  }

  static List getUserMessage(AsyncSnapshot<QuerySnapshot> snapshot){
    Map<String, dynamic> data = snapshot.data!.docs.first.data()! as Map<String, dynamic>;
    return data['message'] ?? [
      {
        "title": "Welcome",
        "subString" : "Welcome to your trip planner and recommender!",
        "isRequest" : false,
        "sendBy" : "official"
      }
    ];
  }

  static getUserLoginState(){
    if (UserServices.getUserInfo() == null){
      return false;
    }return true;
  }

  static getUserInfo()  {
    return _auth.currentUser;
  }


  static getUserUID()  {
    return _auth.currentUser!.uid;
  }

  static logOut() async {
    await _auth.signOut();
  }

  static changingUsername(String name, FirebaseAuth? auth) async {
    if (auth != null){
      return;
    }
    _auth.currentUser!.updateDisplayName(name);
    await DatabaseService().updateName(name);
  }

  static uploadProfilePicture(String path) async {
    await _auth.currentUser!.updatePhotoURL(path);
    await DatabaseService().updatePhotoURL(path);
  }

  static updateGender(String gender, FirebaseFirestore? firebase) async{
    if (firebase != null){
      return await firebase.collection('user_data').doc("123456789").update({'gender': gender,});
    }
    return await DatabaseService().updateGender(gender);
  }

  static reply(String email, bool accept, String id, String? uid, FirebaseFirestore? firebase) async{
    if (firebase != null){
      return;
    }
    if (accept){await DatabaseSavedPlan().reply(id, uid!);}
    return await DatabaseMessage().reply(email, accept);
  }

  static Future<bool> isExists(String email, FirebaseAuth? firebase) async {
    if (firebase != null){
      return true;
    }
    return await DatabaseMessage().isExists(email);
  }

  static invite(String email, String id, FirebaseAuth? firebase) async{
    if (firebase != null){
      return;
    }
    await DatabaseMessage().invite(email, id);
    return;
  }

  static updatePreference(Map<String , List<dynamic>?> preference, FirebaseFirestore? firebase) async{
    if (firebase != null){
      return await firebase.collection('user_data').doc("123456789").update({'preference': preference,});
    }
    await DatabaseService().updatePreference(preference);
  }

  static updateUserMessage(List message, FirebaseFirestore? firebase) async{
    if (firebase != null){
      return await firebase.collection('user_message').doc("123456789").update({'message': message});
    }
    await DatabaseMessage().updateMessage(message);
  }

  static updateStartDate(String startDate) async{
    await DatabaseMakePlan().updateStartDate(startDate);
  }

  static updateTripDuration(String tripDuration) async{
    await DatabaseMakePlan().updateTripDuration(tripDuration);
  }

  static updateTripInterests(Map tripInterests) async{
    await DatabaseMakePlan().updateTripInterests(tripInterests);
  }
  static updateTitle(String title) async{
    await DatabaseMakePlan().updateTitle(title);
  }
  static updateFriendsID(List friendsID) async{
    await DatabaseMakePlan().updateFriendsID(friendsID);
  }

  static Future<String> getUIDByEmail(String email, FirebaseAuth? firebase) async {
    if (firebase != null){
      return "";
    }return await DatabaseMessage().getUIDByEmail(email);
  }

  static Future<bool> userAlreadyAdd(String id, String uid, FirebaseAuth? firebase) async{
    if (firebase != null){
      return false;
    }return await DatabaseSavedPlan().isExists(id, uid);
  }

  static Future<bool> isMailAlreadySend(String email, String id, FirebaseAuth? firebase) async{
    if (firebase != null){
      return false;
    }return await DatabaseMessage().isMailAlreadySend(email, id);
  }

  static updateSavedPlanStartDate(String startDate) async{
    await DatabaseSavedPlan().updateStartDate(startDate);
  }

  static updateSavedPlanTripDuration(String tripDuration) async{
    await DatabaseSavedPlan().updateTripDuration(tripDuration);
  }

  static updateSavedPlanTripInterests(Map tripInterests) async{
    await DatabaseSavedPlan().updateTripInterests(tripInterests);
  }
  static updateSavedPlanTitle(String title) async{
    await DatabaseSavedPlan().updateTitle(title);
  }
  static updateSavedPlanFriendsID(List friendsID) async{
    await DatabaseSavedPlan().updateFriendsID(friendsID);
  }

}