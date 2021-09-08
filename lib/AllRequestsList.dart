import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/RequestColorsList.dart';
import 'package:productdevelopment/request_Model_form/Assumptions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ApproveForTrial.dart';
import 'Dashboard.dart';
import 'DetailsPage.dart';
import 'Model/Dropdown.dart';
import 'Observations.dart';
import 'RequestImagesGallery.dart';
import 'RequestsForTrial.dart';
import 'SchedulePage.dart';
import 'Utils/Utils.dart';
import 'acmcapproval.dart';

class AllRequestList extends StatefulWidget{
  var currentUserRoles;
  String startDate,endDate;
  AllRequestList(this.currentUserRoles,{this.startDate,this.endDate});

  @override
  State<StatefulWidget> createState() {
    return _AllRequestListState();
  }

}
class _AllRequestListState extends State<AllRequestList> {
  List<Request> allRequests = [];
  var isListVisible = false;
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<
      ScaffoldState>();
  TextEditingController _searchQuery;
  bool _isSearching = false;
  var claims;
  var selectedPreference,selectedStatus,selectedSearchPreference;
  String token;
  bool isDateBarVisible=false;
  List<DateTime> picked=[];
  DateTime initialStart=DateTime.now(),initialEnd=DateTime.now().add(Duration(days: 0));
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  String searchQuery = "Search query";
  bool isGm=false,isClient=false,isSaleManager= false,isFDesigner=false,isLabIncharge=false,isMarketingManager=false,isProductManager=false;
  bool isColorsVisible=false;
  int pageNum=1,searchPageNum=1;
  List<Request> requests=[],requestsForSuggestions=[];
  var req;
  List<String> clientNames=[],modelNames=[],modelCodes=[],newModelNames=[],newModelCodes=[];
  List<Dropdown> clientDropdown=[];
  var hasMoreData=false,nextButtonVisible=false,previousButtonVisible=false;
  @override
  void initState() {
    _searchQuery = TextEditingController();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        claims = Utils.parseJwt(prefs.getString("token"));
        token = prefs.getString("token");
        Network_Operations.getRequestsForSearchSuggestions(context, token).then((req){
          this.requestsForSuggestions=req;
          if(requestsForSuggestions!=null){
            if(requestsForSuggestions.length>0){
              for(Request r in requestsForSuggestions){
                if(r.modelName!=null){
                  modelNames.add(r.modelName);
                }
                if(r.modelCode!=null){
                  modelCodes.add(r.modelCode);
                }
                if(r.newModelName!=null){
                  newModelNames.add(r.newModelName);
                }
                if(r.newModelCode!=null){
                  newModelCodes.add(r.newModelCode);
                }
              }
            }
          }
        });
        print(claims);
        //Checking Roles
        if (claims['role'].contains('General Manager')) {
          setState(() {
            isGm = true;
          });
        } else if (claims['role'].contains('Sales Manager')) {
          setState(() {
            isSaleManager = true;
          });
        } else if (claims['role'].contains('Designer')) {
          setState(() {
            isFDesigner = true;
          });
        } else if (claims['role'].contains('Lab Incharge')) {
          setState(() {
            isLabIncharge = true;
          });
        } else if (claims['role'].contains('Marketing Manager')) {
          setState(() {
            isMarketingManager = true;
          });
        } else if (claims['role'].contains('Product Manager')) {
          setState(() {
            isProductManager = true;
          });
        } else {
          setState(() {
            isClient = true;
          });
        }
      });
      if(widget.startDate!=null&&widget.endDate!=null){
        setState(() {
          isDateBarVisible=true;
        });
      }
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: _isSearching ? const BackButton() : null,
        title: _isSearching ? _buildSearchField() : _buildTitle(context),
        actions: _buildActions(),
          bottom: isDateBarVisible? PreferredSize(
            preferredSize: Size.fromHeight(40),
            child: Container(
              alignment: Alignment.topCenter,

              child:Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(DateFormat("yyyy-MM-dd").format(initialStart)+" - "+DateFormat("yyyy-MM-dd").format(initialEnd),style: TextStyle(color: Colors.white),),
                ),
              ),
            ),
          ):null
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Visibility(
              visible: previousButtonVisible,
              child: FloatingActionButton(
                  backgroundColor: Colors.white12, //Color(0xFF004c4c),
                  splashColor: Colors.red,
                  mini: true,
                  child: Icon(Icons.arrow_back, color: Colors.teal, size: 30,),heroTag: "btn2", onPressed: (){
                    if(!_isSearching){
                      setState(() {
                        pageNum=pageNum-1;
                      });
                      print(pageNum);
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
                    }else{
                      setState(() {
                        searchPageNum=searchPageNum-1;
                      });
                      print(searchPageNum);
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
                    }

              }
              ),
            ),
            Visibility(
              visible: nextButtonVisible,
              child: FloatingActionButton(
                  backgroundColor: Colors.white12,//Color(0xFF004c4c),
                  splashColor: Colors.red,
                  mini: true,
                  child: Icon(Icons.arrow_forward, color: Colors.teal, size: 30,),heroTag: "btn1", onPressed: (){
                    if(!_isSearching){
                      setState(() {
                        pageNum=pageNum+1;
                      });
                      print(pageNum);
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
                    }else{
                      setState(() {
                        searchPageNum=searchPageNum+1;
                      });
                      print(searchPageNum);
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
                    }

              }
              ),
            ),
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
              image: AssetImage('Assets/img/pattren.png'),
            )
        ),
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: (){
            return Utils.check_connectivity().then((isConnected){
              if(isConnected){
                SharedPreferences.getInstance().then((prefs) {
                  if(!_isSearching){
                    Network_Operations.getRequestForGM(
                        context,
                        prefs.getString("token"),
                        10,
                        pageNum,
                      startDate: widget.startDate,
                      endDate: widget.endDate,
                    ).then((response) {
                      setState(() {
                        requests.clear();
                        req=jsonDecode(response);
                        for(int i=0;i<req["response"]['allRequests'].length;i++){
                          requests.add(Request.fromMap(req["response"]['allRequests'][i]));
                        }
                        this.allRequests = requests;

                        if (this.allRequests.length > 0) {
                          isListVisible = true;
                        }
                        if(req['hasNext']&&req['hasPrevious']){
                          nextButtonVisible=true;
                          previousButtonVisible=true;
                        }else if(req['hasPrevious']&&!req['hasNext']){
                          previousButtonVisible=true;
                          nextButtonVisible=false;
                        }else if(!req['hasPrevious']&&req['hasNext']){
                          previousButtonVisible=false;
                          nextButtonVisible=true;
                        }else{
                          previousButtonVisible=false;
                          nextButtonVisible=false;
                        }
                        if(allRequests.length==0){
                          Utils.showError(context,"No Requests Found");
                        }
                      });
                    });
                  }else{
                    Network_Operations.getRequestForGMSearchable(context, prefs.getString("token"), 10, searchPageNum,searchQuery,startDate: widget.startDate,
                      endDate: widget.endDate,).then((response) {
                      setState(() {
                        requests.clear();
                        req=jsonDecode(response);
                        for(int i=0;i<req["response"]['allRequests'].length;i++){
                          requests.add(Request.fromMap(req["response"]['allRequests'][i]));
                        }
                        this.allRequests = requests;

                        if (this.allRequests.length > 0) {
                          isListVisible = true;
                        }
                        print(requests.length);
                        if(req['hasNext']&&req['hasPrevious']){
                          nextButtonVisible=true;
                          previousButtonVisible=true;
                        }else if(req['hasPrevious']&&!req['hasNext']){
                          previousButtonVisible=true;
                          nextButtonVisible=false;
                        }else if(!req['hasPrevious']&&req['hasNext']){
                          previousButtonVisible=false;
                          nextButtonVisible=true;
                        }else{
                          previousButtonVisible=false;
                          nextButtonVisible=false;
                        }
                        if(allRequests.length==0){
                          Utils.showError(context,"No Requests Found");
                        }
                      });
                    });
                  }
                });
              }else{
                Utils.showError(context,"Network Not Available");
              }
            });
          },
          child: Visibility(
            visible: isListVisible,
            child: ListView.builder(
                itemCount: allRequests != null ? allRequests.length : 0,
                itemBuilder: (context, int index) {
                  return Card(
                    elevation: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        //color: Colors.teal,
                      ),
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,

                      child: Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      List<String> imageUrl = [];
                                      for (int i = 0; i <
                                          allRequests[index].multipleImages
                                              .length; i++) {
                                        if (allRequests[index].multipleImages[i] !=
                                            null) {
                                          imageUrl.add(
                                              allRequests[index].multipleImages[i]);
                                        }
                                      }
                                      imageUrl.add(allRequests[index].image);
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => RequestImageGallery(
                                              allRequests[index])));
                                    });
                                  },
                                  child: CachedNetworkImage(
                                    imageUrl: allRequests[index].image!=null?allRequests[index].image:"http://anokha.world/images/not-found.png",
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
                                allRequests[index].multipleColorNames != null &&
                                    allRequests[index].multipleColorNames.length > 0
                                    ?Container(
                                  width: 55,
                                      height:20,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                  children: [
                                      Row(
                                        children: <Widget>[
                                          for(int i = 0; i <
                                              allRequests[index].multipleColorNames
                                                  .length; i++)
                                            Padding(
                                              padding: const EdgeInsets.only(top:8,left: 2,right: 2),
                                              child: Wrap(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(
                                                          2),
                                                      color: Color(Utils.getColorFromHex(
                                                          allRequests[index]
                                                              .multipleColorNames[i]
                                                              .colorCode)),
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
                                    ) : Container(),
                              ],
                            ),
                            VerticalDivider(color: Colors.grey,),
                            GestureDetector(
                              onTapDown: (details)async{
                                if(allRequests[index].statusName=="New Request"){
                                  if(widget.currentUserRoles["2"]!=null||widget.currentUserRoles["3"]!=null) {
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
                                        showAlertDialog(context,allRequests[index]);
                                      }else if(selectedItem=="Details"){
                                        //Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(allRequests[index])));
                                        SharedPreferences.getInstance().then((prefs){
                                          Network_Operations.getRequestById(context, prefs.getString("token"), allRequests[index].requestId);
                                        });
                                      }else if(selectedItem=="addImage"){
                                        Navigator.push(context,MaterialPageRoute(builder: (context)=>RequestColorsList(allRequests[index])));
                                      }else if(selectedItem=='updateRequest'){
                                        SharedPreferences.getInstance().then((prefs){
                                          Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"), allRequests[index].requestId).then((req){
                                            Navigator.push(context,MaterialPageRoute(builder:(context)=>Assumptions(request: req,)));
                                          });
                                        });
                                      }else if(selectedItem=="deleteRequest"){
                                        SharedPreferences.getInstance().then((prefs){
                                          Network_Operations.deleteRequestById(context, prefs.getString("token"), allRequests[index].requestId).then((req){
                                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder:(context)=>Dashboard()), (route) => false);
                                            Utils.showSuccess(context,"Request Deleted Successfully");
                                          });
                                        });
                                      }
                                    });
                                  }else if(isClient){
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
                                        //Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(allRequests[index])));
                                        SharedPreferences.getInstance().then((prefs){
                                          Network_Operations.getRequestById(context, prefs.getString("token"), allRequests[index].requestId);
                                        });
                                      }else if(selectedItem=="addImage"){
                                        Navigator.push(context,MaterialPageRoute(builder: (context)=>RequestColorsList(allRequests[index])));
                                      }
                                    });
                                  }else{
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(allRequests[index])));
                                  }
                                }else if(allRequests[index].statusName=="Approved By GM"){
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
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>SchedulePage(allRequests[index])));
                                      }else if(selectedItem=="Details"){
                                        //Navigator.push(context,MaterialPageRoute(builder: (context)=>DetailsPage(allRequests[index])));
                                        SharedPreferences.getInstance().then((prefs){
                                          Network_Operations.getRequestById(context, prefs.getString("token"), allRequests[index].requestId);
                                        });
                                      }
                                    });
                                  }else{
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(allRequests[index])));
                                  }

                                }else if(allRequests[index].statusName=="Samples Scheduled"){
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
                                        showAlertChangeStatus(context,allRequests[index]);
                                      }else if(selectedItem=="Details"){
                                       // Navigator.push(context,MaterialPageRoute(builder: (context)=>DetailsPage(allRequests[index])));
                                        SharedPreferences.getInstance().then((prefs){
                                          Network_Operations.getRequestById(context, prefs.getString("token"), allRequests[index].requestId);
                                        });
                                      }else if(selectedItem=="updateschedule"){
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>SchedulePage(allRequests[index])));
                                      }
                                    });

                                  }else{
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(allRequests[index])));
                                  }
                                }else if(allRequests[index].statusName=="Model Approved"){
                                  if(widget.currentUserRoles["7"]!=null||widget.currentUserRoles["8"]!=null){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestsForTrial(allRequests[index].requestId,widget.currentUserRoles)));
                                  }else{
                                    SharedPreferences.getInstance().then((prefs){
                                      Network_Operations.getRequestById(context, prefs.getString("token"), allRequests[index].requestId);
                                    });
                                  }
                                }else {
                                  SharedPreferences.getInstance().then((prefs){
                                    Network_Operations.getRequestById(context, prefs.getString("token"), allRequests[index].requestId);
                                  });
                                }
                              },
                              child: Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.62,
                                height: 130,
                                color: Colors.white,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6, top: 8, bottom: 2),
                                      child: Text((){
                                        if(allRequests[index].newModelName!=null){
                                          return allRequests[index].newModelName;
                                        }else if(allRequests[index].modelName!=null){
                                          return allRequests[index].modelName;
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
                                              padding: EdgeInsets.only(
                                                  left: 2, right: 2),
                                            ),
                                            Text(DateFormat("yyyy-MM-dd").format(
                                                DateTime.parse(
                                                    allRequests[index].date)))
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
                                        //       text: allRequests[index].multipleSizeNames
                                        //             .toString()
                                        //             .replaceAll("[", "")
                                        //             .replaceAll("]", "")
                                        //             .replaceAll(".00", ""),
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
                                          child: Text(allRequests[index].multipleSizeNames
                                              .toString()
                                              .replaceAll("[", "")
                                              .replaceAll("]", "")
                                              .replaceAll(".00", ""),
                                              maxLines: 3,
                                             overflow: TextOverflow.visible,
                                          ),
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
                                          padding: EdgeInsets.only(
                                              left: 2, right: 2),
                                        ),
                                        Container(
                                          child: Text(allRequests[index].surfaceName !=
                                              null ? allRequests[index]
                                              .surfaceName : '',overflow: TextOverflow.ellipsis,maxLines: 1,softWrap: true),
                                        )
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
                                            padding: EdgeInsets.only(
                                                left: 3, right: 3),
                                          ),
                                          Text(allRequests[index].statusName != null
                                              ? allRequests[index].statusName
                                              : '')
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
                }),
          ),
        ),
      ),
    );
  }

  void _startSearch() {
    ModalRoute
        .of(context)
        .addLocalHistoryEntry(new LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }
  Widget _buildSearchField() {
    return  Autocomplete(
      displayStringForOption: (String value){
        return value;
      },
      optionsBuilder: (TextEditingValue text){
        if(selectedSearchPreference=="searchByProductionModelName"){
          return newModelNames.where((element) => element.toLowerCase().contains(text.text));
        }else if(selectedSearchPreference=="searchByProductionModelCode"){
          return newModelCodes.where((element) => element.toLowerCase().contains(text.text));
        }else if(selectedSearchPreference=="searchByModelName"){
          return modelNames.where((element) =>element.toLowerCase().contains(text.text));
        }else if(selectedSearchPreference=="searchByModelCode"){
          return modelCodes.where((element) =>element.toLowerCase().contains(text.text));
        }else if(selectedSearchPreference=="searchByClient"){
          return clientNames.where((element) =>element.toLowerCase().contains(text.text));
        }else
          return null;
      },
        fieldViewBuilder: (BuildContext context,TextEditingController controller,FocusNode focusmode,VoidCallback func) {
          return TextField(
            controller: controller,
            focusNode: focusmode,
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Search...',
              border: InputBorder.none,
              hintStyle: const TextStyle(color: Colors.white30),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 16.0),
            onSubmitted:(query){
              setState(() {
                this.searchQuery=query;
              });
              if(query.isNotEmpty){
                this.searchQuery=query;
                SharedPreferences.getInstance().then((prefs){
                  Network_Operations.getRequestForGMSearchable(context,prefs.getString("token"),10,searchPageNum,query,startDate: widget.startDate,
                    endDate: widget.endDate,).then((response){
                    setState(() {
                      requests.clear();
                      req=jsonDecode(response);
                      for(int i=0;i<req["response"]['allRequests'].length;i++){
                        requests.add(Request.fromMap(req["response"]['allRequests'][i]));
                      }
                      this.allRequests = requests;

                      if (this.allRequests.length > 0) {
                        isListVisible = true;
                      }
                      print(requests.length);
                      if(req['hasNext']&&req['hasPrevious']){
                        nextButtonVisible=true;
                        previousButtonVisible=true;
                      }else if(req['hasPrevious']&&!req['hasNext']){
                        previousButtonVisible=true;
                        nextButtonVisible=false;
                      }else if(!req['hasPrevious']&&req['hasNext']){
                        previousButtonVisible=false;
                        nextButtonVisible=true;
                      }else{
                        previousButtonVisible=false;
                        nextButtonVisible=false;
                      }
                      if(allRequests.length==0){
                        Utils.showError(context,"No Requests Found");
                      }
                    });
                  });
                });
              }else{
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
              }
            },
          );
        }
    );
  }
  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
    print("search query " + newQuery);
  }
  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        new IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQuery == null || _searchQuery.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed:(){
         showSearchDialog(context);
        },
      ),
      IconButton(
        onPressed: ()async{
          if(picked!=null){
            picked.clear();
          }
          var datePicked= await showDateRangePicker(
            context: context,
            cancelText: "Clear Filter",
            firstDate: DateTime.now().subtract(Duration(days: 365)),
            lastDate: DateTime.now().add(Duration(days: 365)),
            initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
          );
          if(datePicked!=null&&datePicked.start!=null){
            picked.add(datePicked.start);
          }
          if(datePicked!=null&&datePicked.end!=null){
            picked.add(datePicked.end);
          }
          if(picked!=null&&picked.length==2){
            setState(() {
              this.initialStart=picked[0];
              this.initialEnd=picked[1];
              widget.startDate=DateFormat("yyyy-MM-dd").format(picked[0]);
              widget.endDate=DateFormat("yyyy-MM-dd").format(picked[1]);
              isDateBarVisible=true;
            });

          }else if(picked!=null&&picked.length==1){
            setState(() {
              this.initialStart=picked[0];
              this.initialEnd=picked[0].add(Duration(days: 0));
              widget.startDate=DateFormat("yyyy-MM-dd").format(initialStart);
              widget.endDate=DateFormat("yyyy-MM-dd").format(initialEnd);
              isDateBarVisible=true;
            });
          }
          if(picked==null||picked.length==0){
            setState(() {
              isDateBarVisible=false;
              initialStart=DateTime.now();
              initialEnd=DateTime.now().add(Duration(days: 0));
              widget.startDate=null;
              widget.endDate=null;
            });
          }
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
          print(picked);
        },
        icon: Icon(Icons.filter_alt),
      ),
    ];
  }
  void _stopSearching() {
    _clearSearchQuery();
    setState(() {
      _isSearching = false;
      searchPageNum=1;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    });
  }
  void _clearSearchQuery() {
    print("close search box");
    setState(() {
      _searchQuery.clear();
      updateSearchQuery("Search query");
    });
  }
  Widget _buildTitle(BuildContext context) {
    var horizontalTitleAlignment =
    Platform.isIOS ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return new InkWell(
      onTap: () => scaffoldKey.currentState.openDrawer(),
      child: new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: horizontalTitleAlignment,
          children: <Widget>[
            const Text('All Requests'),
          ],
        ),
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
        SharedPreferences.getInstance().then((prefs){
          Network_Operations.getRequestById(context, prefs.getString("token"),request.requestId);
        });
      },
    );
    Widget approveRejectButton = TextButton(
      child: Text("Set"),
      onPressed: () {
        if(selectedPreference=="Approve"){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>ApproveForTrial(request,'Approve')));
        }else if(selectedPreference=="Reject"){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Observations(6,request)));
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
        SharedPreferences.getInstance().then((prefs){
          print("Request Id "+request.requestId.toString());
          Network_Operations.getRequestById(context, prefs.getString("token"),request.requestId);
        });
      },
    );
    Widget approveRejectButton = TextButton(
      child: Text("Set"),
      onPressed: () {
        if(selectedPreference=="Approve"){
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context)=>acmcApproval(selectedPreference,request)));
        }else if(selectedPreference=="Reject"){
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context)=>acmcApproval(selectedPreference,request)));
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
  showSearchDialog(BuildContext context) {
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
        print(selectedSearchPreference);
        if(selectedSearchPreference=="searchByClient"){
          clientNames.clear();
          if(clientDropdown.length>0){
            setState(() {
              for(Dropdown d in clientDropdown){
                clientNames.add(d.name);
              }
            });
          }else{
            Network_Operations.getDropDowns(context, token,"Clients").then((value){
              setState(() {
                this.clientDropdown=value;
                for(Dropdown d in clientDropdown){
                  clientNames.add(d.name);
                }
              });
            });

          }
          _startSearch();
          Navigator.pop(context);
        }else{
          _startSearch();
          Navigator.pop(context);
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Search By"),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile(
                title: Text("Samples Model Name"),
                value: 'searchByModelName',
                groupValue: selectedSearchPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedSearchPreference = choice;
                  });
                },
              ),
              RadioListTile(
                title: Text("Samples Model Code"),
                value: 'searchByModelCode',
                groupValue: selectedSearchPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedSearchPreference = choice;
                  });
                },
              ),
              RadioListTile(
                title: Text("Client"),
                value: 'searchByClient',
                groupValue: selectedSearchPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedSearchPreference = choice;
                  });
                },
              ),
               RadioListTile(
                title: Text("Production Model Name"),
                value: 'searchByProductionModelName',
                groupValue: selectedSearchPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedSearchPreference = choice;
                  });
                },
              ),
              RadioListTile(
                title: Text("Production Model Code"),
                value: 'searchByProductionModelCode',
                groupValue: selectedSearchPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedSearchPreference = choice;
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
}