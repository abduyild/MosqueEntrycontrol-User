import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:confirm_dialog/confirm_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moschee-Ausweis',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        accentColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
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
      home: MyHomePage(title: ''),
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

  String titleText = "Ausweis erstellen";

  final title;

  String imageUrl;
  bool color = false;
  Color pickerColor = new Color(0xff443a49);
  AnimationController _animationController;

  String qrUrl = "";
  String name = "";

  _read(String prefKey) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(prefKey) ?? "";
    if (prefKey == "qrurl") {
      setState(() {
        qrUrl = value;
      });
    } else if (prefKey == "name") {
      setState(() {
        name = value;
      });
    }
  }

  _save(String prefKey, String prefValue) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(prefKey, prefValue);
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _read("qrurl");
    _read("name");
    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        backgroundColor: Colors.black12,
        elevation: 0,
        actions: [
          IconButton(
            icon: qrUrl != "" ? Icon(Icons.logout,
              color: Colors.black) : Icon(
              Icons.account_circle_outlined,
              color: Colors.black,
            ),
            onPressed: () async{
              if(qrUrl != "") {
                if (await confirm(
                context,
                title: Text('Bestätigen'),
              content: Text('Möchten Sie sich wirklich abmelden? Sie müssen dann erneut alle Daten eingeben.'),
              textOK: Text('Ja'),
              textCancel: Text('Nein'),
              )) {
                  qrUrl = "";
                  _save("qrurl", "");
              }
              }
            },
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [getContent(context)],
      ),
    );
  }

  Widget getContent(BuildContext context) {
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
                      ? new Column(children: <Widget>[
                          Image.file(
                            File(qrUrl),
                            height: 250.0,
                            width: 250.0,
                          ),
                          const SizedBox(height: 24.0),
                          new Container(
                            constraints: new BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width - 128),
                            child: Text(name,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 20.0)),
                          ),
                        ])
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
  bool _agreedToTOS = false;

  String fname = "";
  String lname = "";
  String phone = "";
  String adress = "";
  String plz = "";
  String city = "";
  String street = "";
  String number = "";

  Widget registerForm(BuildContext context) {
    final node = FocusScope.of(context);
    return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 12.0),
              TextFormField(
                textInputAction: TextInputAction.next,
                onEditingComplete: () => node.nextFocus(),
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
                textInputAction: TextInputAction.next,
                onEditingComplete: () => node.nextFocus(),
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
                textInputAction: TextInputAction.next,
                onEditingComplete: () => node.nextFocus(),
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
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () => node.nextFocus(),
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
                    width: 16.0,
                  ),
                  new Flexible(
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () => node.nextFocus(),
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
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Flexible(
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () => node.nextFocus(),
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
                  ),
                  SizedBox(
                    width: 16.0,
                  ),
                  new Flexible(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Hausnummer',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Hausnummer ist erforderlich!';
                        }
                        number = value;
                        return null;
                      },
                    ),
                  ),
                ],
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
                            'Ich stimme der Speicherung und Nutzung meiner Daten zu. Für Information zum Umgang mit diesen Daten, klicken Sie unten auf den Knopf'),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
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
          const Spacer(),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              primary: Colors.black,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => _buildPopupDialog(context),
              );
            },
            child: const Text('Datennutzung'),
          ),

      ],
              ),
            ],
          ),
        ));
  }

  Widget _buildPopupDialog(BuildContext context) {
    return new AlertDialog(
      title: const Text('Datennutzung'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Es ist lediglich befugtes Personal ermächtigt, Ihre Daten zu erheben und einzusehen."
              "Alle interessierte Moscheen untergehen einer Schulung und stimmen der Datenschutzgerechten Verarbeitung und Handhabung Ihrer Daten zu."
              "Ihre Daten werden verschlüsselt an einen Drittanbieter (goqr.me) zum erstellen des QR-Codes gesendet. "
              "Ihre persönlichen Daten sind auf dem QR-Code gespeichert. Sie sind dafür verantwortlich, diese Daten lediglich entsprechenden befugten Stellen zu zeigen (Moscheen welche die App zum Erfassen verwenden."
              "Ihre Daten werden zudem nach erfolgreicher Anmeldung auf einem passwort-geschützten Server gespeichert und sind lediglich für die nächsten 30 Tage von befugtem Personal, bei einem Falle einer positiv getesteten Person unter den Anmeldungen, einsehbar."),
        ],
      ),
      actions: <Widget>[
        new OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: OutlinedButton.styleFrom(
            primary: Colors.black,
          ),
          child: const Text('Schließen'),
        ),
      ],
    );
  }


  void _submit() {
    String address = street + " " + number + ", " + plz + " " + city;
    setState(() {
      storeNewUser(fname, lname, phone, address);
    });
  }

  storeNewUser(String fname, String lname, String phone, String address) async {
    var reference = fname + ";" + lname + ";" + phone + ";" + address;
    var refString = replaceWhitespace(reference);
    if (refString == "") {
      return;
    }
    HttpClient httpClient = new HttpClient();
    var request = await httpClient.getUrl(Uri.parse(
        "https://api.qrserver.com/v1/create-qr-code/?data=${refString}&size=300x300"));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    final Directory directory = await getApplicationDocumentsDirectory();
    final dir =
        await Directory(directory.path + "/assets").create(recursive: true);
    File file = await File('${dir.path}/${fname}.png').create(recursive: true);
    await file.writeAsBytes(bytes);

    _save("qrurl", file.path);
    _save("name", fname + " " + lname);
    setState(() {
      titleText = "Moschee Ausweis";
      qrUrl = file.path;
    });
  }

  String replaceWhitespace(String s) {
    if (s == null) {
      return "";
    }
    final pattern = RegExp('\\s+');
    return s.replaceAll(pattern, "+");
  }
}
