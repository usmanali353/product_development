import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:filter_list/filter_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:productdevelopment/Model/Dropdown.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/Model/RequestColors.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/Utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';



class Suitability extends StatefulWidget{
  Request request;
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
       {this.request}
      );
  @override
  State<StatefulWidget> createState() {
    return _Suitability_State(market,event,sizesList,surface,thickness,classification,colorsList,technologyId, structureId, edge,range,designTopologies,myClient,colorDropDown);
  }
}

class _Suitability_State extends State<Suitability> {
  List myClient;
  String selected_color;
  var base64EncodedImage,colorID;
  final formKey = new GlobalKey<FormState>();
  final fbKey = new GlobalKey<FormBuilderState>();
  List<Dropdown> suitibility=[];
  List<String> suitibilityName=[],colorName=[],selectedSuitibilityIds=[];
  List<dynamic> suitibilitys=[],colorDropDown=[],colorIds=[],selectedSuitibilityNames=[];
  bool suitibilityDropDownVisible=false,colorDropDownVisible=false;
  List<Widget> selectedSuitibilityOptions=[];
  List<Dropdown> colorsDropDown=[];
  TextEditingController technical_consideration;
  List<dynamic> designTopologies=[],sizesList=[],colorsList=[];
  var market,event,other,size,surface,thickness,classification,color,technologyId, structureId, edge,range,material;
 @override
  void initState() {
   technical_consideration=TextEditingController();
   if(widget.request!=null){
     if(widget.request.technicalConcentration!=null){
       technical_consideration.text=widget.request.technicalConcentration;
     }
     if(widget.request.multipleColorNames!=null&&widget.request.multipleColorNames.length>0){
       setState(() {
         for(RequestColors mc in widget.request.multipleColorNames){
           if(mc.colorImage!=null){
             selected_color=mc.colorName;
             return;
           }
         }
       });
     }
   }
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
         if(suitibilityName.length>0) {
           suitibilityDropDownVisible = true;
           if (widget.request != null) {
             if (widget.request.multipleSuitabilityNames != null && widget.request.multipleSuitabilityNames.length > 0) {
                for(var s in widget.request.multipleSuitabilityNames){
                  selectedSuitibilityNames.add(s);
                  selectedSuitibilityOptions.add(
                      Chip(label: Text(s,overflow: TextOverflow.ellipsis,))
                  );
                  selectedSuitibilityIds.add(suitibility[suitibilityName.indexOf(s)].id.toString());
                }
             }
           }
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
    return Scaffold(
        appBar: AppBar(
          title: Text("Suitability"),
        ),
        body:Container(
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
                key: fbKey,
                child: Column(
                  children: <Widget>[
                    //ProductName Dropdown
                    //Product Color multiSelect FormField
                    Visibility(
                      visible: suitibilityDropDownVisible,
                      child: InkWell(
                        onTap: (){
                          showSelectSuitibilityDialog();
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
                                          child: Text("Select Suitibility"),
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
                                  selectedSuitibilityNames.length > 0
                                      ? Wrap(
                                    spacing: 8.0,
                                    runSpacing: 0.0,
                                    children: selectedSuitibilityOptions,
                                  )
                                      : new Container(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Text("Select one or more Suitibilities"),
                                  )
                                ],
                              ),
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
                           name: "Technical Consideration",
                           controller: technical_consideration,
                           maxLines: 8,
                           validator: FormBuilderValidators.required(context,errorText: "This Field is Required"),
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
                    Visibility(
                      visible: selected_color==null,
                      child: Padding(

                        padding: const EdgeInsets.only(left: 16,right:16,bottom: 16),

                        child: Card(

                          elevation: 10,

                          shape: RoundedRectangleBorder(

                            borderRadius: BorderRadius.circular(15),

                          ),

                          child: FormBuilderDropdown(

                            name: "Color",

                            validator: FormBuilderValidators.required(context,errorText: "This Field is Required"),

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
                    ),
                    Visibility(
                      visible: selected_color!=null,
                      child: Padding(

                        padding: const EdgeInsets.only(left: 16,right:16,bottom: 16),

                        child: Card(

                          elevation: 10,

                          shape: RoundedRectangleBorder(

                            borderRadius: BorderRadius.circular(15),

                          ),

                          child: FormBuilderDropdown(

                            name: "Color",

                            validator: FormBuilderValidators.required(context,errorText: "This Field is Required"),
                            initialValue: selected_color,
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
                                if(fbKey.currentState.validate()&&selectedSuitibilityIds!=null&&selectedSuitibilityIds.length>0){
//                                setState(() {
//                                  _myActivitiesResult = _myActivities.toString();
//                                });
                                if(widget.request!=null){
                                  SharedPreferences.getInstance().then((prefs){
                                    var claims=Utils.parseJwt(prefs.getString("token"));
                                    Network_Operations.updateRequest(context,prefs.getString("token") ,Request(
                                      requestId: widget.request.requestId,
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
                                      multipleSuitability: selectedSuitibilityIds,
                                    ));
                                  });
                                }else{
                                  if(base64EncodedImage!=null){
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
                                        multipleSuitability: selectedSuitibilityIds,
                                      ));
                                    });
                                  }
                                }
                                }else{
                                  Utils.showError(context,"Please Provide All Required Information");
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
          ),
        )
    );
  }
  showSelectSuitibilityDialog()async{
    await FilterListDialog.display(
        context,
        height: 480,
        listData: suitibilityName,
        selectedListData: selectedSuitibilityNames,
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
        headlineText: "Select Suitibility",
        searchFieldHintText: "Search Suitibility",
        onApplyButtonClick: (list) {
          if (list != null) {
            setState(() {
              selectedSuitibilityNames.clear();
              selectedSuitibilityOptions.clear();
              selectedSuitibilityIds.clear();
              this.selectedSuitibilityNames = list;
              for(int i=0;i<selectedSuitibilityNames.length;i++){
                selectedSuitibilityOptions.add(
                    Chip(label: Text(selectedSuitibilityNames[i],overflow: TextOverflow.ellipsis,))
                );
                selectedSuitibilityIds.add(suitibility[suitibilityName.indexOf(selectedSuitibilityNames[i])].id.toString());
                print(selectedSuitibilityIds.toString());
              }
            });
          }
          Navigator.pop(context);
        });
  }
}