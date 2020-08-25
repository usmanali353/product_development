
import 'dart:convert';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:need_resume/need_resume.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ModelRequests extends StatefulWidget {

  List<dynamic> products;

  ModelRequests(this.products);

  @override
  _ModelReState createState() => _ModelReState(products);
}

class _ModelReState extends ResumableState<ModelRequests>{
  List<dynamic> products=[];
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
                if(isGm&&products[index]['statusName']=="New Request"){
                  showAlertDialog(context,products[index]);
                }else if(isGm&&products[index]['statusName']=="Approved by ACMC"){
                  showDatePicker(helpText:"Select Date for Sample Production",context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(Duration(days: 60))).then((selectedDate){
                    if(selectedDate!=null){

                    }
                  });
                }else if(isGm&&products[index]['statusName']=="Scheduled for Samples Production"){
                  showAlertChangeStatus(context);
                }else if(isGm&&products[index]['statusName']=="Samples Produced"){
                   showCustomerApprovalDialog(context);
                  showTrialApprovalDialog(context);
                }else if(isGm&&(products[index]['statusName']=="Approved for Trial")){
                  showDatePicker(helpText:"Select Date for Produced Sample Trial",context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(Duration(days: 60))).then((selectedDate){
                    if(selectedDate!=null){

                    }
                  });
                }else if(isClient&&products[index]['statusName']=='Scheduled for Trial'){
                  showCustomerApprovalDialog(context);
                }else if(isGm&&products[index]['statusName']=='Approved by Customer'){
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
                            Visibility(
                              visible: products[index]['image']!=null?true:false,
                              child: Container(
                                //color: Color(0xFF004c4c),
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: MemoryImage(base64Decode(products[index]['image'])),
                                      fit: BoxFit.cover,
                                    )
                                ),
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
                                      Text(products[index]['surfaceName']!=null?products[index]['surfaceName']:'')
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
                                      Text(products[index]['multipleSizes'].toString()),
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
                                      Text(products[index]['date']!=null?products[index]['date']:'')
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
                                    Text(products[index]['statusName']!=null?products[index]['statusName']:'')
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
  showCustomerApprovalDialog(BuildContext context){
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
        //push(context, MaterialPageRoute(builder: (context)=>Observations(selectedPreference,productId)));
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
  showAlertChangeStatus(BuildContext context){
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
    Widget changeStatus = FlatButton(
      child: Text("Change Status"),
      onPressed: () {
        Navigator.pop(context);
       // push(context, MaterialPageRoute(builder: (context)=>productionCompleted(productId)));
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Change Status of Request"),
      content: Text("are you sure you want to change status to request to Produced?"),
      actions: [
        cancelButton,
        detailsPage,
        changeStatus,
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
  showAlertDialog(BuildContext context,dynamic request) {
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
          Network_Operations.changeStatusOfRequest(context, token, request['requestId'], 2);
          //push(context, MaterialPageRoute(builder: (context)=>acmcApproval(selectedPreference,productId,users.name,userId)));

        }else if(selectedPreference=="Reject"){
          Navigator.pop(context);
          print(request['requestId']);
          Network_Operations.changeStatusOfRequest(context, token, request['requestId'], 3);
          //push(context, MaterialPageRoute(builder: (context)=>acmcApproval(selectedPreference,productId,users.name,userId)));
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
//  showStatusAlertDialog(BuildContext context) {
//    // set up the buttons
//    Widget searchBtn = FlatButton(
//      child: Text("Search"),
//      onPressed:  () {
//        Navigator.pop(context);
//        if(selectedStatus=='All'){
//          WidgetsBinding.instance
//              .addPostFrameCallback((_) => refreshIndicatorKey.currentState.show());
//        }else{
//
//        }
//
//      },
//    );
//    Widget cancelBtn = FlatButton(
//      child: Text("Cancel"),
//      onPressed:  () {
//        Navigator.pop(context);
//      },
//    );
//
//    // set up the AlertDialog
//    AlertDialog alert = AlertDialog(
//      title: Text("Filter by Status"),
//      content:FormBuilder(
//          child: Column(
//            mainAxisSize: MainAxisSize.min,
//            children: <Widget>[
//              FormBuilderDropdown(
//                attribute: "Select Status",
//                hint: Text("Select Status"),
//                items: status!=null?status.map((plans)=>DropdownMenuItem(
//                  child: Text(plans),
//                  value: plans,
//                )).toList():[""].map((name) => DropdownMenuItem(
//                    value: name, child: Text("$name")))
//                    .toList(),
//                onChanged: (value){
//                  setState(() {
//                    this.selectedStatus=value;
//                  });
//                },
//                style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(fontSize: 11)),
//                decoration: InputDecoration(
//                  contentPadding: EdgeInsets.all(16),
//                ),
//
//              ),
//            ],
//          )
//      ),
//      actions: [
//        cancelBtn,
//        searchBtn,
//      ],
//    );
//
//    // show the dialog
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        return alert;
//      },
//    );
//  }


}

