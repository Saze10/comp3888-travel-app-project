import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_app/objects/user.dart';

class DatabaseService {

  final CollectionReference userData = FirebaseFirestore.instance.collection('user_data');
  User? user = UserServices.getUserInfo();

  Future setupUserData() async {
    return await userData.doc(user!.uid).set({
      'name': user!.displayName,
      'email' : user!.email,
      'uid' : user!.uid,
      'gender' : "secrecy",
      'preference' : {"Accommodation" : [], "Food" : []},
      'trips' : [],
      'saved' : [],
      'photoURL' : user!.photoURL,
    });
  }

  Future updateName(String name) async{
    return await userData.doc(user!.uid).update({'name': name,});
  }

  Future updatePhotoURL(String path) async{
    return await userData.doc(user!.uid).update({'photoURL': path,});
  }

  Future updateGender(String gender) async{
    return await userData.doc(user!.uid).update({'gender': gender,});
  }

  Future updatePreference(Map<String , List<dynamic>?> preference) async{
    return await userData.doc(user!.uid).update({'preference': preference});
  }


  Future getUserData() async {
    return await userData.doc(user!.uid).get();
  }

  List<LocalUser> userListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc){
      Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
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
    }).toList();
  }

  Stream<List<LocalUser>>? get streamUserData {
    try {
      Query userID = userData.where('uid', isEqualTo: user!.uid);
      return userID.snapshots().map(userListFromSnapshot);
    }on FirebaseException catch (e){
      print(e);
      return null;
    }
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

  Stream<QuerySnapshot>? getStreamUserDataSnapshot(String uid) {
    try {
      Query userID = userData.where('uid', isEqualTo: uid);
      return userID.snapshots();
    }on FirebaseException catch (e){
      print(e);
      return null;
    }
  }
}