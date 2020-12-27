import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:productdevelopment/AddClientsForTrial.dart';
import 'package:productdevelopment/DetailsPage.dart';
import 'package:productdevelopment/Model/ClientVisitSchedule.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/Utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
class DailyClientSchedule extends StatefulWidget {
  @override
  _DailyClientScheduleState createState() => _DailyClientScheduleState();
}

class _DailyClientScheduleState extends State<DailyClientSchedule> {
  bool isVisible=false;
  DateTime initialStart=DateTime.now(),initialEnd=DateTime.now().add(Duration(days: 0));
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  List<ClientVisitSchedule> clientVisitSchedules=[];
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
        title: Text("Client Visit Schedule"),
        bottom: PreferredSize(
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
        ),
        actions: [
          IconButton(
            onPressed: ()async{
              final List<DateTime> picked = await DateRagePicker.showDatePicker(
                  context: context,
                  initialFirstDate:  initialStart,
                  initialLastDate: initialEnd,
                  firstDate: DateTime.now().subtract(Duration(days: 365)),
                  lastDate:  DateTime.now().add(Duration(days: 365)),
              );
              if(picked!=null&&picked.length==2){
                setState(() {
                  this.initialStart=picked[0];
                  this.initialEnd=picked[1];
                });
                SharedPreferences.getInstance().then((prefs){
                  Network_Operations.getClientVisitSchedule(context, prefs.getString("token"), DateFormat("yyyy-MM-dd").format(picked[0]),DateFormat("yyyy-MM-dd").format(picked[1])).then((clientVisitSchedulesList){
                    setState(() {
                      if(clientVisitSchedules!=null&&clientVisitSchedules.length>0) {
                        clientVisitSchedules.clear();
                      }
                      this.clientVisitSchedules=clientVisitSchedulesList;
                      print(DateFormat("yyyy-MM-dd").format(DateTime.now()));
                      if(clientVisitSchedules!=null&&clientVisitSchedules.length>0){
                        isVisible=true;
                      }else{
                        Utils.showError(context,"No Schedules Found Between these Dates");
                      }
                    });
                  });
                });
              }else if(picked!=null&&picked.length==1){
                setState(() {
                  this.initialStart=picked[0];
                  this.initialEnd=picked[0].add(Duration(days: 0));
                });
                SharedPreferences.getInstance().then((prefs){
                  Network_Operations.getClientVisitSchedule(context, prefs.getString("token"), DateFormat("yyyy-MM-dd").format(picked[0]),'').then((clientVisitSchedulesList){
                    setState(() {
                      if(clientVisitSchedules!=null&&clientVisitSchedules.length>0) {
                        clientVisitSchedules.clear();
                      }
                      this.clientVisitSchedules=clientVisitSchedulesList;
                      print(DateFormat("yyyy-MM-dd").format(DateTime.now()));
                      if(clientVisitSchedules!=null&&clientVisitSchedules.length>0){
                        isVisible=true;
                      }else{
                        Utils.showError(context,"No Schedules Found for Specified Date");
                      }
                    });
                  });
                });
              }

              print(picked);
            },
            icon: Icon(Icons.filter_list),
          ),
          IconButton(
            icon:Icon(Icons.add),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder:(context)=>AddClientsToTrial()));
            },
          )
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
              image: AssetImage('Assets/img/pattren.png'),
            )
        ),
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: (){
            return Utils.check_connectivity().then((isConnected){
              if(isConnected){
                SharedPreferences.getInstance().then((prefs){
                  Network_Operations.getClientVisitSchedule(context, prefs.getString("token"), DateFormat("yyyy-MM-dd").format(DateTime.now()),'').then((clientVisitSchedulesList){
                    setState(() {
                      this.clientVisitSchedules=clientVisitSchedulesList;
                      print(DateFormat("yyyy-MM-dd").format(DateTime.now()));
                      if(clientVisitSchedules!=null&&clientVisitSchedules.length>0){
                        isVisible=true;
                      }else{
                        Utils.showError(context,"No Schedules Found for Today");
                      }
                    });
                  });
                });
              }
            });
          },
          child: Visibility(
            visible: isVisible,
            child: ListView.builder(
                itemCount: clientVisitSchedules!=null&&clientVisitSchedules.length>0?clientVisitSchedules.length:0,
                itemBuilder:(context,index){
                return Column(
                  children: [
                    ExpansionTile(
                      title: Text(clientVisitSchedules[index].modelName!=null?"Model Name: "+clientVisitSchedules[index].modelName:''),
                      subtitle: Text(clientVisitSchedules[index].clientName!=null?"Client Name: "+clientVisitSchedules[index].clientName:''),
                      leading: Icon(Icons.schedule,color: Color(0xFF004c4c),size: 40,),
                      children: [
                        ListTile(
                          title: Text("Expected Client Visit Date"),
                          subtitle: Text(clientVisitSchedules[index].clientVisitDate!=null?DateFormat("yyyy-MM-dd").format(DateTime.parse(clientVisitSchedules[index].clientVisitDate)):''),
                        ),
                        Divider(),
                        ListTile(
                          title: Text("Actual Client Visit Date"),
                          subtitle: Text(clientVisitSchedules[index].actualClientVisitDate!=null?DateFormat("yyyy-MM-dd").format(DateTime.parse(clientVisitSchedules[index].actualClientVisitDate)):''),
                        ),
                        Center(
                          child: FlatButton(
                            child: Text("View Details",style: TextStyle(color: Color(0xFF004c4c)),),
                            onPressed: (){
                              SharedPreferences.getInstance().then((prefs){
                                Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"),clientVisitSchedules[index].requestId).then((request){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailsPage(request)));
                                });
                              });
                            },
                          ),
                        )
                      ],
                    ),
                    Divider(),
                  ],
                );
            }
            ),
          ),
        ),
      ),

    );
  }
}
