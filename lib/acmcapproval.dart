import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:productdevelopment/Model/Dropdown.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Model/Request.dart';

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
  List myDesigners;
  List<Dropdown> designer=[];
  List<dynamic> designers=[];
  Request request;
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
            designers.add(
                {
                  "display":d.name,
                  "value":d.stringId
                }
            );
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
        title: Text("ACMC Approval"),
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
                  Form(
                    key: formState,
                    child: Visibility(
                      visible: status=="Approve",
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: MultiSelectFormField(
                            autovalidate: false,
                            title: Text("Select Designers"),
                            hintWidget: Text("Select Designers Involved"),
                            textField: 'display',
                            valueField: 'value',
                            okButtonLabel: 'OK',
                            cancelButtonLabel: 'CANCEL',
                            dataSource: designers,
                            border: InputBorder.none,
                            validator: (value) {
                              return value == null || value.length == 0?'Please select one or more Designer':null;
                            },
                            onSaved: (value){
                              if (value == null) return;
                              setState(() {
                                myDesigners = value;
                              });
                            },
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
                          attribute: "Designer Observations",
                          maxLines: 5,
                          controller: designerObservations,
                          validators: [FormBuilderValidators.required()],
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
                  Padding(
                    padding: status=="Approve"?EdgeInsets.only(left: 16,right: 16,bottom: 16):EdgeInsets.all(16),
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
                  MaterialButton(
                    color: Color(0xFF004c4c),
                    child: Text("Proceed",style: TextStyle(color: Colors.white),),
                    onPressed: (){
                      if(fbKey.currentState.validate()&&formState.currentState.validate()){
                        formState.currentState.save();
                        if(status=='Reject'){
                          Network_Operations.changeStatusWithRemarks(context, token, request.requestId, 3,remarks.text);
                        }else{
                          Network_Operations.addDesignersAndObservationToRequest(context, request.requestId,myDesigners,designerObservations.text,token,modelName.text,modelCode.text,remarks.text);
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

}