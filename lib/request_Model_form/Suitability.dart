import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:productdevelopment/Model/Dropdown.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/Utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';



class Suitability extends StatefulWidget{

  var market,event,size,surface,thickness,classification,color,technologyId,structureId, edge,range,material,myClient;
  List<dynamic> designTopologies=[],sizesList=[],colorsList=[],colorDropDown=[];
  List<String> colorNames=[];
  Suitability(
    this.market,
    this.event,
    this.sizesList,
    this.surface,
    this.thickness,
    this.classification,
    this.colorsList,
    this.technologyId,
    this.structureId,
    this.edge,
    this.range,
    this.designTopologies,
      this.myClient,
      this.colorDropDown,
      );
  @override
  State<StatefulWidget> createState() {
    return _Suitability_State(market,event,sizesList,surface,thickness,classification,colorsList,technologyId, structureId, edge,range,designTopologies,myClient,colorDropDown);
  }
}

class _Suitability_State extends State<Suitability> {
  List _myActivities,myClient;
  var base64EncodedImage,colorID;
  final formKey = new GlobalKey<FormState>();
  final fbKey = new GlobalKey<FormBuilderState>();
  List<Dropdown> suitibility=[];
  List<String> suitibilityName=[],colorName=[];
  List<dynamic> suitibilitys=[],colorDropDown=[],colorIds=[];
  bool suitibilityDropDownVisible=false,colorDropDownVisible=false;
  List<Dropdown> colorsDropDown=[];
  TextEditingController technical_consideration;
  List<dynamic> designTopologies=[],sizesList=[],colorsList=[];
  var market,event,other,size,surface,thickness,classification,color,technologyId, structureId, edge,range,material;
 @override
  void initState() {
   technical_consideration=TextEditingController();
   for(int i=0;i<colorDropDown.length;i++){
     setState(() {
       colorIds.add(colorDropDown[i]['value']);
     });
   }
   colorName.clear();
   for(int i=0;i<colorsList.length;i++){
     setState(() {
       colorName.add(colorDropDown[colorIds.indexOf(colorsList[i])]['display']);
     });
   }
   print(colorName);
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
      this.event,
      this.sizesList,
      this.surface,
      this.thickness,
      this.classification,
      this.colorsList,
      this.technologyId,
      this.structureId,
      this.edge,
      this.range,
      this.designTopologies,
      this.myClient,
      this.colorDropDown,
      );

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
                                      base64EncodedImage=base64Encode(picked_image);
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
                  Padding(

                    padding: const EdgeInsets.only(left: 16,right:16,bottom: 16),

                    child: Card(

                      elevation: 10,

                      shape: RoundedRectangleBorder(

                        borderRadius: BorderRadius.circular(15),

                      ),

                      child: FormBuilderDropdown(

                        attribute: "Color",

                        validators: [FormBuilderValidators.required()],

                        hint: Text("Select Color for Image"),

                        items:colorName!=null?colorName.map((horse)=>DropdownMenuItem(

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
                            for(int i=0;i<colorDropDown.length;i++){
                               if(colorDropDown[i]['display']==value){
                                 this.colorID =colorDropDown[i]['value'];
                               }
                            }
                          });

                        },

                      ),

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
                              if(fbKey.currentState.validate()&&formKey.currentState.validate()&&base64EncodedImage!=null){
                                formKey.currentState.save();
//                                setState(() {
//                                  _myActivitiesResult = _myActivities.toString();
//                                });
                                SharedPreferences.getInstance().then((prefs){
                                  var claims=Utils.parseJwt(prefs.getString("token"));
                                  Network_Operations.saveRequest(context,prefs.getString("token") ,Request(
                                    requestId: 0,
                                    marketId: market,
                                    multipleClients: myClient,
                                    event: event,
                                    userId: claims['nameid'],
                                    technicalConcentration: technical_consideration.text,
                                    statusId: 1,
                                    thickness: double.parse(thickness),
                                    surfaceId: surface,
                                    classificationId: classification,
                                    rangeId: range,
                                    technologyId: technologyId,
                                    structureId: structureId,
                                    edgeId: edge,
                                    image: base64EncodedImage,
                                    multipleColors: colorsList,
                                    multipleSizes: sizesList,
                                    ImageSelectedForColor:colorID,
                                    multipleDesignTopoligies: designTopologies,
                                    multipleSuitability: _myActivities,
                                  ));
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