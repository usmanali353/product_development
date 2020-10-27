import 'dart:io';
import 'package:badges/badges.dart';
import 'package:productdevelopment/DailyClientSchedule.dart';
import 'package:productdevelopment/Model/AssignedRejectedModels.dart';
import 'package:productdevelopment/Notifications/NotificationListPage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:need_resume/need_resume.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:productdevelopment/RejectedModelsActions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AllRequestsList.dart';
import 'CustomerRejectionPageWithJustification.dart';
import 'ModelRequests.dart';
import 'Network_Operations/Network_Operations.dart';
import 'ProductionManagerRequests.dart';
import 'Utils/Utils.dart';
import 'request_Model_form/Assumptions.dart';
class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends ResumableState<Dashboard> {
 var claims;
 var requestCount,notificationCount;
 var currentUserRoles;
 FirebaseMessaging messaging;
 final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
 @override
  void onResume() {
   WidgetsBinding.instance
       .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    super.onResume();
  }
 @override
  void initState() {
   messaging=FirebaseMessaging();
   messaging.getToken().then((value) =>debugPrint(value));
   messaging.configure(
       onMessage:(Map<String, dynamic> message)async{
         WidgetsBinding.instance
             .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
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
   WidgetsBinding.instance
       .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Container(
              color: Color(0xEBECF0),
              alignment: Alignment.topCenter,
              child: DrawerHeader(
                child:  Image.asset("Assets/img/AC.png",width: 200,height: 200,),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  currentUserRoles!=null&&currentUserRoles["1"]!=null?Column(
                    children: [
                      ListTile(
                        title: Text("Add Model Request"),
                        leading: Icon(Icons.add),
                        onTap: (){
                          Navigator.push(context,MaterialPageRoute(builder: (context)=>Assumptions()));
                        },
                      ),
                      Divider(),
                    ],
                  ):Container(),
                  ListTile(
                    title: Text("Scan Barcode"),
                    leading: Icon(FontAwesomeIcons.barcode),
                    onTap: (){
                     Utils.scan(context);
                      //Navigator.push(context, MaterialPageRoute(builder: (context)=>QRScanner()));
                    },
                  ),
                  Divider(),
                  currentUserRoles!=null&&currentUserRoles["12"]!=null?Column(
                    children: [
                      ListTile(
                        title: Text("Model Rejection Actions"),
                        leading: Icon(FontAwesomeIcons.gavel),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>RejectedModelActions()));
                        },
                      ),
                      Divider(),
                    ],
                  ):Container(),
                  currentUserRoles!=null&&currentUserRoles["11"]!=null?Column(
                    children: [
                      ListTile(
                        title: Text("Client Visit Schedule"),
                        leading: Icon(Icons.schedule),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>DailyClientSchedule()));
                        },
                      ),
                      Divider(),
                    ],
                  ):Container(),
                  ListTile(
                    title: Text("Sign Out"),
                    leading: Icon(FontAwesomeIcons.signOutAlt),
                    onTap: (){
                     SharedPreferences.getInstance().then((prefs){

                       messaging.getToken().then((fcmToken){
                         Network_Operations.deleteFCMToken(context, claims["nameid"],fcmToken, prefs.getString("token")).then((value){
                           prefs.remove("token");
                         });
                       });
                     });
                    },
                  ),

                ],
              ),
            )
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
            icon:Badge(
              toAnimate: true,
              showBadge:notificationCount!=null&&notificationCount['Unread Notifications Count']!=null&&notificationCount['Unread Notifications Count']!=0,
                badgeContent: Text(notificationCount!=null&&notificationCount['Unread Notifications Count']!=null?notificationCount['Unread Notifications Count'].toString():'',style: TextStyle(color: Colors.white),),
                child: Icon(Icons.notifications)
            ),
            onPressed: (){
              push(context, MaterialPageRoute(builder: (context)=>NotificationListPage()));
            },
          )
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: (){
          return Utils.check_connectivity().then((isConnected){
            if(isConnected){
              SharedPreferences.getInstance().then((prefs){
                setState(() {
                  claims=Utils.parseJwt(prefs.getString("token"));
                  if(!claims['role'].contains("Client")) {
                    Network_Operations.getRequestCount(context, prefs.getString("token")).then((requestCountMap){
                      setState(() {
                        this.requestCount=requestCountMap['statuses'];
                        this.currentUserRoles=requestCountMap['currentLoggedInUserStatuses'];
                        this.notificationCount=requestCountMap['notificationsCount'];
                      });
                    });
                  }else{
                    Network_Operations.getRequestCountIndividualUser(context,prefs.getString("token")).then((requestCountMap){
                      setState(() {
                        this.requestCount=requestCountMap['statuses'];
                        this.currentUserRoles=requestCountMap['currentLoggedInUserStatuses'];
                      });
                    });
                  }
                });

              });
            }else{
              Utils.showError(context, "Network Not Available");
            }
          });
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                image: AssetImage('Assets/img/pattren.png'),
              )
          ),
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top:16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(margin: EdgeInsets.only(left: 17),
                        child: Text("Model Requests", style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),)
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: claims!=null&&!claims['role'].contains("Client"),
                child: Padding(
                  padding: EdgeInsets.only(top: 15),
                ),
              ),
              Visibility(
                visible: claims!=null&&!claims['role'].contains("Client"),
                child: InkWell(
                  onTap: (){
                    push(context, MaterialPageRoute(builder: (context)=>AllRequestList(currentUserRoles)));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0,right:8.0),
                    child: Card(
                      elevation: 10,
                      child: Container(
                        // margin: EdgeInsets.only(left: 12.5,right: 12.5),
                        height: 130,
                        width: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(left: 12),
                              child: Text("All Requests",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            Container(
                              //margin: EdgeInsets.only(left: 10, top: 5,bottom: 5),
                              height: 30,
                              width: MediaQuery.of(context).size.width *0.35,
                              //width: 145,
                              decoration: BoxDecoration(

                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    bottomLeft: Radius.circular(15)
                                ),
                                color: Color(0xFF004c4c),
                              ),
                              child: Container(margin: EdgeInsets.only(left: 10,top: 5),
                                child: Text(requestCount!=null&&requestCount['All Requests Count']!=null?requestCount['All Requests Count'].toString():"0",
                                  style: TextStyle(
                                      color:Colors.white,
                                      //Color(0xFF004c4c),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold
                                  ),

                                ),
                              ),
                            ),
                          ],
                        ),

                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 15),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  InkWell(
                    onTap:(){
                      push(context, MaterialPageRoute(builder: (context)=>ModelRequests(1,currentUserRoles)));
                    },
                    child: Card(
                      elevation: 10,
                      child: Container(
                        height: 130,
                        //width: 185,
                        width: MediaQuery.of(context).size.width * 0.45 ,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xFF004c4c),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              //margin: EdgeInsets.only(left: 12),
                              child: Text("New Requests",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 5, right: 5),
                              height: 30,
                              width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey.shade100,
                              ),
                              child: Center(
                                child: Container(
                                  //margin: EdgeInsets.only(left: 10,top: 5),
                                  child: Text(requestCount!=null&&requestCount['New Request']!=null?requestCount['New Request'].toString():"0", style: TextStyle(color:Color(0xFF004c4c),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold
                                  ),

                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Weekly Deliveries
                  InkWell(
                    onTap: (){
                      push(context, MaterialPageRoute(builder: (context)=>ModelRequests(3,currentUserRoles)));
                    },
                    child: Card(
                      elevation: 10,
                      child: Container(
                        height: 130,
                        width: MediaQuery.of(context).size.width * 0.45 ,
                        //width: MediaQuery.of(context).size.width /2.2 ,
                        //width: 185,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0xFF004c4c),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              //margin: EdgeInsets.only(left: 12),
                              child: Text('ACMC Rejected',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            Container(
                              //padding: EdgeInsets.all(3),
                              margin: EdgeInsets.only(left: 5, right: 5),

                              height: 30,
                              width: 145,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey.shade100,
                              ),
                              child: Center(
                                child: Container(
                                  //margin: EdgeInsets.only(left: 10,top: 5),
                                  child: Text(requestCount!=null&&requestCount['Rejected By GM']!=null?requestCount['Rejected By GM'].toString():"0",
                                    style: TextStyle(
                                        color:Colors.teal.shade800,
                                        //Color(0xFF004c4c),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),

                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 8.0),
              ),
              InkWell(
                onTap: (){
                 push(context, MaterialPageRoute(builder: (context)=>ModelRequests(2,currentUserRoles)));
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0,right:8.0),
                  child: Card(
                    elevation: 10,
                    child: Container(
                      // margin: EdgeInsets.only(left: 12.5,right: 12.5),
                      height: 130,
                      width: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 12),
                            child: Text("ACMC Approved",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Container(
                            //margin: EdgeInsets.only(left: 10, top: 5,bottom: 5),
                            height: 30,
                            width: MediaQuery.of(context).size.width *0.35,
                            //width: 145,
                            decoration: BoxDecoration(

                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomLeft: Radius.circular(15)
                              ),
                              color: Color(0xFF004c4c),
                            ),
                            child: Container(margin: EdgeInsets.only(left: 10,top: 5),
                              child: Text(requestCount!=null&&requestCount['Approved By GM']!=null?requestCount['Approved By GM'].toString():"0",
                                style: TextStyle(
                                    color:Colors.white,
                                    //Color(0xFF004c4c),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold
                                ),

                              ),
                            ),
                          ),
                        ],
                      ),

                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  //Today Deliveries
                  InkWell(
                    onTap:(){
                      push(context, MaterialPageRoute(builder: (context)=>ModelRequests(4,currentUserRoles)));
                    },
                    child: Card(
                      elevation: 10,
                      child: Container(
                        height: 130,
                        //width: 185,
                        width: MediaQuery.of(context).size.width * 0.45 ,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0xFF004c4c),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              //margin: EdgeInsets.only(left: 12),
                              child: Text("Samples Scheduled",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 5, right: 5),
                              height: 30,
                              width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey.shade100,
                              ),
                              child: Center(
                                child: Container(
                                  //margin: EdgeInsets.only(left: 10,top: 5),
                                  child: Text(requestCount!=null&&requestCount['Samples Scheduled']!=null?requestCount['Samples Scheduled'].toString():"0", style: TextStyle(color:Color(0xFF004c4c),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold
                                  ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Weekly Deliveries
                  InkWell(
                    onTap: (){
                     push(context, MaterialPageRoute(builder: (context)=>ModelRequests(6,currentUserRoles)));
                    },
                    child: Card(
                      elevation: 10,
                      child: Container(
                        height: 130,
                        width: MediaQuery.of(context).size.width * 0.45 ,
                        //width: MediaQuery.of(context).size.width /2.2 ,
                        //width: 185,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0xFF004c4c),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              //margin: EdgeInsets.only(left: 12),
                              child: Text('Rejected Models',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            Container(
                              //padding: EdgeInsets.all(3),
                              margin: EdgeInsets.only(left: 5, right: 5),
                              height: 30,
                              width: 145,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey.shade100,
                              ),
                              child: Center(
                                child: Container(
                                  //margin: EdgeInsets.only(left: 10,top: 5),
                                  child: Text(requestCount!=null&&requestCount['Model Rejected']!=null?requestCount['Model Rejected'].toString():"0",
                                    style: TextStyle(
                                        color:Colors.teal.shade800,
                                        //Color(0xFF004c4c),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 8.0),
              ),
              InkWell(
                onTap: (){
                push(context, MaterialPageRoute(builder: (context)=>ModelRequests(5,currentUserRoles)));
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0,right:8.0),
                  child: Card(
                    elevation: 10,
                    child: Container(
                      // margin: EdgeInsets.only(left: 12.5,right: 12.5),
                      height: 130,
                      width: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 12),
                            child: Text("Approved Models",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Container(
                            //margin: EdgeInsets.only(left: 10, top: 5,bottom: 5),
                            height: 30,
                            width: MediaQuery.of(context).size.width *0.35,
                            //width: 145,
                            decoration: BoxDecoration(

                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomLeft: Radius.circular(15)
                              ),
                              color: Color(0xFF004c4c),
                            ),
                            child: Container(margin: EdgeInsets.only(left: 10,top: 5),
                              child: Text(requestCount!=null&&requestCount['Model Approved']!=null?requestCount['Model Approved'].toString():"0",
                                style: TextStyle(
                                    color:Colors.white,
                                    //Color(0xFF004c4c),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  //Today Deliveries
                  InkWell(
                    onTap:(){
                     push(context, MaterialPageRoute(builder: (context)=>ProductionManagerRequests(7,"Dashboard",currentUserRoles)));
                    },
                    child: Card(
                      elevation: 10,
                      child: Container(
                        height: 130,
                        //width: 185,
                        width: MediaQuery.of(context).size.width * 0.45 ,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0xFF004c4c),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              //margin: EdgeInsets.only(left: 12),
                              child: Text("Customer Approved",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 5, right: 5),
                              height: 30,
                              width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey.shade100,
                              ),
                              child: Center(
                                child: Container(
                                  //margin: EdgeInsets.only(left: 10,top: 5),
                                  child: Text(requestCount!=null&&requestCount['Approved By Customer']!=null?requestCount['Approved By Customer'].toString():"0", style: TextStyle(color:Color(0xFF004c4c),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold
                                  ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Weekly Deliveries
                  InkWell(
                    onTap: (){
                      push(context, MaterialPageRoute(builder: (context)=>ProductionManagerRequests(8,"Dashboard",currentUserRoles)));
                    },
                    child: Card(
                      elevation: 10,
                      child: Container(
                        height: 130,
                        width: MediaQuery.of(context).size.width * 0.45 ,
                        //width: MediaQuery.of(context).size.width /2.2 ,
                        //width: 185,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0xFF004c4c),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              //margin: EdgeInsets.only(left: 12),
                              child: Text('Customer Rejected',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            Container(
                              //padding: EdgeInsets.all(3),
                              margin: EdgeInsets.only(left: 5, right: 5),
                              height: 30,
                              width: 145,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey.shade100,
                              ),
                              child: Center(
                                child: Container(
                                  //margin: EdgeInsets.only(left: 10,top: 5),
                                  child: Text(requestCount!=null&&requestCount['Rejected By Customer']!=null?requestCount['Rejected By Customer'].toString():"0",
                                    style: TextStyle(
                                        color:Colors.teal.shade800,
                                        //Color(0xFF004c4c),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 15),
              ),
              InkWell(
                onTap: (){
                  push(context, MaterialPageRoute(builder: (context)=>CustomerRejectionPageWithJustification(1)));
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0,right:8.0),
                  child: Card(
                    elevation: 10,
                    child: Container(
                      // margin: EdgeInsets.only(left: 12.5,right: 12.5),
                      height: 130,
                      width: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 12),
                            child: Text("Justified Rejections",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Container(
                            //margin: EdgeInsets.only(left: 10, top: 5,bottom: 5),
                            height: 30,
                            width: MediaQuery.of(context).size.width *0.35,
                            //width: 145,
                            decoration: BoxDecoration(

                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomLeft: Radius.circular(15)
                              ),
                              color: Color(0xFF004c4c),
                            ),
                            child: Container(margin: EdgeInsets.only(left: 10,top: 5),
                              child: Text(requestCount!=null&&requestCount['Rejection Justified']!=null?requestCount['Rejection Justified'].toString():"0",
                                style: TextStyle(
                                    color:Colors.white,
                                    //Color(0xFF004c4c),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // Weekly Deliveries
                  InkWell(
                    onTap: (){
                      push(context, MaterialPageRoute(builder: (context)=>CustomerRejectionPageWithJustification(0)));
                    },
                    child: Card(
                      elevation: 10,
                      child: Container(
                        height: 130,
                        width: MediaQuery.of(context).size.width * 0.45 ,
                        //width: MediaQuery.of(context).size.width /2.2 ,
                        //width: 185,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0xFF004c4c),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              //margin: EdgeInsets.only(left: 12),
                              child: Text('UnJustified Rejections',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            Container(
                              //padding: EdgeInsets.all(3),
                              margin: EdgeInsets.only(left: 5, right: 5),
                              height: 30,
                              width: 145,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey.shade100,
                              ),
                              child: Center(
                                child: Container(
                                  //margin: EdgeInsets.only(left: 10,top: 5),
                                  child: Text(requestCount!=null&&requestCount['Rejection UnJustified']!=null?requestCount['Rejection UnJustified'].toString():"0",
                                    style: TextStyle(
                                        color:Colors.teal.shade800,
                                        //Color(0xFF004c4c),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      push(context, MaterialPageRoute(builder: (context)=>ProductionManagerRequests(10,"Dashboard",currentUserRoles)));
                    },
                    child: Card(
                      elevation: 10,
                      child: Container(
                        height: 130,
                        width: MediaQuery.of(context).size.width * 0.45 ,
                        //width: MediaQuery.of(context).size.width /2.2 ,
                        //width: 185,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0xFF004c4c),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              //margin: EdgeInsets.only(left: 12),
                              child: Text('Production Rejected',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            Container(
                              //padding: EdgeInsets.all(3),
                              margin: EdgeInsets.only(left: 5, right: 5),
                              height: 30,
                              width: 145,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey.shade100,
                              ),
                              child: Center(
                                child: Container(
                                  //margin: EdgeInsets.only(left: 10,top: 5),
                                  child: Text(requestCount!=null&&requestCount['Rejected For Production']!=null?requestCount['Rejected For Production'].toString():"0",
                                    style: TextStyle(
                                        color:Colors.teal.shade800,
                                        //Color(0xFF004c4c),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 15),
              ),
              InkWell(
                onTap: (){
                  push(context, MaterialPageRoute(builder: (context)=>ProductionManagerRequests(9,"Dashboard",currentUserRoles)));
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0,right:8.0),
                  child: Card(
                    elevation: 10,
                    child: Container(
                      // margin: EdgeInsets.only(left: 12.5,right: 12.5),
                      height: 130,
                      width: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 12),
                            child: Text("Production Approved",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Container(
                            //margin: EdgeInsets.only(left: 10, top: 5,bottom: 5),
                            height: 30,
                            width: MediaQuery.of(context).size.width *0.35,
                            //width: 145,
                            decoration: BoxDecoration(

                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomLeft: Radius.circular(15)
                              ),
                              color: Color(0xFF004c4c),
                            ),
                            child: Container(margin: EdgeInsets.only(left: 10,top: 5),
                              child: Text(requestCount!=null&&requestCount['Approved For Production']!=null?requestCount['Approved For Production'].toString():"0",
                                style: TextStyle(
                                    color:Colors.white,
                                    //Color(0xFF004c4c),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    super.dispose();
  }

}
