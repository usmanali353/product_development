import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:need_resume/need_resume.dart';
import 'package:productdevelopment/Model/Dropdown.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/request_Model_form/designTopology.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Specifications extends StatefulWidget {
  var market,clientId,event,other;

  Specifications(this.market, this.clientId, this.event, this.other);

  @override
  _SpecificationsState createState() => _SpecificationsState(market,clientId,event,other);
}

class _SpecificationsState extends ResumableState<Specifications> {
  var market,clientId,event,other;
  TextEditingController thickness;
  List<dynamic> sizes=[],colors=[];
  bool classificationDropDownVisible=false,surfaceDropDownVisible=false,sizeDropDownVisible=false,colorDropDownVisible=false;
  List<Dropdown> classifications=[],surface=[],size=[],color=[];
  bool sizeVisible=false,surfaceVisible=false,thicknessVisible=false,colorVisible=false;
  List<String> colorName=[], surfaceName=[],sizeName=[], product_name =["Alma","Apollo","Aqua","Aragon","Arcadia","Area","Artic","Atrium","Avenue","Baikal","Barsha","Bistro","Bologna","Brada","Bronze","CalaCatta","Canica","Capri","carrara","Cement","Circle","Code","Coliseo","Cotto","Cotton","Daka","Darco","Dayana","Devon","Diverse","Dogana","Duomo","Finnis","Joly","Maria","Tiera","Venecia"],classificationName=[];

