import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DetailsPage.dart';
import 'Network_Operations/DynamicLinkService.dart';
import 'Utils/Utils.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController username,password;
  bool isVisible=true;
  @override
  void initState() {
    super.initState();
    DynamicLinkService.handleDynamicLinks(context);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if(message.data!=null){
        print("Message Data "+message.data["RequestId"]);
        if(message.data["RequestId"]!=null){
          SharedPreferences.getInstance().then((prefs){
            Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"),int.parse(message.data["RequestId"])).then((req){
              Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(context)=>DetailsPage(req)), (route) => false);
            });
          });
        }
      }
    });
    username=TextEditingController();
    password=TextEditingController();
    Utils.setupQuickActions(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Container(
        padding: EdgeInsets.only(top: 55, bottom: 20),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("Assets/img/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Image.asset('Assets/img/login.png',width: 230,height: 230,),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                      controller: username,
                      style: TextStyle(color: Colors.white),
                      decoration: new InputDecoration(
                        prefixIcon: Icon(Icons.person,color: Colors.white,),
                        border: new OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.white, width: 2),
                        ),
                        focusedBorder: new OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.white, width: 2),
                        ),
                        enabledBorder: new OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.white, width: 2),
                        ),
                        disabledBorder: new OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.blueGrey, width: 2),
                        ),
                        errorBorder: new OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        focusedErrorBorder: new OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        filled: false,
                        hintStyle: new TextStyle(color: Colors.white70),
                        hintText: "Username",
                      )
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20,right: 20),
                  child: TextField(
                      controller: password,
                      style: TextStyle(color: Colors.white),
                      obscureText: isVisible,
                      decoration: new InputDecoration(
                          labelStyle: TextStyle(color:Colors.white),
                          prefixIcon: Icon(Icons.lock,color: Colors.white,),
                          suffixIcon: IconButton(icon: Icon(isVisible?Icons.visibility:Icons.visibility_off,color: Colors.white,size: 27),onPressed: () {
                          setState(() {
                            if(isVisible){
                              isVisible=false;
                            }else{
                              isVisible=true;
                            }
                          });
                        },//(Icons.https,color: yellowColor,size: 27,)
                      ),
                          border: new OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.white, width: 10),
                          ),
                          focusedBorder: new OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.white, width: 2),
                          ),
                          enabledBorder: new OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.white, width: 2),
                          ),
                          disabledBorder: new OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.blueGrey, width: 2),
                          ),
                          errorBorder: new OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                          focusedErrorBorder: new OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                          filled: false,
                          hintStyle: new TextStyle(color: Colors.white70),
                          hintText: "Password",
                          fillColor: Colors.white70
                      )
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Builder(
                    builder: (BuildContext context){
                      return MaterialButton(
                        padding: EdgeInsets.all(16),
                        minWidth: MediaQuery.of(context).size.width,
                        onPressed: (){
                         if(username.text==null||username.text.isEmpty){
                           Utils.showError(context, "Enter Email");
                         }else if(!Utils.validateEmail(username.text)) {
                          Utils.showError(context, "Invalid Email");
                         }else if(password.text==null||password.text.isEmpty){
                           Utils.showError(context, "Enter Password");
                         }else if(!Utils.validatePassword(password.text)){
                           Utils.showError(context, "Invalid Password");
                         }else {
                           Network_Operations.signIn(context, username.text, password.text);
                         }
                        },
                        color: Colors.white,
                        child: Text("SIGN IN",style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.teal
                        ),),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      );
                    },
                  ),
                )
              ],
            )
          ],
        ) /* add child content here */,
      ),
    );
  }
}