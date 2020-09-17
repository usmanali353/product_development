import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Dashboard.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:progress_dialog/progress_dialog.dart';
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
  var request;
  TextEditingController remarks,modelName,modelCode;
  GlobalKey<FormBuilderState> fbKey=GlobalKey();
  _ObservationsState(this.status,this.request);
 @override
  void initState() {
    remarks=TextEditingController();
    modelName=TextEditingController();
    modelCode=TextEditingController();
    SharedPreferences.getInstance().then((prefs){
      setState(() {
        token= prefs.getString("token");
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Remarks"),),
      body: ListView(
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
                  visible: status==7,
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
                  visible: status==7,
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
                Center(
                  child: MaterialButton(
                    child: Text("Change Status",style: TextStyle(color: Colors.white),),
                    color: Color(0xFF004c4c),
                    onPressed: (){
                      if(fbKey.currentState.validate()){
                        if(status==6){
                            Network_Operations.changeStatusWithRemarks(context,token, request.requestId, status, remarks.text);
                        }else if(status==7){
                         Network_Operations.changeStatusClientWithRemarks(context, token, request.id, status, remarks.text,modelName.text,modelCode.text);
                       }else if(status==8){
                         Network_Operations.changeStatusClientWithRemarks(context, token, request.id, status, remarks.text,null,null);
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
    );
  }
}
