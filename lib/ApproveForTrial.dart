import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Model/Dropdown.dart';
import 'Network_Operations/Network_Operations.dart';
import 'Utils/Utils.dart';
class ApproveForTrial extends StatefulWidget {
  Request request;
  String status;
  ApproveForTrial(this.request,this.status);

  @override
  _ApproveForTrialState createState() => _ApproveForTrialState(request,status);
}

class _ApproveForTrialState extends State<ApproveForTrial> {
  GlobalKey<FormBuilderState> fbKey=GlobalKey();
  DateTime clientVisitDate = DateTime.now(),actualStartDate=DateTime.now(),actualEndDate=DateTime.now();
  TextEditingController remarks,modelName,modelCode;
  List myClients=[];
  List<dynamic> clients=[];
  List<Dropdown> clientsDropdown=[];
  List<String> clientNames=[];
  Request request;
  String status;
  var clientId;
  _ApproveForTrialState(this.request,this.status);
  @override
  void initState() {
    remarks=TextEditingController();
    modelName=TextEditingController();
    modelCode=TextEditingController();
    SharedPreferences.getInstance().then((prefs){
      Network_Operations.getClientsForTrial(context, prefs.getString("token"),request.requestId).then((cli){
        setState(() {
          this.clientsDropdown=cli;
          for(var c in cli){
            clientNames.add(c.name);
            clients.add({
              "display":c.name,
              "value": c.stringId
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
                       decoration: InputDecoration(hintText: "Sample Production Actual Start Date",contentPadding: EdgeInsets.all(16),border: InputBorder.none),
                       onChanged: (value){
                         setState(() {
                           this.actualStartDate=value;
                         });
                       },
                     ),
                   ),
                 ),
                 Padding(
                   padding: EdgeInsets.only(left: 16,right: 16),
                   child:Card(
                     elevation: 10,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(15),
                     ),
                     child: FormBuilderDateTimePicker(
                       attribute: "Sample Production Actual End Date",
                       style: Theme.of(context).textTheme.bodyText1,
                       inputType: InputType.date,
                       validators: [FormBuilderValidators.required()],
                       format: DateFormat("MM-dd-yyyy"),
                       decoration: InputDecoration(hintText: "Sample Production Actual End Date",contentPadding: EdgeInsets.all(16),border: InputBorder.none),
                       onChanged: (value){
                         setState(() {
                           this.actualEndDate=value;
                         });
                       },
                     ),
                   ),
                 ),
                 Visibility(
                   visible: status=="Approve",
                   child: Padding(
                     padding: const EdgeInsets.only(left: 16,right: 16,top: 16),
                     child: Card(
                       elevation: 10,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(15),
                       ),
                       child: FormBuilderTextField(
                         attribute: "Model Name",
                         controller: modelName,
                         validators: [FormBuilderValidators.required()],
                         decoration: InputDecoration(
                             contentPadding: EdgeInsets.all(16),
                             border: InputBorder.none,
                             hintText: "Model Name"
                         ),
                       ),
                     ),
                   ),
                 ),
                 Visibility(
                   visible: status=="Approve",
                   child: Padding(
                     padding: const EdgeInsets.all(16),
                     child: Card(
                       elevation: 10,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(15),
                       ),
                       child: FormBuilderTextField(
                         attribute: "Model Code",
                         controller: modelCode,
                         validators: [FormBuilderValidators.required()],
                         decoration: InputDecoration(
                             contentPadding: EdgeInsets.all(16),
                             border: InputBorder.none,
                             hintText: "Model Code"
                         ),
                       ),
                     ),
                   ),
                 ),

                 Visibility(
                   visible: status=="Approve"&&clientNames.length>0,
                   child: Padding(
                     padding: const EdgeInsets.only(left: 16,right: 16,bottom: 16),
                     child: Card(
                       elevation: 10,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(15),
                       ),
                       child: MultiSelectFormField(
                         autovalidate: false,
                         title: Text("Select Clients"),
                         hintWidget: Text("Select Clients for the Trial"),
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
                   padding: EdgeInsets.only(bottom: 16,left: 16,right: 16),
                   child:Card(
                     elevation: 10,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(15),
                     ),
                     child: FormBuilderDateTimePicker(
                       attribute: "Client Visit Date",
                       style: Theme.of(context).textTheme.bodyText1,
                       inputType: InputType.date,
                       validators: [FormBuilderValidators.required()],
                       format: DateFormat("MM-dd-yyyy"),
                       decoration: InputDecoration(hintText: "Client Visit Date",contentPadding: EdgeInsets.all(16),border: InputBorder.none),
                       onChanged: (value){
                         setState(() {
                           this.clientVisitDate=value;
                         });
                       },
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
                               if(actualStartDate.isBefore(actualEndDate)&&actualEndDate.isAfter(actualStartDate)){
                                 SharedPreferences.getInstance().then((prefs){
                                   if(request.marketId==2){
                                     myClients.clear();
                                     myClients.add(clientId);
                                   }

                                   Network_Operations.trialClient(context, prefs.getString("token"),myClients, request.requestId,remarks.text,clientVisitDate,actualStartDate,actualEndDate,modelName.text,modelCode.text);
                                 });
                               }else{
                                 Utils.showError(context,"Actual Start Date Should be before Actual End Date and ");
                               }

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
