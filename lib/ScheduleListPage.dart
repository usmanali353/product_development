import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ScheduleListPage extends StatefulWidget {
  var request;

  ScheduleListPage(this.request);

  @override
  _ScheduleListPageState createState() => _ScheduleListPageState(request);
}

class _ScheduleListPageState extends State<ScheduleListPage> {
  DateTime newExpectedDate;
  var request;
  var isVisible = false;
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
        title: Text(() {
          if (request.newModelName != null) {
            return "Schedule for " + request.newModelName;
          } else if (request.modelName != null) {
            return "Schedule for " + request.modelName;
          }
        }()),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
          fit: BoxFit.cover,
          //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
          image: AssetImage('Assets/img/pattren.png'),
        )),
        child: ListView.builder(
          itemCount: request.allRequestClients != null
              ? request.allRequestClients.length
              : 0,
          itemBuilder: (context, index) {
            return Column(
              children: [
                ExpansionTile(
                  leading: FaIcon(FontAwesomeIcons.calendarCheck,
                      color: Colors.teal.shade800, size: 45),
                  title: Text(request.allRequestClients[index]['clientName']),
                  children: [
                    ListTile(
                      title: Text("Sample Production Start Date"),
                      subtitle: Text(request.actualStartDate != null
                          ? DateFormat("dd MMMM yyyy")
                              .format(DateTime.parse(request.actualStartDate))
                          : ""),
                    ),
                    Divider(),
                    ListTile(
                      title: Text("Sample Production End Date"),
                      subtitle: Text(request.actualEndDate != null
                          ? DateFormat("dd MMMM yyyy")
                              .format(DateTime.parse(request.actualEndDate))
                          : ""),
                    ),
                    Divider(),
                    ListTile(
                      title: Text("Expected Client Visit Date"),
                      subtitle: Text(request.allRequestClients[index]
                                  ['clientVisitDate'] !=
                              null
                          ? DateFormat("dd MMMM yyyy").format(DateTime.parse(
                              request.allRequestClients[index]
                                      ['clientVisitDate']
                                  .toString()))
                          : ""),
                      trailing: Visibility(
                        visible: request.allRequestClients[index]['status']=="Not Approved Nor Rejected",
                        child: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            showAlertChangeStatus(context, request.allRequestClients[index]);
                          },
                        ),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text("Actual Client Visit Date"),
                      subtitle: Text(request.allRequestClients[index]
                                  ['actualClientVisitDate'] !=
                              null
                          ? DateFormat("dd MMMM yyyy").format(DateTime.parse(
                              request.allRequestClients[index]
                                      ['actualClientVisitDate']
                                  .toString()))
                          : ""),
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
      ),
    );
  }

  showAlertChangeStatus(BuildContext context,var request) {
    // set up the buttons
    Widget Save = FlatButton(
      child: Text("Set"),
      onPressed: () {
          SharedPreferences.getInstance().then((value) {
            Network_Operations.changeClientExpectedVisitDate(
                context, value.getString('token'), request['id'],
                newExpectedDate);
          });
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Please Select Client Visit Date"),
      content: Padding(
                padding: EdgeInsets.all(16),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: FormBuilderDateTimePicker(
                    attribute: "Client Visit Date",
                    initialValue: DateTime.parse(request['clientVisitDate']),
                    style: Theme.of(context).textTheme.bodyText1,
                    inputType: InputType.date,
                    validators: [FormBuilderValidators.required()],
                    format: DateFormat("MM-dd-yyyy"),
                    decoration: InputDecoration(
                        hintText: "Select Client Visit Date",
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none),
                    onChanged: (value) {
                      setState(() {
                        this.newExpectedDate = value;
                      });
                    },
                    onSaved: (value) {
                      setState(() {
                        this.request['clientVisitDate'] = value;
                      });
                    },
                  ),
                ),
              ),
      //       ],
      //     );
      //   },
      // ),
      actions: [Save],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
