import 'package:filter_list/filter_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:productdevelopment/Model/Dropdown.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/Utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Specifications.dart';

class Assumptions extends StatefulWidget {
 bool isUpdate;
 Assumptions({isUpdate});
  @override

  _AssumptionsState createState() => _AssumptionsState();

}



class _AssumptionsState extends State<Assumptions> {

  TextEditingController event;

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey();

  bool marketDropdownVisible=false,clientDropDownVisible=false;

  int marketId;

  List<Dropdown> clients=[];

  List<Dropdown> markets=[];

  List<String> marketNames=[];

  List<String> clientNames=[],selectedClientIds=[];

  List<Widget> selectedOptions=[];

  List<dynamic> selectedClientNames=[];

  String selectedMarket,selectedClient="Client 1";

  String clientId;

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
         Network_Operations.getDropDowns(context,prefs.getString("token"),"Clients").then((clientDropDown){
           setState(() {
             if(clients!=null){
               this.clients=clientDropDown;
               for(var c in clients){
                 clientNames.add(c.name);
               }
             }
           });
         });
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
                    // Client Dropdown
                  Visibility(
                    visible:selectedMarket!=null&&selectedMarket=="Local Exclusive",
                    child: Padding(

                      padding: const EdgeInsets.only(left: 16,right:16,bottom: 16),

                      child: Card(

                        elevation: 10,

                        shape: RoundedRectangleBorder(

                          borderRadius: BorderRadius.circular(15),

                        ),

                        child: FormBuilderDropdown(

                          attribute: "Client",

                          validators: [FormBuilderValidators.required()],

                          hint: Text("Select Client"),

                          items:clientNames!=null?clientNames.map((horse)=>DropdownMenuItem(

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
                              this.clientId =clients[clientNames.indexOf(value)].stringId;
                            });

                          },

                        ),

                      ),

                    ),
                  ),
                  Visibility(
                    visible:selectedMarket!=null&&selectedMarket!="Local Exclusive",
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16,right: 16,bottom: 16),
                      child: InkWell(
                        onTap: (){
                          showSelectClientDialog();
                        },
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
                                        child: Text("Select Clients"),
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
                                selectedClientNames.length > 0
                                    ? Wrap(
                                  spacing: 8.0,
                                  runSpacing: 0.0,
                                  children: selectedOptions,
                                )
                                    : new Container(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text("Select one or more Clients"),
                                )
                              ],
                            ),
                          ),
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
                            if(selectedMarket=="Local Exclusive") {
                              selectedClientIds.add(clientId);
                            }
                            if(selectedClientIds==null||selectedClientIds.length==0){
                              Utils.showError(context,"Please Select one or more Client");
                            }else {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) =>
                                      Specifications(marketId, event.text,
                                          selectedClientIds)));
                            }
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
      ),

    );

  }
  showSelectClientDialog()async{
    await FilterListDialog.display(
        context,
        height: 480,
        listData: clientNames,
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
        headlineText: "Select Clients",
        searchFieldHintText: "Search Clients",
        onApplyButtonClick: (list) {
          if (list != null) {
            setState(() {
              selectedClientNames.clear();
              selectedOptions.clear();
              selectedClientIds.clear();
              this.selectedClientNames = list;
              for(int i=0;i<selectedClientNames.length;i++){
                selectedOptions.add(
                    Chip(label: Text(selectedClientNames[i],overflow: TextOverflow.ellipsis,))
                );
                selectedClientIds.add(clients[clientNames.indexOf(selectedClientNames[i])].stringId);
                print(selectedClientIds.length);
                print(selectedClientIds.toString());
              }
            });
          }
          Navigator.pop(context);
        });
  }
}