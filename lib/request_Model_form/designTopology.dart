import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:need_resume/need_resume.dart';
import 'package:productdevelopment/Model/Dropdown.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Suitability.dart';
class designTopology extends StatefulWidget {
  var market,clientId,event,other,size,surfaceId,thickness,classification,color;
  List<dynamic> sizesList=[],colorsList=[];

  designTopology(this.market, this.clientId, this.event, this.sizesList,
      this.surfaceId, this.thickness, this.classification, this.colorsList);

  @override
  _designTopologyState createState() => _designTopologyState(market,clientId,event,sizesList,surfaceId,thickness,classification,colorsList);
}

class _designTopologyState extends ResumableState<designTopology> {
  List _myMaterials;
  bool designTopologyDropDownVisible=false;
  final formKey = new GlobalKey<FormState>();
  bool rangeDropdownVisible=false,technologyDropdownVisible=false,edgeDropdownVisible=false,structureDropdownVisible=false;
 List<Dropdown> designTopology=[], range=[], material=[],structure=[], edge=[],technology=[];
 List<String> designTopologyName=[], rangeName=[], materialName=[],structureName=[], edgeName=[],technologyName=[];
 List<dynamic> designTopologies=[],sizesList=[],colorsList=[];
 var market,clientId,event,other,size,surfaceId,name,thickness,classification,color;
String selected_technology, selected_structure, selected_edge,selected_range, selected_material;
GlobalKey<FormBuilderState> fbkey=GlobalKey();
int range_id, material_id,technology_id, structure_id, edge_id;
 _designTopologyState(
      this.market,
      this.clientId,
      this.event,
      this.sizesList,
      this.surfaceId,
      this.thickness,
      this.classification,
      this.colorsList);
 @override
  void onResume() {
   if(resume.data.toString()=='Close') {
     Navigator.pop(context, 'Close');
   }
    super.onResume();
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs){
      Network_Operations.getDropDowns(context, prefs.getString("token"), "DesignTopology").then((designTopologyDropDown){
        setState(() {
          this.designTopology=designTopologyDropDown;
          for(var s in designTopology){
            designTopologyName.add(s.name);
            designTopologies.add(
                {
                  "display": s.name,
                  "value": s.id.toString()
                }
            );
          }
          if(designTopologyName.length>0){
            designTopologyDropDownVisible=true;
          }
          Network_Operations.getDropDowns(context, prefs.getString("token"), "Ranges").then((rangeDropDown){
            setState(() {
              this.range=rangeDropDown;
              for(var r in range){
                rangeName.add(r.name);
              }
              if(rangeName.length>0){
                rangeDropdownVisible=true;
              }
            });

          });
          Network_Operations.getDropDowns(context, prefs.getString("token"), "Technologys").then((rangeDropDown){
            setState(() {
              this.technology=rangeDropDown;
              for(var r in technology){
                technologyName.add(r.name);
              }
              if(technologyName.length>0){
                technologyDropdownVisible=true;
              }
            });

          });
          Network_Operations.getDropDowns(context, prefs.getString("token"), "Structures").then((rangeDropDown){
            setState(() {
              this.structure=rangeDropDown;
              for(var r in structure){
                structureName.add(r.name);
              }
              if(structureName.length>0){
                structureDropdownVisible=true;
              }
            });

          });
          Network_Operations.getDropDowns(context, prefs.getString("token"), "Edges").then((rangeDropDown){
            setState(() {
              this.edge=rangeDropDown;
              for(var r in edge){
                edgeName.add(r.name);
              }
              if(edgeName.length>0){
                edgeDropdownVisible=true;
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
        title: Text("More Specifications"),
      ),
      body: ListView(
        children: <Widget>[
          FormBuilder(
            key: fbkey,
            child: Column(
              children: <Widget>[
                Form(
                  key: formKey,
                  child: Visibility(
                    visible: designTopologyDropDownVisible,
                    child: Padding(
                      padding: EdgeInsets.only(top:16,left:16,right:16),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                        ),
                        child: MultiSelectFormField(
                          hintText: "Select Design Topology",
                          titleText: 'Select Design Topology',
                          border: InputBorder.none,
                          validator: (value) {
                            return value == null || value.length == 0?'Please select one or more options':null;
                          },
                          dataSource: designTopologies,
                          textField: 'display',
                          valueField: 'value',
                          okButtonLabel: 'OK',
                          cancelButtonLabel: 'CANCEL',
                          //value: _myActivities,
                          onSaved: (value) {
                            if (value == null) return;
                            setState(() {
                              _myMaterials = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                //Product Materials

                //Product Range
                Visibility(
                  visible: rangeDropdownVisible,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16,left: 16,right:16),
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: FormBuilderDropdown(
                        attribute: "Range",
                        validators: [FormBuilderValidators.required()],
                        hint: Text("Select Range"),
                        items:rangeName!=null?rangeName.map((horse)=>DropdownMenuItem(
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
                            this.selected_range=value;
                            this.range_id=range[rangeName.indexOf(value)].id;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                //Product Technology
                Padding(
                  padding: const EdgeInsets.only(top: 16,left: 16,right:16),
                  child: Visibility(
                     visible: technologyDropdownVisible,
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: FormBuilderDropdown(
                        attribute: "Technology",
                        validators: [FormBuilderValidators.required()],
                        hint: Text("Select Technology"),
                        items:technologyName!=null?technologyName.map((horse)=>DropdownMenuItem(
                          child: Text(horse),
                          value: horse,
                        )).toList():[""].map((name) => DropdownMenuItem(
                            value: name, child: Text("$name")))
                            .toList(),
                        style: Theme.of(context).textTheme.bodyText1,
                        decoration: InputDecoration(
                          border:InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        onChanged: (value){
                          setState(() {
                            this.selected_technology=value;
                            this.technology_id=technology[technologyName.indexOf(value)].id;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                //Product Structure
                Padding(
                  padding: const EdgeInsets.only(top: 16,right: 16,left: 16),
                  child: Visibility(
                     visible: structureDropdownVisible,
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: FormBuilderDropdown(
                        attribute: "Structure",
                        validators: [FormBuilderValidators.required()],
                        hint: Text("Select Structure"),
                        items:structureName!=null?structureName.map((horse)=>DropdownMenuItem(
                          child: Text(horse),
                          value: horse,
                        )).toList():[""].map((name) => DropdownMenuItem(
                            value: name, child: Text("$name")))
                            .toList(),
                        style: Theme.of(context).textTheme.bodyText1,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16)
                        ),
                        onChanged: (value){
                          setState(() {
                            this.selected_structure=value;
                            this.structure_id=structure[structureName.indexOf(value)].id;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                //Edge
                Padding(
                  padding: const EdgeInsets.only(top: 16,left: 16,right:16),
                  child: Visibility(
                     visible: edgeDropdownVisible,
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: FormBuilderDropdown(
                        attribute: "Edge",
                        validators: [FormBuilderValidators.required()],
                        hint: Text("Select Edge"),
                        items:edgeName!=null?edgeName.map((horse)=>DropdownMenuItem(
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
                            this.selected_edge=value;
                            this.edge_id=edge[edgeName.indexOf(value)].id;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MaterialButton(
                      color: Color(0xFF004c4c),
                      child: Text("Proceed",style: TextStyle(color: Colors.white),),
                      onPressed: (){
                        if(fbkey.currentState.validate()&&formKey.currentState.validate()){
                          formKey.currentState.save();
                          setState(() {
                            selected_material=_myMaterials.toString();
                            print(selected_material);
                          });
                          print(technology_id.toString());
                          print( range_id.toString());
                          push(context, MaterialPageRoute(builder: (context)=>Suitability(
                              market,
                              clientId,
                              event,
                              sizesList,
                              surfaceId,
                              thickness,
                              classification,
                              colorsList,
                              technology_id,
                              structure_id,
                              edge_id,
                              range_id,
                              _myMaterials)));

                        }
                      },
                    ),
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
