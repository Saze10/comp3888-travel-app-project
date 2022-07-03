import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_app/objects/user.dart';
import 'package:flutter_app/objects/personalPlan.dart';
import 'package:intl/intl.dart';

class DatabaseMakePlan {
  final CollectionReference makePlanData =
      FirebaseFirestore.instance.collection('day_plan');
  User? user = UserServices.getUserInfo();

  Future setupMakePlanData() async {
    return await makePlanData
        .doc(user!.uid)
        .set({
          'startDate': getCurrentDay(),
          'tripDuration': "",
          'tripInterests': {
            "Day 1": {
              "origin": ["current place"],
              "destination": [""],
            },
            "Day 2": {}
          },
          'uid': user!.uid,
          'email': user!.email,
          'title': "",
          'friendsID': [],
        })
        .then((value) => print("plan Added"))
        .catchError((error) => print("Fail to add plan page"));
  }

  Future updateStartDate(String startDate) async {
    return await makePlanData.doc(user!.uid).update({'startDate': startDate});
  }

  Future updateTripDuration(String tripDuration) async {
    return await makePlanData
        .doc(user!.uid)
        .update({'tripDuration': tripDuration});
  }

  Future updateTripInterests(Map tripInterests) async {
    return await makePlanData
        .doc(user!.uid)
        .update({'tripInterests': tripInterests});
  }

  Future updateTitle(String title) async {
    return await makePlanData.doc(user!.uid).update({'title': title});
  }

  Future updateFriendsID(List friendsID) async {
    return await makePlanData.doc(user!.uid).update({'friendsID': friendsID});
  }

  Future getUserData() async {
    return await makePlanData.doc(user!.uid).get();
  }

  List<DayPlan> dayPlanListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
      return DayPlan(
        startDate: data['startDate'],
        tripDuration: data['tripDuration'],
        tripInterests: data['tripInterests'],
        uid: data['uid'],
        email: data['email'],
        title: data['title'],
        friendsID: data['friendsID'],
      );
    }).toList();
  }

  Stream<QuerySnapshot>? get streamDayPlanData {
    try {
      Query userID = makePlanData.where('uid', isEqualTo: user!.uid);
      return userID.snapshots();
    } on FirebaseException catch (e) {
      print(e);
      return null;
    }
  }

  Stream<QuerySnapshot>? get streamDayPlanDataSnapshot {
    try {
      Query userID = makePlanData.where('uid', isEqualTo: user!.uid);
      return userID.snapshots();
    } on FirebaseException catch (e) {
      print(e);
      return null;
    }
  }

  Stream<QuerySnapshot>? get streamShardPlan {
    try {
      Query userID = makePlanData.where('friendsID', arrayContains: user!.uid);
      return userID.snapshots();
    } on FirebaseException catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> isExists(String id, String uid) async {
    return await makePlanData.doc(id).get().then((snapshot) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List friendsID = data['friendsID'];
      if (friendsID.contains(uid)) {
        return true;
      } else {
        return false;
      }
    });
  }

  Future reply(String id, String uid) async {
    await makePlanData.doc(id).get().then((snapshot) async {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List friendsID = data['friendsID'];
      if (!friendsID.contains(uid)) {
        friendsID.add(uid);
      }
      return await makePlanData.doc(id).update({'friendsID': friendsID});
    });
  }

  String getCurrentDay() {
    DateTime now = DateTime.now();
    String date = DateFormat('yyyy-MM-dd').format(now);

    return date;
  }
}
