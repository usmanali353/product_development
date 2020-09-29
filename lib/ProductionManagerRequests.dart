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
  List<TrialRequests> requests;
  bool isVisible=false;
  var selectedPreference;
  int statusId;
  String type;
  var currentUserRole;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  _ProductionManagerRequestsState(this.statusId,this.type,this.currentUserRole);

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: type!=null?AppBar(title: Text("Model Requests"),):null,
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: (){
          return Utils.check_connectivity().then((isConnected){
            if(isConnected){
              SharedPreferences.getInstance().then((prefs){
                Network_Operations.getClientRequestsByStatus(context, prefs.getString("token"), statusId).then((trialRequestsList){
                  setState(() {
                    this.requests=trialRequestsList;
                    if(requests.length>0){
                      isVisible=true;
                    }else{
                      Utils.showSuccess(context, "No Requests Found");
                    }
                  });
                });
              });
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
                                padding: const EdgeInsets.only(left: 6, top: 8),
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
}
