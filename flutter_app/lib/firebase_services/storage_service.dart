import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_app/services/user_services.dart';
class StorageService{
  final Reference ref = FirebaseStorage.instance.ref();
  final User user = UserServices.getUserInfo();


  Future uploadProfilePicture(File image) async{
    final Reference pictureRef = ref.child('${user.email}/${user.email}_profile/${user.email}_profilePicture.jpg');
    final UploadTask uploadTask = pictureRef.putFile(image);
    try{
      await uploadTask.whenComplete(() => null);
      return pictureRef.getDownloadURL();
    } on FirebaseException catch (e){
      print(e);
      return null;
    }
  }


}