  String selected_product_name, selected_surface, selected_size,selected_classification;
  int product_name_id, surface_id, size_id,classification_id;
  _SpecificationsState(this.market, this.clientId, this.event, this.other);
  List _myActivities,selectedSizes;
  String _myActivitiesResult;
  final formKey = new GlobalKey<FormState>();
  final formKey2 = new GlobalKey<FormState>();
  final fbKey = new GlobalKey<FormBuilderState>();
  @override
  void onResume() {
    if(resume.data.toString()=='Close') {
      Navigator.pop(context, 'Close');
      Navigator.pop(context, 'Close');
    }
    super.onResume();
  }
@override
  void initState() {
   thickness=TextEditingController();
   SharedPreferences.getInstance().then((prefs){
     Network_Operations.getDropDowns(context, prefs.getString("token"), "Classifications").then((classificationDropDown){
       setState(() {
         this.classifications=classificationDropDown;
         for(var market in classifications){
           classificationName.add(market.name);
         }
         if(classificationName.length>0){
           classificationDropDownVisible=true;
         }
       });
          //Method for Surfaces
       Network_Operations.getDropDowns(context, prefs.getString("token"), "Surfaces").then((surfaceDropDown){
         setState(() {
           this.surface=surfaceDropDown;
           for(var surfaces in surface){
             surfaceName.add(surfaces.name);
           }
           if(surfaceName.length>0){
             surfaceDropDownVisible=true;
           }
         });

       });
       // Method for Sizes
       Network_Operations.getDropDowns(context, prefs.getString("token"), "Sizes").then((sizeDropDown){
         setState(() {
           this.size=sizeDropDown;
           for(var s in size){
             sizeName.add(s.name);
             sizes.add(
               {
                 "display":s.name,
                  "value": s.id.toString()
               }
             );
           }
           if(sizeName.length>0){
             sizeDropDownVisible=true;
           }
         });

       });
       // for Colors Multiselect
       Network_Operations.getDropDowns(context, prefs.getString("token"), "Colors").then((colorsDropDown){
         setState(() {
           this.color=colorsDropDown;
           for(var s in color){
             colorName.add(s.name);
             colors.add(
                 {
                   "display":s.name,
                   "value": s.id.toString()
                 }
             );
           }
           if(colorName.length>0){
             colorDropDownVisible=true;
           }
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
        title: Text("Specifications"),
      ),
      body:ListView(
        children: <Widget>[
          FormBuilder(
            key: fbKey,
            child: Column(
              children: <Widget>[
                //ProductName Dropdown
                //Product Classification Dropdown
                Visibility(
                  visible: classificationDropDownVisible,
                  child: Padding(
                    padding: const EdgeInsets.only(top:16,left: 16,right:16,bottom: 16),
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: FormBuilderDropdown(
                        attribute: "Classification",
                        validators: [FormBuilderValidators.required()],
                        hint: Text("Select Classification"),
                        items:classificationName!=null?classificationName.map((horse)=>DropdownMenuItem(
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
                            surfaceVisible=true;
                            this.selected_classification=value;
                            this.classification_id=classifications[classificationName.indexOf(value)].id;
//                            if(selected_classification=="Floor Tiles"||selected_classification=="Wall Tiles"){
//                              if(surface.length>0){
//                                surface.clear();
//                              }
//                              surface.add("Glossy");
//                              surface.add("Mate");
//                              surface.add("Outdoor");
//                              surface.add("Plain");
//                              surface.add("Structured");
//                            }else if(selected_classification=='Floor Decor'||selected_classification=="Wall Decor"){
//                              if(surface.length>0){
//                                surface.clear();
//                              }
//                              surface.add("Mate");
//                              surface.add("Glossy");
//                            }
                          });
                        },
                      ),
                    ),
                  ),
                ),
                //Product Surface Dropdown
                Visibility(
                  visible: surfaceDropDownVisible,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16,right: 16),
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: FormBuilderDropdown(
                        attribute: "Surface",
                        validators: [FormBuilderValidators.required()],
                        hint: Text('Select Surface'),
                        items:surfaceName!=null?surfaceName.map((horse)=>DropdownMenuItem(
                          child: Text(horse),
                          value: horse,
                        )).toList():[""].map((name) => DropdownMenuItem(
                            value: name, child: Text("$name")))
                            .toList(),
                        style: Theme.of(context).textTheme.bodyText1,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(16),
                            border: InputBorder.none
                        ),
                          onChanged: (value){
                            setState(() {
                              this.selected_surface=value;
                              this.surface_id=surface[surfaceName.indexOf(value)].id;
//                            if(selected_surface=="Mate"&&selected_classification=='Floor Tiles'){
//                              if(size.length>0){
//                                selected_size=null;
//                                size.clear();
//                              }
//                              size.add(
//                                {"display":"32 x 32","value":"32 x 32"}
//                              );
//                            }else if(selected_surface=="Mate"&&selected_classification=='Floor Decor'){
//                              if(size.length>0){
//                                selected_size=null;
//                                size.clear();
//                              }
//                              size.add(
//                                  {"display":"32 x 32","value":"32 x 32"}
//                              );
//                            }else if(selected_surface=="Mate"&&selected_classification=='Wall Tiles'){
//                              if(size.length>0){
//                                selected_size=null;
//                                size.clear();
//                              } size.add(
//                                  {"display":"25 x 40","value":"25 x 40"}
//                              );
//                            }else if(selected_surface=="Mate"&&selected_classification=='Wall Decor'){
//                              if(size.length>0){
//                                selected_size=null;
//                                size.clear();
//                              }
//                              size.add(
//                                  {"display":"25 x 40","value":"25 x 40"}
//                              );
//                            }else if(selected_surface=="Glossy"&&selected_classification=='Floor Tiles'){
//                              if(size.length>0){
//                                selected_size=null;
//                                size.clear();
//                              }
//                              size.add(
//                                  {"display":"45 x 45","value":"45 x 45"},
//                              );
//                              size.add(
//                                  {"display":"60 x 60","value":"60 x 60"}
//                              );

//                            }else if(selected_surface=="Glossy"&&selected_classification=='Floor Decor'){
//                              if(size.length>0){
//                                selected_size=null;
//                                size.clear();
//                              }
//                              size.add(
//                                  {"display":"45 x 45","value":"45 x 45"},
//                              );
//                            }else if(selected_surface=="Glossy"&&selected_classification=='Wall Tiles'){
//                              if(size.length>0){
//                                selected_size=null;
//                                size.clear();
//                              }
//                              size.add(
//                                  {"display":"25 x 50","value":"25 x 50"},
//                              );
//                            }else if(selected_surface=="Glossy"&&selected_classification=='Wall Decor'){
//                              if(size.length>0){
//                                selected_size=null;
//                                size.clear();
//                              }
//                              size.add('25 x 50');
//                            }else if(selected_surface=="Plain"&&selected_classification=='Floor Tiles'){
//                              if(size.length>0){
//                                selected_size=null;
//                                size.clear();
//                              }
//                              size.add(
//                                  {"display":"32 x 32","value":"32 x 32"},
//                              );
//                            }else if(selected_surface=="Plain"&&selected_classification=='Wall Tiles'){
//                              if(size.length>0){
//                                selected_size=null;
//                                size.clear();
//                              }
//                              size.add(
//                                  {"display":"25 x 40","value":"25 x 40"},
//                              );
//                            }else if(selected_surface=="Structured"&&selected_classification=='Floor Tiles'){
//                              if(size.length>0){
//                                selected_size=null;
//                                size.clear();
//                              }
//                              size.add(
//                                  {"display":"45 x 45","value":"45 x 45"},
//                              );
//                              size.add(
//                                  {"display":"60 x 60","value":"60 x 60"},
//                              );
//                            }else  if(selected_surface=="Structured"&&selected_classification=='Wall Tiles'){
//                              if(size.length>0){
//                                selected_size=null;
//                                size.clear();
//                              }
//                              size.add(
//                                  {"display":"25 x 50","value":"25 x 50"},
//                              );
//                            }else  if(selected_surface=="Outdoor"&&selected_classification=='Floor Tiles'){
//                              if(size.length>0){
//                                selected_size=null;
//                                size.clear();
//                              }
//                              size.add(
//                                  {"display":"60 x 60","value":"60 x 60"}
//                              );

                               });
                            }
                      ),
                    ),
                  ),
                ),
                //Product Size Dropdown
                Visibility(
                  visible: sizeDropDownVisible,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16,left: 16,right: 16),
                    child: Form(
                      key: formKey2,
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: MultiSelectFormField(
                          hintText: "Select Sizes for the Product",
                          titleText: 'Select Sizes',
                          border: InputBorder.none,
                          validator: (value) {
                            return value == null || value.length == 0?'Please select one or more options':null;
                          },
                          dataSource: sizes,
                          textField: 'display',
                          valueField: 'value',
                          okButtonLabel: 'OK',
                          cancelButtonLabel: 'CANCEL',
                          onSaved: (value) {
                            if (value == null) return;
                            setState(() {
                              selectedSizes = value;
                            });
                          },

                        ),
                      ),
                    ),
                  ),
                ),
                //Product Thickness TextBox
                Padding(
                  padding: EdgeInsets.only(top: 16,left: 16,right: 16),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: FormBuilderTextField(
                      controller: thickness,
                      attribute: "Thickness",
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validators: [FormBuilderValidators.required()],
                      decoration: InputDecoration(hintText: "Thickness (cm)",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ),
                //Product Color multiSelect FormField
                Form(
                  key: formKey,
                  child: Visibility(
                    visible: colorDropDownVisible,
                    child: Padding(
                      padding: EdgeInsets.only(top:16,left:16,right:16),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: MultiSelectFormField(
                          hintText: "Select Color for the Product",
                          titleText: 'Select Colors',
                          border: InputBorder.none,
                          validator: (value) {
                            return value == null || value.length == 0?'Please select one or more options':null;
                          },
                          dataSource: colors,
                          textField: 'display',
                          valueField: 'value',
                          okButtonLabel: 'OK',
                          cancelButtonLabel: 'CANCEL',
                          //value: _myActivities,
                          onSaved: (value) {
                            if (value == null) return;
                            setState(() {
                              _myActivities = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: MaterialButton(
                      color: Color(0xFF004c4c),
                      child: Text("Proceed",style: TextStyle(color: Colors.white),),
                      onPressed: (){
                        if(fbKey.currentState.validate()&&formKey.currentState.validate()&&formKey2.currentState.validate()){
                          formKey.currentState.save();
                          formKey2.currentState.save();
                          setState(() {
                            _myActivitiesResult = _myActivities.toString();
                          });
                          push(context, MaterialPageRoute(builder: (context)=>designTopology(market,clientId,event,other,selectedSizes,surface_id,thickness.text,classification_id,_myActivities)));
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      )
    );
  }
  _saveForm() {
    var form = formKey.currentState;
    if (form.validate()) {
      form.save();
      setState(() {
        _myActivitiesResult = _myActivities.toString();
      });
    }
  }
}
