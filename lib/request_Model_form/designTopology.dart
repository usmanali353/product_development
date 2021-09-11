import 'package:filter_list/filter_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:productdevelopment/Model/Dropdown.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/Utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Suitability.dart';
class designTopology extends StatefulWidget {
  Request request;
  var market,event,other,size,surfaceId,thickness,classification,color,myClients;
  List<dynamic> sizesList=[],colorsList=[],colorsDropDown=[],colorNames=[];
  designTopology(
      this.market,
      this.event,
      this.sizesList,
      this.surfaceId,
      this.thickness,
      this.classification,
      this.colorsList,
      this.myClients,
      this.colorsDropDown,
      {this.request}
      );

  @override
  _designTopologyState createState() => _designTopologyState(market,event,sizesList,surfaceId,thickness,classification,colorsList,myClients,colorsDropDown,request: this.request);
}

class _designTopologyState extends State<designTopology> {
  List myClients;
  Request request;
  bool designTopologyDropDownVisible=false;
  final formKey = new GlobalKey<FormState>();
  bool rangeDropdownVisible=false,technologyDropdownVisible=false,edgeDropdownVisible=false,structureDropdownVisible=false;
 List<Dropdown> designTopology=[], range=[], material=[],structure=[], edge=[],technology=[];
 List<String> designTopologyName=[], rangeName=[], materialName=[],structureName=[], edgeName=[],technologyName=[],colorNames=[],selectedDesigntopologyIds=[];
 List<dynamic> designTopologies=[],sizesList=[],colorsList=[],colorsDropDown=[],selectedDesigntopologyName=[];
 List<Widget> selectedDesignTopologyoptions=[];
 var market,event,other,size,surfaceId,name,thickness,classification,color;
String selected_technology, selected_structure, selected_edge,selected_range, selected_material;
GlobalKey<FormBuilderState> fbkey=GlobalKey();
int range_id, material_id,technology_id, structure_id, edge_id;
 _designTopologyState(
      this.market,
      this.event,
      this.sizesList,
      this.surfaceId,
      this.thickness,
      this.classification,
      this.colorsList,
      this.myClients,
     this.colorsDropDown,
     {this.request}
     );

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
            if(request!=null){
              if(request.multipleDesignTopoligyNames!=null&&request.multipleDesignTopoligyNames.length>0){
                for(var dt in request.multipleDesignTopoligyNames){
                  selectedDesigntopologyName.add(dt);
                  selectedDesignTopologyoptions.add(
                      Chip(label: Text(dt,overflow: TextOverflow.ellipsis,))
                  );
                  selectedDesigntopologyIds.add(designTopology[designTopologyName.indexOf(dt)].id.toString());
                }
              }
            }
          }
          Network_Operations.getDropDowns(context, prefs.getString("token"), "Ranges").then((rangeDropDown){
            setState(() {
              this.range=rangeDropDown;
              for(var r in range){
                rangeName.add(r.name);
              }
              if(rangeName.length>0){
                rangeDropdownVisible=true;
                if(request!=null){
                  if(request.rangeName!=null&&request.rangeId!=null){
                    selected_range=request.rangeName;
                    range_id=request.rangeId;
                  }
                }
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
                if(request!=null){
                  if(request.technologyName!=null&&request.technologyId!=null){
                    selected_technology=request.technologyName;
                    technology_id=request.technologyId;
                  }
                }
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
                if(request!=null){
                  if(request.structureName!=null&&request.structureId!=null){
                    selected_structure=request.structureName;
                    structure_id=request.structureId;
                  }
                }
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
                if(request!=null){
                  if(request.edgeName!=null&&request.edgeId!=null){
                    selected_edge=request.edgeName;
                    edge_id=request.edgeId;
                  }
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
        title: Text("More Specifications"),
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
              key: fbkey,
              child: Column(
                children: <Widget>[
                  //Product Design Topologies
                  Visibility(
                    visible: designTopologyDropDownVisible,
                    child: InkWell(
                      onTap: (){
                        showSelectDesignTopologyDialog();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16,left: 16,right:16),
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
                                        child: Text("Select Design Topology"),
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
                                selectedDesigntopologyName.length > 0
                                    ? Wrap(
                                  spacing: 8.0,
                                  runSpacing: 0.0,
                                  children: selectedDesignTopologyoptions,
                                )
                                    : new Container(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text("Select one or more Design Topologies"),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  //Product Range
                  Visibility(
                    visible: rangeDropdownVisible&&selected_range==null,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16,left: 16,right:16),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: FormBuilderDropdown(
                          name: "Range",
                          validator: FormBuilderValidators.required(context,errorText: "This Field is Required"),
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
                  Visibility(
                    visible: rangeDropdownVisible&&selected_range!=null,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16,left: 16,right:16),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: FormBuilderDropdown(
                          name: "Range",
                          validator: FormBuilderValidators.required(context,errorText: "This Field is Required"),
                          hint: Text("Select Range"),
                          initialValue: selected_range,
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
                  Visibility(
                     visible: technologyDropdownVisible&&selected_technology==null,
                    child: Padding(
                      padding: const EdgeInsets.only(top:16,left: 18,right:16),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: FormBuilderDropdown(
                          name: "Technology",
                          validator: FormBuilderValidators.required(context,errorText: "This Field is Required"),
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
                  Visibility(
                    visible: technologyDropdownVisible&&selected_technology!=null,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16,left: 16,right: 16),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: FormBuilderDropdown(
                          name: "Technology",
                          validator: FormBuilderValidators.required(context,errorText: "This Field is Required"),
                          hint: Text("Select Technology"),
                          initialValue: selected_technology,
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
                  Visibility(
                     visible: structureDropdownVisible&&selected_structure==null,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16,left: 16,right: 16),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: FormBuilderDropdown(
                          name: "Structure",
                          validator: FormBuilderValidators.required(context,errorText: "This Field is Required"),
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
                  Visibility(
                    visible: structureDropdownVisible&&selected_structure!=null,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16,left: 16,right: 16),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: FormBuilderDropdown(
                          name: "Structure",
                          validator: FormBuilderValidators.required(context,errorText: "This Field is Required"),
                          hint: Text("Select Structure"),
                          initialValue: selected_structure,
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
                  Visibility(
                     visible: edgeDropdownVisible&&selected_edge==null,
                    child: Padding(
                      padding: const EdgeInsets.only(top:16,right: 16,left: 16),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: FormBuilderDropdown(
                          name: "Edge",
                          validator: FormBuilderValidators.required(context,errorText: "This Field is Required"),
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
                  Visibility(
                    visible: edgeDropdownVisible&&selected_edge!=null,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16,left: 16,right: 16),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: FormBuilderDropdown(
                          name: "Edge",
                          validator: FormBuilderValidators.required(context,errorText: "This Field is Required"),
                          hint: Text("Select Edge"),
                          initialValue: selected_edge,
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
                  //Proceed Button
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MaterialButton(
                        color: Color(0xFF004c4c),
                        child: Text("Proceed",style: TextStyle(color: Colors.white),),
                        onPressed: (){
                          if(fbkey.currentState.validate()){
                            if(selectedDesigntopologyIds==null||selectedDesigntopologyIds.length==0){
                              Utils.showError(context,"Please Select one or more Design Topologies");
                            }else {
                              if(widget.request==null) {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) =>
                                        Suitability(
                                          market,
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
                                          selectedDesigntopologyIds,
                                          myClients,
                                          colorsDropDown,
                                        )));
                              }else
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) =>
                                        Suitability(
                                          market,
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
                                          selectedDesigntopologyIds,
                                          myClients,
                                          colorsDropDown,
                                          request: request,
                                        )));
                            }
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
      ),
    );
  }
  showSelectDesignTopologyDialog()async{
    await FilterListDialog.display(
        context,
        height: 480,
        listData: designTopologyName,
        selectedListData: selectedDesigntopologyName,
        headerTextColor: Color(0xFF004c4c),
        choiceChipLabel: (item){
          return item;
        },
        validateSelectedItem: (list, val) {
          return list.contains(val);
        },
        onItemSearch: (list, text) {
          if (list.any((element) =>
              element.toLowerCase().contains(text.replaceAll(".00","").toLowerCase()))) {
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
        headlineText: "Design Topology",
        searchFieldHintText: "Search Design Topology",
        onApplyButtonClick: (list) {
          if (list != null) {
            setState(() {
              selectedDesigntopologyName.clear();
              selectedDesignTopologyoptions.clear();
              selectedDesigntopologyIds.clear();
              this.selectedDesigntopologyName = list;
              for(int i=0;i<selectedDesigntopologyName.length;i++){
                selectedDesignTopologyoptions.add(
                    Chip(label: Text(selectedDesigntopologyName[i],overflow: TextOverflow.ellipsis,))
                );
                selectedDesigntopologyIds.add(designTopology[designTopologyName.indexOf(selectedDesigntopologyName[i])].id.toString());
                print(selectedDesigntopologyIds.toString());
              }
            });
          }
          Navigator.pop(context);
        });
  }
}
