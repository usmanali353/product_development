import 'package:flutter/material.dart';
import 'package:productdevelopment/Login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    myColor = MaterialColor(0xFF004c4c, color);
    return MaterialApp(
      title: 'Product Development',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: myColor,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Login(),
    );
  }
}

