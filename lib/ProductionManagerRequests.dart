import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Model/Dropdown.dart';
import 'package:productdevelopment/Model/TrialRequests.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/Observations.dart';
import 'package:productdevelopment/RequestImagesGallery.dart';
import 'package:productdevelopment/Utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Model/Request.dart';
class ProductionManagerRequests extends StatefulWidget {
  int statusId;
  String type,startDate,endDate;
  var currentUserRole;
  String name;

  ProductionManagerRequests(this.statusId,this.type,this.currentUserRole,{this.name,this.startDate,this.endDate});

  @override
  _ProductionManagerRequestsState createState() => _ProductionManagerRequestsState(statusId,type,currentUserRole);
}

class _ProductionManagerRequestsState extends State<ProductionManagerRequests> {
  List<TrialRequests> requests=[];
  bool isVisible=false;
  var selectedPreference,selectedSearchPreference;
  int statusId;
  String type;
  var currentUserRole,req;
  int pageNum=1,searchPageNum=1;
  bool isDateBarVisible=false;
  List<DateTime> picked=[];
  DateTime initialStart=DateTime.now(),initialEnd=DateTime.now().add(Duration(days: 0));
  String searchQuery = "Search query";
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _searchQuery;
  bool _isSearching = false;
  List<String> clientNames=[],newModelNames=[],newModelCodes=[];
  List<Dropdown> clientDropdown=[];
  List<Request>requestsForSuggestions=[];
  var hasMoreData=false,nextButtonVisible=false,previousButtonVisible=false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  _ProductionManagerRequestsState(this.statusId,this.type,this.currentUserRole);

