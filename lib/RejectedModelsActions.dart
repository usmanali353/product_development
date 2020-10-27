import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Model/AssignedRejectedModels.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Network_Operations/Network_Operations.dart';
import 'RequestImagesGallery.dart';
import 'Utils/Utils.dart';

class RejectedModelActions extends StatefulWidget {
  @override
  _RejectedModelActionsState createState() => _RejectedModelActionsState();
}

class _RejectedModelActionsState extends State<RejectedModelActions> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  String searchQuery = "Search query";
  List<AssignedRejectedModels> requests=[],allRequests=[];
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int pageNum=1,searchPageNum=1;
  TextEditingController _searchQuery;
  bool _isSearching = false;
  var selectedPreference;
  var req;
  bool isListVisible=false;
  var hasMoreData=false,nextButtonVisible=false,previousButtonVisible=false;
  @override
  void initState() {
    _searchQuery = TextEditingController();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
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
                    Network_Operations.getAssignedRejectedModels(
                        context, prefs.getString("token"), 10, pageNum).then((response) {
                      setState(() {
                        requests.clear();
                        req=jsonDecode(response);
                        for(int i=0;i<req["response"]['allAssignedRequest'].length;i++){
                          requests.add(AssignedRejectedModels.fromJson(req["response"]['allAssignedRequest'][i]['requestClientDetails']));
                          print(requests[i].currentAction);
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
                      });
                    });
                  }else{
                    Network_Operations.getAssignedRejectedModelsSearchable(context, prefs.getString("token"), 10, searchPageNum,searchQuery).then((response) {
                      setState(() {
                        requests.clear();
                        req=jsonDecode(response);
                        for(int i=0;i<req["response"]['allAssignedRequest'].length;i++){
                          requests.add(AssignedRejectedModels.fromJson(req["response"]['allAssignedRequest'][i]['requestClientDetails']));
                        }
                        this.allRequests = requests;

                        if (this.allRequests.length > 0) {
                          isListVisible = true;
                          print(allRequests[0].modelName);
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
                });
              }else{
                Utils.showError(context,"Network Not Available");
              }
            });
          },
          child: Visibility(
              visible: isListVisible,
              child: ListView.builder(itemCount:allRequests!=null?allRequests.length:0,itemBuilder:(context,int index){
                return Card(
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
                                    for(int i=0;i<allRequests[index].multipleImages.length;i++){
                                      if(allRequests[index].multipleImages[i]!=null){
                                        imageUrl.add(allRequests[index].multipleImages[i]);
                                      }
                                    }
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestImageGallery(allRequests[index])));
                                  });

                                },
                                child: CachedNetworkImage(
                                  imageUrl: allRequests[index].image!=null?allRequests[index].image:"https://cidco-smartcity.niua.org/wp-content/uploads/2017/08/No-image-found.jpg",
                                  placeholder:(context, url)=> Container(width:60,height: 60,child: Center(child: CircularProgressIndicator())),
                                  errorWidget: (context, url, error) => Icon(Icons.upload_file),
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
                              allRequests[index].multipleColors!=null&&allRequests[index].multipleColors.length>0
                                  ?Container(
                                    width: 55,
                                    height: 15,
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                children: [
                                    Row(
                                      children: <Widget>[
                                        for(int i=0;i<allRequests[index].multipleColors.length;i++)
                                          Padding(
                                            padding: const EdgeInsets.all(2),
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
                                SharedPreferences.getInstance().then((prefs){
                                  Network_Operations.getRequestById(context, prefs.getString("token"), allRequests[index].requestId);
                                });
                              }else{
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
                                    if(allRequests[index].currentAction=="Assigned"){
                                      SharedPreferences.getInstance().then((prefs){
                                        Network_Operations.changeStatusOfAssignedModel(context, prefs.getString("token"),allRequests[index].id, 1).then((value){
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
                                        });
                                      });
                                    }else if(allRequests[index].currentAction=="In Progress"){
                                      showAlertDialog(context,allRequests[index]);
                                    }
                                  }else if(selectedItem=="Details"){
                                    SharedPreferences.getInstance().then((prefs){
                                      Network_Operations.getRequestById(context, prefs.getString("token"), allRequests[index].requestId);
                                    });
                                  }
                                });
                              }
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
                                      Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.layers,
                                            color: Colors.teal,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: 2, right: 2),
                                          ),
                                          Text(allRequests[index].surfaceName!=null?requests[index].surfaceName:''),
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
                                          Container(
                                              padding: EdgeInsets.only(right: 8),
                                              child: Text(allRequests[index].multipleSizeNames.toString().replaceAll(".00", "").replaceAll("[","").replaceAll("]", ""),maxLines: 1,overflow: TextOverflow.ellipsis,)
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
          this.searchQuery=query;
          SharedPreferences.getInstance().then((prefs){
            Network_Operations.getAssignedRejectedModelsSearchable(context,prefs.getString("token"),10,searchPageNum,query).then((response){
              setState(() {
                requests.clear();
                req=jsonDecode(response);
                for(int i=0;i<req["response"]['allAssignedRequest'].length;i++){
                  requests.add(AssignedRejectedModels.fromJson(req["response"]['allAssignedRequest'][i]['requestClientDetails']));
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
            const Text('Assigned Requests'),
          ],
        ),
      ),
    );
  }
  showAlertDialog(BuildContext context,AssignedRejectedModels request) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget approveRejectButton = FlatButton(
      child: Text("Set"),
      onPressed: () {
        if(selectedPreference=="Cancelled"){
          Navigator.pop(context);
          SharedPreferences.getInstance().then((prefs){
            Network_Operations.changeStatusOfAssignedModel(context, prefs.getString("token"),request.id, 3).then((value){
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
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
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget approveRejectButton = FlatButton(
      child: Text("Set"),
      onPressed: () {
         if(selectedPreference=="Yes"){
          Navigator.pop(context);
          SharedPreferences.getInstance().then((prefs){
            Network_Operations.changeStatusOfAssignedModelWithJustification(context, prefs.getString("token"),request.id, 2,1).then((value){
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
            });
          });
        }else{
           Navigator.pop(context);
           SharedPreferences.getInstance().then((prefs){
             Network_Operations.changeStatusOfAssignedModelWithJustification(context, prefs.getString("token"),request.id, 2,0).then((value){
               WidgetsBinding.instance
                   .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
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
}
