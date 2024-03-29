import 'package:filter_list/filter_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Model/Dropdown.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/Utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AddClientsToTrial extends StatefulWidget {
  @override
  _AddClientsToTrialState createState() => _AddClientsToTrialState();
}

class _AddClientsToTrialState extends State<AddClientsToTrial> {
  GlobalKey<FormBuilderState> fbkey=GlobalKey();
  DateTime clientVisitDate=DateTime.now();
  bool isClientDropDownVisible=false,isModelDropDownVisible=false;
  List<Dropdown> clientsDropdown=[],modelDropDowns=[];
  List<dynamic> selectedModelNames=[];
  List<String> clientNames=[],modelNames=[],selectedModelIds=[],selectedClientIds=[];
  List<Widget> selectedOptions=[],selectedClientOptions=[];
  List<dynamic> selectedClientNames=[];
  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs){
      Network_Operations.getDropDowns(context, prefs.getString("token"),"Clients").then((cli){
        setState(() {
          this.clientsDropdown=cli;
          for(var c in cli){
            clientNames.add(c.name);
            if(clientsDropdown!=null&&clientsDropdown.length>0){
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
            if(modelDropDowns!=null&&modelDropDowns.length>0){
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
        title: Text("Schedule Client Visit"),
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
              key: fbkey,
              child: Column(
                children: [
                  Visibility(
                    visible: isModelDropDownVisible,
                    child: InkWell(
                      onTap: (){
                       showSelectModelDialog();
                      },
                      child: Padding(
                        padding:EdgeInsets.all(16),
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
                                          child: Text("Select Model"),
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
                                selectedModelNames.length > 0
                                    ? Wrap(
                                  spacing: 8.0,
                                  runSpacing: 0.0,
                                  children: selectedOptions,
                                )
                                    : new Container(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text("Select one or more Models"),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isClientDropDownVisible,
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
                                  child: Text("Select one or more Clients for Model Approval"),
                                )
                              ],
                            ),
                          ),
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
                  Builder(builder:(BuildContext context){
                    return Center(
                      child: MaterialButton(
                        color: Color(0xFF004c4c),
                          child: Text("Add Clients",style: TextStyle(color: Colors.white),),
                          onPressed: (){
                           if(!fbkey.currentState.validate()){

                           }else if(selectedModelIds.length==0){
                             Utils.showError(context,"Select one or More Models For seeking client Approval");
                           }else if(selectedClientIds.length==0){
                             Utils.showError(context,"Select one or More Clients For Model Approval");
                           }else {
                             SharedPreferences.getInstance().then((prefs) {
                               Network_Operations.addClientsToTrial(
                                   context, prefs.getString("token"),
                                   selectedModelIds, selectedClientIds, clientVisitDate);
                             });
                           }
                          },
                      ),
                    );
                  }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  showSelectModelDialog()async{
    await FilterListDialog.display(
        context,
        height: 480,
        listData: modelNames,
        selectedListData: selectedModelNames,
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
        headlineText: "Select Model",
        searchFieldHintText: "Search Models",
        onApplyButtonClick: (list) {
          if (list != null) {
            setState(() {
              selectedModelNames.clear();
              selectedOptions.clear();
              selectedModelIds.clear();
              this.selectedModelNames = list;
              for(int i=0;i<selectedModelNames.length;i++){
                selectedOptions.add(
                    Chip(label: Text(selectedModelNames[i],overflow: TextOverflow.ellipsis,))
                );
                selectedModelIds.add(modelDropDowns[modelNames.indexOf(selectedModelNames[i])].id.toString());
                print(selectedModelIds.toString());
              }
            });
          }
          Navigator.pop(context);
        });
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
