
import 'dart:convert';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:need_resume/need_resume.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Observations.dart';
import 'acmcapproval.dart';
import 'productionCompleted.dart';


class ModelRequests extends StatefulWidget {

  List<Request> products;

  ModelRequests(this.products);

  @override
  _ModelReState createState() => _ModelReState(products);
}

class _ModelReState extends ResumableState<ModelRequests>{
  List<Request> products=[];
  //List<String> status=['All','New Request','Approved by ACMC','Rejected by ACMC','Scheduled for Samples Production','Samples Produced','Approved for Trial','Rejected for Trial','Scheduled for Trial','Approved by Customer','Rejected by Customer','Scheduled for Production'];
  GlobalKey<RefreshIndicatorState> refreshIndicatorKey=GlobalKey();
  var selectedPreference,selectedStatus;
  _ModelReState(this.products);
 bool isGm=false;
 bool isSaleManager= false;
 bool isClient=false;
  String token;
  @override
  void onResume() {
    print(resume.data.toString());
     Navigator.pop(context,'Refresh');
     Navigator.pop(context,'Refresh');
    super.onResume();
  }
  @override
  void initState() {
    print(products.toString());
    SharedPreferences.getInstance().then((prefs){
      setState(() {
        token=prefs.getString("token");
      });
    if(prefs.getString('email')== "tahir@mailinator.com"){
      setState(() {
        isGm = true;
      });
    }
   else if(prefs.getString('email')== "basit@mailinator.com"){
      setState(() {
        isSaleManager = true;
      });
    }
   else{
    setState(() {
      isClient=true;
    });
    }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text("Model Requests", style: TextStyle(
              color: Colors.white
          ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: (){
                //showStatusAlertDialog(context);
              },
            )
          ],
        ),
      body: ListView.builder(
              itemCount:products.length, itemBuilder: (context,int index)
          {
            return InkWell(
              onTap: (){
                if(isGm&&products[index].statusName=="New Request"){
                  showAlertDialog(context,products[index]);
                } if(isGm&&products[index].statusName=="Approved By GM"){
                  showDatePicker(helpText:"Select Date for Sample Production",context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(Duration(days: 60))).then((selectedDate){
                    if(selectedDate!=null){
                       Network_Operations.changeStatusOfRequest(context, token, products[index].requestId, 4);
                    }
                  });
                } if(isGm&&products[index].statusName=="Samples Scheduled"){
                  showAlertChangeStatus(context,products[index]);
                }  if(isGm&&(products[index].statusName=="Approved Trial")){
                  showCustomerApprovalDialog(context,products[index]);
                } if(isGm&&products[index].statusName=='Approved by Customer'){
                  showDatePicker(helpText:"Select Date for Production for Customer",context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(Duration(days: 120))).then((selectedDate){
                    if(selectedDate!=null){

                    }
                  });
                }else{
                 //Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailPage(products[index],productId[index])));
                }
              },
              child: Card(
                elevation: 6,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    //color: Colors.teal,
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.21,

                  child: Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      //mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              //color: Color(0xFF004c4c),
                              height: 90,
                              width: 90,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: AssetImage("Assets/img/AC.png"), //MemoryImage(base64Decode(products[index]['image'])),
                                    fit: BoxFit.cover,
                                  )
                              ),
                            ),
                            //Padding(padding: EdgeInsets.only(top:2),),
                            Row(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: Colors.orange.shade100,
                                    //color: Colors.teal,
                                  ),
                                  height: 10,
                                  width: 15,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 2, right: 2),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: Colors.grey.shade300,
                                    //color: Colors.teal,
                                  ),
                                  height: 10,
                                  width: 15,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 2, right: 2),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: Colors.brown.shade200,
                                    //color: Colors.teal,
                                  ),
                                  height: 10,
                                  width: 15,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 2, right: 2),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: Colors.brown.shade500,
                                    //color: Colors.teal,
                                  ),
                                  height: 10,
                                  width: 15,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 2, right: 2),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: Colors.orangeAccent.shade100,
                                    //color: Colors.teal,
                                  ),
                                  height: 10,
                                  width: 15,
                                ),
                              ],
                            )
                          ],
                        ),
                        VerticalDivider(color: Colors.grey,),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.62,
                          height: MediaQuery.of(context).size.height * 0.62,
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 6, top: 8),
                                child: Text('', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Row(
                                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Icon(
                                        Icons.layers,
                                        color: Colors.teal,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 2, right: 2),
                                      ),
                                      Text(products[index].surfaceName!=null?products[index].surfaceName:'')
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 50),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.zoom_out_map,
                                        color: Colors.teal,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 2, right: 2),
                                      ),
                                      Text(products[index].multipleSizes.toString()),
                                    ],


                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.date_range,
                                        color: Colors.teal,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 2, right: 2),
                                      ),
                                      Text(products[index].date!=null?products[index].date:'')
                                    ],

                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 27),
                                  ),

                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 1),
                                child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(
                                      Icons.done_all,
                                      //size: 14,
                                      color: Colors.teal,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 3, right: 3),
                                    ),
                                    Text(products[index].statusName!=null?products[index].statusName:'')
                                  ],


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
          })
    );

  }
  showCustomerApprovalDialog(BuildContext context,Request request){
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget detailsPage = FlatButton(
      child: Text("Go to Details"),
      onPressed: () {
        Navigator.pop(context);
      //  Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailPage(product,productId)));
      },
    );
    Widget approveRejectButton = FlatButton(
      child: Text("Set"),
      onPressed: () {
        Navigator.pop(context);
        push(context, MaterialPageRoute(builder: (context)=>Observations(selectedPreference,request)));
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Approve/Reject Model Request"),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile(
                title: Text("Approve"),
                value: 'Approve',
                groupValue: selectedPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedPreference = choice;
                  });
                },
              ),
              RadioListTile(
                title: Text("Reject"),
                value: 'Reject',
                groupValue: selectedPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedPreference = choice;
                  });
                },
              ),
            ],
          );
        },
      ),
      actions: [
        cancelButton,
        detailsPage,
        approveRejectButton
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
  showTrialApprovalDialog(BuildContext context){
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget detailsPage = FlatButton(
      child: Text("Go to Details"),
      onPressed: () {
        Navigator.pop(context);
       // Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailPage(product,productId)));
      },
    );
    Widget approveRejectButton = FlatButton(
      child: Text("Set"),
      onPressed: () {
        Navigator.pop(context);
        if(selectedPreference=="Approve"){

        }else if(selectedPreference=="Reject"){

        }
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Approve/Reject Model for Trials"),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile(
                title: Text("Approve"),
                value: 'Approve',
                groupValue: selectedPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedPreference = choice;
                  });
                },
              ),
              RadioListTile(
                title: Text("Reject"),
                value: 'Reject',
                groupValue: selectedPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedPreference = choice;
                  });
                },
              ),
            ],
          );
        },
      ),
      actions: [
        cancelButton,
        detailsPage,
        approveRejectButton
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
  showAlertChangeStatus(BuildContext context,Request request){
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget detailsPage = FlatButton(
      child: Text("Go to Details"),
      onPressed: () {
        Navigator.pop(context);
        //Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailPage(product,productId)));
      },
    );
    Widget approveRejectButton = FlatButton(
      child: Text("Set"),
      onPressed: () {
        if(selectedPreference=="Approve"){
          Navigator.pop(context);
          push(context, MaterialPageRoute(builder: (context)=>productionCompleted(selectedPreference,request)));
        }else if(selectedPreference=="Reject"){
          Navigator.pop(context);
          push(context, MaterialPageRoute(builder: (context)=>productionCompleted(selectedPreference,request)));
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Approve/Reject Model for Trial"),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile(
                title: Text("Approve"),
                value: 'Approve',
                groupValue: selectedPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedPreference = choice;
                  });
                },
              ),
              RadioListTile(
                title: Text("Reject"),
                value: 'Reject',
                groupValue: selectedPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedPreference = choice;
                  });
                },
              ),
            ],
          );
        },
      ),
      actions: [
        cancelButton,
        detailsPage,
        approveRejectButton
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
  showAlertDialog(BuildContext context,Request request) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget detailsPage = FlatButton(
      child: Text("Go to Details"),
      onPressed: () {
        Navigator.pop(context);
        //Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailPage(product,productId)));
      },
    );
    Widget approveRejectButton = FlatButton(
      child: Text("Set"),
      onPressed: () {
        if(selectedPreference=="Approve"){
          Navigator.pop(context);
          push(context, MaterialPageRoute(builder: (context)=>acmcApproval(selectedPreference,request)));
        }else if(selectedPreference=="Reject"){
          Navigator.pop(context);
          push(context, MaterialPageRoute(builder: (context)=>acmcApproval(selectedPreference,request)));
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Approve/Reject Model Request"),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile(
                title: Text("Approve"),
                value: 'Approve',
                groupValue: selectedPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedPreference = choice;
                  });
                },
              ),
              RadioListTile(
                title: Text("Reject"),
                value: 'Reject',
                groupValue: selectedPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedPreference = choice;
                  });
                },
              ),
            ],
          );
        },
      ),
      actions: [
        cancelButton,
        detailsPage,
        approveRejectButton
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
}

