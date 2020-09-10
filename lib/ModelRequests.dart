import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:need_resume/need_resume.dart';
import 'package:photo_view/photo_view.dart';
import 'package:productdevelopment/Dashboard.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/Utils/Utils.dart';
import 'package:productdevelopment/addClientToTrial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DetailPage.dart';
import 'RequestsForTrial.dart';
import 'acmcapproval.dart';
import 'addImagetoColor.dart';


class ModelRequests extends StatefulWidget {

  List<Request> products;

  ModelRequests(this.products);

  @override
  _ModelReState createState() => _ModelReState(products);
}

class _ModelReState extends ResumableState<ModelRequests>{
  List<Request> products=[];
  var claims;
  GlobalKey<RefreshIndicatorState> refreshIndicatorKey=GlobalKey();
  var selectedPreference,selectedStatus;
  _ModelReState(this.products);
 bool isGm=false,isClient=false,isSaleManager= false,isFDesigner=false,isLabIncharge,isMarketingManager=false,isProductManager=false;
 bool isColorsVisible=false;
  String token;
  @override
  void onResume() {
    print(resume.data.toString());
     Navigator.pop(context,'Refresh');
    super.onResume();
  }
  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs){
      setState(() {
        claims=Utils.parseJwt(prefs.getString("token"));
        print(claims);
        token=prefs.getString("token");
      });
      //Checking Roles
    if(claims['role'].contains('General Manager')){
      setState(() {
        isGm = true;
      });
    } else if(claims['role'].contains('Sales Manager')){
      setState(() {
        isSaleManager = true;
      });
    }else if(claims['role'].contains('Designer')){
      setState(() {
        isFDesigner=true;
      });
    }else if(claims['role'].contains('Lab Incharge')){
      setState(() {
        isLabIncharge=true;
      });
    }else if(claims['role'].contains('Marketing Manager')){
       setState(() {
         isMarketingManager=false;
       });
    }else if(claims['role'].contains('Product Manager')){
       setState(() {
         isProductManager=false;
       });
    }else{
    setState(() {
      isClient=true;
    });
    }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text("Model Requests", style: TextStyle(
              color: Colors.white
          ),
          ),
          actions: <Widget>[

          ],
        ),
      body: ListView.builder(
              itemCount:products.length, itemBuilder: (context,int index)
          {
            return GestureDetector(
              onTapDown: (TapDownDetails details)async{
                if(products[index].statusName=="New Request"){
                  await showMenu(
                    context: context,
                    position:  RelativeRect.fromLTRB(details.globalPosition.dx, details.globalPosition.dy, 0, 0),
                    items: [
                      PopupMenuItem<String>(
                          child: const Text('Change Status'), value: 'changeStatus'),
                      PopupMenuItem<String>(
                          child: const Text('Add Images'), value: 'addImage'),
                    ],
                    elevation: 8.0,
                  ).then((selectedItem){
                     if(selectedItem=="changeStatus"){
                       showAlertDialog(context,products[index]);
                     }else if(selectedItem=="addImage"){
                       Navigator.push(context,MaterialPageRoute(builder: (context)=>addImageToColors(products[index])));
                     }
                  });

                }else if(products[index].statusName=="Approved By GM"){
                  await showMenu(
                    context: context,
                    position:  RelativeRect.fromLTRB(details.globalPosition.dx, details.globalPosition.dy, 0, 0),
                    items: [
                      PopupMenuItem<String>(
                          child: const Text('Change Status'), value: 'changeStatus'),
                      PopupMenuItem<String>(
                          child: const Text('See Details'), value: 'Details'),
                    ],
                    elevation: 8.0,
                  ).then((selectedItem){
                    if(selectedItem=="changeStatus"){
                      showDatePicker(helpText:"Select Target Date for Starting Sample Production",context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(Duration(days: 365))).then((startDate){
                        if(startDate!=null){
                          showDatePicker(helpText:"Select Target Date for Ending Sample Production",context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(Duration(days: 365))).then((endDate){
                            if(endDate!=null){
                              Network_Operations.addRequestSchedule(context, token, products[index].requestId, startDate, endDate, null, null);
                            }
                          });
                        }
                      });
                    }else if(selectedItem=="Details"){
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>DetailPage(products[index])));
                    }
                  });

                }else if(products[index].statusName=="Samples Scheduled"){
                  showAlertChangeStatus(context,products[index]);
                }else if(products[index].statusName=="Approved Trial"){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestsForTrial(products[index].requestId)));
                 // showCustomerApprovalDialog(context, products[index]);
                }else {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => DetailPage(products[index])));
                }
              },
              child: Card(
                elevation: 6,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    //color: Colors.teal,
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.21,

                  child: Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      //mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            GestureDetector(
                              onTapDown: (TapDownDetails details)async{
                                return showDialog<Null>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return  Container(
                                        width: 200,
                                        height: 200,
                                        child: PhotoView(
                                          imageProvider: NetworkImage(products[index].image),
                                        ),
                                      );
                                    }
                                );


                              },
                              child: Container(
                                //color: Color(0xFF004c4c),
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(products[index].image!=null?products[index].image:"https://cidco-smartcity.niua.org/wp-content/uploads/2017/08/No-image-found.jpg"), //MemoryImage(base64Decode(products[index]['image'])),
                                      fit: BoxFit.cover,
                                    )
                                ),
                              ),
                            ),
                            //Padding(padding: EdgeInsets.only(top:2),),
                            products[index].multipleColorNames!=null&&products[index].multipleColorNames.length>0?Row(
                              children: <Widget>[
                                for(int i=0;i<products[index].multipleColorNames.length;i++)
                                  Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Wrap(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(2),
                                            color: Color(Utils.getColorFromHex(products[index].multipleColorNames[i].colorCode)),
                                            //color: Colors.teal,
                                          ),
                                          height: 10,
                                          width: 15,
                                        ),

                                      ],
                                    ),
                                  ),

                                // Container(
                                //   decoration: BoxDecoration(
                                //     borderRadius: BorderRadius.circular(2),
                                //     color: Colors.grey.shade300,
                                //     //color: Colors.teal,
                                //   ),
                                //   height: 10,
                                //   width: 15,
                                // ),
                                // Padding(
                                //   padding: EdgeInsets.only(left: 2, right: 2),
                                // ),
                                // Container(
                                //   decoration: BoxDecoration(
                                //     borderRadius: BorderRadius.circular(2),
                                //     color: Colors.brown.shade200,
                                //     //color: Colors.teal,
                                //   ),
                                //   height: 10,
                                //   width: 15,
                                // ),
                                // Padding(
                                //   padding: EdgeInsets.only(left: 2, right: 2),
                                // ),
                                // Container(
                                //   decoration: BoxDecoration(
                                //     borderRadius: BorderRadius.circular(2),
                                //     color: Colors.brown.shade500,
                                //     //color: Colors.teal,
                                //   ),
                                //   height: 10,
                                //   width: 15,
                                // ),
                                // Padding(
                                //   padding: EdgeInsets.only(left: 2, right: 2),
                                // ),
                                // Container(
                                //   decoration: BoxDecoration(
                                //     borderRadius: BorderRadius.circular(2),
                                //     color: Colors.orangeAccent.shade100,
                                //     //color: Colors.teal,
                                //   ),
                                //   height: 10,
                                //   width: 15,
                                // ),
                              ],
                            ):Container(),
                          ],
                        ),
                        VerticalDivider(color: Colors.grey,),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.62,
                          height: MediaQuery.of(context).size.height * 0.62,
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 6, top: 8),
                                child: Text(products[index].modelName!=null?products[index].modelName:'', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Row(
                                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Icon(
                                        Icons.layers,
                                        color: Colors.teal,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 2, right: 2),
                                      ),
                                      Text(products[index].surfaceName!=null?products[index].surfaceName:'')
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 50),
                                  ),

                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.zoom_out_map,
                                    color: Colors.teal,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 2, right: 2),
                                  ),
                                  Text(products[index].multipleSizeNames.toString().replaceAll("[", "").replaceAll("]", "").replaceAll(".00", "")),
                                ],


                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.date_range,
                                        color: Colors.teal,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 2, right: 2),
                                      ),
                                      Text(DateFormat("yyyy-MM-dd").format(DateTime.parse(products[index].date)))
                                    ],

                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 27),
                                  ),

                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 1),
                                child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(
                                      Icons.done_all,
                                      //size: 14,
                                      color: Colors.teal,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 3, right: 3),
                                    ),
                                    Text(products[index].statusName!=null?products[index].statusName:'')
                                  ],


                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                ),
              ),
            );
          })
    );

  }
  showCustomerApprovalDialog(BuildContext context,Request request){
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget detailsPage = FlatButton(
      child: Text("Go to Details"),
      onPressed: () {
        Navigator.pop(context);
       Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailPage(request)));
      },
    );
    Widget approveRejectButton = FlatButton(
      child: Text("Set"),
      onPressed: () {
        if(selectedPreference=="Approve") {
          Navigator.pop(context);
          Network_Operations.changeStatusOfRequest(context, token, request.requestId, 7).then((value){
            Navigator.pop(context,"Refresh");
            Navigator.pop(context,"Refresh");
          });
        }else{
          Network_Operations.changeStatusOfRequest(context, token, request.requestId, 8).then((value){
            Navigator.pop(context,"Refresh");
            Navigator.pop(context,"Refresh");
          });
        }
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Approve/Reject Model Request"),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile(
                title: Text("Approve"),
                value: 'Approve',
                groupValue: selectedPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedPreference = choice;
                  });
                },
              ),
              RadioListTile(
                title: Text("Reject"),
                value: 'Reject',
                groupValue: selectedPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedPreference = choice;
                  });
                },
              ),
            ],
          );
        },
      ),
      actions: [
        cancelButton,
        detailsPage,
        approveRejectButton
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  showTrialApprovalDialog(BuildContext context,Request request){
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget detailsPage = FlatButton(
      child: Text("Go to Details"),
      onPressed: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailPage(request)));
      },
    );
    Widget approveRejectButton = FlatButton(
      child: Text("Set"),
      onPressed: () {
        Navigator.pop(context);
        if(selectedPreference=="Approve"){

        }else if(selectedPreference=="Reject"){

        }
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Approve/Reject Model for Trials"),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile(
                title: Text("Approve"),
                value: 'Approve',
                groupValue: selectedPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedPreference = choice;
                  });
                },
              ),
              RadioListTile(
                title: Text("Reject"),
                value: 'Reject',
                groupValue: selectedPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedPreference = choice;
                  });
                },
              ),
            ],
          );
        },
      ),
      actions: [
        cancelButton,
        detailsPage,
        approveRejectButton
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  showAlertChangeStatus(BuildContext context,Request request){
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget detailsPage = FlatButton(
      child: Text("Go to Details"),
      onPressed: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailPage(request)));
      },
    );
    Widget approveRejectButton = FlatButton(
      child: Text("Set"),
      onPressed: () {
        if(selectedPreference=="Approve"){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>AddClientToTrial(request.requestId)));
        }else if(selectedPreference=="Reject"){
          Network_Operations.changeStatusOfRequest(context, token, request.requestId, 6);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Dashboard()), (route) => false);
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Approve/Reject Model for Trial"),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile(
                title: Text("Approve"),
                value: 'Approve',
                groupValue: selectedPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedPreference = choice;
                  });
                },
              ),
              RadioListTile(
                title: Text("Reject"),
                value: 'Reject',
                groupValue: selectedPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedPreference = choice;
                  });
                },
              ),
            ],
          );
        },
      ),
      actions: [
        cancelButton,
        detailsPage,
        approveRejectButton
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  showAlertDialog(BuildContext context,Request request) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget detailsPage = FlatButton(
      child: Text("Go to Details"),
      onPressed: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailPage(request)));
      },
    );
    Widget approveRejectButton = FlatButton(
      child: Text("Set"),
      onPressed: () {
        if(selectedPreference=="Approve"){
          Navigator.pop(context);
          push(context, MaterialPageRoute(builder: (context)=>acmcApproval(selectedPreference,request)));
        }else if(selectedPreference=="Reject"){
          Navigator.pop(context);
          push(context, MaterialPageRoute(builder: (context)=>acmcApproval(selectedPreference,request)));
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Approve/Reject Model Request"),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile(
                title: Text("Approve"),
                value: 'Approve',
                groupValue: selectedPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedPreference = choice;
                  });
                },
              ),
              RadioListTile(
                title: Text("Reject"),
                value: 'Reject',
                groupValue: selectedPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedPreference = choice;
                  });
                },
              ),
            ],
          );
        },
      ),
      actions: [
        cancelButton,
        detailsPage,
        approveRejectButton
      ],
    );

    // show the dialog
    showDialog(

      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

