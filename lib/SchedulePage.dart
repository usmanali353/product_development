import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Network_Operations/Network_Operations.dart';
class SchedulePage extends StatefulWidget {
  var request;

  SchedulePage(this.request);

  @override
  _SchedulePageState createState() => _SchedulePageState(request);
}

class _SchedulePageState extends State<SchedulePage> {
  var request;
   GlobalKey<FormBuilderState> fbKey=GlobalKey();
  _SchedulePageState(this.request);
  TextEditingController remarks;
  DateTime targetStartDate,targetEndDate;
@override
  void initState() {
   remarks=TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Schedule Request"),
      ),
      body: ListView(
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
                      attribute: "Target Start Date",
                      style: Theme.of(context).textTheme.bodyText1,
                      inputType: InputType.date,
                      validators: [FormBuilderValidators.required()],
                      format: DateFormat("MM-dd-yyyy"),
                      decoration: InputDecoration(hintText: "Target Start Date",contentPadding: EdgeInsets.all(16),border: InputBorder.none),
                      onChanged: (value){
                        setState(() {
                          this.targetStartDate=value;
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
                      attribute: "Target End Date",
                      style: Theme.of(context).textTheme.bodyText1,
                      inputType: InputType.date,
                      validators: [FormBuilderValidators.required()],
                      format: DateFormat("MM-dd-yyyy"),
                      decoration: InputDecoration(hintText: "Target End Date",contentPadding: EdgeInsets.all(16),border: InputBorder.none),
                      onChanged: (value){
                        setState(() {
                          this.targetEndDate=value;
                        });
                      },
                    ),
                  ),
                ),
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
                      SharedPreferences.getInstance().then((prefs){
                        Network_Operations.addRequestSchedule(context,prefs.getString("token"), request.requestId, targetStartDate, targetEndDate, null,null,4,remarks.text);
                      });
                    }
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
