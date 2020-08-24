import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:need_resume/need_resume.dart';
import 'package:productdevelopment/Model/Dropdown.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/Utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';



class Suitability extends StatefulWidget{

  var market,client,event,other,size,surface,thickness,classification,color,technologyId,structureId, edge,range,material;
  List<dynamic> designTopologies=[],sizesList=[],colorsList=[];
  Suitability(
    this.market,
    this.client,
    this.event,
    this.other,
    this.sizesList,
    this.surface,
    this.thickness,
    this.classification,
    this.colorsList,
    this.technologyId,
    this.structureId,
    this.edge,
    this.range,
    this.designTopologies);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _Suitability_State(market,client,event,other,sizesList,surface,thickness,classification,colorsList,technologyId, structureId, edge,range,designTopologies);
  }
}

class _Suitability_State extends ResumableState<Suitability> {
  List _myActivities;
  String _myActivitiesResult;
  var base64EncodedImage;
  final formKey = new GlobalKey<FormState>();
  final fbKey = new GlobalKey<FormBuilderState>();
  List<Dropdown> suitibility=[];
  List<String> suitibilityName=[];
  List<dynamic> suitibilitys=[];
  bool suitibilityDropDownVisible=false;
  TextEditingController technical_consideration;
  List<dynamic> designTopologies=[],sizesList=[],colorsList=[];
  var market,client,event,other,size,surface,thickness,classification,color,technologyId, structureId, edge,range,material;
 @override
  void initState() {
   technical_consideration=TextEditingController();
   SharedPreferences.getInstance().then((prefs){
     Network_Operations.getDropDowns(context, prefs.getString("token"), "GetSuitability").then((suitibilityDropDown){
       setState(() {
         this.suitibility=suitibilityDropDown;
         for(var s in suitibility){
           suitibilityName.add(s.name);
           suitibilitys.add(
               {
                 "display": s.name,
                 "value": s.id.toString()
               }
           );
         }
         if(suitibilityName.length>0){
           suitibilityDropDownVisible=true;
         }
       });

     });
   });
    super.initState();
  }

  _Suitability_State(
      this.market,
      this.client,
      this.event,
      this.other,
      this.sizesList,
      this.surface,
      this.thickness,
      this.classification,
      this.colorsList,
      this.technologyId,
      this.structureId,
      this.edge,
      this.range,
      this.designTopologies);

  Uint8List picked_image;
  File _image;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text("Suitability"),
        ),
        body:ListView(
          children: <Widget>[
            FormBuilder(
              key: fbKey,
              child: Column(
                children: <Widget>[
                  //ProductName Dropdown
                  //Product Color multiSelect FormField
                  Form(
                    key: formKey,
                    child: Visibility(
                      visible: suitibilityDropDownVisible,
                      child: Padding(
                        padding: EdgeInsets.only(top:16,left:16,right:16),
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)
                          ),
                          child: MultiSelectFormField(
                            hintText: "Suitable for",
                            titleText: 'Select Suitability',
                            border: InputBorder.none,
                            validator: (value) {
                              return value == null || value.length == 0?'Please select one or more options':null;
                            },
                            dataSource:suitibilitys,
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
                     padding: EdgeInsets.only(top:16,left:16,right: 16),
                     child: Card(
                       elevation: 10,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(15),
                       ),
                       child: FormBuilderTextField(
                         attribute: "Technical Consideration",
                         controller: technical_consideration,
                         maxLines: 8,
                         validators: [FormBuilderValidators.required()],
                         decoration: InputDecoration(
                             contentPadding: EdgeInsets.all(16),
                             border: InputBorder.none,
                             hintText: "Technical Consideration"
                         ),
                       ),
                     ),
                   ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(16),
                          height: 100,
                          width: 80,
                          child: _image == null ? Text('No image selected.') : Image.file(_image),
                        ),
                        MaterialButton(
                          color: Color(0xFF004c4c),
                          onPressed: (){
                            Utils.getImage().then((image_file){
                              if(image_file!=null){
                                image_file.readAsBytes().then((image){
                                  if(image!=null){
                                    setState(() {
                                      this.picked_image=image;
                                      _image = File(image_file.path);
                                      _image.readAsBytes().then((bytes){
                                        this.base64EncodedImage= base64.encode(bytes);
                                      });

                                    });
                                  }
                                });
                              }else{

                              }
                            });
                          },
                          child: Text("Select Image",style: TextStyle(color: Colors.white),),
                        ),
                      ],
                    ),
                  ),
                  Builder(
                    builder: (BuildContext context){
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: MaterialButton(
                            color: Color(0xFF004c4c),
                            child: Text("Proceed",style: TextStyle(color: Colors.white),),
                            onPressed: (){
                              if(fbKey.currentState.validate()&&formKey.currentState.validate()){
                                formKey.currentState.save();
//                                setState(() {
//                                  _myActivitiesResult = _myActivities.toString();
//                                });
                                SharedPreferences.getInstance().then((prefs){
                                  Network_Operations.SaveRequest(context,prefs.getString("token") ,0, market, event, technical_consideration.text , 1, double.parse(thickness), surface, classification, range, technologyId, structureId, edge,base64EncodedImage!=null?base64EncodedImage:"", colorsList,sizesList, designTopologies, _myActivities,surface);
                                });

                              }
                            },
                          ),
                        ),
                      );
                    },

                  ),
                ],
              ),
            ),
          ],
        )
    );
  }
}