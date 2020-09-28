import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ApproveForTrial.dart';
import 'DetailsPage.dart';
import 'Observations.dart';
import 'RequestImagesGallery.dart';
import 'RequestsForTrial.dart';
import 'SchedulePage.dart';
import 'Utils/Utils.dart';
import 'acmcapproval.dart';
import 'addImagetoColor.dart';

class AllRequestList extends StatefulWidget{
  var currentUserRoles;

  AllRequestList(this.currentUserRoles);

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
  var selectedPreference,selectedStatus;
  String token;
  String searchQuery = "Search query";
  bool isGm=false,isClient=false,isSaleManager= false,isFDesigner=false,isLabIncharge=false,isMarketingManager=false,isProductManager=false;
  bool isColorsVisible=false;
  ScrollController _scrollController =  ScrollController();

  bool isLoading = false;
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
      });
    });
    SharedPreferences.getInstance().then((prefs) {
      Network_Operations.getRequestForGM(
          context, prefs.getString("token"), 100, 1).then((allRequests) {
        setState(() {
          this.allRequests = allRequests;
          if (this.allRequests.length > 0) {
            isListVisible = true;
          }
        });
      });
    });
    _scrollController.addListener(() {
      if(_scrollController.position.pixels==_scrollController.position.maxScrollExtent){

      }
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
      ),
      body: Visibility(
        visible: isListVisible,
        child: ListView.builder(
            itemCount: allRequests != null ? allRequests.length : 0,
            controller: _scrollController,
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
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.21,

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
                              child: Container(
                                //color: Color(0xFF004c4c),
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          allRequests[index].image != null
                                              ? allRequests[index].image
                                              : "https://cidco-smartcity.niua.org/wp-content/uploads/2017/08/No-image-found.jpg"),
                                      //MemoryImage(base64Decode(products[index]['image'])),
                                      fit: BoxFit.cover,
                                    )
                                ),
                              ),
                            ),
                            //Padding(padding: EdgeInsets.only(top:2),),
                            allRequests[index].multipleColorNames != null &&
                                allRequests[index].multipleColorNames.length > 0
                                ? Row(
                              children: <Widget>[
                                for(int i = 0; i <
                                    allRequests[index].multipleColorNames
                                        .length; i++)
                                  Padding(
                                    padding: const EdgeInsets.all(2),
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
                                : Container(),
                          ],
                        ),
                        VerticalDivider(color: Colors.grey,),
                        GestureDetector(
                          onTapDown: (details)async{
                            if(allRequests[index].statusName=="New Request"){
                              if(widget.currentUserRoles["1"]!=null) {
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
                                    showAlertDialog(context,allRequests[index]);
                                  }else if(selectedItem=="Details"){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(allRequests[index])));
                                  }else if(selectedItem=="addImage"){
                                    Navigator.push(context,MaterialPageRoute(builder: (context)=>addImageToColors(allRequests[index])));
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
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(allRequests[index])));
                                  }else if(selectedItem=="addImage"){
                                    Navigator.push(context,MaterialPageRoute(builder: (context)=>addImageToColors(allRequests[index])));
                                  }
                                });
                              }else{
                                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(allRequests[index])));
                              }
                            }else if(allRequests[index].statusName=="Approved By GM"){
                              if(widget.currentUserRoles["2"]!=null||widget.currentUserRoles["3"]!=null){
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
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>SchedulePage(allRequests[index])));
                                  }else if(selectedItem=="Details"){
                                    Navigator.push(context,MaterialPageRoute(builder: (context)=>DetailsPage(allRequests[index])));
                                  }
                                });
                              }else{
                                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(allRequests[index])));
                              }

                            }else if(allRequests[index].statusName=="Samples Scheduled"){
                              if(widget.currentUserRoles["4"]!=null){
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
                                    showAlertChangeStatus(context,allRequests[index]);
                                  }else if(selectedItem=="Details"){
                                    Navigator.push(context,MaterialPageRoute(builder: (context)=>DetailsPage(allRequests[index])));
                                  }else if(selectedItem=="updateschedule"){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>SchedulePage(allRequests[index])));
                                  }
                                });

                              }else{
                                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(allRequests[index])));
                              }
                            }else if(allRequests[index].statusName=="Model Approved"){
                              if(widget.currentUserRoles["5"]!=null||widget.currentUserRoles["6"]!=null){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestsForTrial(allRequests[index].requestId,widget.currentUserRoles)));
                              }else{
                                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(allRequests[index])));
                              }
                            }else {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(allRequests[index])));
                            }
                          },
                          child: Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.62,
                            height: MediaQuery
                                .of(context)
                                .size
                                .height * 0.62,
                            color: Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 6, top: 8),
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
                                    Padding(
                                      padding: EdgeInsets.only(left: 30),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.layers,
                                            color: Colors.teal,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 2, right: 2),
                                          ),
                                          Text(allRequests[index].surfaceName !=
                                              null ? allRequests[index]
                                              .surfaceName : '')
                                        ],

                                      ),
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
                                    Text(allRequests[index].multipleSizeNames
                                        .toString()
                                        .replaceAll("[", "")
                                        .replaceAll("]", "")
                                        .replaceAll(".00", "")),
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
          SharedPreferences.getInstance().then((prefs){
            Network_Operations.getRequestForGMSearchable(context,prefs.getString("token"),100,1,query).then((allRequests){
              setState(() {
                this.allRequests.clear();
                this.allRequests = allRequests;
                if (this.allRequests.length > 0) {
                  isListVisible = true;
                }
              });
            });
          });
        }else{
          SharedPreferences.getInstance().then((prefs) {
            Network_Operations.getRequestForGM(
                context, prefs.getString("token"), 100, 1).then((allRequests) {
              setState(() {
                this.allRequests.clear();
                this.allRequests = allRequests;
                if (this.allRequests.length > 0) {
                  isListVisible = true;
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
    });
  }

  void _clearSearchQuery() {
    print("close search box");
    setState(() {
      _searchQuery.clear();
      updateSearchQuery("Search query");
      SharedPreferences.getInstance().then((prefs) {
        Network_Operations.getRequestForGM(
            context, prefs.getString("token"), 100, 1).then((allRequests) {
          setState(() {
            this.allRequests.clear();
            this.allRequests = allRequests;
            if (this.allRequests.length > 0) {
              isListVisible = true;
            }
          });
        });
      });
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

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
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
}