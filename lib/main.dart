import 'package:flutter/material.dart';
import 'package:productdevelopment/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Dashboard.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLogin=false;
  @override
  void initState(){
    myColor = MaterialColor(0xFF004c4c, color);
    SharedPreferences.getInstance().then((prefs){
      if(prefs.getString("token")!=null){
        setState(() {
          isLogin=true;
        });
      }
    });
    super.initState();
  }
  Map<int, Color> color =
  {
    50:Color.fromRGBO(0,96,94,  .1),
    100:Color.fromRGBO(0,96,94, .2),
    200:Color.fromRGBO(0,96,94, .3),
    300:Color.fromRGBO(0,96,94, .4),
    400:Color.fromRGBO(0,96,94, .5),
    500:Color.fromRGBO(0,96,94, .6),
    600:Color.fromRGBO(0,96,94, .7),
    700:Color.fromRGBO(0,96,94, .8),
    800:Color.fromRGBO(0,96,94, .9),
    900:Color.fromRGBO(0,96,94,  1),
  };
  MaterialColor myColor;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product Development',
      theme: ThemeData(
        primarySwatch: myColor,
        brightness: Brightness.light,
      ),
      home: isLogin?Dashboard():Login(),

    );
  }

}
