import 'package:filter_list/filter_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:productdevelopment/Model/Dropdown.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/Model/RequestColors.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/Utils/Utils.dart';
import 'package:productdevelopment/request_Model_form/designTopology.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Specifications extends StatefulWidget {
  var market,event,other,myClients;
  Request request;

  Specifications(this.market, this.event,this.myClients,{this.request});

  @override
  _SpecificationsState createState() => _SpecificationsState(market,event,myClients);
}

class _SpecificationsState extends State<Specifications> {
  var market,event,other,myClients;
  TextEditingController thickness;
  List<dynamic> colors=[], selectedSizeNames=[],selectedColorNames=[];
  List<Widget> selectedSizeOptions=[],selectedColorOptions=[];
  bool classificationDropDownVisible=false,surfaceDropDownVisible=false,sizeDropDownVisible=false,colorDropDownVisible=false;
  List<Dropdown> classifications=[],surface=[],size=[],color=[];
  bool sizeVisible=false,surfaceVisible=false,thicknessVisible=false,colorVisible=false;
  List<String> colorName=[], surfaceName=[],sizeName=[],classificationName=[],selectedSizeIds=[],selectedColorIds=[];

  String selected_product_name, selected_surface, selected_size,selected_classification;
  int product_name_id, surface_id, size_id,classification_id;
  _SpecificationsState(this.market, this.event,this.myClients);
  List selectedSizes;
  final formKey = new GlobalKey<FormState>();
  final formKey2 = new GlobalKey<FormState>();
  final fbKey = new GlobalKey<FormBuilderState>();
@override
  void initState() {
   thickness=TextEditingController();
   if(widget.request!=null){
     if(widget.request.thickness!=null){
       thickness.text=widget.request.thickness.toString();
     }
   }
   //Method for getting Classification
   SharedPreferences.getInstance().then((prefs){
     Network_Operations.getDropDowns(context, prefs.getString("token"), "Classifications").then((classificationDropDown){
       setState(() {
         this.classifications=classificationDropDown;
         for(var market in classifications){
           classificationName.add(market.name);
         }
         if(classificationName.length>0){
           classificationDropDownVisible=true;
           if(widget.request!=null){
             if(widget.request.classificationName!=null&&widget.request.classificationId!=null) {
               selected_classification = widget.request.classificationName;
               classification_id=widget.request.classificationId;
             }
           }
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
             if(widget.request!=null){
               if(widget.request.surfaceName!=null&&widget.request.surfaceId!=null)
               selected_surface=widget.request.surfaceName;
               surface_id=widget.request.surfaceId;
             }
           }
         });

       });
       // Method for Sizes
       Network_Operations.getDropDowns(context, prefs.getString("token"), "Sizes").then((sizeDropDown){
         setState(() {
           this.size=sizeDropDown;
           for(var s in size){
             sizeName.add(s.name);
           }
           if(sizeName.length>0){
             sizeDropDownVisible=true;
             if(widget.request!=null){
               print("Updatable Sizes "+widget.request.multipleSizeNames.toString());
               if(widget.request.multipleSizeNames!=null&&widget.request.multipleSizeNames.length>0){
                 for(var s in widget.request.multipleSizeNames){
                   selectedSizeNames.add(s);
                   selectedSizeIds.add(size[sizeName.indexOf(s)].id.toString());
                   selectedSizeOptions.add(
                       Chip(label: Text(s,overflow: TextOverflow.ellipsis,))
                   );
                 }
               }
             }
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
             if(widget.request!=null){
               if(widget.request.multipleColorNames!=null&&widget.request.multipleColorNames.length>0){
                 for(RequestColors colors in widget.request.multipleColorNames){
                   selectedColorNames.add(colors.colorName);
                   selectedColorIds.add(color[colorName.indexOf(colors.colorName)].id.toString());
                   selectedColorOptions.add(
                       Chip(label: Text(colors.colorName,overflow: TextOverflow.ellipsis,))
                   );
                 }
               }
             }
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
                  //Product Classification Dropdown
                  Visibility(
                    visible: classificationDropDownVisible&&selected_classification==null,
                    child: Padding(
                      padding: const EdgeInsets.only(top:16,left: 16,right:16,bottom: 16),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: FormBuilderDropdown(
                          name: "Classification",
                          validator: FormBuilderValidators.required(context,errorText: "This Field is Required"),
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
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: classificationDropDownVisible&&selected_classification!=null,
                    child: Padding(
                      padding: const EdgeInsets.only(top:16,left: 16,right:16,bottom: 16),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: FormBuilderDropdown(
                          name: "Classification",
                          validator: FormBuilderValidators.required(context,errorText: "This Field is Required"),
                          hint: Text("Select Classification"),
                          initialValue: selected_classification,
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
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  //Product Surface Dropdown
                  Visibility(
                    visible: surfaceDropDownVisible&&selected_surface==null,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16,right: 16),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                        ),
                        child: FormBuilderDropdown(
                          name: "Surface",
                          validator: FormBuilderValidators.required(context,errorText: "This Field is Required"),
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
                                 });
                              }
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: surfaceDropDownVisible&&selected_surface!=null,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16,right: 16),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                        ),
                        child: FormBuilderDropdown(
                            name: "Surface",
                            validator: FormBuilderValidators.required(context,errorText: "This Field is Required"),
                            hint: Text('Select Surface'),
                            initialValue: selected_surface,
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
                              });
                            }
                        ),
                      ),
                    ),
                  ),
                  //Product Size Dropdown
                  Visibility(
                    visible: sizeDropDownVisible,
                    child: InkWell(
                      onTap: (){
                        showSelectSizeDialog();
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
                                        child: Text("Select Sizes"),
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
                                selectedSizeNames.length > 0
                                    ? Wrap(
                                  spacing: 8.0,
                                  runSpacing: 0.0,
                                  children: selectedSizeOptions,
                                )
                                    : new Container(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text("Select one or more Sizes"),
                                )
                              ],
                            ),
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
                        name: "Thickness",
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: FormBuilderValidators.required(context,errorText: "This Field is Required"),
                        decoration: InputDecoration(hintText: "Thickness (cm)",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ),
                  //Product Color multiSelect FormField
                  Visibility(
                    visible: colorDropDownVisible,
                    child: InkWell(
                      onTap: (){
                        showSelectColorDialog();
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
                                        child: Text("Select Colors"),
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
                                selectedColorNames.length > 0
                                    ? Wrap(
                                  spacing: 8.0,
                                  runSpacing: 0.0,
                                  children: selectedColorOptions,
                                )
                                    : new Container(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text("Select one or more Colors for Product"),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: MaterialButton(
                        color: Color(0xFF004c4c),
                        child: Text("Proceed",style: TextStyle(color: Colors.white),),
                        onPressed: (){
                          if(fbKey.currentState.validate()){
                            //formKey.currentState.save();
                            //formKey2.currentState.save();
                            if(selectedSizeIds==null||selectedSizeIds.length==0){
                              Utils.showError(context,"Please Select Sizes");
                            }else if(selectedColorIds==null||selectedColorIds.length==0){
                              Utils.showError(context,"Please Select Colors");
                            }else {
                              if(widget.request==null){
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) =>
                                        designTopology(
                                            market,
                                            event,
                                            selectedSizeIds,
                                            surface_id,
                                            thickness.text,
                                            classification_id,
                                            selectedColorIds,
                                            myClients,
                                            colors)));
                              }else
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) =>
                                        designTopology(
                                            market,
                                            event,
                                            selectedSizeIds,
                                            surface_id,
                                            thickness.text,
                                            classification_id,
                                            selectedColorIds,
                                            myClients,
                                            colors,
                                            request: widget.request,
                                        )));
                            }
                          }
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
  showSelectSizeDialog()async{
    await FilterListDialog.display(
        context,
        height: 480,
        listData: sizeName,
        selectedListData: selectedSizeNames,
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
        headlineText: "Select Sizes",
        searchFieldHintText: "Search Sizes",
        onApplyButtonClick: (list) {
          if (list != null) {
            setState(() {
              selectedSizeNames.clear();
              selectedSizeOptions.clear();
              selectedSizeIds.clear();
              this.selectedSizeNames = list;
              for(int i=0;i<selectedSizeNames.length;i++){
                selectedSizeOptions.add(
                    Chip(label: Text(selectedSizeNames[i],overflow: TextOverflow.ellipsis,))
                );
                selectedSizeIds.add(size[sizeName.indexOf(selectedSizeNames[i])].id.toString());
                print(selectedSizeIds.toString());
              }
            });
          }
          Navigator.pop(context);
        });
  }
  showSelectColorDialog()async{
    await FilterListDialog.display(
        context,
        height: 480,
        listData: colorName,
        selectedListData: selectedColorNames,
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
        headlineText: "Select Colors",
        searchFieldHintText: "Search Colors",
        onApplyButtonClick: (list) {
          if (list != null) {
            setState(() {
              selectedColorNames.clear();
              selectedColorOptions.clear();
              selectedColorIds.clear();
              this.selectedColorNames = list;
              for(int i=0;i<selectedColorNames.length;i++){
                selectedColorOptions.add(
                    Chip(label: Text(selectedColorNames[i],overflow: TextOverflow.ellipsis,))
                );
                selectedColorIds.add(color[colorName.indexOf(selectedColorNames[i])].id.toString());
                print(selectedColorIds.toString());
              }
            });
          }
          Navigator.pop(context);
        });
  }
}
