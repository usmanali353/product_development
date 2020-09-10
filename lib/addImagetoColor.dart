 import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Utils/Utils.dart';
class addImageToColors extends StatefulWidget {
  Request request;
  addImageToColors(this.request);

  @override
   _AddImageToColorsState createState() => _AddImageToColorsState(request);
 }

 class _AddImageToColorsState extends State<addImageToColors> {
  GlobalKey<FormBuilderState> fbKey=GlobalKey();
  Request request;
  List<String> colorNames=[];
  int colorId;
 var base64EncodedImage;
  File _image;
  _AddImageToColorsState(this.request);
  @override
  void initState() {
    for(int i=0;i<request.multipleColorNames.length;i++) {
      setState(() {
        colorNames.add(request.multipleColorNames[i].colorName);
      });
    }
    super.initState();
  }
   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: Text("Add Images"),
       ),
       body: ListView(
         children: [
          FormBuilder(
            key: fbKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: FormBuilderDropdown(

                      attribute: "Color",

                      validators: [FormBuilderValidators.required()],

                      hint: Text("Select Color"),

                      items:colorNames!=null?colorNames.map((horse)=>DropdownMenuItem(

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
                          this.colorId = request.multipleColorNames[colorNames.indexOf(value)].id;
                        });

                      },

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
                          Utils.getImage().then((imageFile){
                            if(imageFile!=null){
                              imageFile.readAsBytes().then((image){
                                if(image!=null){
                                  setState(() {
                                    _image = File(imageFile.path);
                                    base64EncodedImage=base64Encode(image);
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
                    return Center(
                      child: MaterialButton(
                        onPressed: (){
                          SharedPreferences.getInstance().then((prefs){
                            if(fbKey.currentState.validate()&&base64EncodedImage!=null) {
                              Network_Operations.addRequestImages(context, prefs.getString("token"), colorId, base64EncodedImage);
                            }
                          });
                        },
                        color: Color(0xFF004c4c),
                        child: Text("Add",style: TextStyle(color: Colors.white),),
                      ),
                    );
                  },
                )
              ],
            ),
          )
         ],
       ),
     );
   }
 }
