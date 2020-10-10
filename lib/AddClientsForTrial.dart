import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:productdevelopment/Model/Dropdown.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AddClientsToTrial extends StatefulWidget {
  @override
  _AddClientsToTrialState createState() => _AddClientsToTrialState();
}

class _AddClientsToTrialState extends State<AddClientsToTrial> {
  List myClients=[],myApprovedModels=[];
  List<dynamic> clients=[],approvedModels=[];
  DateTime clientVisitDate=DateTime.now();
  bool isClientDropDownVisible=false,isModelDropDownVisible=false;
  List<Dropdown> clientsDropdown=[],modelDropDowns=[];
  List<String> clientNames=[],modelNames=[];
  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs){
      Network_Operations.getDropDowns(context, prefs.getString("token"),"Clients").then((cli){
        setState(() {
          this.clientsDropdown=cli;
          for(var c in cli){
            clientNames.add(c.name);
            clients.add({
              "display":c.name,
              "value": c.stringId
            });
            if(clients!=null&&clients.length>0){
              setState(() {
                isClientDropDownVisible=true;
              });
            }
          }
        });
      });
      Network_Operations.getModelsDropDowns(context, prefs.getString("token"),"GetRequests").then((cli){
        setState(() {
          this.modelDropDowns=cli;
          for(var c in cli){
            modelNames.add(c.name);
            approvedModels.add({
              "display":c.name,
              "value": c.id.toString()
            });
            if(approvedModels!=null&&approvedModels.length>0){
              setState(() {
                isModelDropDownVisible=true;
              });
            }
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
        title: Text("Add Clients to Trial"),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              Visibility(
                visible: isModelDropDownVisible,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: MultiSelectFormField(
                      autovalidate: false,
                      title: Text("Select Approved Model"),
                      hintWidget: Text("Select Approved Model for the Trial"),
                      textField: 'display',
                      valueField: 'value',
                      okButtonLabel: 'OK',
                      cancelButtonLabel: 'CANCEL',
                      dataSource: approvedModels,
                      border: InputBorder.none,
                      validator: (value) {
                        return value == null || value.length == 0?'Please select one or more Models':null;
                      },
                      onSaved: (value){
                        if (value == null) return;
                        setState(() {
                          myApprovedModels = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: isClientDropDownVisible,
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
                padding: EdgeInsets.only(left: 16,right: 16,bottom: 16),
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
              Builder(builder:(BuildContext context){
                return Center(
                  child: MaterialButton(
                    color: Color(0xFF004c4c),
                      child: Text("Add Clients",style: TextStyle(color: Colors.white),),
                      onPressed: (){
                        SharedPreferences.getInstance().then((prefs){
                          Network_Operations.addClientsToTrial(context, prefs.getString("token"), myApprovedModels, myClients, clientVisitDate);
                        });
                      },
                  ),
                );
              }),
            ],
          )
        ],
      ),
    );
  }
}
