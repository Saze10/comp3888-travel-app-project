import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_app/objects/user.dart';

class DatabaseMessage {

  final CollectionReference userData = FirebaseFirestore.instance.collection('user_message');
  User? user = UserServices.getUserInfo();

  Future setupUserData() async {
    return await userData.doc(user!.email).set({
      'uid' : user!.uid,
      'email' :user!.email,
      'message' : [
        {
          "title": "Welcome",
          "subString" : "Welcome to your trip planner and recommender!",
          "isRequest" : false,
          "sendBy" : "official"
        }
      ],
    });
  }

  Future updateMessage(List message) async{
    return await userData.doc(user!.email).update({'message': message});
  }

  Future<bool> isMailAlreadySend(String email, String id) async {
    return await userData
        .doc(email)
        .get()
        .then((snapshot){
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List message = data['message'];
      for (Map m in message){
        if(m["subString"].split(" ").last == id){
          return true;
        }
      }return false;
    });
  }

  Future invite(String email, String id) async{
    await userData
        .doc(email)
        .get()
        .then((snapshot) async {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List message = data['message'] ?? [
        {
          "title": "Welcome",
          "subString" : "Welcome to your trip planner and recommender!",
          "isRequest" : false,
          "sendBy" : "official"
        }
      ];
      message.insert(0,
          {
            "title": "Invitation",
            "subString" : "Hi there, would you like to join my trip. id: " + id,
            "isRequest" : true,
            "sendBy" : user!.email
          }
        );
      return await userData.doc(email).update({'message': message});
    });
  }

  Future reply(String email, bool accept) async{
    await userData
        .doc(email)
        .get()
        .then((snapshot) async {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List message = data['message'] ?? [
        {
          "title": "Welcome",
          "subString" : "Welcome to your trip planner and recommender!",
          "isRequest" : false,
          "sendBy" : "official"
        }
      ];
      if (accept){
        message.insert(0,
            {
              "title": "Accept",
              "subString" : "I accepted your invitation to travel",
              "isRequest" : false,
              "sendBy" : user!.email
            }
        );
      }else{
        message.insert(0,
            {
              "title": "Reject",
              "subString" : "I Rejected your invitation to travel",
              "isRequest" : false,
              "sendBy" : user!.email
            }
        );
      }
      return await userData.doc(email).update({'message': message});
    });
  }

  Future<bool> isExists(String email) async {
    return await userData
    .doc(email)
    .get()
    .then((snapshot){
      if(snapshot.exists){
        return true;
      }else{
        return false;
      }
    });
  }

  Future<String> getUIDByEmail(String email) async {
    return await userData
        .doc(email)
        .get()
        .then((snapshot){
      if(snapshot.exists){
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return data["uid"];
      }else{
        return "";
      }
    });
  }

  Future getUserData() async {
    return await userData.doc(user!.email).get();
  }

  Stream<QuerySnapshot>? get streamUserDataSnapshot {
    try {
      Query userID = userData.where('uid', isEqualTo: user!.uid);
      return userID.snapshots();
    }on FirebaseException catch (e){
      print(e);
      return null;
    }
  }
}