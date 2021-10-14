import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:productdevelopment/Login.dart';
import 'package:productdevelopment/Dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Network_Operations/Network_Operations.dart';
import 'Utils/Utils.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //HttpOverrides.global = new MyHttpOverrides();
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
    super.initState();
    myColor = MaterialColor(0xFF004c4c, color);

    SharedPreferences.getInstance().then((prefs){

      if(prefs.getString("token")!=null){
        if(prefs.getBool("is_otp_verified")==null||prefs.getBool("is_otp_verified")==true){
          var claims=Utils.parseJwt(prefs.getString("token"));

          if(DateTime.fromMillisecondsSinceEpoch(int.parse(claims['exp'].toString()+"000")).isAfter(DateTime.now())){
            print(DateTime.fromMillisecondsSinceEpoch(int.parse(claims['exp'].toString()+"000")));
            setState(() {
              isLogin=true;
            });

          }else{
            if(Platform.isAndroid){
              SharedPreferences.getInstance().then((prefs){
                FirebaseMessaging.instance.getToken().then((fcmToken){
                  Network_Operations.deleteFCMToken(context, claims["nameid"],fcmToken, prefs.getString("token")).then((value){
                    prefs.remove("token");
                    prefs.remove("is_otp_verified");
                  });
                });
              });
            }else{
              SharedPreferences.getInstance().then((prefs){
                prefs.remove("token");
                prefs.remove("is_otp_verified");
              });
            }
          }
        }
      }

    });
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