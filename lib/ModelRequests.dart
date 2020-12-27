import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/AddClientsForTrial.dart';
import 'package:productdevelopment/ApproveForTrial.dart';
import 'package:productdevelopment/DetailsPage.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/Observations.dart';
import 'package:productdevelopment/RequestColorsList.dart';
import 'package:productdevelopment/RequestImagesGallery.dart';
import 'package:productdevelopment/SchedulePage.dart';
import 'package:productdevelopment/Utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DetailsPage.dart';
import 'RequestsForTrial.dart';
import 'acmcapproval.dart';


class ModelRequests extends StatefulWidget {

  int statusId;
  var currentUserRoles;
  ModelRequests(this.statusId,this.currentUserRoles);


  @override
  _ModelReState createState() => _ModelReState(statusId,currentUserRoles);
}

class _ModelReState extends State<ModelRequests>{
  List<Request> products=[];
  var claims;
  GlobalKey<RefreshIndicatorState> refreshIndicatorKey=GlobalKey();
  var selectedPreference,selectedStatus;
  int statusId;
  var currentUserRoles;
  var hasMoreData=false,nextButtonVisible=false,previousButtonVisible=false;
  int searchPageNum=1,pageNum=1;
  TextEditingController _searchQuery;
  bool _isSearching = false;
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  String searchQuery = "Search query";
  _ModelReState(this.statusId,this.currentUserRoles);
 bool isGm=false,isClient=false,isSaleManager= false,isFDesigner=false,isLabIncharge=false,isMarketingManager=false,isProductManager=false,isListVisible=false;
 bool isColorsVisible=false;
 List<Request> requests=[];
 var req;
  String token;
  @override
  void initState() {
    _searchQuery = TextEditingController();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        claims = Utils.parseJwt(prefs.getString("token"));
        token = prefs.getString("token");
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
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
      });
    });
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
                  if(!isClient){
                    Network_Operations.getRequestByStatusGM(context, token, statusId,pageNum,10).then((response){
                      setState(() {
                        requests.clear();
                        req=jsonDecode(response);
                        for(int i=0;i<req["response"]['allRequests'].length;i++){
                          requests.add(Request.fromMap(req["response"]['allRequests'][i]));
                        }
                        this.products = requests;
                        if (this.products.length > 0) {
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
                      });
                    });
                  }
                  else {
                    Network_Operations.getRequestByStatusIndividualUser(context, token, statusId,pageNum,10).then((response){
                      setState(() {
                        requests.clear();
                        for(int i=0;i<jsonDecode(response).length;i++){
                          requests.add(Request.fromMap(jsonDecode(response)[i]));
                        }
                        this.products=requests;
                        if(products!=null&&products.length>0){
                          isListVisible=true;
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
                      });
                    });
                  }
                }else{
                  if(!isClient){
                    Network_Operations.getRequestByStatusGMSearchable(context, token, statusId,pageNum,10,searchQuery).then((response){
                      setState(() {
                        requests.clear();
                        req=jsonDecode(response);
                        for(int i=0;i<req["response"]['allRequests'].length;i++){
                          requests.add(Request.fromMap(req["response"]['allRequests'][i]));
                        }
                        this.products = requests;
                        if (this.products.length > 0) {
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
                      });
                    });
                  }
                  else {
                    Network_Operations.getRequestByStatusIndividualUserSearchable(context,token,statusId,searchQuery,searchPageNum,10).then((response){
                      setState(() {
                        requests.clear();
                        for(int i=0;i<jsonDecode(response).length;i++){
                          requests.add(Request.fromMap(jsonDecode(response)[i]));
                        }
                        this.products=requests;
                        if(products!=null&&products.length>0){
                          isListVisible=true;
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
                      });
                    });
                  }
                }

              }else{
                Utils.showError(context,"Network Not Available");
              }
            });
          },
          child: Visibility(
            visible: isListVisible,
            child: ListView.builder(
                    itemCount:products!=null?products.length:0, itemBuilder: (context,int index)
                {
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
                                    setState(() {
                                      List<String> imageUrl=[];
                                      for(int i=0;i<products[index].multipleImages.length;i++){
                                        if(products[index].multipleImages[i]!=null){
                                          imageUrl.add(products[index].multipleImages[i]);
                                        }
                                      }
                                      imageUrl.add(products[index].image);
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestImageGallery(products[index])));
                                    });
                                  },
                                  child:CachedNetworkImage(
                                    imageUrl: products[index].image!=null?products[index].image:"https://cidco-smartcity.niua.org/wp-content/uploads/2017/08/No-image-found.jpg",
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
                                products[index].multipleColorNames!=null&&products[index].multipleColorNames.length>0
                                    ?Container(
                                     width: 55,
                                      height: 20,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                  children: [
                                      Row(
                                        children: <Widget>[
                                          for(int i=0;i<products[index].multipleColorNames.length;i++)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8,left: 2,right: 2),
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
                                if(products[index].statusName=="New Request"){
                                  if(currentUserRoles["2"]!=null||currentUserRoles["3"]) {
                                    await showMenu(
                                      context: context,
                                      position:  RelativeRect.fromLTRB(details.globalPosition.dx, details.globalPosition.dy, 0, 0),
                                      items: [
                                        PopupMenuItem<String>(
                                            child: const Text('Change Status'), value: 'changeStatus'),
                                        PopupMenuItem<String>(
                                            child: const Text('Add Images'), value: 'addImage'),
                                        PopupMenuItem<String>(
                                            child: const Text('See Details'), value: 'Details'),
                                      ],
                                      elevation: 8.0,
                                    ).then((selectedItem){
                                      if(selectedItem=="changeStatus"){
                                        showAlertDialog(context,products[index]);
                                      }else if(selectedItem=="Details"){
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(products[index])));
                                      }else if(selectedItem=="addImage"){
                                        Navigator.push(context,MaterialPageRoute(builder: (context)=>RequestColorsList(products[index])));
                                      }
                                    });
                                  }else if(isClient){
                                    await showMenu(
                                      context: context,
                                      position:  RelativeRect.fromLTRB(details.globalPosition.dx, details.globalPosition.dy, 0, 0),
                                      items: [
                                        PopupMenuItem<String>(
                                            child: const Text('Add Images'), value: 'addImage'),
                                        PopupMenuItem<String>(
                                            child: const Text('See Details'), value: 'Details'),
                                      ],
                                      elevation: 8.0,
                                    ).then((selectedItem){
                                       if(selectedItem=="Details"){
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(products[index])));
                                      }else if(selectedItem=="addImage"){
                                        Navigator.push(context,MaterialPageRoute(builder: (context)=>RequestColorsList(products[index])));
                                      }
                                    });
                                  }else{
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(products[index])));
                                  }
                                }else if(products[index].statusName=="Approved By GM"){
                                 if(currentUserRoles["4"]!=null){
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
                                       Navigator.push(context, MaterialPageRoute(builder: (context)=>SchedulePage(products[index])));
                                     }else if(selectedItem=="Details"){
                                       Navigator.push(context,MaterialPageRoute(builder: (context)=>DetailsPage(products[index])));
                                     }
                                   });
                                 }else{
                                   Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(products[index])));
                                 }
                                }else if(products[index].statusName=="Samples Scheduled"){
                                  if(currentUserRoles["5"]!=null||currentUserRoles["6"]!=null){
                                    await showMenu(
                                      context: context,
                                      position:  RelativeRect.fromLTRB(details.globalPosition.dx, details.globalPosition.dy, 0, 0),
                                      items: [
                                        PopupMenuItem<String>(
                                            child: const Text('Change Status'), value: 'changeStatus'),
                                        PopupMenuItem<String>(
                                            child: const Text('Update Schedule'), value: 'updateschedule'),
                                        PopupMenuItem<String>(
                                            child: const Text('See Details'), value: 'Details'),
                                      ],
                                      elevation: 8.0,
                                    ).then((selectedItem){
                                      if(selectedItem=="changeStatus"){
                                        showAlertChangeStatus(context,products[index]);
                                      }else if(selectedItem=="Details"){
                                        Navigator.push(context,MaterialPageRoute(builder: (context)=>DetailsPage(products[index])));
                                      }else if(selectedItem=="updateschedule"){
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>SchedulePage(products[index])));
                                      }
                                    });

                                  }else{
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(products[index])));
                                  }
                                }else if(products[index].statusName=="Model Approved"){
                                  if(currentUserRoles["7"]!=null||currentUserRoles["8"]!=null){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestsForTrial(products[index].requestId,currentUserRoles)));
                                  }else{
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(products[index])));
                                  }
                                }else {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(products[index])));
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
                                        if(products[index].newModelName!=null){
                                          return products[index].newModelName;
                                        }else if(products[index].modelName!=null){
                                          return products[index].modelName;
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
                                            Text(DateFormat("yyyy-MM-dd").format(DateTime.parse(products[index].date)))
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
                                        //       text: products[index].multipleSizeNames.toString().replaceAll("[", "").replaceAll("]", "").replaceAll(".00", ""),
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
                                             child: Text(products[index].multipleSizeNames.toString().replaceAll("[", "").replaceAll("]", "").replaceAll(".00", ""),maxLines: 3,overflow: TextOverflow.visible,)
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
                                        Text(products[index].surfaceName!=null?products[index].surfaceName:'',overflow: TextOverflow.ellipsis,maxLines: 2,softWrap: true)
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
                            ),
                          ],
                        ),
                      ),

                    ),
                  );
                }),
          ),
        ),
      )
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
       Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailsPage(request)));
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
        Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailsPage(request)));
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
        Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailsPage(request)));
      },
    );
    Widget approveRejectButton = FlatButton(
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
        Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailsPage(request)));
      },
    );
    Widget approveRejectButton = FlatButton(
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
          if(!isClient){
            Network_Operations.getRequestByStatusGMSearchable(context, token, statusId,searchPageNum,10,query).then((response){
              setState(() {
                requests.clear();
                req=jsonDecode(response);
                for(int i=0;i<req["response"]['allRequests'].length;i++){
                  requests.add(Request.fromMap(req["response"]['allRequests'][i]));
                }
                this.products = requests;
                if (this.products.length > 0) {
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
              });
            });
          }else {
            Network_Operations.getRequestByStatusIndividualUserSearchable(context, token, statusId,query,searchPageNum,10).then((response){
              setState(() {
                requests.clear();
                for(int i=0;i<jsonDecode(response).length;i++){
                  requests.add(Request.fromMap(jsonDecode(response)[i]));
                }
                this.products=requests;
                if(products!=null&&products.length>0){
                  isListVisible=true;
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
              });
            });
          }
        }else{
          if(!isClient){
            Network_Operations.getRequestByStatusGM(context, token, statusId,pageNum,10).then((response){
              setState(() {
                requests.clear();
                req=jsonDecode(response);
                for(int i=0;i<req["response"]['allRequests'].length;i++){
                  requests.add(Request.fromMap(req["response"]['allRequests'][i]));
                }
                this.products = requests;
                if (this.products.length > 0) {
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
              });
            });
          }else {
            Network_Operations.getRequestByStatusIndividualUser(context, token, statusId,pageNum,10).then((response){
              setState(() {
                requests.clear();
                for(int i=0;i<jsonDecode(response).length;i++){
                  requests.add(Request.fromMap(jsonDecode(response)[i]));
                }
                this.products=requests;
                if(products!=null&&products.length>0){
                  isListVisible=true;
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
              });
            });
          }
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
       IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
     statusId==5?IconButton(
        icon: const Icon(Icons.person_add),
        onPressed:(){
          Navigator.push(context, MaterialPageRoute(builder:(context)=>AddClientsToTrial()));
        },
      ):Container(),
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

