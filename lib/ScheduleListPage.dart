import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Model/TrialRequests.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Network_Operations/Network_Operations.dart';

class ScheduleListPage extends StatefulWidget {
  var request;

  ScheduleListPage(this.request);

  @override
  _ScheduleListPageState createState() => _ScheduleListPageState(request);
}

class _ScheduleListPageState extends State<ScheduleListPage> {
  var request;
  var isVisible=false;
  _ScheduleListPageState(this.request);
 @override
  void initState() {
    print(request.allRequestClients.length);
    //print(request.allRequestClients[0]['actualClientVisitDate']);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((){
          if(request.modelName!=null){
            return "Schedule for "+request.modelName;
          }else if(request.newModelName!=null){
            return "Schedule for "+request.newModelName;
          }
        }()),
      ),
      body: ListView.builder(
        itemCount:request.allRequestClients!=null?request.allRequestClients.length:0,
        itemBuilder: (context, index) {
          return Column(
            children: [
          ExpansionTile(
          leading: FaIcon(FontAwesomeIcons.calendarCheck, color: Colors.teal.shade800, size: 45),
          title: Text(request.allRequestClients[index]['clientName']),
          children: [
          ListTile(
          title: Text("Sample Production Start Date"),
          subtitle: Text(request.actualStartDate!=null?DateFormat("dd MMMM yyyy").format(DateTime.parse(request.actualStartDate)):""),
          ),
          Divider(),
          ListTile(
          title: Text("Sample Production End Date"),
          subtitle: Text(request.actualEndDate!=null?DateFormat("dd MMMM yyyy").format(DateTime.parse(request.actualEndDate)):""),
          ),
          Divider(),
          ListTile(
          title: Text("Expected Client Visit Date"),
          subtitle: Text(request.allRequestClients[index]['clientVisitDate']!=null?DateFormat("dd MMMM yyyy").format(DateTime.parse(request.allRequestClients[index]['clientVisitDate'].toString())):""),
          ),
          Divider(),
          ListTile(
          title: Text("Actual Client Visit Date"),
          subtitle: Text(request.allRequestClients[index]['actualClientVisitDate']!=null?DateFormat("dd MMMM yyyy").format(DateTime.parse(request.allRequestClients[index]['actualClientVisitDate'].toString())):""),
          ),
          ],
          ),
              Divider(),
            ],
          );
          // return Card(
          //   elevation: 5,
          //   child: Container(
          //     width: MediaQuery.of(context).size.width,
          //     height: MediaQuery.of(context).size.height * 0.18,
          //     child: Row(
          //       children: <Widget>[
          //         Column(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: <Widget>[
          //             Padding(
          //               padding: const EdgeInsets.only(left: 20, right: 5, top: 10),
          //               child: FaIcon(FontAwesomeIcons.calendarCheck, color: Colors.teal.shade800, size: 45,),
          //             ),
          //             Padding(
          //               padding: EdgeInsets.only(top: 5, bottom: 5),
          //             ),
          //
          //           ],
          //         ),
          //         Padding(
          //           padding: const EdgeInsets.all(5.0),
          //           child: VerticalDivider(color: Colors.grey.shade300,),
          //         ),
          //         Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: <Widget>[
          //             Padding(padding: EdgeInsets.only(top: 30),),
          //             Row(
          //               children: <Widget>[
          //                 FaIcon(FontAwesomeIcons.userTie, color: Colors.teal.shade800, size: 25,),
          //                 Padding(
          //                   padding: EdgeInsets.only(left: 5, right: 5),
          //                 ),
          //                 Text(request.allRequestClients[index]['clientName']),
          //                 Padding(
          //                   padding: EdgeInsets.only(left: 50, right: 5),
          //                 ),
          //               ],
          //             ),
          //             Padding(
          //               padding: EdgeInsets.only(top: 20),
          //             ),
          //             Row(
          //               children: <Widget>[
          //                 FaIcon(FontAwesomeIcons.calendarAlt, color: Colors.teal.shade800, size: 25,),
          //                 Padding(
          //                   padding: EdgeInsets.only(left: 5, right: 5),
          //                 ),
          //                 Text(request.allRequestClients[index]['actualClientVisitDate']!=null?"Visit Date: "+DateFormat("yyyy-MM-dd").format(DateTime.parse(request.allRequestClients[index]['actualClientVisitDate'].toString())):"Target Visit Date: "+DateFormat("yyyy-MM-dd").format(DateTime.parse(request.allRequestClients[index]['clientVisitDate'].toString()))),
          //               ],
          //             ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),
          // );
        },
      ),
    );
  }
}
