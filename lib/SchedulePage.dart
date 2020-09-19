import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Client's Schedules"),
        centerTitle: true,
        backgroundColor: Colors.teal.shade800,
      ),
      body: ListView.builder(
        itemCount: 2,
        itemBuilder: (context, index) {
          return Card(
            elevation: 5,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.18,
              child: Row(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 5, top: 10),
                        child: FaIcon(FontAwesomeIcons.calendarCheck, color: Colors.teal.shade800, size: 45,),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                      ),

                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: VerticalDivider(color: Colors.grey.shade300,),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(top: 30),),


                      Row(
                        children: <Widget>[
                          FaIcon(FontAwesomeIcons.userTie, color: Colors.teal.shade800, size: 25,),
                          Padding(
                            padding: EdgeInsets.only(left: 5, right: 5),
                          ),
                          Text("Client Name"),
                          Padding(
                            padding: EdgeInsets.only(left: 50, right: 5),
                          ),

                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                      ),
                      Row(
                        children: <Widget>[
                          FaIcon(FontAwesomeIcons.calendarAlt, color: Colors.teal.shade800, size: 25,),
                          Padding(
                            padding: EdgeInsets.only(left: 5, right: 5),
                          ),
                          Text("Date:"),
                        ],
                      ),
                    ],
                  ),

                ],

              ),
//             child: ListTile(
//               leading: Padding(
//                 padding: const EdgeInsets.only(top: 50, bottom: 50),
//                 child: FaIcon(FontAwesomeIcons.history, color: Colors.teal.shade800, size: 40,),
//               ),
//             ),
            ),
          );
        },
      ),
    );
  }
}