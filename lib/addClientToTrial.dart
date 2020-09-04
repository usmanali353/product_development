import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AddClientToTrial extends StatefulWidget {
  int requestId;

  AddClientToTrial(this.requestId);

  @override
  _AddClientToTrialState createState() => _AddClientToTrialState(requestId);
}

class _AddClientToTrialState extends State<AddClientToTrial> {
  GlobalKey<FormState> fbKey=GlobalKey();
  List myClients;
  List<dynamic> clients;
  int requestId;

  _AddClientToTrialState(this.requestId);
 @override
  void initState() {
   SharedPreferences.getInstance().then((prefs){
     Network_Operations.getClients(context, prefs.getString("token")).then((clientsDropDown){
       setState(() {
         this.clients=clientsDropDown;
       });
     });
   });

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Clients to Trial"),),
      body: ListView(
        children: [
          Form(
            key: fbKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: MultiSelectFormField(
                      autovalidate: false,
                      hintText: "Select Clients",
                      titleText: 'Select Clients',
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
                Center(
                  child: MaterialButton(
                    onPressed: (){
                      SharedPreferences.getInstance().then((prefs){
                        Network_Operations.trialClient(context, prefs.getString("token"), myClients, requestId);
                      });
                    },
                    color: Colors.teal,
                    child: Text("Add Clients",style: TextStyle(color: Colors.white),),
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
