import 'dart:math';

import 'package:filter_list/filter_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
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
  List<dynamic> selectedClientNames=[];
  List<Dropdown> clientsDropdown=[];
  List<String> clientNames=[],selectedClientIds=[];
  List<Widget> selectedClientOptions=[];
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
        title: Text(status=="Approve"?"Approve Model":"Reject Model"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
              image: AssetImage('Assets/img/pattren.png'),
            )
        ),
        child: ListView(
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
                         name: "Actual Start Date",
                         style: Theme.of(context).textTheme.bodyText1,
                         inputType: InputType.date,
                         validator: FormBuilderValidators.required(context,errorText: "This Field is Required"),
                         format: DateFormat("MM-dd-yyyy"),
                         decoration: InputDecoration(hintText: "Sample Actual Start Date",contentPadding: EdgeInsets.all(16),border: InputBorder.none),
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
                         name: "Sample Production Actual End Date",
                         style: Theme.of(context).textTheme.bodyText1,
                         inputType: InputType.date,
                         validator: FormBuilderValidators.required(context,errorText: "This Field is Required"),
                         format: DateFormat("MM-dd-yyyy"),
                         decoration: InputDecoration(hintText: "Sample Actual End Date",contentPadding: EdgeInsets.all(16),border: InputBorder.none),
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
                           name: "Model Name",
                           controller: modelName,
                           validator: FormBuilderValidators.required(context,errorText: "This Field is Required"),
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
                           name: "Model Code",
                           controller: modelCode,
                           validator: FormBuilderValidators.required(context,errorText: "This Field is Required"),
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
                     visible:status=="Approve"&&clientNames.length>0,
                     child: InkWell(
                       onTap: (){
                         showSelectClientsDialog();
                       },
                       child: Padding(
                         padding:EdgeInsets.only(left:16,right: 16,bottom: 16),
                         child: Card(
                           elevation: 10,
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(15),
                           ),
                           child: InputDecorator(
                             decoration: InputDecoration(
                               filled: true,
                               errorMaxLines: 4,
                               fillColor: Theme.of(context).canvasColor,
                               border: InputBorder.none,
                             ),

                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Padding(
                                   padding:EdgeInsets.fromLTRB(0, 2, 0, 0),
                                   child: Row(
                                     children: [
                                       Expanded(
                                         child: Text("Select Clients"),
                                       ),
                                       Padding(
                                         padding: EdgeInsets.only(top: 5, right: 5),
                                         child: Text(
                                           ' *',
                                           style: TextStyle(
                                             color: Colors.red.shade700,
                                             fontSize: 17.0,
                                           ),
                                         ),
                                       ),
                                       Icon(
                                         Icons.arrow_drop_down,
                                         color: Colors.black87,
                                         size: 25.0,
                                       ),
                                     ],
                                   ),
                                 ),
                                 selectedClientNames.length > 0
                                     ? Wrap(
                                   spacing: 8.0,
                                   runSpacing: 0.0,
                                   children: selectedClientOptions,
                                 )
                                     : new Container(
                                   padding: EdgeInsets.only(top: 4),
                                   child: Text("Select one or more Clients"),
                                 )
                               ],
                             ),
                           ),
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
                         name: "Client Visit Date",
                         style: Theme.of(context).textTheme.bodyText1,
                         inputType: InputType.date,
                         validator: FormBuilderValidators.required(context,errorText: "This Field is Required"),
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
                         name: "Remarks",
                         controller: remarks,
                         validator: FormBuilderValidators.required(context,errorText: "This Field is Required"),
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
                                 if(selectedClientIds.length==0){
                                   Utils.showError(context,"Select one or More Clients For Model Approval");
                                 }else
                                 if(actualStartDate.isBefore(actualEndDate)&&actualEndDate.isAfter(actualStartDate)){
                                   if(actualStartDate.isBefore(DateTime.now())||actualEndDate.isBefore(DateTime.now())||clientVisitDate.isBefore(DateTime.now())){
                                     Utils.showError(context,"Actual Start and End Date and Client Visit Date Should not be in past");
                                   }else{
                                     SharedPreferences.getInstance().then((prefs){
                                       Network_Operations.trialClient(context, prefs.getString("token"),selectedClientIds, request.requestId,remarks.text,clientVisitDate,actualStartDate,actualEndDate,modelName.text,modelCode.text);
                                     });
                                   }
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
      ),
    );
  }
  showSelectClientsDialog()async{
    await FilterListDialog.display(
        context,
        height: 480,
        listData: clientNames,
        selectedListData: selectedClientNames,
        headerTextColor: Color(0xFF004c4c),
        choiceChipLabel: (item){
          return item;
        },
        validateSelectedItem: (list, val) {
          return list.contains(val);
        },
        onItemSearch: (list, text) {
          if (list.any((element) =>
              element.toLowerCase().contains(text.toLowerCase()))) {
            return list
                .where((element) =>
                element.toLowerCase().contains(text.toLowerCase()))
                .toList();
          }
          else{
            return [];
          }
        },
        borderRadius: 20,
        selectedTextBackgroundColor: Color(0xFF004c4c),
        // allResetButonColor: Color(0xFF004c4c),
        applyButonTextBackgroundColor: Color(0xFF004c4c),
        // headerTextColor: Color(0xFF004c4c),
        closeIconColor: Color(0xFF004c4c),
        headlineText: "Select Clients",
        searchFieldHintText: "Search Clients",
        onApplyButtonClick: (list) {
          if (list != null) {
            setState(() {
              selectedClientNames.clear();
              selectedClientOptions.clear();
              selectedClientIds.clear();
              this.selectedClientNames = list;
              for(int i=0;i<selectedClientNames.length;i++){
                selectedClientOptions.add(
                    Chip(label: Text(selectedClientNames[i],overflow: TextOverflow.ellipsis,))
                );
                selectedClientIds.add(clientsDropdown[clientNames.indexOf(selectedClientNames[i])].stringId.toString());
                print(selectedClientIds.toString());
              }
            });
          }
          Navigator.pop(context);
        });
  }
}
