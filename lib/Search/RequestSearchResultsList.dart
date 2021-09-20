import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/Utils/Utils.dart';
import 'package:productdevelopment/request_Model_form/Assumptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ApproveForTrial.dart';
import '../Dashboard.dart';
import '../DetailsPage.dart';
import '../Observations.dart';
import '../RequestColorsList.dart';
import '../RequestImagesGallery.dart';
import '../RequestsForTrial.dart';
import '../SchedulePage.dart';
import '../acmcapproval.dart';

class RequestSearchResultsList extends StatefulWidget {
  String token;
  bool isClient=false;
  int statusId;
  String query;
  var currentUserRoles;

  RequestSearchResultsList({this.token, this.isClient, this.statusId, this.query, this.currentUserRoles});

  @override
  _RequestSearchResultsListState createState() => _RequestSearchResultsListState();
}

class _RequestSearchResultsListState extends State<RequestSearchResultsList> {
  var selectedPreference="";
  List<Request> requests=[];
  int pageNum=1;
   bool isLastPage=false;
  var req,isLoading=false,isListVisible=false,_isFirstLoadRunning=false,_isLoadMoreRunning = false;
  final ScrollController controller = ScrollController();
  @override
  void initState() {
    setState(() {
      _isFirstLoadRunning=true;
    });
    if(!widget.isClient){
      if(widget.statusId==0){
        Network_Operations.getRequestForGMSearchable(context,widget.token, 10, pageNum,widget.query).then((response) {
          setState(() {
            _isFirstLoadRunning=false;
            requests.clear();
            req=jsonDecode(response);
            for(int i=0;i<req["response"]['allRequests'].length;i++){
              requests.add(Request.fromMap(req["response"]['allRequests'][i]));
            }
            if(requests!=null&&requests.length>0){
              pageNum=pageNum+1;
              isLastPage=requests.length==req["totalCount"];
            }

            if (this.requests.length > 0) {
              isListVisible = true;
            }
            print(requests.length);

            if(requests.length==0){
              Utils.showError(context,"No Requests Found");
            }
          });
        });
      }else{
        Network_Operations.getRequestByStatusGMSearchable(context, widget.token, widget.statusId,pageNum,10,widget.query).then((response){
          setState(() {
            _isFirstLoadRunning=false;
            requests.clear();
            req=jsonDecode(response);
            for(int i=0;i<req["response"]['allRequests'].length;i++){
              requests.add(Request.fromMap(req["response"]['allRequests'][i]));
            }
            if(requests!=null&&requests.length>0){
              pageNum=pageNum+1;
              isLastPage=requests.length==req["totalCount"];
            }

            if(requests.length==0){
              Utils.showError(context,"No Request Found");
            }
          });
        });
      }
    }
    else {
      Network_Operations.getRequestByStatusIndividualUserSearchable(context,widget.token,widget.statusId,widget.query,pageNum,10).then((response){
        setState(() {
          _isFirstLoadRunning=false;
          requests.clear();
          isLoading=false;
          for(int i=0;i<jsonDecode(response).length;i++){
            requests.add(Request.fromMap(jsonDecode(response)[i]));
          }
          if(requests!=null&&requests.length>0){
            pageNum=pageNum+1;
            isLastPage=requests.length==req["totalCount"];
          }
          print(requests.length);
          if(requests.length==0){
            Utils.showError(context,"No Request Found");
          }
        });

      });
    }
    controller.addListener(() {
      if(controller.position.pixels>=controller.position.maxScrollExtent) {
        if (!isLastPage) {
          setState(() {
            print("Page Number " + pageNum.toString());
            _isLoadMoreRunning = true;
          });
          if (!widget.isClient) {
            if (widget.statusId == 0) {
              Network_Operations.getRequestForGMSearchable(
                  context, widget.token, 10, pageNum, widget.query).then((
                  response) {
                setState(() {
                  _isLoadMoreRunning = false;
                  req = jsonDecode(response);
                  for (int i = 0; i <
                      req["response"]['allRequests'].length; i++) {
                    requests.add(
                        Request.fromMap(req["response"]['allRequests'][i]));
                  }
                  if (requests != null && requests.length > 0) {
                    pageNum = pageNum + 1;
                    isLastPage=requests.length==req["totalCount"];
                  }
                  print(requests.length);

                  if (requests.length == 0) {
                    Utils.showError(context, "No Requests Found");
                  }
                });
              });
            } else {
              Network_Operations.getRequestByStatusGMSearchable(
                  context, widget.token, widget.statusId, pageNum, 10,
                  widget.query).then((response) {
                setState(() {
                  _isLoadMoreRunning = false;
                  req = jsonDecode(response);
                  for (int i = 0; i <
                      req["response"]['allRequests'].length; i++) {
                    requests.add(
                        Request.fromMap(req["response"]['allRequests'][i]));
                  }
                  if (requests != null && requests.length > 0) {
                    pageNum = pageNum + 1;
                    isLastPage=requests.length==req["totalCount"];
                  }

                  if (requests.length == 0) {
                    Utils.showError(context, "No Request Found");
                  }
                });
              });
            }
          } else {
            Network_Operations.getRequestByStatusIndividualUserSearchable(
                context, widget.token, widget.statusId, widget.query, pageNum,
                10).then((response) {
              setState(() {
                _isLoadMoreRunning = false;
                isLoading = false;
                for (int i = 0; i < jsonDecode(response).length; i++) {
                  requests.add(Request.fromMap(jsonDecode(response)[i]));
                }
                if (requests != null && requests.length > 0) {
                  pageNum = pageNum + 1;
                  isLastPage=requests.length==req["totalCount"];
                }
                print(requests.length);
                if (requests.length == 0) {
                  Utils.showError(context, "No Request Found");
                }
              });
            });
          }
        }
      }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: !_isFirstLoadRunning?ListView.builder(
              controller: controller,
              itemCount: requests.length,
              itemBuilder: (context,index){
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
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              InkWell(
                                onTap: (){
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>RequestImageGallery(requests[index])));
                                },
                                child:CachedNetworkImage(
                                  imageUrl: requests[index].image!=null?requests[index].image:"http://anokha.world/images/not-found.png",
                                  placeholder:(context, url)=> Container(width:60,height: 60,child: Center(child: CircularProgressIndicator())),
                                  errorWidget: (context, url, error) => Icon(Icons.error,color: Colors.red,),
                                  imageBuilder: (context, imageProvider){
                                    return Container(
                                      height: 85,
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
                              requests[index].multipleColorNames!=null&&requests[index].multipleColorNames.length>0
                                  ?Container(
                                width: 55,
                                height: 20,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    Row(
                                      children: <Widget>[
                                        for(int i=0;i<requests[index].multipleColorNames.length;i++)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8,left: 2,right: 2),
                                            child: Wrap(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(2),
                                                    color: Color(Utils.getColorFromHex(requests[index].multipleColorNames[i].colorCode)),
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
                              ):Container(),
                            ],
                          ),
                          VerticalDivider(color: Colors.grey,),
                          GestureDetector(
                            onTapDown: (details)async{
                              if(requests[index].statusName=="New Request"){
                                if(widget.currentUserRoles["2"]!=null||widget.currentUserRoles["3"]) {
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
                                                child: Icon(Icons.edit,color:Color(0xFF004c4c)),
                                              ),
                                              Text("Update Request")
                                            ],
                                          ), value: 'updateRequest'),
                                      PopupMenuItem<String>(
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(right:8.0),
                                                child: Icon(Icons.delete,color:Color(0xFF004c4c),),
                                              ),
                                              Text("Delete Request")
                                            ],
                                          ), value: 'deleteRequest'),
                                      PopupMenuItem<String>(
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(right:8.0),
                                                child: Icon(Icons.add_photo_alternate,color: Color(0xFF004c4c),),
                                              ),
                                              Text("Add Images")
                                            ],
                                          ), value: 'addImage'),
                                      PopupMenuItem<String>(
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(right:8.0),
                                                child: Icon(Icons.info,color: Color(0xFF004c4c),),
                                              ),
                                              Text("See Details")
                                            ],
                                          ), value: 'Details'),
                                    ],
                                    elevation: 8.0,
                                  ).then((selectedItem){
                                    if(selectedItem=="changeStatus"){
                                      showAlertDialog(context,requests[index]);
                                    }else if(selectedItem=="Details"){
                                      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DetailsPage(requests[index])));
                                      SharedPreferences.getInstance().then((prefs){
                                        Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"), requests[index].requestId).then((value){
                                          Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>DetailsPage(value)));
                                        });
                                      });
                                    }else if(selectedItem=="addImage"){
                                      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>RequestColorsList(requests[index])));
                                    }else if(selectedItem=='updateRequest'){
                                      SharedPreferences.getInstance().then((prefs){
                                        Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"), requests[index].requestId).then((req){
                                          Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>Assumptions(request: req,)));
                                        });
                                      });
                                    }else if(selectedItem=="deleteRequest"){
                                      SharedPreferences.getInstance().then((prefs){
                                        Network_Operations.deleteRequestById(context, prefs.getString("token"), requests[index].requestId).then((req){
                                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder:(context)=>Dashboard()), (route) => false);
                                          Utils.showSuccess(context,"Request Deleted Successfully");
                                        });
                                      });
                                    }
                                  });
                                }else if(widget.isClient){
                                  await showMenu(
                                    context: context,
                                    position:  RelativeRect.fromLTRB(details.globalPosition.dx, details.globalPosition.dy, 0, 0),
                                    items: [
                                      PopupMenuItem<String>(
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(right:8.0),
                                                child: Icon(Icons.add_photo_alternate,color: Color(0xFF004c4c),),
                                              ),
                                              Text("Add Images")
                                            ],
                                          ), value: 'addImage'),
                                      PopupMenuItem<String>(
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(right:8.0),
                                                child: Icon(Icons.info,color: Color(0xFF004c4c),),
                                              ),
                                              Text("See Details")
                                            ],
                                          ), value: 'Details'),
                                    ],
                                    elevation: 8.0,
                                  ).then((selectedItem){
                                    if(selectedItem=="Details"){
                                      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DetailsPage(requests[index])));
                                      SharedPreferences.getInstance().then((prefs){
                                        Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"), requests[index].requestId).then((value){
                                          Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>DetailsPage(value)));
                                        });                                      });
                                    }else if(selectedItem=="addImage"){
                                      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>RequestColorsList(requests[index])));
                                    }
                                  });
                                }else{
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DetailsPage(requests[index])));
                                }
                              }else if(requests[index].statusName=="Approved By GM"){
                                if(widget.currentUserRoles["4"]!=null){
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
                                                padding: const EdgeInsets.only(right:8.0),
                                                child: Icon(Icons.info,color: Color(0xFF004c4c),),
                                              ),
                                              Text("See Details")
                                            ],
                                          ), value: 'Details'),
                                    ],
                                    elevation: 8.0,
                                  ).then((selectedItem){
                                    if(selectedItem=="changeStatus"){
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SchedulePage(requests[index])));
                                    }else if(selectedItem=="Details"){
                                      //Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>DetailsPage(requests[index])));
                                      SharedPreferences.getInstance().then((prefs){
                                        Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"), requests[index].requestId).then((value){
                                          Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>DetailsPage(value)));
                                        });
                                      });
                                    }
                                  });
                                }else{
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DetailsPage(requests[index])));
                                }
                              }else if(requests[index].statusName=="Samples Scheduled"){
                                if(widget.currentUserRoles["5"]!=null||widget.currentUserRoles["6"]!=null){
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
                                                child: Icon(Icons.insert_invitation,color: Color(0xFF004c4c),),
                                              ),
                                              Text("Update Schedule")
                                            ],
                                          ), value: 'updateschedule'),
                                      PopupMenuItem<String>(
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(right:8.0),
                                                child: Icon(Icons.info,color: Color(0xFF004c4c),),
                                              ),
                                              Text("See Deatils")
                                            ],
                                          ), value: 'Details'),
                                    ],
                                    elevation: 8.0,
                                  ).then((selectedItem){
                                    if(selectedItem=="changeStatus"){
                                      showAlertChangeStatus(context,requests[index]);
                                    }else if(selectedItem=="Details"){
                                      //Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>DetailsPage(requests[index])));
                                      SharedPreferences.getInstance().then((prefs){
                                        Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"), requests[index].requestId).then((value){
                                          Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>DetailsPage(value)));
                                        });                                      });
                                    }else if(selectedItem=="updateschedule"){
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SchedulePage(requests[index])));
                                    }
                                  });

                                }else{
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DetailsPage(requests[index])));
                                }
                              }else if(requests[index].statusName=="Model Approved"){
                                if(widget.currentUserRoles["7"]!=null||widget.currentUserRoles["8"]!=null){
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>RequestsForTrial(requests[index].requestId,widget.currentUserRoles)));
                                }else{
                                  //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DetailsPage(requests[index])));
                                  SharedPreferences.getInstance().then((prefs){
                                    Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"), requests[index].requestId).then((value){
                                      Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>DetailsPage(value)));
                                    });                                  });
                                }
                              }else {
                                //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DetailsPage(requests[index])));
                                SharedPreferences.getInstance().then((prefs){
                                  Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"), requests[index].requestId).then((value){
                                    Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>DetailsPage(value)));
                                  });                                });
                              }
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.62,
                              height: 130,
                              color: Colors.white,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6, top: 8),
                                    child: Text((){
                                      if(requests[index].newModelName!=null){
                                        return requests[index].newModelName;
                                      }else if(requests[index].modelName!=null){
                                        return requests[index].modelName;
                                      }else{
                                        return '';
                                      }
                                    }(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
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
                                          Text(DateFormat("yyyy-MM-dd").format(DateTime.parse(requests[index].date)))
                                        ],
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
                                      // Padding(
                                      //   padding: const EdgeInsets.only(top: 12),
                                      //   child: Container(
                                      //     width: 120,
                                      //     height: 30,
                                      //     child: Marquee(
                                      //       text: requests[index].multipleSizeNames.toString().replaceAll("[", "").replaceAll("]", "").replaceAll(".00", ""),
                                      //       //style: TextStyle(fontWeight: FontWeight.bold),
                                      //       scrollAxis: Axis.horizontal,
                                      //       crossAxisAlignment: CrossAxisAlignment.start,
                                      //       blankSpace: 20.0,
                                      //       velocity: 40.0,
                                      //       pauseAfterRound: Duration(seconds: 1),
                                      //       startPadding: 10.0,
                                      //       accelerationDuration: Duration(seconds: 1),
                                      //       accelerationCurve: Curves.linear,
                                      //       decelerationDuration: Duration(milliseconds: 500),
                                      //       decelerationCurve: Curves.easeOut,
                                      //     ),
                                      //   ),
                                      // ),
                                      Container(
                                          width: MediaQuery.of(context).size.width*0.4,
                                          child: Text(requests[index].multipleSizeNames.toString().replaceAll("[", "").replaceAll("]", "").replaceAll(".00", ""),maxLines: 3,overflow: TextOverflow.visible,)
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
                                      Text(requests[index].surfaceName!=null?requests[index].surfaceName:'',overflow: TextOverflow.ellipsis,maxLines: 2,softWrap: true)
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
                                        Text(requests[index].statusName!=null?requests[index].statusName:'')
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
              },
            ):Center(child: CircularProgressIndicator(),),
          ),

            if (_isLoadMoreRunning == true)
              Center(
                child: CircularProgressIndicator(),
              ),
            // Positioned(
            //     bottom: 0,
            //     left: 0,
            //     right: 0,
            //     child: Container(
            //         width: 30,
            //         height: 30
            //         ,child: CircularProgressIndicator())
            // ),
          // Positioned(
          //   bottom:0,
          //   child: Container(
          //       width: MediaQuery.of(context).size.width,
          //       //height: 40,
          //       //color: Colors.white,
          //
          //       child: Center(child: CircularProgressIndicator())),
          // )
        ],
      ),
    );
  }

  showAlertChangeStatus(BuildContext context,Request request){
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget detailsPage = TextButton(
      child: Text("Go to Details"),
      onPressed: () {
        Navigator.pop(context);
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DetailsPage(request)));
        SharedPreferences.getInstance().then((prefs){
          Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"), request.requestId).then((value){
            Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>DetailsPage(value)));
          });        });
      },
    );
    Widget approveRejectButton = TextButton(
      child: Text("Set"),
      onPressed: () {
        if(selectedPreference=="Approve"){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ApproveForTrial(request,'Approve')));
        }else if(selectedPreference=="Reject"){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Observations(6,request)));
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
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget detailsPage = TextButton(
      child: Text("Go to Details"),
      onPressed: () {
        Navigator.pop(context);
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DetailsPage(request)));
        SharedPreferences.getInstance().then((prefs){
          Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"), request.requestId).then((value){
            Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>DetailsPage(value)));
          });
        });
      },
    );
    Widget approveRejectButton = TextButton(
      child: Text("Set"),
      onPressed: () {
        if(selectedPreference=="Approve"){
          Navigator.pop(context);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>acmcApproval(selectedPreference,request)));
        }else if(selectedPreference=="Reject"){
          Navigator.pop(context);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>acmcApproval(selectedPreference,request)));
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

  @override
  void dispose() {
    setState(() {
      pageNum=1;
      requests.clear();
      controller.dispose();
      print("Dispose Method is Called");
    });
    super.dispose();
  }
}

