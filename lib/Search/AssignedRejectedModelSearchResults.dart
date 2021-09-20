import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Model/AssignedRejectedModels.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/Utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../DetailsPage.dart';
import '../RequestImagesGallery.dart';

class AssignedRejectedModelSearchResults extends StatefulWidget {
  String token,query;

  AssignedRejectedModelSearchResults({this.token, this.query});

  @override
  _AssignedRejectedModelSearchResultsState createState() => _AssignedRejectedModelSearchResultsState();
}

class _AssignedRejectedModelSearchResultsState extends State<AssignedRejectedModelSearchResults> {
  List<AssignedRejectedModels> requests=[],allRequests=[];
  int pageNum=1;
  var req;
  var selectedPreference="",isLastPage=false,_isFirstLoadRunning=false,_isLoadMoreRunning = false;
  final ScrollController controller=ScrollController();
  @override
  void initState() {
    setState(() {
      _isFirstLoadRunning=true;
    });
      Network_Operations.getAssignedRejectedModelsSearchable(context, widget.token, 10, pageNum,widget.query).then((response) {
        setState(() {
          _isFirstLoadRunning=false;
          requests.clear();
          req=jsonDecode(response);
          for(int i=0;i<req["response"]['allAssignedRequest'].length;i++){
            requests.add(AssignedRejectedModels.fromJson(req["response"]['allAssignedRequest'][i]['requestClientDetails']));
          }
          this.allRequests = requests;

          if (this.allRequests.length > 0) {
            pageNum=pageNum+1;
            isLastPage=allRequests.length==req["totalCount"];
          }
          if(requests.length==0) {
            Utils.showError(context, "No Assigned Rejections Found");
          }
        });
      });
    controller.addListener(() {
      if(controller.position.pixels>=controller.position.maxScrollExtent) {
        if (!isLastPage) {
          setState(() {
            _isLoadMoreRunning = true;
          });
          Network_Operations.getAssignedRejectedModelsSearchable(context, widget.token, 10, pageNum,widget.query).then((response) {
            setState(() {
              _isFirstLoadRunning=false;
              req=jsonDecode(response);
              for(int i=0;i<req["response"]['allAssignedRequest'].length;i++){
                requests.add(AssignedRejectedModels.fromJson(req["response"]['allAssignedRequest'][i]['requestClientDetails']));
              }
              this.allRequests = requests;

              if (this.allRequests.length > 0) {
                pageNum=pageNum+1;
                isLastPage=allRequests.length==req["totalCount"];
              }
              if(requests.length==0) {
                Utils.showError(context, "No Assigned Rejections Found");
              }
            });
          });
        }
      }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child:!_isFirstLoadRunning? ListView.builder(
              itemCount:allRequests!=null?allRequests.length:0,
              controller: controller,
              itemBuilder:(context,int index){
                return Card(
                  elevation: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      //color: Colors.teal,
                    ),
                    width: MediaQuery.of(context).size.width,


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
                              InkWell(
                                onTap: (){
                                  setState(() {
                                    List<String> imageUrl=[];
                                    for(int i=0;i<allRequests[index].multipleImages.length;i++){
                                      if(allRequests[index].multipleImages[i]!=null){
                                        imageUrl.add(allRequests[index].multipleImages[i]);
                                      }
                                    }
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>RequestImageGallery(allRequests[index])));
                                  });

                                },
                                child: CachedNetworkImage(
                                  imageUrl: allRequests[index].image!=null?allRequests[index].image:"http://anokha.world/images/not-found.png",
                                  placeholder:(context, url)=> Container(width:60,height: 60,child: Center(child: CircularProgressIndicator())),
                                  errorWidget: (context, url, error) => Icon(Icons.error,color: Colors.red,),
                                  imageBuilder: (context, imageProvider){
                                    return Container(
                                      height: 100,
                                      width: 85,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          )
                                      ),
                                    );
                                  },
                                ),
                              ),
                              //Padding(padding: EdgeInsets.only(top:2),),
                              allRequests[index].multipleColors!=null&&allRequests[index].multipleColors.length>0
                                  ?Container(
                                width: 55,
                                height: 20,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    Row(
                                      children: <Widget>[
                                        for(int i=0;i<allRequests[index].multipleColors.length;i++)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8,left: 2,right: 2),
                                            child: Wrap(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(2),
                                                    color: Color(Utils.getColorFromHex(allRequests[index].multipleColors[i].colorCode)),
                                                    //color: Colors.teal,
                                                  ),
                                                  height: 10,
                                                  width: 15,
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    )
                                  ],
                                ),
                              ) :Container(),
                            ],
                          ),
                          VerticalDivider(color: Colors.grey,),
                          GestureDetector(
                            onTapDown: (details)async{
                              if(allRequests[index].currentAction=="Completed"||allRequests[index].currentAction=="Cancelled"){
                                await showMenu(
                                  context: context,
                                  position:  RelativeRect.fromLTRB(details.globalPosition.dx, details.globalPosition.dy, 0, 0),
                                  items: [
                                    PopupMenuItem<String>(
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(right:8.0),
                                              child: Icon(Icons.disabled_by_default,color: Color(0xFF004c4c),),
                                            ),
                                            Text("Rejection Reasons")
                                          ],
                                        ),
                                        value: 'rejectionReason'
                                    ),
                                    PopupMenuItem<String>(
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(right:8.0),
                                              child: Icon(Icons.info,color: Color(0xFF004c4c),),
                                            ),
                                            Text("See Deatils")
                                          ],
                                        ),
                                        value: 'Details'
                                    ),
                                  ],
                                  elevation: 8.0,
                                ).then((selectedItem){
                                  if(selectedItem=="Details"){
                                    SharedPreferences.getInstance().then((prefs){
                                      Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"), allRequests[index].requestId).then((value){
                                        Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>DetailsPage(value)));
                                      });
                                    });
                                  }
                                  else if(selectedItem=="rejectionReason"){
                                    showReasonDialog(allRequests[index]);
                                  }
                                });
                              }
                              else{
                                await showMenu(
                                  context: context,
                                  position:  RelativeRect.fromLTRB(details.globalPosition.dx, details.globalPosition.dy, 0, 0),
                                  items: [
                                    PopupMenuItem<String>(
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(right:8.0),
                                              child: Icon(Icons.update,color: Color(0xFF004c4c),),
                                            ),
                                            Text("Change Status")
                                          ],
                                        ), value: 'changeStatus'),
                                    PopupMenuItem<String>(
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(right:8.0),
                                              child: Icon(Icons.disabled_by_default,color: Color(0xFF004c4c),),
                                            ),
                                            Text("Rejection Reasons")
                                          ],
                                        ),
                                        value: 'rejectionReasons'
                                    ),
                                    PopupMenuItem<String>(
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(right:8.0),
                                              child: Icon(Icons.info,color: Color(0xFF004c4c),),
                                            ),
                                            Text("See Deatils")
                                          ],
                                        ),
                                        value: 'Details'
                                    ),
                                  ],
                                  elevation: 8.0,
                                ).then((selectedItem){
                                  if(selectedItem=="changeStatus"){
                                    if(allRequests[index].currentAction=="Assigned"){
                                      SharedPreferences.getInstance().then((prefs){
                                        Network_Operations.changeStatusOfAssignedModel(context, prefs.getString("token"),allRequests[index].id, 1).then((value){
                                          setState(() {
                                            _isFirstLoadRunning=true;
                                          });
                                          Network_Operations.getAssignedRejectedModelsSearchable(context, widget.token, 10, pageNum,widget.query).then((response) {
                                            setState(() {
                                              _isFirstLoadRunning=false;
                                              requests.clear();
                                              req=jsonDecode(response);
                                              for(int i=0;i<req["response"]['allAssignedRequest'].length;i++){
                                                requests.add(AssignedRejectedModels.fromJson(req["response"]['allAssignedRequest'][i]['requestClientDetails']));
                                              }
                                              this.allRequests = requests;

                                              if (this.allRequests.length > 0) {
                                                pageNum=pageNum+1;
                                                isLastPage=allRequests.length==req["totalCount"];
                                              }
                                              if(requests.length==0) {
                                                Utils.showError(context, "No Assigned Rejections Found");
                                              }
                                            });
                                          });
                                        });
                                      });
                                    }else if(allRequests[index].currentAction=="In Progress"){
                                      showAlertDialog(context,allRequests[index]);
                                    }
                                  }
                                  else if(selectedItem=="Details"){
                                    SharedPreferences.getInstance().then((prefs){
                                      Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"), allRequests[index].requestId).then((value){
                                        Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>DetailsPage(value)));
                                      });                                    });
                                  }
                                  else if(selectedItem=="rejectionReasons"){
                                    showReasonDialog(allRequests[index]);
                                  }
                                });
                              }
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.62,
                              height: 160,
                              color: Colors.white,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6, top: 8,bottom: 6),
                                    child: Text(allRequests[index].modelName!=null?allRequests[index].modelName:'', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    //mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Row(
                                        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Icon(
                                            Icons.date_range,
                                            color: Colors.teal,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: 2, right: 2),
                                          ),
                                          Text(DateFormat("yyyy-MM-dd").format(DateTime.parse(allRequests[index].requestDate!=null?allRequests[index].requestDate:DateTime.now().toString())))
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 30),
                                      ),

                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.zoom_out_map,
                                            color: Colors.teal,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: 2, right: 2),
                                          ),
                                          Container(
                                              width: MediaQuery.of(context).size.width*0.4,
                                              child: Text(allRequests[index].multipleSizeNames.toString().replaceAll(".00", "").replaceAll("[","").replaceAll("]", ""),maxLines: 3,overflow: TextOverflow.visible,)
                                          )
                                        ],

                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 27),
                                      ),

                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.person,
                                            color: Colors.teal,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: 2, right: 2),
                                          ),
                                          Text(allRequests[index].clientName)
                                        ],

                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 27),
                                      ),

                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.layers,
                                        color: Colors.teal,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 2, right: 2),
                                      ),
                                      Text(allRequests[index].surfaceName!=null?requests[index].surfaceName:'',overflow: TextOverflow.ellipsis,maxLines: 1,),
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
                                        Text(allRequests[index].currentAction!=null?allRequests[index].currentAction:'')
                                      ],

                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ),
                );
              }):Center(child: CircularProgressIndicator(),),
        ),
        if(_isLoadMoreRunning)
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 40),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
  showAlertDialog(BuildContext context,AssignedRejectedModels request) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget approveRejectButton = TextButton(
      child: Text("Set"),
      onPressed: () {
        if(selectedPreference=="Cancelled"){
          Navigator.pop(context);
          SharedPreferences.getInstance().then((prefs){
            Network_Operations.changeStatusOfAssignedModel(context, prefs.getString("token"),request.id, 3).then((value){
              setState(() {
                _isFirstLoadRunning=true;
              });
              Network_Operations.getAssignedRejectedModelsSearchable(context, widget.token, 10, pageNum,widget.query).then((response) {
                setState(() {
                  _isFirstLoadRunning=false;
                  requests.clear();
                  req=jsonDecode(response);
                  for(int i=0;i<req["response"]['allAssignedRequest'].length;i++){
                    requests.add(AssignedRejectedModels.fromJson(req["response"]['allAssignedRequest'][i]['requestClientDetails']));
                  }
                  this.allRequests = requests;

                  if (this.allRequests.length > 0) {
                    pageNum=pageNum+1;
                    isLastPage=allRequests.length==req["totalCount"];
                  }
                  if(requests.length==0) {
                    Utils.showError(context, "No Assigned Rejections Found");
                  }
                });
              });
            });
          });
        }else if(selectedPreference=="Completed"){
          Navigator.pop(context);
          showJustificationAlertDialog(context,request);
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Select your Action"),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile(
                title: Text("Completed"),
                value: 'Completed',
                groupValue: selectedPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedPreference = choice;
                  });
                },
              ),
              RadioListTile(
                title: Text("Cancelled"),
                value: 'Cancelled',
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
  showJustificationAlertDialog(BuildContext context,AssignedRejectedModels request) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget approveRejectButton = TextButton(
      child: Text("Set"),
      onPressed: () {
        if(selectedPreference=="Yes"){
          Navigator.pop(context);
          SharedPreferences.getInstance().then((prefs){
            Network_Operations.changeStatusOfAssignedModelWithJustification(context, prefs.getString("token"),request.id, 2,1).then((value){
              setState(() {
                _isFirstLoadRunning=true;
              });
              Network_Operations.getAssignedRejectedModelsSearchable(context, widget.token, 10, pageNum,widget.query).then((response) {
                setState(() {
                  _isFirstLoadRunning=false;
                  requests.clear();
                  req=jsonDecode(response);
                  for(int i=0;i<req["response"]['allAssignedRequest'].length;i++){
                    requests.add(AssignedRejectedModels.fromJson(req["response"]['allAssignedRequest'][i]['requestClientDetails']));
                  }
                  this.allRequests = requests;

                  if (this.allRequests.length > 0) {
                    pageNum=pageNum+1;
                    isLastPage=allRequests.length==req["totalCount"];
                  }
                  if(requests.length==0) {
                    Utils.showError(context, "No Assigned Rejections Found");
                  }
                });
              });
            });
          });
        }else{
          Navigator.pop(context);
          SharedPreferences.getInstance().then((prefs){
            Network_Operations.changeStatusOfAssignedModelWithJustification(context, prefs.getString("token"),request.id, 2,0).then((value){
              setState(() {
                _isFirstLoadRunning=true;
              });
              Network_Operations.getAssignedRejectedModelsSearchable(context, widget.token, 10, pageNum,widget.query).then((response) {
                setState(() {
                  _isFirstLoadRunning=false;
                  requests.clear();
                  req=jsonDecode(response);
                  for(int i=0;i<req["response"]['allAssignedRequest'].length;i++){
                    requests.add(AssignedRejectedModels.fromJson(req["response"]['allAssignedRequest'][i]['requestClientDetails']));
                  }
                  this.allRequests = requests;

                  if (this.allRequests.length > 0) {
                    pageNum=pageNum+1;
                    isLastPage=allRequests.length==req["totalCount"];
                  }
                  if(requests.length==0) {
                    Utils.showError(context, "No Assigned Rejections Found");
                  }
                });
              });
            });
          });
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Was the Rejection Justified?"),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile(
                title: Text("Yes"),
                value: 'Yes',
                groupValue: selectedPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedPreference = choice;
                  });
                },
              ),
              RadioListTile(
                title: Text("No"),
                value: 'No',
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
  showReasonDialog(AssignedRejectedModels trialRequests){
    showDialog(
      context: context,
      useSafeArea: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Rejection Reasons"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height:  MediaQuery.of(context).size.height/3,
                child: ListView.builder(
                    itemCount: trialRequests.multipleReasons.length,
                    itemBuilder:(context,index){
                      return ListTile(
                        title: Text(trialRequests.multipleReasons[index]),
                        leading: Container(
                          height: 20.0,
                          width: 20.0,
                          decoration: new BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
              )
            ],
          ),
          actions: [
            TextButton(onPressed: (){
              Navigator.pop(context);
            }, child: Text("Ok"))
          ],
        );
      },
    );
  }
}
