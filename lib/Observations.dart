import 'package:filter_list/filter_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Model/Dropdown.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Observations extends StatefulWidget {
  int status;
  var request;
  Observations(this.status,this.request);
  @override
  _ObservationsState createState() => _ObservationsState(status,request);
}

class _ObservationsState extends State<Observations> {
  String token;
  int status;
  var request,selectedRejectionReason,selectedReasonId;
  List<String> rejectionReasonName=[],selectedReasonNames=[],selectedReasonIds=[];
  List<Dropdown> rejectionReasonDropdown=[];
  bool rejectionReasonVisible=false;
  DateTime visitDate=DateTime.now();
  List<Widget> selectedOptions = [];

  TextEditingController remarks;
  GlobalKey<FormBuilderState> fbKey=GlobalKey();
  _ObservationsState(this.status,this.request);
 @override
  void initState() {
    remarks=TextEditingController();

    SharedPreferences.getInstance().then((prefs){
      setState(() {
        token= prefs.getString("token");
      });
      Network_Operations.getDropDowns(context, token,"Reasons").then((rejectionReasonList){
        setState(() {
          this.rejectionReasonDropdown=rejectionReasonList;
          if(rejectionReasonDropdown!=null&&rejectionReasonDropdown.length>0){
            this.rejectionReasonVisible=true;
            for(int i=0;i<rejectionReasonDropdown.length;i++){
              this.rejectionReasonName.add(rejectionReasonDropdown[i].name);
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
      appBar: AppBar(title: Text("Remarks"),),
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
          children: <Widget>[
            FormBuilder(
              key: fbKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: FormBuilderTextField(
                        attribute: "Remarks",
                        controller: remarks,
                        validators: [FormBuilderValidators.required()],
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText: "Remarks",
                          contentPadding: EdgeInsets.all(16),
                          border: InputBorder.none
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: status==7||status==8,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16,right: 16,bottom: 16),
                      child:Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: FormBuilderDateTimePicker(
                          attribute: "Visit Date",
                          style: Theme.of(context).textTheme.bodyText1,
                          inputType: InputType.date,
                          validators: [FormBuilderValidators.required()],
                          format: DateFormat("MM-dd-yyyy"),
                          decoration: InputDecoration(hintText: "Visit Date",contentPadding: EdgeInsets.all(16),border: InputBorder.none),
                          onChanged: (value){
                            setState(() {
                              this.visitDate=value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  // Visibility(
                  //   visible: rejectionReasonVisible&&status==8,
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(left: 16,right:16,bottom: 16),
                  //     child: Card(
                  //       elevation: 10,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(15),
                  //       ),
                  //       child: FormBuilderDropdown(
                  //
                  //         attribute: "Rejection Reason",
                  //
                  //         validators: [FormBuilderValidators.required()],
                  //
                  //         hint: Text("Select Rejection Reason"),
                  //
                  //         items:rejectionReasonName!=null?rejectionReasonName.map((horse)=>DropdownMenuItem(
                  //
                  //           child: Text(horse),
                  //
                  //           value: horse,
                  //
                  //         )).toList():[""].map((name) => DropdownMenuItem(
                  //
                  //             value: name, child: Text("$name")))
                  //
                  //             .toList(),
                  //
                  //         style: Theme.of(context).textTheme.bodyText1,
                  //
                  //         decoration: InputDecoration(
                  //
                  //           border: InputBorder.none,
                  //
                  //           contentPadding: EdgeInsets.all(16),
                  //
                  //         ),
                  //
                  //         onChanged: (value){
                  //
                  //           setState(() {
                  //
                  //             this.selectedRejectionReason=value;
                  //
                  //             this.selectedReasonId=rejectionReasonDropdown[rejectionReasonName.indexOf(value)].id;
                  //
                  //           });
                  //
                  //         },
                  //
                  //       ),
                  //
                  //     ),
                  //
                  //   ),
                  //
                  // ),
                  Visibility(
                    visible: rejectionReasonVisible&&status==8,
                    child: InkWell(
                      onTap: (){
                        showSelectModelDialog();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16,right:16,bottom: 16),
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
                                        child: Text("Select Rejection Reason"),
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
                                selectedReasonNames.length > 0
                                    ? Wrap(
                                  spacing: 8.0,
                                  runSpacing: 0.0,
                                  children: selectedOptions,
                                )
                                    : new Container(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text("Select one or more Rejection Reasons"),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: MaterialButton(
                      child: Text("Change Status",style: TextStyle(color: Colors.white),),
                      color: Color(0xFF004c4c),
                      onPressed: (){
                        if(fbKey.currentState.validate()){
                          if(status==6){
                              Network_Operations.changeStatusWithRemarks(context,token, request.requestId, status, remarks.text);
                          }else if(status==7){
                           Network_Operations.changeStatusClientWithRemarks(context, token, request.id, status, remarks.text,visitDate,null);
                         }else if(status==8){
                           Network_Operations.changeStatusClientWithRemarks(context, token, request.id, status, remarks.text,visitDate,selectedReasonIds);
                         }else if(status==9){
                           Network_Operations.changeStatusClientWithRemarks(context, token, request.id, status, remarks.text,null,null);
                         }else if(status==10){
                           Network_Operations.changeStatusClientWithRemarks(context, token, request.id, status, remarks.text,null,null);
                         }
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  showSelectModelDialog()async{
    await FilterListDialog.display(
        context,
        height: 480,
        allTextList: rejectionReasonName,
        borderRadius: 20,
       // selectedItemTitle: "Reasons Selected",
        selectedTextBackgroundColor: Colors.teal,
        allResetButonColor: Color(0xFF004c4c),
        applyButonTextBackgroundColor: Color(0xFF004c4c),
        headerTextColor: Color(0xFF004c4c),
        closeIconColor: Color(0xFF004c4c),
        headlineText: "Select Reason",
        searchFieldHintText: "Search Reasons",
        selectedTextList: selectedReasonNames,
        onApplyButtonClick: (list) {
          if (list != null) {
            setState(() {
              selectedReasonNames.clear();
              selectedOptions.clear();
              selectedReasonIds.clear();
              this.selectedReasonNames = list;
              for(int i=0;i<selectedReasonNames.length;i++){
                selectedOptions.add(
                    Chip(label: Text(selectedReasonNames[i],overflow: TextOverflow.ellipsis,))
                );
                selectedReasonIds.add(rejectionReasonDropdown[rejectionReasonName.indexOf(selectedReasonNames[i])].id.toString());
                print(selectedReasonIds.toString());
              }
            });
          }
          Navigator.pop(context);
        });
  }
}
