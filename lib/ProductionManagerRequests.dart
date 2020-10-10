import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Model/TrialRequests.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/Observations.dart';
import 'package:productdevelopment/RequestImagesGallery.dart';
import 'package:productdevelopment/Utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ProductionManagerRequests extends StatefulWidget {
  int statusId;
  String type;
  var currentUserRole;
  ProductionManagerRequests(this.statusId,this.type,this.currentUserRole);

  @override
  _ProductionManagerRequestsState createState() => _ProductionManagerRequestsState(statusId,type,currentUserRole);
}

class _ProductionManagerRequestsState extends State<ProductionManagerRequests> {
  List<TrialRequests> requests=[];
  bool isVisible=false;
  var selectedPreference;
  int statusId;
  String type;
  var currentUserRole,req;
  int pageNum=1,searchPageNum=1;
  String searchQuery = "Search query";
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _searchQuery;
  bool _isSearching = false;
  var hasMoreData=false,nextButtonVisible=false,previousButtonVisible=false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  _ProductionManagerRequestsState(this.statusId,this.type,this.currentUserRole);

  @override
  void initState() {
    _searchQuery=TextEditingController();
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
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: (){
          return Utils.check_connectivity().then((isConnected){
            if(isConnected){
              if(!_isSearching){
                SharedPreferences.getInstance().then((prefs){
                  Network_Operations.getClientRequestsByStatus(context, prefs.getString("token"), statusId,pageNum,10).then((response){
                    setState(() {
                      req=jsonDecode(response);
                      this.requests.clear();
                      for(int i=0;i<jsonDecode(response)['response'].length;i++){
                        this.requests.add(TrialRequests.fromJson(jsonDecode(response)['response'][i]));
                      }
                      if(requests.length>0){
                        isVisible=true;
                      }else{
                        Utils.showSuccess(context, "No Requests Found");
                      }
                    });
                  });
                });
              }
              else{
                SharedPreferences.getInstance().then((prefs){
                  Network_Operations.getClientRequestsByStatusSearchable(context, prefs.getString("token"), statusId,searchPageNum,10,searchQuery).then((response){
                    setState(() {
                      req=jsonDecode(response);
                      this.requests.clear();
                      for(int i=0;i<jsonDecode(response)['response'].length;i++){
                        this.requests.add(TrialRequests.fromJson(jsonDecode(response)['response'][i]));
                      }
                      if(requests.length>0){
                        isVisible=true;
                      }else{
                        Utils.showSuccess(context, "No Requests Found");
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
            return InkWell(
              onTap: (){
                if(requests[index].status=="Approved By Customer"){
                  if(currentUserRole["9"]!=null) {
                    showProductionApprovalDialog(context, requests[index]);
                  }else{
                    SharedPreferences.getInstance().then((prefs){
                      Network_Operations.getRequestById(context, prefs.getString("token"), requests[index].requestId);
                    });
                  }
                }else if(requests[index].status=="Not Approved Nor Rejected"){
                  if(currentUserRole["7"]!=null){
                    showTrialApprovalDialog(context, requests[index]);
                  }else{
                    SharedPreferences.getInstance().then((prefs){
                      Network_Operations.getRequestById(context, prefs.getString("token"), requests[index].requestId);
                    });
                  }
                }else{
                  SharedPreferences.getInstance().then((prefs){
                    Network_Operations.getRequestById(context, prefs.getString("token"), requests[index].requestId);
                  });
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
                            InkWell(
                              onTap: (){
                                setState(() {
                                  List<String> imageUrl=[];
                                  for(int i=0;i<requests[index].multipleImages.length;i++){
                                    if(requests[index].multipleImages[i]!=null){
                                      imageUrl.add(requests[index].multipleImages[i]);
                                    }
                                  }
                                  imageUrl.add(requests[index].image);
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestImageGallery(requests[index])));
                                });

                              },
                              child: Container(
                                //color: Color(0xFF004c4c),
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(requests[index].image!=null?requests[index].image:"https://cidco-smartcity.niua.org/wp-content/uploads/2017/08/No-image-found.jpg"), //MemoryImage(base64Decode(products[index]['image'])),
                                      fit: BoxFit.cover,
                                    )
                                ),
                              ),
                            ),
                            //Padding(padding: EdgeInsets.only(top:2),),
                            requests[index].multipleColors!=null&&requests[index].multipleColors.length>0?Row(
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
                                      Text(requests[index].multipleSizeNames.toString().replaceAll(".00", "").replaceAll("[","").replaceAll("]", ""))
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
                      ],
                    ),
                  ),

                ),
              ),
            );
          }),
        ),
      ),
    );
  }
  showTrialApprovalDialog(BuildContext context,TrialRequests request){
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
        SharedPreferences.getInstance().then((prefs){
          Network_Operations.getRequestById(context, prefs.getString("token"), request.requestId);
        });
      },
    );
    Widget approveRejectButton = FlatButton(
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
        SharedPreferences.getInstance().then((prefs){
          Network_Operations.getRequestById(context, prefs.getString("token"), request.requestId);
        });
      },
    );
    Widget approveRejectButton = FlatButton(
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
    return  TextField(
      controller: _searchQuery,
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
            Network_Operations.getClientRequestsByStatusSearchable(context, prefs.getString("token"), statusId,searchPageNum,10,searchQuery).then((response){
              setState(() {
                req=jsonDecode(response);
                requests.clear();
                for(int i=0;i<jsonDecode(response)['response'].length;i++){
                  this.requests.add(TrialRequests.fromJson(jsonDecode(response)['response'][i]));
                }
                if(requests.length>0){
                  isVisible=true;
                }else{
                  Utils.showSuccess(context, "No Requests Found");
                }
              });
            });
          });
        }
        else{
          SharedPreferences.getInstance().then((prefs){
            Network_Operations.getClientRequestsByStatus(context, prefs.getString("token"), statusId,pageNum,10).then((response){
              setState(() {
                req=jsonDecode(response);
                requests.clear();
                for(int i=0;i<jsonDecode(response)['response'].length;i++){
                  this.requests.add(TrialRequests.fromJson(jsonDecode(response)['response'][i]));
                }
                if(requests.length>0){
                  isVisible=true;
                }else{
                  Utils.showSuccess(context, "No Requests Found");
                }
              });
            });
          });
        }
      },
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
      new IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
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
            const Text('Model Requests'),
          ],
        ),
      ),
    );
  }
}
