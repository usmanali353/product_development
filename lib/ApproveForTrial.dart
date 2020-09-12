import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:productdevelopment/Dashboard.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Model/Dropdown.dart';
import 'Network_Operations/Network_Operations.dart';
class ApproveForTrial extends StatefulWidget {
  Request request;
  String status;
  ApproveForTrial(this.request,this.status);

  @override
  _ApproveForTrialState createState() => _ApproveForTrialState(request,status);
}

class _ApproveForTrialState extends State<ApproveForTrial> {
  GlobalKey<FormBuilderState> fbKey=GlobalKey();
  DateTime startDate = DateTime.now();
  DateTime endDate =DateTime.now();
  TextEditingController remarks;
  List myClients;
  List<dynamic> clients=[];
  List<Dropdown> clientsDropdown=[];
  Request request;
  String status;
  _ApproveForTrialState(this.request,this.status);
  @override
  void initState() {
    remarks=TextEditingController();
    SharedPreferences.getInstance().then((prefs){
      Network_Operations.getDropDowns(context, prefs.getString("token"),"Clients").then((cli){
        setState(() {
          this.clientsDropdown=cli;
          for(var c in cli){
            clients.add({
              "display":c.name,
              "value":   c.id.toString()
            });
          }
        });
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Approve/Reject for Trial"),
      ),
      body: ListView(
        children: [
           FormBuilder(
             key: fbKey,
             child: Column(
               children: [
                 Padding(
                   padding: EdgeInsets.all(16),
                   child:Card(
                     elevation: 10,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(15),
                     ),
                     child: FormBuilderDateTimePicker(
                       attribute: "Actual Start Date",
                       style: Theme.of(context).textTheme.bodyText1,
                       inputType: InputType.date,
                       validators: [FormBuilderValidators.required()],
                       format: DateFormat("MM-dd-yyyy"),
                       decoration: InputDecoration(hintText: "Actual Production Start Date",contentPadding: EdgeInsets.all(16),border: InputBorder.none),
                       onChanged: (value){
                         setState(() {
                           this.startDate=value;
                         });
                       },
                     ),
                   ),
                 ),
                 Padding(
                   padding: EdgeInsets.only(left: 16,right: 16,bottom: 16),
                   child:Card(
                     elevation: 10,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(15),
                     ),
                     child: FormBuilderDateTimePicker(
                       attribute: "Actual End Date",
                       style: Theme.of(context).textTheme.bodyText1,
                       inputType: InputType.date,
                       validators: [FormBuilderValidators.required()],
                       format: DateFormat("MM-dd-yyyy"),
                       decoration: InputDecoration(hintText: "Actual Production End Date",contentPadding: EdgeInsets.all(16),border: InputBorder.none),
                       onChanged: (value){
                         setState(() {
                           this.endDate=value;
                         });
                       },
                     ),
                   ),
                 ),
                 Visibility(
                   visible: status=="Approve",
                   child: Padding(
                     padding: const EdgeInsets.only(left: 16,right: 16,bottom: 16),
                     child: Card(
                       elevation: 10,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(15),
                       ),
                       child: MultiSelectFormField(
                         autovalidate: false,
                         hintText: "Select Clients",
                         titleText: 'Select Clients',
                         textField: 'display',
                         valueField: 'value',
                         okButtonLabel: 'OK',
                         cancelButtonLabel: 'CANCEL',
                         dataSource: clients,
                         border: InputBorder.none,
                         validator: (value) {
                           return value == null || value.length == 0?'Please select one or more Clients':null;
                         },
                         onSaved: (value){
                           if (value == null) return;
                           setState(() {
                             myClients = value;
                           });
                         },
                       ),
                     ),
                   ),
                 ),
                 Padding(
                   padding: EdgeInsets.only(left: 16,right: 16,bottom: 16),
                   child: Card(
                     elevation: 10,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(15),
                     ),
                     child: FormBuilderTextField(
                       attribute: "Remarks",
                       controller: remarks,
                       validators: [FormBuilderValidators.required()],
                       maxLines: 5,
                       decoration: InputDecoration(
                           hintText: "Remarks",
                           contentPadding: EdgeInsets.all(16),
                           border: InputBorder.none
                       ),
                     ),
                   ),
                 ),
                 Builder(
                   builder: (BuildContext context){
                     return Center(
                       child: MaterialButton(
                         onPressed: (){
                           if(fbKey.currentState.validate()){
                             if(status=="Approve"){
                               SharedPreferences.getInstance().then((prefs){
                                 Network_Operations.addRequestSchedule(context, prefs.getString("token"), request.requestId,DateTime.parse(request.targetStartDate) ,DateTime.parse(request.targetEndDate) , startDate, endDate,5).then((value){
                                   Network_Operations.trialClient(context, prefs.getString("token"), myClients, request.requestId,remarks.text);
                                 });
                               });
                             }else if(status=="Reject"){
                               SharedPreferences.getInstance().then((prefs){
                                 Network_Operations.addRequestSchedule(context, prefs.getString("token"), request.requestId,DateTime.parse(request.targetStartDate) ,DateTime.parse(request.targetEndDate) , startDate, endDate,5).then((value){
                                   Network_Operations.changeStatusWithRemarks(context, prefs.getString("token"), request.requestId, 6, remarks.text).then((value){
                                     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Dashboard()), (route) => false);
                                   });
                                 });

                               });

                             }
                           }

                         },
                         color: Color(0xFF004c4c),
                         child: Text("Proceed",style: TextStyle(color: Colors.white),),
                       ),
                     );
                   },
                 )
               ],
             ),
           )
        ],
      ),
    );
  }
}
