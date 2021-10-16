import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Model/AssignedRejectedModels.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Model/Dropdown.dart';
import 'Model/Request.dart';
import 'Model/RequestSuggestions.dart';
import 'Network_Operations/Network_Operations.dart';
import 'RequestImagesGallery.dart';
import 'Search/RequestSearch.dart';
import 'Utils/Utils.dart';

class RejectedModelActions extends StatefulWidget {
  @override
  _RejectedModelActionsState createState() => _RejectedModelActionsState();
}

class _RejectedModelActionsState extends State<RejectedModelActions> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  String searchQuery = "";
  List<AssignedRejectedModels> requests=[],allRequests=[];
  int pageNum=1,searchPageNum=1;
  var selectedPreference,selectedSearchPreference;
  var req;
  String token;
  List<RequestSuggestions> allSuggestionsList=[];
  bool isLastPage=false;
  List<String> clientNames=[],newModelNames=[],newModelCodes=[];
  List<Dropdown> clientDropdown=[];
  List<Request>requestsForSuggestions=[];
  PagingController<int,AssignedRejectedModels> controller=PagingController<int,AssignedRejectedModels>(firstPageKey: 1);
  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs){
      token=prefs.getString("token");
      Network_Operations.getRequestClientsForSuggestions(context, prefs.getString("token"),forAssignedClientRejectionSuggestions: true).then((req){
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
      Network_Operations.getDropDowns(context, prefs.getString("token"),"Clients").then((value){
        setState(() {
          this.clientDropdown=value;
          for(Dropdown d in clientDropdown){
            clientNames.add(d.name);
          }
        });
      });
    });
        // WidgetsBinding.instance
        //     .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  controller.addPageRequestListener((pageKey) {
    if(!isLastPage){
      requests.clear();
        SharedPreferences.getInstance().then((prefs) {
          Network_Operations.getAssignedRejectedModels(
              context, prefs.getString("token"), 10, pageKey).then((response) {
              req=jsonDecode(response);
              for(int i=0;i<req["response"]['allAssignedRequest'].length;i++){
                requests.add(AssignedRejectedModels.fromJson(req["response"]['allAssignedRequest'][i]['requestClientDetails']));
              }
              this.allRequests = requests;
              pageNum=pageNum+1;
              pageKey=pageNum;
              isLastPage=pageNum>req["totalPages"];
              if(isLastPage){
                controller.appendLastPage(allRequests);
              }else{
                controller.appendPage(allRequests,pageKey);
              }
          });

        });
    }
  });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Assigned Requests"),
        actions: _buildActions(),
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
            setState(() {
              requests.clear();
              allRequests.clear();
              controller.refresh();
            });
            return Utils.check_connectivity().then((isConnected){
              if(isConnected){
                if(pageNum>1){
                  setState(() {
                    requests.clear();
                    allRequests.clear();
                    pageNum=1;
                  });
                }
                SharedPreferences.getInstance().then((prefs) {
                    Network_Operations.getAssignedRejectedModels(
                        context, prefs.getString("token"), 10, pageNum).then((response) {
                      setState(() {
                        req=jsonDecode(response);
                        for(int i=0;i<req["response"]['allAssignedRequest'].length;i++){
                          requests.add(AssignedRejectedModels.fromJson(req["response"]['allAssignedRequest'][i]['requestClientDetails']));
                        }
                        this.allRequests = requests;
                        pageNum=pageNum+1;
                        isLastPage=pageNum>req["totalPages"];
                        if(isLastPage){
                          controller.appendLastPage(allRequests);
                        }else{
                          controller.appendPage(allRequests,pageNum);
                        }
                      });
                    });

                });
              }else{
                Utils.showError(context,"Network Not Available");
              }
            });
          },
          child: PagedListView<int,AssignedRejectedModels>(
            pagingController: controller,
              builderDelegate: PagedChildBuilderDelegate<AssignedRejectedModels>(
                  itemBuilder:(context,allRequests,int index){
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
                                        for(int i=0;i<allRequests.multipleImages.length;i++){
                                          if(allRequests.multipleImages[i]!=null){
                                            imageUrl.add(allRequests.multipleImages[i]);
                                          }
                                        }
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestImageGallery(allRequests)));
                                      });

                                    },
                                    child: CachedNetworkImage(
                                      imageUrl: allRequests.image!=null?allRequests.image:"http://anokha.world/images/not-found.png",
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
                                  allRequests.multipleColors!=null&&allRequests.multipleColors.length>0
                                      ?Container(
                                    width: 55,
                                    height: 20,
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: [
                                        Row(
                                          children: <Widget>[
                                            for(int i=0;i<allRequests.multipleColors.length;i++)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 8,left: 2,right: 2),
                                                child: Wrap(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(2),
                                                        color: Color(Utils.getColorFromHex(allRequests.multipleColors[i].colorCode)),
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
                                  if(allRequests.currentAction=="Completed"||allRequests.currentAction=="Cancelled"){
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
                                          Network_Operations.getRequestById(context, prefs.getString("token"), allRequests.requestId);
                                        });
                                      }
                                      else if(selectedItem=="rejectionReason"){
                                        showReasonDialog(allRequests);
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
                                        if(allRequests.currentAction=="Assigned"){
                                          SharedPreferences.getInstance().then((prefs){
                                            Network_Operations.changeStatusOfAssignedModel(context, prefs.getString("token"),allRequests.id, 1).then((value){
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
                                            });
                                          });
                                        }else if(allRequests.currentAction=="In Progress"){
                                          showAlertDialog(context,allRequests);
                                        }
                                      }
                                      else if(selectedItem=="Details"){
                                        SharedPreferences.getInstance().then((prefs){
                                          Network_Operations.getRequestById(context, prefs.getString("token"), allRequests.requestId);
                                        });
                                      }
                                      else if(selectedItem=="rejectionReasons"){
                                        showReasonDialog(allRequests);
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
                                        child: Text(allRequests.modelName!=null?allRequests.modelName:'', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
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
                                              Text(DateFormat("yyyy-MM-dd").format(DateTime.parse(allRequests.requestDate!=null?allRequests.requestDate:DateTime.now().toString())))
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
                                                  child: Text(allRequests.multipleSizeNames.toString().replaceAll(".00", "").replaceAll("[","").replaceAll("]", ""),maxLines: 3,overflow: TextOverflow.visible,)
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
                                              Text(allRequests.clientName)
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
                                          Text(allRequests.surfaceName!=null?requests[index].surfaceName:'',overflow: TextOverflow.ellipsis,maxLines: 1,),
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
                                            Text(allRequests.currentAction!=null?allRequests.currentAction:'')
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
              ),
          ),
        ),
      ),
      );
  }
  List<Widget> _buildActions() {
    return <Widget>[
      new IconButton(
        icon: const Icon(Icons.search),
        onPressed:()async{
          allSuggestionsList.clear();
          if(clientNames.length>0){
            for(String c in clientNames){
              allSuggestionsList.add(RequestSuggestions(c, "Client"));
            }
          }
          if(newModelNames.length>0){
            for(String c in newModelNames){
              allSuggestionsList.add(RequestSuggestions(c, "Production Model Name"));
            }
          }
          if(newModelCodes.length>0){
            for(String c in newModelCodes){
              allSuggestionsList.add(RequestSuggestions(c, "Production Model Code"));
            }
          }
          allSuggestionsList.sort((a,b)=>a.suggestionText.toLowerCase().compareTo(b.suggestionText.toLowerCase()));
          await showSearch<String>(context:context,delegate:RequestSearch(allSuggestionsList,isClient:false,token: token,isAssignedRejection: true));
         // showSearchDialog(context);
        },
      ),
    ];
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
  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}
