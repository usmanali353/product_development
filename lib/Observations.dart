import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Observations extends StatefulWidget {
  String status;
  Request request;
  Observations(this.status,this.request);
  @override
  _ObservationsState createState() => _ObservationsState(status,request);
}

class _ObservationsState extends State<Observations> {
  String token;
  String status;
  Request request;
  TextEditingController observation;
  GlobalKey<FormBuilderState> fbKey=GlobalKey();
  _ObservationsState(this.status,this.request);
 @override
  void initState() {
    observation=TextEditingController();
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
      appBar: AppBar(title: Text("Observations"),),
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
                      attribute: "Commercial Observation",
                      controller: observation,
                      validators: [FormBuilderValidators.required()],
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: "Commercial Observation",
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none
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
                          Network_Operations.approveRequestClient(context, token, request.requestId, 1);
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
