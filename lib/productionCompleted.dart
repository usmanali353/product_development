import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
class productionCompleted extends StatefulWidget {
  Request request;
  String status;
  productionCompleted(this.status,this.request);

  @override
  _productionCompletedState createState() => _productionCompletedState(status,request);
}

class _productionCompletedState extends State<productionCompleted> {
  Request request;
  TextEditingController modelName,modelCode;
  GlobalKey<FormBuilderState> fbKey=GlobalKey();
  _productionCompletedState(this.status,this.request);
  String token;
  String status;
  @override
  void initState() {
    modelName=TextEditingController();
    modelCode=TextEditingController();
    SharedPreferences.getInstance().then((prefs){
      this.token=prefs.getString("token");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(title: Text("Model Name/Code"),),
    body: ListView(
      children: <Widget>[
        FormBuilder(
          key: fbKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16),
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
              Padding(
                padding: const EdgeInsets.only(left: 16,right: 16,bottom: 16),
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
              Center(
                child: MaterialButton(
                  color: Color(0xFF004c4c),
                  child: Text("Proceed",style: TextStyle(color: Colors.white),),
                  onPressed: (){
                    if(fbKey.currentState.validate()){
                      if(status=="Approve"){
                        Network_Operations.changeStatusOfRequest(context, token, request.requestId, 5);
                      }else{
                        Network_Operations.changeStatusOfRequest(context, token, request.requestId, 6);
                      }

                    }

                  },
                ),
              )
            ],
          ),
        )

      ],
    ),
    );
  }
}
