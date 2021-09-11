import 'package:filter_list/filter_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:productdevelopment/Model/Dropdown.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Model/Request.dart';
import 'Utils/Utils.dart';

class acmcApproval extends StatefulWidget {
  String status,productId,approvedBy,approveById;
  Request request;
  acmcApproval(this.status, this.request);
  @override
  _acmcApprovalState createState() => _acmcApprovalState(status,request);
}
class _acmcApprovalState extends State<acmcApproval> {
  GlobalKey<FormBuilderState> fbKey=GlobalKey();
  GlobalKey<FormState> formState=GlobalKey();
  List<Dropdown> designer=[];
  List<dynamic> designers=[],selectedDesignerNames=[];
  List<String> selectedDesignerIds=[],designerNames=[];
  List<Widget> selectedDesignerOptions=[];
  Request request;
  bool isDesignerListVisible=false;
  TextEditingController designerObservations,modelName,modelCode,remarks;
  String status,productId;
  int requestId;
  String token;
  _acmcApprovalState(this.status, this.request);
  @override
  void initState() {
    designerObservations=TextEditingController();
    modelName=TextEditingController();
    modelCode=TextEditingController();
    remarks=TextEditingController();
    SharedPreferences.getInstance().then((prefs){
      token=prefs.getString("token");
      Network_Operations.getDesignerDropDowns(context, prefs.getString("token"), "Designer").then((designerDopDown){
        setState(() {
          designer=designerDopDown;
          for(var d in designer){
            designerNames.add(d.name);
          }
          if(designer!=null&&designer.length>0){
            this.isDesignerListVisible=true;
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
        title: Text(status=="Approve"?"ACMC Approval":"ACMC Rejection"),
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
          children: <Widget>[
            FormBuilder(
              key: fbKey,
              child: Column(
                children: <Widget>[
                  Visibility(
                    visible: status=="Approve",
                    child: InkWell(
                      onTap:(){
                        showSelectDesignersDialog();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
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
                                        child: Text("Select Designers"),
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
                                selectedDesignerNames.length > 0
                                    ? Wrap(
                                  spacing: 8.0,
                                  runSpacing: 0.0,
                                  children: selectedDesignerOptions,
                                )
                                    : new Container(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text("Select one or more Designers"),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: status=="Approve",
                    child: Padding(
                      padding: EdgeInsets.only(left: 16,right: 16,bottom: 16),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: FormBuilderTextField(
                          name: "Designer Observations",
                          maxLines: 5,
                          controller: designerObservations,
                          validator: FormBuilderValidators.required(context,errorText: "This Field is Required"),
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(16),
                              border: InputBorder.none,
                              hintText: "Designer Observations"
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: status=="Approve",
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16,right: 16),
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
                  Padding(
                    padding: status=="Approve"?EdgeInsets.only(left: 16,right: 16,bottom: 16):EdgeInsets.all(16),
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
                  MaterialButton(
                    color: Color(0xFF004c4c),
                    child: Text("Proceed",style: TextStyle(color: Colors.white),),
                    onPressed: (){
                      if(fbKey.currentState.validate()){
                        if(status=='Reject'){
                          Network_Operations.changeStatusWithRemarks(context, token, request.requestId, 3,remarks.text);
                        }else{
                          if(selectedDesignerIds.length==0){
                            Utils.showError(context,"Please Select one or More Designers Involved");
                          }else {
                            Network_Operations.addDesignersAndObservationToRequest(context, request.requestId, selectedDesignerIds, designerObservations.text, token, modelName.text, modelCode.text, remarks.text);
                          }
                        }

                      }

                    },

                  ),
                ],

              ),

            )

          ],

        ),
      ),

    );

  }
  showSelectDesignersDialog()async{
    await FilterListDialog.display(
        context,
        height: 480,
        listData: designerNames,
        selectedListData: selectedDesignerNames,
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
        headlineText: "Select Designers",
        searchFieldHintText: "Search Designers",
        onApplyButtonClick: (list) {
          if (list != null) {
            setState(() {
              selectedDesignerNames.clear();
              selectedDesignerOptions.clear();
              selectedDesignerIds.clear();
              this.selectedDesignerNames = list;
              for(int i=0;i<selectedDesignerNames.length;i++){
                selectedDesignerOptions.add(
                    Chip(label: Text(selectedDesignerNames[i],overflow: TextOverflow.ellipsis,))
                );
                selectedDesignerIds.add(designer[designerNames.indexOf(selectedDesignerNames[i])].stringId.toString());
                print(selectedDesignerIds.toString());
              }
            });
          }
          Navigator.pop(context);
        });
  }

}