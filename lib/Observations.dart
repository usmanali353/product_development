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
  DateTime visitDate=DateTime.now();
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
                Center(
                  child: MaterialButton(
                    child: Text("Change Status",style: TextStyle(color: Colors.white),),
                    color: Color(0xFF004c4c),
                    onPressed: (){
                      if(fbKey.currentState.validate()){
                        if(status==6){
                            Network_Operations.changeStatusWithRemarks(context,token, request.requestId, status, remarks.text);
                        }else if(status==7){
                         Network_Operations.changeStatusClientWithRemarks(context, token, request.id, status, remarks.text,visitDate);
                       }else if(status==8){
                         Network_Operations.changeStatusClientWithRemarks(context, token, request.id, status, remarks.text,visitDate);
                       }else if(status==9){
                         Network_Operations.changeStatusClientWithRemarks(context, token, request.id, status, remarks.text,null);
                       }else if(status==10){
                         Network_Operations.changeStatusClientWithRemarks(context, token, request.id, status, remarks.text,null);
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
