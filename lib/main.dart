import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_qr/userManagement.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mosque Entrycontrol',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        accentColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        textSelectionHandleColor: Colors.black,
        textSelectionColor: Colors.black12,
        cursorColor: Colors.black,
        toggleableActiveColor: Colors.black,
        inputDecorationTheme: InputDecorationTheme(
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          labelStyle: const TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Mosque Entrycontrol'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState(this.title);
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  _MyHomePageState(this.title);

  final title;

  String imageUrl;
  bool color = false;
  Color pickerColor = new Color(0xff443a49);
  AnimationController _animationController;

  String qrUrl = "";

  _read() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'qrUrl';
    final value = prefs.getString(key) ?? "";
    qrUrl = value;
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    _read();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text("Mosque Entrycontrol"),
        leading: Icon(
          Icons.android,
          color: Colors.greenAccent,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              icon: Icon(
                Icons.account_circle_outlined,
                color: Colors.white,
              ))
        ],
      ),
      backgroundColor: Colors.white,
      body: ListView(
          children: [
      FirebaseAuth.instance.currentUser != null
      ? getLoggedIn(context)
          : registerForm(context)
      ],
    ),);
  }

  Widget getLoggedIn(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Stack(
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.only(top: 10),
                  height: 250,
                  width: 250,
                  child: qrUrl != "" ?
                  FadeInImage.assetNetwork(
                      placeholder: "assets/loading.gif", image: qrUrl) :
                  Image.asset(
                    "assets/loading.gif",
                    height: 250.0,
                    width: 250.0,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _agreedToTOS = true;

  String fname = "";
  String lname = "";
  String phone = "";
  String adress = "";

  @override
  Widget registerForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 32.0),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Vorname',
            ),
            validator: (String value) {
              if (value
                  .trim()
                  .isEmpty) {
                return 'Vorname ist erforderlich!';
              }
              fname = value;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Nachname',
            ),
            validator: (String value) {
              if (value
                  .trim()
                  .isEmpty) {
                return 'Nachname ist erforderlich!';
              }
              lname = value;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Telefon',
            ),
            validator: (String value) {
              if (value
                  .trim()
                  .isEmpty) {
                return 'Telefonnummer ist erforderlich!';
              }
              phone = value;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Adresse',
            ),
            validator: (String value) {
              if (value
                  .trim()
                  .isEmpty) {
                return 'Adresse ist erforderlich!';
              }
              adress = value;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: <Widget>[
                Checkbox(
                  value: _agreedToTOS,
                  onChanged: _setAgreedToTOS,
                ),
                GestureDetector(
                  onTap: () => _setAgreedToTOS(!_agreedToTOS),
                  child: const Text(
                    'Ich stimme der Speicherung und Nutzung \n meiner Daten zu.',
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              const Spacer(),
              OutlineButton(
                highlightedBorderColor: Colors.black,
                onPressed: () {
                  setState(() {
                    if(_agreedToTOS) {
                      _submit();
                    }
                  });

                } ,
                child: const Text('Registrieren'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit(){
    _formKey.currentState.validate();
    FirebaseAuth.instance
        .signInAnonymously()
        .then((value) {
      setState(() {
        storeNewUser(
            value.user, fname, lname, phone, adress);
      });
    });
  }

  void _setAgreedToTOS(bool newValue) {
    setState(() {
      _agreedToTOS = newValue;
    });
  }

  String uid;
  storeNewUser(User user, String fname, String lname, String phone, String adress) async {
    FirebaseFirestore.instance.collection('/users').add({
      "firstName": fname,
      "lastName": lname,
      "phone": phone,
      "address": adress,
      'uid': user.uid,
    }).catchError((e) {
      print(e);
    });
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
    _save(downloadUrl);
    setState(() {
      qrUrl = downloadUrl;
    });
  }


_save(String qrImageUrl) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'qrUrl';
  final value = qrImageUrl;
  prefs.setString(key, value);
}

}