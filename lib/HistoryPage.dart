import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Model/RemarksHistory.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  var request;

  HistoryPage(this.request);

  @override
  _HistoryPageState createState() => _HistoryPageState(request);
}

class _HistoryPageState extends State<HistoryPage> {
  var request;
  var isVisible=false;
  List<RemarksHistory> remarksHistory=[],undoableList=[];
  _HistoryPageState(this.request);
  @override
  void initState() {
    if(request.remarksHistory!=null){
      setState(() {
        this.remarksHistory=request.remarksHistory;
        if(remarksHistory.length>0){
          if(request.allRequestClientRemarks!=null&&request.allRequestClientRemarks.length>0){
            remarksHistory.addAll(request.allRequestClientRemarks);
          }
          for(RemarksHistory history in remarksHistory){
            if(history.undo==null){
              undoableList.add(history);
            }
          }
          isVisible=true;
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Remarks & Status History"),
      ),
     body: Visibility(
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
           itemCount: remarksHistory!=null?remarksHistory.length:0,
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
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 5, top: 25),
                            child: FaIcon(FontAwesomeIcons.history, color: Color(0xFF004c4c), size: 40,),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5, bottom: 5),
                          ),
                          Visibility(
                            visible: remarksHistory!=null&&remarksHistory.length>0&&undoableList!=null&&undoableList.length>0&&index==remarksHistory.indexOf(undoableList[undoableList.length-1]),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: InkWell(
                                onTap: (){
                                  SharedPreferences.getInstance().then((prefs){
                                    Network_Operations.undoStatus(context,prefs.getString("token"),undoableList[undoableList.length-1].id);
                                  });
                                },
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
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: VerticalDivider(color: Colors.grey.shade400),
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
                              Text(remarksHistory[index].statusName.trim()),
                              Padding(
                                padding: EdgeInsets.only(left: 100, right: 5),
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
                              Text(remarksHistory[index].clientName!=null?remarksHistory[index].clientName:remarksHistory[index].remarkedByName),
                              Padding(
                                padding: EdgeInsets.only(left: 20, right: 5),
                              ),
                              Row(
                                children: <Widget>[
                                  FaIcon(FontAwesomeIcons.calendarAlt, color: Color(0xFF004c4c), size: 15,),
                                  Padding(
                                    padding: EdgeInsets.only(left: 5, right: 5),
                                  ),
                                  Text(DateFormat("yyyy-MM-dd").format(DateTime.parse(remarksHistory[index].date)).toString()),
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
                              Text("Remarks:"),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 18,bottom: 10),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 1.5,
                              //color: Colors.teal,
                              child: Card(color: Colors.white, elevation: 0,
                                  child: Text(remarksHistory[index].remarks,maxLines: 2,overflow: TextOverflow.ellipsis,)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
               ),
             );
           },
         ),
       ),
     ),
    );
  }
}
