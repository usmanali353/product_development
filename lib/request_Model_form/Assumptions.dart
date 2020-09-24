import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:need_resume/need_resume.dart';

import 'package:productdevelopment/Model/Dropdown.dart';

import 'package:productdevelopment/Network_Operations/Network_Operations.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'Specifications.dart';

class Assumptions extends StatefulWidget {

  @override

  _AssumptionsState createState() => _AssumptionsState();

}



class _AssumptionsState extends ResumableState<Assumptions> {

  TextEditingController event;

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey();

  bool marketDropdownVisible=false;

  int marketId;

  List<Dropdown> markets=[];

  List<String> marketNames=[];

  String selectedMarket,selectedClient="Client 1";

  int clientId;

  @override

  void onResume() {

   Navigator.pop(context,'Refresh');

    super.onResume();

  }

  @override

  void initState() {

    event=TextEditingController();

    SharedPreferences.getInstance().then((prefs){

     Network_Operations.getDropDowns(context, prefs.getString("token"), "Markets").then((marketDropDown){

       setState(() {

         this.markets=marketDropDown;

         for(var market in markets){

           marketNames.add(market.name);
         }

         if(marketNames.length>0){
           marketDropdownVisible=true;
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

        title: Text("Assumptions"),

      ),

      body: ListView(

        children: <Widget>[

          FormBuilder(

            key: _fbKey,

            child: Column(

              children: <Widget>[

                //Market Dropdown

                Visibility(

                  visible: marketDropdownVisible,

                  child: Padding(

                    padding: const EdgeInsets.only(top: 16,left: 16,right:16),

                    child: Card(

                      elevation: 10,

                      shape: RoundedRectangleBorder(

                        borderRadius: BorderRadius.circular(15),

                      ),

                      child: FormBuilderDropdown(

                        attribute: "Market",

                        validators: [FormBuilderValidators.required()],

                        hint: Text("Select Market"),

                        items:marketNames!=null?marketNames.map((horse)=>DropdownMenuItem(

                          child: Text(horse),

                          value: horse,

                        )).toList():[""].map((name) => DropdownMenuItem(

                            value: name, child: Text("$name")))

                            .toList(),

                        style: Theme.of(context).textTheme.bodyText1,

                        decoration: InputDecoration(

                          border: InputBorder.none,

                          contentPadding: EdgeInsets.all(16),

                        ),

                        onChanged: (value){

                          setState(() {

                            this.selectedMarket=value;

                            this.marketId=markets[marketNames.indexOf(value)].id;

                          });

                        },

                      ),

                    ),

                  ),

                ),

                // Event TextBox

                Padding(

                  padding: EdgeInsets.only(top: 16,left: 16,right: 16,bottom: 16),

                  child: Card(

                    elevation: 10,

                    shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(15),

                    ),

                    child: FormBuilderTextField(

                      controller: event,

                      attribute: "Event",

                      validators: [FormBuilderValidators.required()],

                      decoration: InputDecoration(hintText: "Event",

                        border: InputBorder.none,

                        contentPadding: EdgeInsets.all(16),

                      ),

                    ),

                  ),

                ),



                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(

                    child: MaterialButton(

                      child: Text("Proceed",style: TextStyle(color: Colors.white),),

                      color: Color(0xFF004c4c),

                      onPressed: (){

                        if(_fbKey.currentState.validate()){

                          push(context, MaterialPageRoute(builder: (context)=>Specifications(marketId,event.text)));

                        }

                      },

                    ),

                  ),
                ),

              ],

            ),

          )

        ],

      ),

    );

  }

}