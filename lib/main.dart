import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final RemoteConfig remoteConfig = await RemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: Duration(seconds: 10),
    minimumFetchInterval: Duration(hours: 1),
  ));
  await remoteConfig.setDefaults(<String, dynamic>{
    'welcome': 'default welcome',
    'hello': 'default hello',
  });
  RemoteConfigValue(null, ValueSource.valueStatic);
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

  _save(String qrImageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'qrUrl';
    final value = qrImageUrl;
    prefs.setString(key, value);
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
      ),
    );
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
                  child: qrUrl != ""
                      ? Image.file(
                          File(qrUrl),
                          height: 250.0,
                          width: 250.0,
                        )
                      : registerForm(context),
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
  String plz = "";
  String city = "";
  String street = "";

  @override
  Widget registerForm(BuildContext context) {
    return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 32.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Vorname',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vorname ist erforderlich!';
                  }
                  fname = value;
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nachname',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nachname ist erforderlich!';
                  }
                  lname = value;
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Telefon',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Telefonnummer ist erforderlich!';
                  }
                  phone = value;
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Flexible(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Postleitzahl',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'PLZ ist erforderlich!';
                        }
                        plz = value;
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  new Flexible(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Stadt',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Stadt ist erforderlich!';
                        }
                        city = value;
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Straße',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Straße ist erforderlich!';
                  }
                  street = value;
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: <Widget>[
                    Checkbox(
                        value: _agreedToTOS,
                        onChanged: (bool newValue) {
                          setState(() {
                            _agreedToTOS = newValue;
                          });
                        }),
                    GestureDetector(
                      onTap: () => setState(() {
                        _agreedToTOS = !_agreedToTOS;
                      }),
                      child: new Container(
                        constraints: new BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 128),
                        child: Text(
                            'Ich stimme der Speicherung und Nutzung meiner Daten zu.'),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  const Spacer(),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      primary: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_formKey.currentState.validate()) {
                          if (_agreedToTOS) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Daten werden verarbeitet, bitte warten Sie')));
                            _submit();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Sie müssen der Verarbeitung Ihrer Daten zustimmen')));
                          }
                        }
                      });
                    },
                    child: const Text('Registrieren'),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  void _submit() {
    String address = street + ", " + plz + " " + city;
    FirebaseAuth.instance.signInAnonymously().then((value) {
      setState(() {
        storeNewUser(value.user, fname, lname, phone, address);
      });
    });
  }

  String uid;

  storeNewUser(User user, String fname, String lname, String phone,
      String address) async {
    FirebaseFirestore.instance.collection('/users').add({
      "firstName": fname,
      "lastName": lname,
      "phone": phone,
      "address": address,
      'uid': user.uid,
    }).catchError((e) {
      print(e);
    });
    HttpClient httpClient = new HttpClient();
    var request = await httpClient.getUrl(Uri.parse(
        "https://api.qrserver.com/v1/create-qr-code/?data=${user.uid}&size=250x250"));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    final Directory directory = await getApplicationDocumentsDirectory();
    final dir =
        await Directory(directory.path + "/assets").create(recursive: true);
    File file =
        await File('${dir.path}/${user.uid}.png').create(recursive: true);
    await file.writeAsBytes(bytes);

    _save(file.path);
    setState(() {
      qrUrl = file.path;
    });
  }
}
