import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Model/TrialRequests.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/Observations.dart';
import 'package:productdevelopment/RequestImagesGallery.dart';
import 'package:productdevelopment/Utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Dashboard.dart';
import 'Model/Dropdown.dart';
 class RequestsForTrial extends StatefulWidget {
int requestId;
var currentUserRole;
RequestsForTrial(this.requestId,this.currentUserRole);

  @override
   _RequestsForTrialState createState() => _RequestsForTrialState(requestId,currentUserRole);
 }

 class _RequestsForTrialState extends State<RequestsForTrial> {
   List<TrialRequests> requests=[],allRequests=[];
   var selectedPreference;
   int requestId;
   var currentUserRole,req;
   int pageNum=1;
   var isLastPage=false;
   PagingController<int,TrialRequests> controller=PagingController<int,TrialRequests>(firstPageKey: 1);
   final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
   _RequestsForTrialState(this.requestId,this.currentUserRole);

  @override
  void initState() {
    controller.addPageRequestListener((pageKey) { 
      if(!isLastPage){
        allRequests.clear();
          SharedPreferences.getInstance().then((prefs){
            Network_Operations.getTrialRequests(context, prefs.getString("token"), requestId, pageKey, 10).then((response){
                if(response!=null&&response.isNotEmpty) {
                  req = jsonDecode(response);
                  for (int i = 0; i < jsonDecode(response)['response'].length; i++) {
                    this.allRequests.add(TrialRequests.fromJson(
                        jsonDecode(response)['response'][i]));
                  }
                  this.requests=allRequests;
                  pageNum=pageNum+1;
                  pageKey=pageNum;
                  isLastPage=pageNum>req["totalPages"];
                  if(isLastPage){
                    controller.appendLastPage(requests);
                  }else{
                    controller.appendPage(requests,pageKey);
                  }
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
         title: Text("Trial Requests"),
       ),
       body: RefreshIndicator(
         key: _refreshIndicatorKey,
         onRefresh: (){
           setState(() {
             allRequests.clear();
             requests.clear();
             controller.refresh();
           });
           return Utils.check_connectivity().then((isConnected){
             if(isConnected){
               if(pageNum>1){
                 setState(() {
                   allRequests.clear();
                   requests.clear();
                   pageNum=1;
                 });
               }
                   SharedPreferences.getInstance().then((prefs){
                     Network_Operations.getTrialRequests(context, prefs.getString("token"), requestId, pageNum, 10).then((response){
                       setState(() {
                         if(response!=null&&response.isNotEmpty) {
                           req = jsonDecode(response);
                           for (int i = 0; i < jsonDecode(response)['response'].length; i++) {
                             this.allRequests.add(TrialRequests.fromJson(
                                 jsonDecode(response)['response'][i]));
                           }
                           this.requests=allRequests;
                           pageNum=pageNum+1;
                           isLastPage=pageNum>req["totalPages"];
                           if(isLastPage){
                             controller.appendLastPage(requests);
                           }else{
                             controller.appendPage(requests,pageNum);
                           }
                         }
                       });
                     });
                   });
             }else{
               Utils.showError(context,"Network Not Available");
             }
           });
         },
         child: Container(
           width: MediaQuery.of(context).size.width,
           height: MediaQuery.of(context).size.height,
           decoration: BoxDecoration(
               image: DecorationImage(
                 fit: BoxFit.cover,
                 //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                 image: AssetImage('Assets/img/pattren.png'),
               )
           ),
           child: PagedListView(
             pagingController: controller,
               builderDelegate: PagedChildBuilderDelegate<TrialRequests>(
                   itemBuilder:(context,requests,int index){
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
                                         Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestImageGallery(requests)));
                                       });

                                     },
                                     child: CachedNetworkImage(
                                       imageUrl: requests.image!=null?requests.image:"http://anokha.world/images/not-found.png",
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
                                   requests.multipleColors!=null&&requests.multipleColors.length>0
                                       ?
                                   Container(
                                     width: 55,
                                     height: 20,
                                     child: ListView(
                                       scrollDirection: Axis.horizontal,
                                       children: [
                                         Row(
                                           children: <Widget>[
                                             for(int i=0;i<requests.multipleColors.length;i++)
                                               Padding(
                                                 padding: const EdgeInsets.only(top: 8,left: 2,right: 2),
                                                 child: Wrap(
                                                   children: [
                                                     Container(
                                                       decoration: BoxDecoration(
                                                         borderRadius: BorderRadius.circular(2),
                                                         color: Color(Utils.getColorFromHex(requests.multipleColors[i].colorCode)),
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
                                   if(requests.status=="Approved By Customer"){
                                     if(currentUserRole["9"]!=null||currentUserRole["10"]!=null){
                                       showProductionApprovalDialog(context, requests);
                                     }else{
                                       SharedPreferences.getInstance().then((prefs){
                                         Network_Operations.getRequestById(context, prefs.getString("token"), requests.requestId);
                                       });
                                     }
                                   }else if(requests.status=="No Status"){
                                     if(currentUserRole["7"]!=null||currentUserRole["8"]!=null) {
                                       showTrialApprovalDialog(context, requests);
                                     }else{
                                       SharedPreferences.getInstance().then((prefs){
                                         Network_Operations.getRequestById(context, prefs.getString("token"), requests.requestId);
                                       });
                                     }
                                   }else if(requests.status=="Rejected By Customer"&&requests.currentAction=="Pending"){
                                     SharedPreferences.getInstance().then((prefs){
                                       if(currentUserRole["12"]!=null) {
                                         Network_Operations.getEmployeesDropDown(
                                             context, prefs.getString("token")).then((userList) {
                                           showAssignUserDialog(
                                               context, userList, requests);
                                         });
                                       }else{
                                         SharedPreferences.getInstance().then((prefs){
                                           Network_Operations.getRequestById(context, prefs.getString("token"), requests.requestId);
                                         });
                                       }
                                     });
                                   }else if(requests.status=="Rejected By Customer"){
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
                                                 Text("See Details")
                                               ],
                                             ), value: 'Details'),
                                         PopupMenuItem<String>(
                                             child: Row(
                                               children: [
                                                 Padding(
                                                   padding: EdgeInsets.only(right:8.0),
                                                   child: Icon(Icons.disabled_by_default,color: Color(0xFF004c4c),),
                                                 ),
                                                 Text("Rejection Reason")
                                               ],
                                             ), value: 'rejectionReason'),
                                       ],
                                       elevation: 8.0,
                                     ).then((selectedItem){
                                       if(selectedItem=="Details"){
                                         SharedPreferences.getInstance().then((prefs){
                                           Network_Operations.getRequestById(context, prefs.getString("token"), requests.requestId);
                                         });
                                       }
                                       else if(selectedItem=="rejectionReason"){
                                         showReasonDialog(requests);
                                       }
                                     });
                                   }else{
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
                                                 Text("See Details")
                                               ],
                                             ), value: 'Details'),
                                       ],
                                       elevation: 8.0,
                                     ).then((selectedItem){
                                       if(selectedItem=="Details"){
                                         SharedPreferences.getInstance().then((prefs){
                                           Network_Operations.getRequestById(context, prefs.getString("token"), requests.requestId);
                                         });
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
                                         child: Text(requests.modelName!=null?requests.modelName:'', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
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
                                               Text(DateFormat("yyyy-MM-dd").format(DateTime.parse(requests.date)))
                                             ],
                                           ),
                                           Padding(
                                             padding: EdgeInsets.only(left: 30),
                                           ),

                                         ],
                                       ),
                                       Row(
                                         crossAxisAlignment: CrossAxisAlignment.center,
                                         mainAxisSize: MainAxisSize.min,
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
                                                   child: Text(requests.multipleSizeNames.toString().replaceAll(".00", "").replaceAll("[","").replaceAll("]", ""),maxLines: 3,overflow: TextOverflow.visible,)
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
                                               Text(requests.clientName)
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
                                           Text(requests.surfaceName!=null?requests.surfaceName:'',overflow: TextOverflow.ellipsis,maxLines: 1,),
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
                                             Text(requests.status!=null?requests.status:'')
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
               ),

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
             Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder:(context)=>Dashboard()), (route) => false);
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
                     itemCount: trialRequests.multipleReasons!=null?trialRequests.multipleReasons.length:0,
                     itemBuilder:(context,index){
                       return ListTile(
                         title: Text(trialRequests.multipleReasons[index]!=null?trialRequests.multipleReasons[index]:""),
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
