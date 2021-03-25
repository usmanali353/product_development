import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:productdevelopment/Login.dart';
import 'package:productdevelopment/Dashboard.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/Notifications/NotificationListPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Network_Operations/MyHttpOverrides.dart';
import 'Utils/Utils.dart';
void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
  FirebaseMessaging().configure(
      onMessage:(Map<String, dynamic> message)async{
        showOverlayNotification((context) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: SafeArea(
              child: ListTile(
                leading:Icon(Icons.notifications,color: Theme.of(context).primaryColor,size: 40,),
                title: Text(message['notification']['title']),
                subtitle: Text(message['notification']['body']),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>NotificationListPage()));
                },
                trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      OverlaySupportEntry.of(context).dismiss();
                    }),
              ),
            ),
          );
        }, duration: Duration(milliseconds: 5000));
      },
      onBackgroundMessage: Platform.isIOS ? null : Network_Operations.myBackgroundMessageHandler,
      onResume: (Map<String, dynamic> message) async{
        print(message.toString());
      },
      onLaunch: (Map<String, dynamic> message)async{
        print(message.toString());
      }
  );
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

        var claims=Utils.parseJwt(prefs.getString("token"));

        if(DateTime.fromMillisecondsSinceEpoch(int.parse(claims['exp'].toString()+"000")).isAfter(DateTime.now())){
          print(DateTime.fromMillisecondsSinceEpoch(int.parse(claims['exp'].toString()+"000")));
          setState(() {
            isLogin=true;
          });

        }

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

    return OverlaySupport(

      child: MaterialApp(


        debugShowCheckedModeBanner: false,

        title: 'ACMC Products',

        theme: ThemeData(

          primarySwatch: myColor,

          brightness: Brightness.light,

        ),

        home: isLogin?Dashboard():Login(),

      ),
    );

  }




}
