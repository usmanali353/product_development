import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Model/AssignedRejectedModels.dart';
import 'package:productdevelopment/Model/Dropdown.dart';
import 'package:productdevelopment/Model/TrialRequests.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/Utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../DetailsPage.dart';
import '../Observations.dart';
import '../RequestImagesGallery.dart';

class ClientRequestSearchResultsList extends StatefulWidget {
  String token;
  bool isClient=false,isAssignedRejection=false;
  int statusId,just;
  String query;
  var currentUserRoles;

  ClientRequestSearchResultsList({this.token, this.isClient, this.statusId, this.query, this.currentUserRoles,this.just,this.isAssignedRejection});

  @override
  _ClientRequestSearchResultsListState createState() => _ClientRequestSearchResultsListState();
}

class _ClientRequestSearchResultsListState extends State<ClientRequestSearchResultsList> {
  List<TrialRequests> requests=[];
  List<AssignedRejectedModels> assignedModels=[];
  var selectedPreference="",isLastPage=false,_isFirstLoadRunning=false,_isLoadMoreRunning = false;
  int pageNum=1;
  var req;
  final ScrollController controller=ScrollController();
  @override
  void initState() {
    setState(() {
      _isFirstLoadRunning=true;
      print("Just "+widget.just.toString());
    });
    if(widget.just!=null){
      Network_Operations.getTrialRequestsWithJustificationSearchable(
          context,
          widget.token,
          widget.just,
          10,
          pageNum,
          widget.query,
      ).then((response) {
        setState(() {
          requests.clear();
          _isFirstLoadRunning=false;
          req=jsonDecode(response);
          for(int i=0;i<req["response"].length;i++){
            requests.add(TrialRequests.fromJson(req["response"][i]));
          }
          if (this.requests.length > 0) {
            pageNum=pageNum+1;
            isLastPage=requests.length==req["totalCount"];
          }
          print(requests.length);

          if(requests.length==0) {
            Utils.showError(context, "No Rejections Found");
          }
        });
      });
    }
    else{
      Network_Operations.getClientRequestsByStatusSearchable(
        context,
        widget.token,
        widget.statusId,
        pageNum,
        10,
        widget.query,).then((response){
        setState(() {
          _isFirstLoadRunning=false;
          req=jsonDecode(response);
          this.requests.clear();
          for(int i=0;i<jsonDecode(response)['response'].length;i++){
            this.requests.add(TrialRequests.fromJson(jsonDecode(response)['response'][i]));
          }
          if(requests!=null&&requests.length>0){
            pageNum=pageNum+1;
            isLastPage=requests.length==req["totalCount"];
          }
        });
      });
    }
    
    controller.addListener(() {
      if(controller.position.pixels>=controller.position.maxScrollExtent) {
        if (!isLastPage) {
          setState(() {
            _isLoadMoreRunning = true;
          });
          if(widget.just!=null){
            Network_Operations.getTrialRequestsWithJustificationSearchable(
              context,
              widget.token,
              widget.just,
              10,
              pageNum,
              widget.query,
            ).then((response) {
              setState(() {
                _isFirstLoadRunning=false;
                req=jsonDecode(response);
                for(int i=0;i<req["response"].length;i++){
                  requests.add(TrialRequests.fromJson(req["response"][i]));
                }
                if (this.requests.length > 0) {
                  pageNum=pageNum+1;
                  isLastPage=requests.length==req["totalCount"];
                }
                print(requests.length);

                if(requests.length==0) {
                  Utils.showError(context, "No Rejections Found");
                }
              });
            });
          }else{
            Network_Operations.getClientRequestsByStatusSearchable(
              context,
              widget.token,
              widget.statusId,
              pageNum,
              10,
              widget.query,).then((response) {
              setState(() {
                _isLoadMoreRunning = false;
                req = jsonDecode(response);
                for (int i = 0; i <
                    jsonDecode(response)['response'].length; i++) {
                  this.requests.add(TrialRequests.fromJson(
                      jsonDecode(response)['response'][i]));
                }
                if (requests != null && requests.length > 0) {
                  pageNum = pageNum + 1;
                  isLastPage=requests.length==req["totalCount"];
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
    return Column(
      children: [
        Expanded(
          child:!_isFirstLoadRunning? ListView.builder(
              itemCount:requests!=null?requests.length:0,
              controller: controller,
              itemBuilder:(context,int index){
                if(widget.just==null){
                  return Card(
                    elevation: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        //color: Colors.teal,
                      ),
                      width: MediaQuery.of(context).size.width,
                      //   height: 175, //MediaQuery.of(context).size.height * 0.25,

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
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>RequestImageGallery(requests[index])));
                                    });

                                  },
                                  child: CachedNetworkImage(
                                    imageUrl:requests[index].image!=null?requests[index].image:"http://anokha.world/images/not-found.png",
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
                                requests[index].multipleColors!=null&&requests[index].multipleColors.length>0
                                    ?Container(
                                  width: 55,
                                  height:20,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      Row(
                                        children: <Widget>[
                                          for(int i=0;i<requests[index].multipleColors.length;i++)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8,left: 2,right: 2),
                                              child: Wrap(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(2),
                                                      color: Color(Utils.getColorFromHex(requests[index].multipleColors[i].colorCode)),
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
                              onTapDown:(details)async{
                                if(requests[index].status=="Approved By Customer"){
                                  if(widget.currentUserRoles["9"]!=null||widget.currentUserRoles["10"]!=null) {
                                    showProductionApprovalDialog(context, requests[index]);
                                  }else{
                                    SharedPreferences.getInstance().then((prefs){
                                      Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"), requests[index].requestId).then((value){
                                        Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>DetailsPage(value)));
                                      });
                                    });
                                  }
                                }else if(requests[index].status=="No Status"){
                                  if(widget.currentUserRoles["7"]!=null||widget.currentUserRoles["8"]!=null){
                                    showTrialApprovalDialog(context, requests[index]);
                                  }else{
                                    SharedPreferences.getInstance().then((prefs){
                                      Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"), requests[index].requestId).then((value){
                                        Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>DetailsPage(value)));
                                      });
                                    });
                                  }
                                }else if(requests[index].status=="Rejected By Customer"&&requests[index].currentAction=="Pending"){
                                  if(widget.currentUserRoles['12']!=null) {
                                    SharedPreferences.getInstance().then((prefs) {
                                      Network_Operations.getEmployeesDropDown(
                                          context, prefs.getString("token")).then((userList) {
                                        showAssignUserDialog(
                                            context, userList, requests[index]);
                                      });
                                    });
                                  }else{
                                    SharedPreferences.getInstance().then((prefs){
                                      Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"), requests[index].requestId).then((value){
                                        Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>DetailsPage(value)));
                                      });
                                    });
                                  }
                                }else if(requests[index].status=="Rejected By Customer"&&requests[index].currentAction!="Pending"){
                                  await showMenu(
                                    context: context,
                                    position:  RelativeRect.fromLTRB(details.globalPosition.dx, details.globalPosition.dy, 0, 0),
                                    items: [
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
                                      )
                                    ],
                                    elevation: 8.0,
                                  ).then((selectedItem){
                                    // if(selectedItem=="rejectionReason"){
                                    //   showReasonDialog(requests[index]);
                                    // }else
                                    if(selectedItem=="Details"){
                                      SharedPreferences.getInstance().then((prefs){
                                        Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"), requests[index].requestId).then((value){
                                          Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>DetailsPage(value)));
                                        });
                                      });
                                    }else if(selectedItem=="rejectionReasons"){
                                      showReasonDialog(requests[index]);
                                    }
                                  });
                                }else{
                                  SharedPreferences.getInstance().then((prefs){
                                    Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"), requests[index].requestId).then((value){
                                      Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>DetailsPage(value)));
                                    });
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
                                      child: Text(requests[index].modelName!=null?requests[index].modelName:'', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
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
                                            // Padding(
                                            //   padding: const EdgeInsets.only(top: 12),
                                            //   child: Container(
                                            //     width: 120,
                                            //     height: 20,
                                            //     child: Marquee(
                                            //       text: requests[index].multipleSizeNames.toString().replaceAll("[", "").replaceAll("]", "").replaceAll(".00", ""),
                                            //       //style: TextStyle(fontWeight: FontWeight.bold),
                                            //       scrollAxis: Axis.horizontal,
                                            //       crossAxisAlignment: CrossAxisAlignment.start,
                                            //       blankSpace: 20.0,
                                            //       velocity: 40.0,
                                            //
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
                                              child: Text(requests[index].multipleSizeNames.toString().replaceAll(".00", "").replaceAll("[","").replaceAll("]", ""),maxLines: 3,overflow: TextOverflow.visible,),
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
                                            Text(requests[index].clientName)
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
                                        Text(requests[index].surfaceName!=null?requests[index].surfaceName:'',overflow: TextOverflow.ellipsis,maxLines: 1,softWrap: true,),
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
                                          Text(requests[index].status!=null?requests[index].status:'')
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
                }
                return Card(
                  elevation: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      //color: Colors.teal,
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: 200, //MediaQuery.of(context).size.height * 0.21,

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
                                    for(int i=0;i<requests[index].multipleImages.length;i++){
                                      if(requests[index].multipleImages[i]!=null){
                                        imageUrl.add(requests[index].multipleImages[i]);
                                      }
                                    }
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>RequestImageGallery(requests[index])));
                                  });

                                },
                                child: CachedNetworkImage(
                                  imageUrl: requests[index].image!=null?requests[index].image:"http://anokha.world/images/not-found.png",
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
                              requests[index].multipleColors!=null&&requests[index].multipleColors.length>0
                                  ?Container(
                                width: 55,
                                height: 15,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    Row(
                                      children: <Widget>[
                                        for(int i=0;i<requests[index].multipleColors.length;i++)
                                          Padding(
                                            padding: const EdgeInsets.all(2),
                                            child: Wrap(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(2),
                                                    color: Color(Utils.getColorFromHex(requests[index].multipleColors[i].colorCode)),
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
                                if(selectedItem=='rejectionReason'){
                                  showReasonDialog(requests[index]);
                                }else if(selectedItem=="Details"){
                                  SharedPreferences.getInstance().then((prefs){
                                    Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"), requests[index].requestId).then((value){
                                      Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>DetailsPage(value)));
                                    });
                                  });
                                }
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.62,
                              height: MediaQuery.of(context).size.height * 0.62,
                              color: Colors.white,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6, top: 8,bottom: 6),
                                    child: Text(requests[index].modelName!=null?requests[index].modelName:'', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                                  ),
                                  Column(
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
                                          Text(DateFormat("yyyy-MM-dd").format(DateTime.parse(requests[index].date!=null?requests[index].date:DateTime.now().toString())))
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 30),
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
                                          Text(requests[index].surfaceName!=null?requests[index].surfaceName:''),
                                        ],


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
                                          // Padding(
                                          //   padding: const EdgeInsets.only(top: 12),
                                          //   child: Container(
                                          //     width: 120,
                                          //     height: 30,
                                          //     child: Marquee(
                                          //       text: requests[index].multipleSizeNames
                                          //           .toString()
                                          //           .replaceAll("[", "")
                                          //           .replaceAll("]", "")
                                          //           .replaceAll(".00", ""),
                                          //       //style: TextStyle(fontWeight: FontWeight.bold),
                                          //       scrollAxis: Axis.horizontal,
                                          //       crossAxisAlignment: CrossAxisAlignment.start,
                                          //       blankSpace: 10.0,
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
                                              padding: EdgeInsets.only(right: 8),
                                              child: Text(requests[index].multipleSizeNames.toString().replaceAll(".00", "").replaceAll("[","").replaceAll("]", ""),maxLines: 1,overflow: TextOverflow.ellipsis,)
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
                                          Text(requests[index].clientName)
                                        ],

                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 27),
                                      ),

                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 1,top: 3),
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
                                        Text(requests[index].status!=null?requests[index].status:'')
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
  showAssignUserDialog(BuildContext context,List<Dropdown> users,TrialRequests request){
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
        Navigator.pop(context);
        var employeeNames=[],employeeId;
        for(int i=0;i<users.length;i++){
          employeeNames.add(users[i].name);
        }
        employeeId=users[employeeNames.indexOf(selectedPreference)].stringId;
        SharedPreferences.getInstance().then((prefs){
          Network_Operations.assignUserToRejectedModel(context, prefs.getString("token"), request.id, employeeId).then((value){
            Network_Operations.getClientRequestsByStatusSearchable(
              context,
              widget.token,
              widget.statusId,
              pageNum,
              10,
              widget.query,).then((response){
              setState(() {
                req=jsonDecode(response);
                this.requests.clear();
                for(int i=0;i<jsonDecode(response)['response'].length;i++){
                  this.requests.add(TrialRequests.fromJson(jsonDecode(response)['response'][i]));
                }
                if(requests!=null&&requests.length>0){
                  pageNum=pageNum+1;
                  isLastPage=pageNum>req["totalPages"];
                }
              });
            });
          });
        });

      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Assign User to Rejected Model"),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height:  MediaQuery.of(context).size.height/3,
                child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context,int index){
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RadioListTile(
                            title: Text(users!=null&&users.length>0?users[index].name:''),
                            value: users!=null&&users.length>0?users[index].name:'',
                            groupValue: selectedPreference,
                            onChanged: (choice) {
                              setState(() {
                                this.selectedPreference = choice;
                              });
                            },
                          ),
                        ],
                      );
                    }
                ),
              ),
              // RadioListTile(
              //   title: Text("Approve"),
              //   value: 'Approve',
              //   groupValue: selectedPreference,
              //   onChanged: (choice) {
              //     setState(() {
              //       this.selectedPreference = choice;
              //     });
              //   },
              // ),
              // RadioListTile(
              //   title: Text("Reject"),
              //   value: 'Reject',
              //   groupValue: selectedPreference,
              //   onChanged: (choice) {
              //     setState(() {
              //       this.selectedPreference = choice;
              //     });
              //   },
              // ),
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
  showReasonDialog(TrialRequests trialRequests){
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
                    itemCount:trialRequests!=null&& trialRequests.multipleReasons!=null?trialRequests.multipleReasons.length:0,
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
  showTrialApprovalDialog(BuildContext context,TrialRequests request){
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
        Navigator.pop(context);
        if(selectedPreference=="Approve"){
          SharedPreferences.getInstance().then((prefs){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Observations(7,request)));
          });
        }else if(selectedPreference=="Reject"){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Observations(8,request)));
        }
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Approve/Reject Trialed Model"),
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
  showProductionApprovalDialog(BuildContext context,TrialRequests request){
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
        Navigator.pop(context);
        if(selectedPreference=="Approve"){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Observations(9,request)));
        }else if(selectedPreference=="Reject"){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Observations(10,request)));
        }
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Approve/Reject Model for Production"),
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
