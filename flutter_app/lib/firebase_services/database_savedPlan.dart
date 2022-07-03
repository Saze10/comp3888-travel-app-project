import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_app/objects/user.dart';
import 'package:flutter_app/objects/personalPlan.dart';
import 'package:flutter_app/objects/savedPlan.dart';
import 'package:flutter_app/firebase_services/database_savedPlan.dart';
import 'dart:math';

class DatabaseSavedPlan {
  final CollectionReference savedPlanData =
  FirebaseFirestore.instance.collection('saved_plan');

  User? user = UserServices.getUserInfo();
  static late String generatedDoc;

  Future setupSavedPlanData() async {
    //await UserServices.updateGender("hello",);
    generatedDoc = generateDoc(user!.uid);
    print(generatedDoc);
    return await savedPlanData
        .doc(generatedDoc)
        .set({
      'startDate': "",
      'tripDuration': "",
      'tripInterests': {},
      'uid': user!.uid,
      'email': user!.email,
      'title':"",
      'friendsID':[],
      'id':generatedDoc,
    })

        .then((value) => print("plan Saved"))
        .catchError((error) => print("Fail to save plan page"));
  }

  Future setupCurrentData(String file ) async {
    generatedDoc = file;
    return savedPlanData
        .doc(generatedDoc);
  }

  Future updateStartDate(String startDate) async {
    return await savedPlanData.doc(generatedDoc).update({'startDate': startDate});
  }

  Future updateTripDuration(String tripDuration) async {
    return await savedPlanData
        .doc(generatedDoc)
        .update({'tripDuration': tripDuration});
  }

  Future updateTripInterests(Map tripInterests) async {
    return await savedPlanData
        .doc(generatedDoc)
        .update({'tripInterests': tripInterests});
  }

  Future updateTitle(String title) async{
    return await savedPlanData.doc(generatedDoc).update({'title': title});
  }
  Future updateFriendsID(List friendsID) async{
    return await savedPlanData.doc(generatedDoc).update({'friendsID': friendsID});
  }


  Future getUserData() async {
    return await savedPlanData.doc(user!.uid).get();
  }

  Future<String> getPlanId() async {
    return await savedPlanData.doc(generatedDoc).id;

  }


  List<SavedPlan> savedPlanListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
      return SavedPlan(
        startDate: data['startDate'],
        tripDuration: data['tripDuration'],
        tripInterests : data['tripInterests'],
        uid: data['uid'],
        email: data['email'],
        title:data['title'],
        friendsID:data['friendsID'],
        id:data["id"],
      );
    }).toList();
  }

  Stream<List<SavedPlan>>? get streamSavedPlanData {
    try {
      Query userID = savedPlanData.where('uid', arrayContains: user!.uid);
      return userID.snapshots().map(savedPlanListFromSnapshot);
    } on FirebaseException catch (e) {
      print(e);
      return null;
    }
  }

  Stream<QuerySnapshot>? get streamSavedPlanDataSnapshot {
    try {
      Query userID = savedPlanData.where('uid', isEqualTo: user!.uid);
      return userID.snapshots();
    } on FirebaseException catch (e) {
      print(e);
      return null;
    }
  }

  String generateDoc(String uid){
    Random random = new Random();
    int randomNumber = random.nextInt(900) + 100;
    String digits = randomNumber.toString();
    String doc = uid + digits;
    return doc;
  }

  Stream<QuerySnapshot>? get streamUserDataSnapshot {
    try {
      Query userID = savedPlanData.where('uid', isEqualTo: user!.uid);
      return userID.snapshots();
    }on FirebaseException catch (e){
      print(e);
      return null;
    }
  }

  Stream<QuerySnapshot>? get streamShardPlan {
    try {
      Query userID = savedPlanData.where('friendsID', arrayContains: user!.uid);
      return userID.snapshots();
    }on FirebaseException catch (e){
      print(e);
      return null;
    }
  }

  Future<bool> isExists(String id, String uid) async {
    return await savedPlanData
        .doc(id)
        .get()
        .then((snapshot){
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List friendsID = data['friendsID'] ;
      if(friendsID.contains(uid)){
        return true;
      }else{
        return false;
      }
    });
  }

  Future reply(String id, String uid) async{
    await savedPlanData
        .doc(id)
        .get()
        .then((snapshot) async {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List friendsID = data['friendsID'] ;
      if(!friendsID.contains(uid)){
        friendsID.add(uid);
      }
      return await savedPlanData.doc(id).update({'friendsID': friendsID});
    });
  }

}
