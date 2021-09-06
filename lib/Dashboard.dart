import 'dart:io';
import 'package:badges/badges.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:intl/intl.dart';
import 'package:need_resume/need_resume.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:productdevelopment/DailyClientSchedule.dart';
import 'package:productdevelopment/Notifications/NotificationListPage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:productdevelopment/RejectedModelsActions.dart';
import 'package:r_upgrade/r_upgrade.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AllRequestsList.dart';
import 'CustomerRejectionPageWithJustification.dart';
import 'DetailsPage.dart';
import 'ModelRequests.dart';
import 'Network_Operations/Network_Operations.dart';
import 'ProductionManagerRequests.dart';
import 'Utils/Utils.dart';
import 'request_Model_form/Assumptions.dart';
class Dashboard extends StatefulWidget {
  @override
  _CRMDashboardState createState() => _CRMDashboardState();
}
Future<void> _messageHandler(RemoteMessage message) async {
  if(message!=null){
    if(message.data!=null){
      print("Message Data "+message.data["RequestId"]);
      if(message!=null&&message.data!=null&&message.data["RequestId"]!=null){
        // SharedPreferences.getInstance().then((prefs){
        //   Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"),int.parse(message.data["RequestId"])).then((req){
        //     Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(context)=>DetailsPage(req)), (route) => false);
        //   });
        // });
      }
    }
  }
}
class _CRMDashboardState extends ResumableState<Dashboard> {
  var claims;
  var requestCount,notificationCount;
  var currentUserRoles;
  bool isDateBarVisible=false;
  List<DateTime> picked=[];
  DateTime initialStart=DateTime.now(),initialEnd=DateTime.now().add(Duration(days: 0));
  PendingDynamicLinkData data;
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
    super.initState();
    FirebaseMessaging.onBackgroundMessage(_messageHandler);
    FirebaseDynamicLinks.instance.getInitialLink().then((deeplink){
      setState(() {
        this.data=deeplink;
        if(data!=null&&data.link!=null){
          print(data.link);
          SharedPreferences.getInstance().then((prefs){
            Network_Operations.getRequestByIdNotifications(context,prefs.getString("token"),int.parse(data.link.toString().split("?")[1].replaceAll("RequestId=", ""))).then((req){
              Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(context)=>DetailsPage(req)), (route) => false);
            });
          });
        }
      });
    });
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          // 3a. handle link that has been retrieved
          setState(() {
            this.data=dynamicLink;
            print(data.link);
            if(data!=null&&data.link!=null){
              SharedPreferences.getInstance().then((prefs){
                Network_Operations.getRequestByIdNotifications(context,prefs.getString("token"),int.parse(data.link.toString().split("?")[1].replaceAll("RequestId=", ""))).then((req){
                  Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(context)=>DetailsPage(req)), (route) => false);
                });
              });
            }
          });
        }, onError: (OnLinkErrorException e) async {
      print('Link Failed: ${e.message}');
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if(message!=null&&message.data!=null){
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
    if(Platform.isAndroid){
      messaging=FirebaseMessaging.instance;
      messaging.getToken().then((value) =>debugPrint(value));
      //for OnLaunch
      messaging.getInitialMessage().then((RemoteMessage message) {
        if(data!=null&&data.link!=null){
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
      //for onMessage
      FirebaseMessaging.onMessage.listen((RemoteMessage message)async{
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
        showOverlayNotification((context){
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: SafeArea(
              child: ListTile(
                leading:Icon(Icons.notifications,color: Theme.of(context).primaryColor,size: 40,),
                title: Text(message.notification.title),
                subtitle: Text(message.notification.body),
                onTap: (){
                  push(context, MaterialPageRoute(builder: (context)=>NotificationListPage()));
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
      });

      // messaging.configure(
      //     onMessage:(Map<String, dynamic> message)async{
      //       WidgetsBinding.instance
      //           .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
      //       showOverlayNotification((context) {
      //         return Card(
      //           margin: const EdgeInsets.symmetric(horizontal: 4),
      //           child: SafeArea(
      //             child: ListTile(
      //               leading:Icon(Icons.notifications,color: Theme.of(context).primaryColor,size: 40,),
      //               title: Text(message['notification']['title']),
      //               subtitle: Text(message['notification']['body']),
      //               onTap: (){
      //                 push(context, MaterialPageRoute(builder: (context)=>NotificationListPage()));
      //               },
      //               trailing: IconButton(
      //                   icon: Icon(Icons.close),
      //                   onPressed: () {
      //                     OverlaySupportEntry.of(context).dismiss();
      //                   }),
      //             ),
      //           ),
      //         );
      //       }, duration: Duration(milliseconds: 5000));
      //     },
      //     onBackgroundMessage: Platform.isIOS ? null : Network_Operations.myBackgroundMessageHandler,
      //     onResume: (Map<String, dynamic> message) async{
      //       print(message.toString());
      //     },
      //     onLaunch: (Map<String, dynamic> message)async{
      //       print(message.toString());
      //     }
      // );
    }

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    // Utils.check_connectivity().then((isConnected){
    //   if(isConnected){
    //
    //   }else{
    //     Utils.showError(context,"Network Not Available");
    //   }
    // });
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
                          push(context,MaterialPageRoute(builder: (context)=>Assumptions()));
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
                        leading: Icon(Icons.event),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>DailyClientSchedule()));
                        },
                      ),
                      Divider(),
                    ],
                  ):Container(),
                  ListTile(
                    title: Text("Check for Updates"),
                    leading: Icon(FontAwesomeIcons.sync),
                    onTap: (){
                      PackageInfo.fromPlatform().then((pkg){
                        print("App Version "+pkg.version);
                        print("App Package Name "+pkg.packageName);
                        print("App Name "+pkg.appName);
                        Network_Operations.checkUpdate(context).then((response){
                          if(response!=null){
                            if(response["version"]!=pkg.version){
                              showAlertDialog(context, response);
                            }else{
                              Utils.showSuccess(context,"Your App is already up to date");
                            }
                          }
                        });
                      });
                    },
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Sign Out"),
                    leading: Icon(FontAwesomeIcons.signOutAlt),
                    onTap: (){
                      if(Platform.isAndroid){
                        SharedPreferences.getInstance().then((prefs){
                          messaging.getToken().then((fcmToken){
                            Network_Operations.deleteFCMToken(context, claims["nameid"],fcmToken, prefs.getString("token")).then((value){
                              prefs.remove("token");
                            });
                          });
                        });
                      }else{
                        SharedPreferences.getInstance().then((prefs){
                          prefs.remove("token");
                        });
                      }

                    },
                  ),

                ],
              ),
            )
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Dashboard',),
        bottom:isDateBarVisible? PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: Container(
            alignment: Alignment.topCenter,

            child:Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(DateFormat("yyyy-MM-dd").format(initialStart)+" - "+DateFormat("yyyy-MM-dd").format(initialEnd),style: TextStyle(color: Colors.white),),
              ),
            ),
          ),
        ):null,
        actions: [
          IconButton(
            onPressed: ()async{
              if(picked!=null){
                picked.clear();
              }
              var datePicked= await showDateRangePicker(
                context: context,
                cancelText: "Clear Filter",
                firstDate: DateTime.now().subtract(Duration(days: 365)),
                lastDate: DateTime.now().add(Duration(days: 365)),
                initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
              );
              if(datePicked!=null&&datePicked.start!=null){
                picked.add(datePicked.start);
              }
              if(datePicked!=null&&datePicked.end!=null){
                picked.add(datePicked.end);
              }
              if(picked!=null&&picked.length==2){
                setState(() {
                  this.initialStart=picked[0];
                  this.initialEnd=picked[1];
                  isDateBarVisible=true;
                });

              }else if(picked!=null&&picked.length==1){
                setState(() {
                  this.initialStart=picked[0];
                  this.initialEnd=picked[0].add(Duration(days: 0));
                  isDateBarVisible=true;
                });
              }
              if(picked==null||picked.length==0){
                setState(() {
                  isDateBarVisible=false;
                  initialStart=DateTime.now();
                  initialEnd=DateTime.now().add(Duration(days: 0));
                });
              }
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
              print(picked);
            },
            icon: Icon(Icons.filter_alt),
          ),
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
                claims=Utils.parseJwt(prefs.getString("token"));
                if(!claims['role'].contains("Client")) {
                  if(this.data==null){
                    if(picked.length>0){
                      Network_Operations.getRequestCount(context, prefs.getString("token"),startDate:DateFormat("yyyy-MM-dd").format(picked[0]),endDate:DateFormat("yyyy-MM-dd").format(picked[1])).then((requestCountMap){
                        setState(() {
                          this.requestCount=requestCountMap['statuses'];
                          this.currentUserRoles=requestCountMap['currentLoggedInUserStatuses'];
                          this.notificationCount=requestCountMap['notificationsCount'];
                          FlutterAppBadger.isAppBadgeSupported().then((isSupported){
                            if(isSupported){
                              if(notificationCount!=null&&notificationCount['Unread Notifications Count']!=null){
                                FlutterAppBadger.updateBadgeCount(notificationCount['Unread Notifications Count']);
                              }
                            }

                          });

                        });
                      });
                    }else{
                      Network_Operations.getRequestCount(context, prefs.getString("token")).then((requestCountMap){
                        setState(() {
                          this.requestCount=requestCountMap['statuses'];
                          this.currentUserRoles=requestCountMap['currentLoggedInUserStatuses'];
                          this.notificationCount=requestCountMap['notificationsCount'];
                          FlutterAppBadger.isAppBadgeSupported().then((isSupported){
                            if(isSupported){
                              if(notificationCount!=null&&notificationCount['Unread Notifications Count']!=null){
                                FlutterAppBadger.updateBadgeCount(notificationCount['Unread Notifications Count']);
                              }
                            }
                          });
                        });
                      });
                    }

                  }

                }else{
                  if(this.data==null){
                    Network_Operations.getRequestCountIndividualUser(context,prefs.getString("token")).then((requestCountMap){
                      setState(() {
                        this.requestCount=requestCountMap['statuses'];
                        this.currentUserRoles=requestCountMap['currentLoggedInUserStatuses'];
                      });
                    });
                  }
                }
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
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                    padding: EdgeInsets.only(top: 10),
                  ),
                ),


                Visibility(
                  visible: claims!=null&&!claims['role'].contains("Client"),

                  child: Padding(
                      padding: const EdgeInsets.only(left:10.0,right: 10.0,bottom: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: (){
                            push(context, MaterialPageRoute(builder: (context)=>AllRequestList(currentUserRoles,startDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[0]):null,endDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[1]):null,)));
                          },
                          child: Card(
                            elevation: 8,
                            child: Container(
                             // height: 120,
                              width: MediaQuery.of(context).size.width / 2.25,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: 80,
                                    width: MediaQuery.of(context).size.width,
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(child: FaIcon(FontAwesomeIcons.clipboardList, color: Color(0xFF004c4c), size: 40,)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text('All Requests',
                                          style: TextStyle(
                                            color: Colors.black,
                                            //fontWeight: FontWeight.bold
                                          ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height / 17.1,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF004c4c),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Center(child: Text(requestCount!=null&&requestCount['All Requests Count']!=null?requestCount['All Requests Count'].toString():"0",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                      ),
                                    )),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap:(){
                            push(context, MaterialPageRoute(builder: (context)=>ModelRequests(1,currentUserRoles,name: "New Requests",startDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[0]):null,endDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[1]):null)));
                          },
                          child: Card(
                            elevation: 8,
                            child: Container(
                              //height: MediaQuery.of(context).size.height / 5.8,
                              width: MediaQuery.of(context).size.width / 2.25,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: 80,
                                    width: MediaQuery.of(context).size.width,
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(child: FaIcon(FontAwesomeIcons.commentDots, color: Color(0xFF004c4c), size: 40,)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text('New Requests',
                                            style: TextStyle(
                                              color: Colors.black,
                                              //fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height / 17.1,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF004c4c),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Center(child: Text(requestCount!=null&&requestCount['New Request']!=null?requestCount['New Request'].toString():"0",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                      ),
                                    )),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                      ),
                    ),

                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: (){
                          push(context, MaterialPageRoute(builder: (context)=>ModelRequests(3,currentUserRoles,name: "ACMC Rejected",startDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[0]):null,endDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[1]):null)));
                        },
                        child: Card(
                          elevation: 8,
                          child: Container(
                            //height: MediaQuery.of(context).size.height / 5.8,
                            width: MediaQuery.of(context).size.width / 2.25,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 80,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(child: FaIcon(FontAwesomeIcons.windowClose, color: Color(0xFF004c4c), size: 40,)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text('ACMC Rejected',
                                          style: TextStyle(
                                            color: Colors.black,
                                            //fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height / 17.1,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Color(0xff383838),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(child: Text(requestCount!=null&&requestCount['Rejected By GM']!=null?requestCount['Rejected By GM'].toString():"0",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    ),
                                  )),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          push(context, MaterialPageRoute(builder: (context)=>ModelRequests(2,currentUserRoles,name: "ACMC Approved",startDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[0]):null,endDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[1]):null)));
                        },
                        child: Card(
                          elevation: 8,
                          child: Container(
                            //height: MediaQuery.of(context).size.height / 5.8,
                            width: MediaQuery.of(context).size.width / 2.25,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 80,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(child: FaIcon(FontAwesomeIcons.checkSquare, color: Color(0xFF004c4c), size: 40,)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text('ACMC Approved',
                                          style: TextStyle(
                                            color: Colors.black,
                                            //fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height / 17.1,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF004c4c),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(child: Text(requestCount!=null&&requestCount['Approved By GM']!=null?requestCount['Approved By GM'].toString():"0",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    ),
                                  )),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Card(
                      //   elevation: 8,
                      //   child: Container(
                      //     //height: MediaQuery.of(context).size.height / 5.8,
                      //     width: MediaQuery.of(context).size.width / 2.25,
                      //     decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //     child: Column(
                      //       children: [
                      //         Container(
                      //           height: 80,
                      //           width: MediaQuery.of(context).size.width,
                      //           color: Colors.white,
                      //           child: Column(
                      //             children: [
                      //               Padding(
                      //                 padding: const EdgeInsets.all(8.0),
                      //                 child: Center(child: FaIcon(FontAwesomeIcons.bell, color: Color(0xFF004c4c), size: 40,)),
                      //               ),
                      //               Padding(
                      //                 padding: const EdgeInsets.all(2.0),
                      //                 child: Text('Notifications',
                      //                   style: TextStyle(
                      //                     color: Colors.black,
                      //                     //fontWeight: FontWeight.bold
                      //                   ),
                      //                 ),
                      //               )
                      //             ],
                      //           ),
                      //         ),
                      //         Container(
                      //           height: MediaQuery.of(context).size.height / 17.1,
                      //           width: MediaQuery.of(context).size.width,
                      //           decoration: BoxDecoration(
                      //             color: Color(0xFF004c4c),
                      //             borderRadius: BorderRadius.circular(4),
                      //           ),
                      //           child: Center(child: Text('0',
                      //             style: TextStyle(
                      //                 fontSize: 15,
                      //                 color: Colors.white,
                      //                 fontWeight: FontWeight.bold
                      //             ),
                      //           )),
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap:(){
                          push(context, MaterialPageRoute(builder: (context)=>ModelRequests(4,currentUserRoles,name: "Samples Scheduled",startDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[0]):null,endDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[1]):null)));
                        },
                        child: Card(
                          elevation: 8,
                          child: Container(
                            //height: MediaQuery.of(context).size.height / 5.8,
                            width: MediaQuery.of(context).size.width / 2.25,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 80,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(child: FaIcon(FontAwesomeIcons.calendarAlt, color: Color(0xFF004c4c), size: 40,)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text('Samples Scheduled',
                                          style: TextStyle(
                                            color: Colors.black,
                                            //fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height / 17.1,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF004c4c),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(child: Text(requestCount!=null&&requestCount['Samples Scheduled']!=null?requestCount['Samples Scheduled'].toString():"0",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    ),
                                  )),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          push(context, MaterialPageRoute(builder: (context)=>ModelRequests(6,currentUserRoles,name:"Rejected Models",startDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[0]):null,endDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[1]):null)));
                        },
                        child: Card(
                          elevation: 8,
                          child: Container(
                            //height: MediaQuery.of(context).size.height / 5.8,
                            width: MediaQuery.of(context).size.width / 2.25,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 80,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(child: FaIcon(FontAwesomeIcons.times, color: Color(0xFF004c4c), size: 40,)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text('Rejected Models',
                                          style: TextStyle(
                                            color: Colors.black,
                                            //fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height / 17.1,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Color(0xff383838),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(child: Text(requestCount!=null&&requestCount['Model Rejected']!=null?requestCount['Model Rejected'].toString():"0",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    ),
                                  )),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Container(
                      //   //height: MediaQuery.of(context).size.height / 5.8,
                      //   width: MediaQuery.of(context).size.width / 2,
                      //   color: Colors.green,
                      // ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: (){
                          push(context, MaterialPageRoute(builder: (context)=>ModelRequests(5,currentUserRoles,name: "Approved Models",startDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[0]):null,endDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[1]):null)));
                        },
                        child: Card(
                          elevation: 8,
                          child: Container(
                            //height: MediaQuery.of(context).size.height / 5.8,
                            width: MediaQuery.of(context).size.width / 2.25,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 80,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(child: FaIcon(FontAwesomeIcons.check, color: Color(0xFF004c4c), size: 40,)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text('Approved Models',
                                          style: TextStyle(
                                            color: Colors.black,
                                            //fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height / 17.1,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF004c4c),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(child: Text(requestCount!=null&&requestCount['Model Approved']!=null?requestCount['Model Approved'].toString():"0",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    ),
                                  )),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap:(){
                          push(context, MaterialPageRoute(builder: (context)=>ProductionManagerRequests(7,"Dashboard",currentUserRoles,name: "Customer Approved",startDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[0]):null,endDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[1]):null)));
                        },
                        child: Card(
                          elevation: 8,
                          child: Container(
                            //height: MediaQuery.of(context).size.height / 5.8,
                            width: MediaQuery.of(context).size.width / 2.25,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 80,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(child: FaIcon(FontAwesomeIcons.checkCircle, color: Color(0xFF004c4c), size: 40,)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text('Customer Approved',
                                          style: TextStyle(
                                            color: Colors.black,
                                            //fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height / 17.1,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF004c4c),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(child: Text(requestCount!=null&&requestCount['Approved By Customer']!=null?requestCount['Approved By Customer'].toString():"0",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    ),
                                  )),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: (){
                          push(context, MaterialPageRoute(builder: (context)=>ProductionManagerRequests(8,"Dashboard",currentUserRoles,name: "Customer Rejected",startDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[0]):null,endDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[1]):null)));
                        },
                        child: Card(
                          elevation: 8,
                          child: Container(
                            //height: MediaQuery.of(context).size.height / 5.8,
                            width: MediaQuery.of(context).size.width / 2.25,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 80,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(child: FaIcon(FontAwesomeIcons.timesCircle, color: Color(0xFF004c4c), size: 40,)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text('Customer Rejected',
                                          style: TextStyle(
                                            color: Colors.black,
                                            //fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height / 17.1,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Color(0xff383838),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(child: Text(requestCount!=null&&requestCount['Rejected By Customer']!=null?requestCount['Rejected By Customer'].toString():"0",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    ),
                                  )),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          push(context, MaterialPageRoute(builder: (context)=>CustomerRejectionPageWithJustification(1,"Rejections Justified",startDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[0]):null,endDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[1]):null)));
                        },
                        child: Card(
                          elevation: 8,
                          child: Container(
                            //height: MediaQuery.of(context).size.height / 5.8,
                            width: MediaQuery.of(context).size.width / 2.25,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 80,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(child: FaIcon(FontAwesomeIcons.fileExcel, color: Color(0xFF004c4c), size: 40,)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text('Justified Rejections',
                                          style: TextStyle(
                                            color: Colors.black,
                                            //fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height / 17.1,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF004c4c),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(child: Text(requestCount!=null&&requestCount['Rejections Justified']!=null?requestCount['Rejections Justified'].toString():"0",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    ),
                                  )),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      InkWell(
                        onTap: (){
                          push(context, MaterialPageRoute(builder: (context)=>CustomerRejectionPageWithJustification(0,"Rejections UnJustified",startDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[0]):null,endDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[1]):null)));
                        },
                        child: Card(
                          elevation: 8,
                          child: Container(
                            //height: MediaQuery.of(context).size.height / 5.8,
                            width: MediaQuery.of(context).size.width / 2.25,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 80,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(child: FaIcon(FontAwesomeIcons.solidFileExcel, color: Color(0xFF004c4c), size: 40,)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text('Unjustified Rejections',
                                          style: TextStyle(
                                            color: Colors.black,
                                            //fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height / 17.1,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Color(0xff383838),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(child: Text(requestCount!=null&&requestCount['Rejections Unjustified']!=null?requestCount['Rejections Unjustified'].toString():"0",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    ),
                                  )),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          push(context, MaterialPageRoute(builder: (context)=>ProductionManagerRequests(10,"Dashboard",currentUserRoles,name: "Production Rejected",startDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[0]):null,endDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[1]):null)));
                        },
                        child: Card(
                          elevation: 8,
                          child: Container(
                            //height: MediaQuery.of(context).size.height / 5.8,
                            width: MediaQuery.of(context).size.width / 2.25,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 80,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(child: FaIcon(FontAwesomeIcons.solidWindowClose, color: Color(0xFF004c4c), size: 40,)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text('Production Rejected',
                                          style: TextStyle(
                                            color: Colors.black,
                                            //fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height / 17.1,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Color(0xff383838),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(child: Text(requestCount!=null&&requestCount['Rejected For Production']!=null?requestCount['Rejected For Production'].toString():"0",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    ),
                                  )),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: (){
                          push(context, MaterialPageRoute(builder: (context)=>ProductionManagerRequests(9,"Dashboard",currentUserRoles,name: "Production Approved",startDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[0]):null,endDate: picked!=null&&picked.length>0?DateFormat("yyyy-MM-dd").format(picked[1]):null)));
                        },
                        child: Card(
                          elevation: 8,
                          child: Container(
                            //height: MediaQuery.of(context).size.height / 5.8,
                            width: MediaQuery.of(context).size.width / 2.25,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 80,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(child: FaIcon(FontAwesomeIcons.solidCheckSquare, color: Color(0xFF004c4c), size: 40,)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text('Production Approved',
                                          style: TextStyle(
                                            color: Colors.black,
                                            //fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height / 17.1,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF004c4c),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(child: Text(requestCount!=null&&requestCount['Approved For Production']!=null?requestCount['Approved For Production'].toString():"0",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    ),
                                  )),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  showAlertDialog(BuildContext context,dynamic response) {

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Install"),
      onPressed:  () async{
          await RUpgrade.upgrade(
            response["url"],
            isAutoRequestInstall: true,
            useDownloadManager: false
        );
          Navigator.pop(context);
        //https://onedrive.live.com/download?cid=A82CB96BFF0FB925&resid=A82CB96BFF0FB925%211072&authkey=AEelcxW-Fldhvg4

      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("ACMC Products"),
      content: Text("New Version of ACMC Products is Available Would you Like to Install it. It will be Downloaded in the Background"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
}
