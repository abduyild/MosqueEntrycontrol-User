import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

class UserManagement {
  storeNewUser(User user, context, name) async {
    var response1;
    String filePath = "";
    HttpClient httpClient = new HttpClient();
    var request = await httpClient.getUrl(Uri.parse("https://api.qrserver.com/v1/create-qr-code/?data=${user.uid}&size=250x250"));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    final Directory directory = await getApplicationDocumentsDirectory();
    final dir = await Directory(directory.path + "/assets").create(recursive: true);
    File file = await File('${dir.path}/${user.uid}.png').create(recursive: true);
    await file.writeAsBytes(bytes);



    UploadTask task;

    final Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('assets/${user.uid}.png');
    task = firebaseStorageRef.putFile(file);

    TaskSnapshot snapshot = await task;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    print("DownloadUrl: ${downloadUrl}");
    _save(downloadUrl);
    FirebaseFirestore.instance.collection('/users').add({
      "displayName": name,
      'signedUpDate': DateFormat("yyyy-MM-dd").format(DateTime.now()),
      'email': user.email,
      'uid': user.uid,
      'qrCodeUrl': downloadUrl,
    }).catchError((e) {
      print(e);
    });
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => MyHomePage()),
        (route) => false);
  }

}

_save(String qrUrl) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'qrUrl';
  final value = qrUrl;
  prefs.setString(key, value);
  print('saved $value');
}