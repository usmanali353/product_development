import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Remarks & Status History"),
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
             //height: MediaQuery.of(context).size.height * 0.24,
              child: Row(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 5, top: 25),
                        child: FaIcon(FontAwesomeIcons.history, color: Color(0xFF004c4c), size: 45,),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: <Widget>[
                            FaIcon(FontAwesomeIcons.undoAlt, color: Color(0xFF004c4c), size: 15,),
                            Padding(
                              padding: EdgeInsets.only(left: 2, right: 2),
                            ),
                            Text("Undo", style: TextStyle(color: Color(0xFF004c4c),),),

                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: VerticalDivider(color: Colors.grey.shade300),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.all(5),),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.donut_large,
                            color: Color(0xFF004c4c), size: 25,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 5, right: 5),
                          ),
                          Text("Status"),
                          Padding(
                            padding: EdgeInsets.only(left: 128, right: 5),
                          ),

                        ],
                      ),

                      Padding(padding: EdgeInsets.all(7),),
                      Row(
                        children: <Widget>[
                          FaIcon(FontAwesomeIcons.userTie, color: Color(0xFF004c4c), size: 15,),
                          Padding(
                            padding: EdgeInsets.only(left: 5, right: 5),
                          ),
                          Text("Approved By:"),
                          Padding(
                            padding: EdgeInsets.only(left: 20, right: 5),
                          ),
                          Row(
                            children: <Widget>[
                              FaIcon(FontAwesomeIcons.calendarAlt, color: Color(0xFF004c4c), size: 15,),
                              Padding(
                                padding: EdgeInsets.only(left: 5, right: 5),
                              ),
                              Text("Date:"),
                            ],
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.all(8),),
                      Row(
                        children: <Widget>[
                          FaIcon(FontAwesomeIcons.comment, color: Color(0xFF004c4c), size: 15,),
                          Padding(
                            padding: EdgeInsets.only(left: 5, right: 5),
                          ),
                          Text("Remarks:", maxLines:2,),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 18,bottom: 10),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 1.5,
                          //color: Colors.teal,
                          child: Card(color: Colors.white, elevation: 0,
                              child: Text("This to inform you that the lines can be maximize by its own and it can be reacreated This to inform you that the lines can be maximize by its own and it can be reacreated",maxLines: 2,overflow: TextOverflow.ellipsis,)),
                        ),
                      ),
//                      Padding(
//                        padding: const EdgeInsets.only(right: 170),
//                        child: Card(
//                          child: Container(
//                            color: Colors.teal,
//                            //width: MediaQuery.of(context).size.height / 8,
//                            child: Text("Remarks hello thsoin mndm,masmk frhrtyhred dkjkjdlkdld"),
//                          ),
//                        ),
//                      )
                      
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