  @override
  void initState() {
    _searchQuery=TextEditingController();
    SharedPreferences.getInstance().then((prefs){
      Network_Operations.getRequestClientsForSuggestions(context, prefs.getString("token"),statusId: statusId).then((req){
        this.requestsForSuggestions=req;
        if(requestsForSuggestions!=null){
          if(requestsForSuggestions.length>0){
            for(Request r in requestsForSuggestions){
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
    });
    if(widget.startDate!=null&&widget.endDate!=null){
      setState(() {
        isDateBarVisible=true;
      });
    }
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                if(!_isSearching){
                  SharedPreferences.getInstance().then((prefs){
                    Network_Operations.getClientRequestsByStatus(
                        context,
                        prefs.getString("token"),
                        statusId,
                        pageNum,
                        10,
                        startDate: widget.startDate,
                        endDate: widget.endDate
                    ).then((response){
                      setState(() {
                        req=jsonDecode(response);
                        this.requests.clear();
                        for(int i=0;i<jsonDecode(response)['response'].length;i++){
                          this.requests.add(TrialRequests.fromJson(jsonDecode(response)['response'][i]));
                        }
                        if(requests.length>0){
                          isVisible=true;
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
                        }else{
                          Utils.showError(context, "No Requests Found");
                        }
                      });
                    });
                  });
                }
                else{
                  SharedPreferences.getInstance().then((prefs){
                    Network_Operations.getClientRequestsByStatusSearchable(
                        context,
                        prefs.getString("token"),
                        statusId,
                        searchPageNum,
                        10,
                        searchQuery,
                        startDate: widget.startDate,
                        endDate: widget.endDate).then((response){
                      setState(() {
                        req=jsonDecode(response);
                        this.requests.clear();
                        for(int i=0;i<jsonDecode(response)['response'].length;i++){
                          this.requests.add(TrialRequests.fromJson(jsonDecode(response)['response'][i]));
                        }
                        if(requests.length>0){
                          isVisible=true;
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
                        }else{
                          Utils.showError(context, "No Requests Found");
                        }
                      });
                    });
                  });
                }
              }else{
                Utils.showError(context, "Network Not Available");
              }
            });
          },

          child: Visibility(
            visible: isVisible,
            child: ListView.builder(itemCount:requests!=null?requests.length:0,itemBuilder:(context,int index){
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
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestImageGallery(requests[index])));
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
                              if(currentUserRole["9"]!=null||currentUserRole["10"]!=null) {
                                showProductionApprovalDialog(context, requests[index]);
                              }else{
                                SharedPreferences.getInstance().then((prefs){
                                  Network_Operations.getRequestById(context, prefs.getString("token"), requests[index].requestId);
                                });
                              }
                            }else if(requests[index].status=="Not Approved Nor Rejected"){
                              if(currentUserRole["7"]!=null||currentUserRole["8"]!=null){
                                showTrialApprovalDialog(context, requests[index]);
                              }else{
                                SharedPreferences.getInstance().then((prefs){
                                  Network_Operations.getRequestById(context, prefs.getString("token"), requests[index].requestId);
                                });
                              }
                            }else if(requests[index].status=="Rejected By Customer"&&requests[index].currentAction=="Pending"){
                              if(currentUserRole['12']!=null) {
                                SharedPreferences.getInstance().then((prefs) {
                                  Network_Operations.getEmployeesDropDown(
                                      context, prefs.getString("token")).then((userList) {
                                    showAssignUserDialog(
                                        context, userList, requests[index]);
                                  });
                                });
                              }else{
                                SharedPreferences.getInstance().then((prefs){
                                  Network_Operations.getRequestById(context, prefs.getString("token"), requests[index].requestId);
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
                                    Network_Operations.getRequestById(context, prefs.getString("token"), requests[index].requestId);
                                  });
                                }else if(selectedItem=="rejectionReasons"){
                                  showReasonDialog(requests[index]);
                                }
                              });
                            }else{
                              SharedPreferences.getInstance().then((prefs){
                                Network_Operations.getRequestById(context, prefs.getString("token"), requests[index].requestId);
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
            }),
          ),
        ),
      ),
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
          Network_Operations.getRequestById(context, prefs.getString("token"), request.requestId);
        });
      },
    );
    Widget approveRejectButton = TextButton(
      child: Text("Set"),
      onPressed: () {
        Navigator.pop(context);
        if(selectedPreference=="Approve"){
          SharedPreferences.getInstance().then((prefs){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>Observations(7,request)));
          });
        }else if(selectedPreference=="Reject"){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Observations(8,request)));
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
          Network_Operations.getRequestById(context, prefs.getString("token"), request.requestId);
        });
      },
    );
    Widget approveRejectButton = TextButton(
      child: Text("Set"),
      onPressed: () {
        Navigator.pop(context);
        if(selectedPreference=="Approve"){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Observations(9,request)));
        }else if(selectedPreference=="Reject"){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Observations(10,request)));
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
              if(query.isNotEmpty){
                setState(() {
                  this.searchQuery=query;
                });

                SharedPreferences.getInstance().then((prefs){
                  Network_Operations.getClientRequestsByStatusSearchable(
                      context,
                      prefs.getString("token"),
                      statusId,
                      searchPageNum,
                      10,
                      searchQuery,
                      startDate: widget.startDate,
                      endDate: widget.endDate).then((response){
                    setState(() {
                      req=jsonDecode(response);
                      requests.clear();
                      for(int i=0;i<jsonDecode(response)['response'].length;i++){
                        this.requests.add(TrialRequests.fromJson(jsonDecode(response)['response'][i]));
                      }
                      if(requests.length>0){
                        isVisible=true;
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
                      }else{
                        Utils.showError(context, "No Requests Found");
                      }
                    });
                  });
                });
              }
              else{
                SharedPreferences.getInstance().then((prefs){
                  Network_Operations.getClientRequestsByStatus(context,
                      prefs.getString("token"),
                      statusId,
                      pageNum,
                      10,
                      startDate: widget.startDate,
                      endDate: widget.endDate
                  ).then((response){
                    setState(() {
                      req=jsonDecode(response);
                      requests.clear();
                      for(int i=0;i<jsonDecode(response)['response'].length;i++){
                        this.requests.add(TrialRequests.fromJson(jsonDecode(response)['response'][i]));
                      }
                      if(requests.length>0){
                        isVisible=true;
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
                      }else{
                        Utils.showError(context, "No Requests Found");
                      }
                    });
                  });
                });
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
       IconButton(
        icon: const Icon(Icons.search),
        onPressed:(){
          showSearchDialog(context);
        },
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
      searchQuery="";
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
             Text(widget.name!=null?widget.name:"Model Requests"),
          ],
        ),
      ),
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
          Network_Operations.getRequestById(context, prefs.getString("token"), request.requestId);
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
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
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
            SharedPreferences.getInstance().then((prefs){
              Network_Operations.getDropDowns(context, prefs.getString("token"),"Clients").then((value){
                setState(() {
                  this.clientDropdown=value;
                  for(Dropdown d in clientDropdown){
                    clientNames.add(d.name);
                  }
                });
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
