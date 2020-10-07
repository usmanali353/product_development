import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: (){
          return Utils.check_connectivity().then((isConnected){
            if(isConnected){
              SharedPreferences.getInstance().then((prefs){
                Network_Operations.getClientVisitSchedule(context, prefs.getString("token"), DateFormat("yyyy-MM-dd").format(DateTime.now())).then((clientVisitSchedulesList){
                  setState(() {
                    this.clientVisitSchedules=clientVisitSchedulesList;
                    print(DateFormat("yyyy-MM-dd").format(DateTime.now()));
                    if(clientVisitSchedules!=null&&clientVisitSchedules.length>0){
                      isVisible=true;
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
                    title: Text(clientVisitSchedules[index].modelName!=null?clientVisitSchedules[index].modelName:''),
                    subtitle: Text(clientVisitSchedules[index].clientName!=null?clientVisitSchedules[index].clientName:''),
                    leading: Icon(Icons.schedule,color: Color(0xFF004c4c),),
                    children: [
                      ListTile(
                        title: Text("Expected Client Visit Date"),
                        subtitle: Text(clientVisitSchedules[index].clientVisitDate!=null?clientVisitSchedules[index].clientVisitDate:''),
                      ),
                      ListTile(
                        title: Text("Actual Client Visit Date"),
                        subtitle: Text(clientVisitSchedules[index].actualClientVisitDate!=null?clientVisitSchedules[index].actualClientVisitDate:''),
                      ),
                    ],
                  ),
                  Divider(),
                ],
              );
          }
          ),
        ),
      ),

    );
  }
}
