import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:need_resume/need_resume.dart';
import 'package:productdevelopment/DetailsPage.dart';
import 'package:productdevelopment/Model/Notifications.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/Utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
class NotificationListPage extends StatefulWidget {
  @override
  _NotificationListPageState createState() => _NotificationListPageState();
}

class _NotificationListPageState extends ResumableState<NotificationListPage> {
  bool isVisible=false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  List<Notifications> notifications=[];
  @override
  void onResume() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    super.onResume();
  }
  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: (){
          return Utils.check_connectivity().then((isConnected){
            if(isConnected){
              SharedPreferences.getInstance().then((prefs){
                Network_Operations.getUserNotifications(context, prefs.getString("token")).then((notificationList){
                  setState(() {
                    this.notifications=notificationList;
                    if(notifications.length>0){
                      isVisible=true;
                    }else{
                      Utils.showError(context,"No Notifications Yet");
                    }
                  });
                });
              });
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Visibility(
            visible: isVisible,
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
              child: ListView.builder(
                itemCount: notifications!=null&&notifications.length>0?notifications.length:0,
                itemBuilder: (context,int index){
                   return Padding(
                     padding: const EdgeInsets.only(bottom:8.0),
                     child: Card(
                       elevation: 10.0,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(15),
                       ),
                       child: Padding(
                         padding: const EdgeInsets.all(8),
                         child: ListTile(
                           title: Text(notifications[index].notificationDetails.title),
                           subtitle: Text(notifications[index].notificationDetails.body+"\n"+DateFormat("MMM-dd-yyyy").format(notifications[index].notificationDetails.dateTime)),
                           leading: Icon(Icons.notifications,color: Color(0xFF004c4c),size: 40,),
                           trailing: notifications[index].read?Text(""):Icon(Icons.new_releases,color: Color(0xFF004c4c)),
                           onTap: (){
                             if(notifications[index].read){
                               SharedPreferences.getInstance().then((prefs){
                                 Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"), notifications[index].notificationDetails.requestId).then((request){
                                   push(context, MaterialPageRoute(builder: (context)=>DetailsPage(request)));
                                 });
                               });
                             }else{
                               SharedPreferences.getInstance().then((prefs){
                                 Network_Operations.readNotification(context, prefs.getString("token"),notifications[index].notificationDetails.id,notifications[index].notificationDetails.requestId).then((v){
                                 Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"), notifications[index].notificationDetails.requestId).then((request){
                                   push(context, MaterialPageRoute(builder: (context)=>DetailsPage(request)));
                                 });
                                 });
                               });
                             }
                           },
                         ),
                       ),
                     ),
                   );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
