import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/firebase_services/storage_service.dart';
import 'package:flutter_app/services/user_services.dart';
import 'package:flutter_app/widgets/button_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerPage extends StatefulWidget {
  ImagePickerPage({Key? key}) : super(key: key);

  _ImagePickerPageState createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  XFile? _image;
  bool ableToGetBack = true;

  late String _imgServerPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: Container(
        child: ListView(
          children: <Widget>[
            SizedBox(height: 20),
            Container(
              height: ScreenUtil().setHeight(1150),
              child: _image != null
                  ? Image.file(File(_image!.path), fit: BoxFit.cover)
                  : Text(
                      "Please select an image",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromRGBO(20, 41, 82, 1),
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      ),
                    ),
            ),
            SizedBox(height: 25),
            ButtonWidget(
              text: 'Select',
              hasBorder: true,
              onPressed: () {
                getBottomSheet(context);
              },
            ),
            SizedBox(height: 15),
            ButtonWidget(
              text: 'Upload',
              onPressed: () async {
                if (_image == null) {
                  Fluttertoast.showToast(
                    msg: 'Invalid Picture',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                  );
                } else {
                  ableToGetBack = false;
                  await _uploadImage();
                  Fluttertoast.showToast(
                    msg: 'Success',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                  );
                  ableToGetBack = true;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  AppBar getAppBar() {
    return AppBar(
      title: const Text(
        'Upload Profile Picture',
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
          if (ableToGetBack) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  Future _getImageFromCamera() async {
    XFile? image = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxWidth: 400);
    setState(() {
      _image = image!;
    });
  }

  Future _getImageFromGallery() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image!;
    });
  }

  _uploadImage() async {
    var path = await StorageService().uploadProfilePicture(File(_image!.path));
    await UserServices.uploadProfilePicture(path);
  }

  Future getBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ListView(children: <Widget>[
            ListTile(
              leading: new Icon(Icons.photo_camera),
              title: Text('Camera'),
              onTap: () {
                _getImageFromCamera();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: new Icon(Icons.photo_library),
              title: Text("Photograph"),
              onTap: () {
                _getImageFromGallery();
                Navigator.pop(context);
              },
            ),
          ]);
        });
  }
}
