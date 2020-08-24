
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:need_resume/need_resume.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ModelRequests extends StatefulWidget {

  List<dynamic> products;
  List<String> productId;

  ModelRequests(this.products, this.productId);

  @override
  _ModelReState createState() => _ModelReState(products,productId);
}

class _ModelReState extends ResumableState<ModelRequests>{
  List<dynamic> products=[];
  List<String> productId=[],status=['All','New Request','Approved by ACMC','Rejected by ACMC','Scheduled for Samples Production','Samples Produced','Approved for Trial','Rejected for Trial','Scheduled for Trial','Approved by Customer','Rejected by Customer','Scheduled for Production'];
  GlobalKey<RefreshIndicatorState> refreshIndicatorKey=GlobalKey();
  bool isDataEntryOperator=false;
  bool isCustomer=false;
  bool canScheduleProduction=false;
  bool canApproveAcmc=false;
  bool canApproveforTrial=false;
  var selectedPreference,selectedStatus;

  _ModelReState(this.products,this.productId);
 bool isGm=false;
 bool isSaleManager= false;
  String userId;
  @override
  void onResume() {
    print(resume.data.toString());
     Navigator.pop(context,'Refresh');
     Navigator.pop(context,'Refresh');
    super.onResume();
  }
  @override
  void initState() {

    SharedPreferences.getInstance().then((prefs){
    if(prefs.getString('email')== "tahir@mailinator.com"){
      setState(() {
        isGm == true;
      });
    }
   else if(prefs.getString('email')== "basit@mailinator.com"){
      setState(() {
        isSaleManager == true;
      });
    }
   else{

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
                showStatusAlertDialog(context);
              },
            )
          ],
        ),
      body: ListView.builder(
              itemCount:products.length, itemBuilder: (context,int index)
          {
            return InkWell(
              onTap: (){
                if(canApproveAcmc&&products[index].status=="New Request"){
                  showAlertDialog(context,products[index],productId[index]);
                }else if(canScheduleProduction&&products[index].status=="Approved by ACMC"){
                  showDatePicker(helpText:"Select Date for Sample Production",context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(Duration(days: 60))).then((selectedDate){
                    if(selectedDate!=null){
                      Map<String,dynamic> map=Map();
                      map.putIfAbsent("status", () => "Scheduled for Samples Production");
                      map.putIfAbsent("closeing_date", () => DateFormat("yyyy-MM-dd").format(selectedDate));
                      ProgressDialog pd=ProgressDialog(context);
                      pd.show();
                      Firestore.instance.collection("model_requests").document(productId[index]).updateData(map).then((value) {
                        pd.hide();
                        Navigator.pop(context,'Refresh');
                        Flushbar(
                          message: "Request Scheduled",
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 5),
                        )..show(context);
                      }).catchError((onError){
                        pd.hide();
                        Flushbar(
                          message: onError.toString(),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 5),
                        )..show(context);
                      });
                    }
                  });
                }else if(canScheduleProduction&&products[index].status=="Scheduled for Samples Production"){
                  showAlertChangeStatus(context, productId[index], products[index]);
                }else if(canApproveforTrial&&products[index].status=="Samples Produced"){
                  // showCustomerApprovalDialog(context, products[index], productId[index]);
                  showTrialApprovalDialog(context,products[index],productId[index]);
                }else if(canApproveforTrial&&(products[index].status=="Approved for Trial")){
                  showDatePicker(helpText:"Select Date for Produced Sample Trial",context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(Duration(days: 60))).then((selectedDate){
                    if(selectedDate!=null){
                      Map<String,dynamic> map=Map();
                      map.putIfAbsent("trial_date", () => DateFormat("yyyy-MM-dd").format(selectedDate));
                      map.putIfAbsent("status", () =>"Scheduled for Trial");
                      ProgressDialog pd=ProgressDialog(context);
                      pd.show();
                      //Firestore.instance.collection("model_requests").document(productId[index]).updateData(map).then((updatedTrialDate){
                        pd.hide();
                        Navigator.pop(context,'Refresh');
                        Flushbar(
                          message: "Trial Scheduled",
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 5),
                        )..show(context);
                      }).catchError((onError){
                        pd.hide();
                        Flushbar(
                          message: onError.toString(),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 5),
                        )..show(context);
                      });
                    }
                  });
                }else if(isCustomer&&products[index].status=='Scheduled for Trial'){
                  showCustomerApprovalDialog(context, products[index], productId[index]);
                }else if(canScheduleProduction&&products[index].status=='Approved by Customer'){
                  showDatePicker(helpText:"Select Date for Production for Customer",context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(Duration(days: 120))).then((selectedDate){
                    if(selectedDate!=null){
                      Map<String,dynamic> map=Map();
                      map.putIfAbsent("production_date", () => DateFormat("yyyy-MM-dd").format(selectedDate));
                      map.putIfAbsent("status", () =>"Scheduled for Production");
                      ProgressDialog pd=ProgressDialog(context);
                      pd.show();
                      Firestore.instance.collection("model_requests").document(productId[index]).updateData(map).then((updatedTrialDate){
                        pd.hide();
                        Navigator.pop(context,'Refresh');
                        Flushbar(
                          message: "Production for Customer Scheduled",
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 5),
                        )..show(context);
                      }).catchError((onError){
                        pd.hide();
                        Flushbar(
                          message: onError.toString(),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 5),
                        )..show(context);
                      });
                    }
                  });
                }else{
                 Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailPage(products[index],productId[index])));
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
                                    image: NetworkImage(products[index].image),
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
                                child: Text(products[index].modelName!=null?products[index].modelName:'', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
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
                                      Text(products[index].surface!=null?products[index].surface:'')
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
                                      Text("60x60, 30x30")
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
                                      Text(products[index].requestDate!=null?products[index].requestDate:'')
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
                                    Text(products[index].status!=null?products[index].status:'')
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
          }),

    );

  }
  showCustomerApprovalDialog(BuildContext context,Product product,String productId){
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
        Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailPage(product,productId)));
      },
    );
    Widget approveRejectButton = FlatButton(
      child: Text("Set"),
      onPressed: () {
        Navigator.pop(context);
        push(context, MaterialPageRoute(builder: (context)=>Observations(selectedPreference,productId)));
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
  showTrialApprovalDialog(BuildContext context,Product product,String productId){
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
        Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailPage(product,productId)));
      },
    );
    Widget approveRejectButton = FlatButton(
      child: Text("Set"),
      onPressed: () {
        Navigator.pop(context);
        ProgressDialog pd=ProgressDialog(context);
        pd.show();
        if(selectedPreference=="Approve"){
          Map<String,dynamic> map=Map();
          map.putIfAbsent("status", () => "Approved for Trial");
          Firestore.instance.collection("model_requests").document(productId).updateData(map).then((value){
            pd.hide();
           Navigator.pop(context,'Refresh');
            Flushbar(
              message: "Request Approved for Trial",
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            )..show(context);
          }).catchError((onError){
            pd.hide();
            Flushbar(
              message: onError.toString(),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            )..show(context);
          });
        }else if(selectedPreference=="Reject"){
          Map<String,dynamic> map=Map();
          map.putIfAbsent("status", () => "Rejected for Trial");
          Firestore.instance.collection("model_requests").document(productId).updateData(map).then((value){
            pd.hide();
            Navigator.pop(context,'Refresh');
            Flushbar(
              message: "Status of Request Changed",
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            )..show(context);
          }).catchError((onError){
            pd.hide();
            Flushbar(
              message: onError.toString(),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            )..show(context);
          });
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
  showAlertChangeStatus(BuildContext context,String productId,Product product){
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
        Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailPage(product,productId)));
      },
    );
    Widget changeStatus = FlatButton(
      child: Text("Change Status"),
      onPressed: () {
        Navigator.pop(context);
        push(context, MaterialPageRoute(builder: (context)=>productionCompleted(productId)));
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
  showAlertDialog(BuildContext context,Product product,String productId) {
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
        Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailPage(product,productId)));
      },
    );
    Widget approveRejectButton = FlatButton(
      child: Text("Set"),
      onPressed: () {
        if(selectedPreference=="Approve"){
          Navigator.pop(context);
          push(context, MaterialPageRoute(builder: (context)=>acmcApproval(selectedPreference,productId,users.name,userId)));

        }else if(selectedPreference=="Reject"){
          Navigator.pop(context);
          push(context, MaterialPageRoute(builder: (context)=>acmcApproval(selectedPreference,productId,users.name,userId)));
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
  showStatusAlertDialog(BuildContext context) {
    // set up the buttons
    Widget searchBtn = FlatButton(
      child: Text("Search"),
      onPressed:  () {
        Navigator.pop(context);
        if(selectedStatus=='All'){
          WidgetsBinding.instance
              .addPostFrameCallback((_) => refreshIndicatorKey.currentState.show());
        }else{
          Firestore.instance.collection("model_requests").where("status",isEqualTo:selectedStatus).getDocuments().then((querySnapshot){
            if(querySnapshot.documents.length>0){
              setState(() {
                if(products.length>0){
                  products.clear();
                }
                if(productId.length>0){
                  productId.clear();
                }
                products.addAll(querySnapshot.documents.map((e) => Product.fromMap(e.data)).toList());
                for(int i=0;i<querySnapshot.documents.length;i++){
                  productId.add(querySnapshot.documents[i].documentID);
                }
              });
            }else{
              Flushbar(
                message: "No Request Found According to the Status",
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              )..show(context);
            }
          });
        }

      },
    );
    Widget cancelBtn = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Filter by Status"),
      content:FormBuilder(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FormBuilderDropdown(
                attribute: "Select Status",
                hint: Text("Select Status"),
                items: status!=null?status.map((plans)=>DropdownMenuItem(
                  child: Text(plans),
                  value: plans,
                )).toList():[""].map((name) => DropdownMenuItem(
                    value: name, child: Text("$name")))
                    .toList(),
                onChanged: (value){
                  setState(() {
                    this.selectedStatus=value;
                  });
                },
                style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(fontSize: 11)),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                ),

              ),
            ],
          )
      ),
      actions: [
        cancelBtn,
        searchBtn,
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

