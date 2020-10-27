import 'package:cached_network_image/cached_network_image.dart';
import 'package:filter_list/filter_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Dashboard.dart';
import 'package:productdevelopment/Model/TrialRequests.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/Observations.dart';
import 'package:productdevelopment/RequestImagesGallery.dart';
import 'package:productdevelopment/Utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Model/Dropdown.dart';
 class RequestsForTrial extends StatefulWidget {
int requestId;
var currentUserRole;
RequestsForTrial(this.requestId,this.currentUserRole);

  @override
   _RequestsForTrialState createState() => _RequestsForTrialState(requestId,currentUserRole);
 }

 class _RequestsForTrialState extends State<RequestsForTrial> {
   List<TrialRequests> requests;
   bool isVisible=false;
   var selectedPreference;
   int requestId;
   var currentUserRole;
   _RequestsForTrialState(this.requestId,this.currentUserRole);

  @override
  void initState() {
     SharedPreferences.getInstance().then((prefs){
       Network_Operations.getTrialRequests(context, prefs.getString("token"),requestId).then((trialRequests){
         setState(() {
           this.requests=trialRequests;
           if(requests!=null){
             isVisible=true;
           }

         });
       });
     });
    super.initState();
  }
   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(title: Text("Trial Requests"),),
       body: Visibility(
         visible: isVisible,
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
           child: ListView.builder(itemCount:requests!=null?requests.length:0,itemBuilder:(context,int index){
               return GestureDetector(
                 onTapDown: (details)async{
                   if(requests[index].status=="Approved By Customer"){
                     if(currentUserRole["9"]!=null||currentUserRole["10"]!=null){
                       showProductionApprovalDialog(context, requests[index]);
                     }else{
                       SharedPreferences.getInstance().then((prefs){
                         Network_Operations.getRequestById(context, prefs.getString("token"), requests[index].requestId);
                       });
                     }
                   }else if(requests[index].status=="Not Approved Nor Rejected"){
                     if(currentUserRole["7"]!=null||currentUserRole["8"]!=null) {
                       showTrialApprovalDialog(context, requests[index]);
                     }else{
                       SharedPreferences.getInstance().then((prefs){
                         Network_Operations.getRequestById(context, prefs.getString("token"), requests[index].requestId);
                       });
                     }
                   }else if(requests[index].status=="Rejected By Customer"&&requests[index].currentAction=="Pending"){
                     SharedPreferences.getInstance().then((prefs){
                       if(currentUserRole["12"]!=null) {
                         Network_Operations.getEmployeesDropDown(
                             context, prefs.getString("token")).then((userList) {
                           showAssignUserDialog(
                               context, userList, requests[index]);
                         });
                       }else{
                         SharedPreferences.getInstance().then((prefs){
                           Network_Operations.getRequestById(context, prefs.getString("token"), requests[index].requestId);
                         });
                       }
                     });
                   }else{
                     await showMenu(
                       context: context,
                       position:  RelativeRect.fromLTRB(details.globalPosition.dx, details.globalPosition.dy, 0, 0),
                       items: [
                         PopupMenuItem<String>(
                             child: const Text('See Details'), value: 'Details'),
                         PopupMenuItem<String>(
                             child: const Text('View Rejection Reason'), value: 'rejectionReason'),
                       ],
                       elevation: 8.0,
                     ).then((selectedItem){
                       if(selectedItem=="Details"){
                         SharedPreferences.getInstance().then((prefs){
                           Network_Operations.getRequestById(context, prefs.getString("token"), requests[index].requestId);
                         });
                       }
                       else if(selectedItem=="rejectionReason"){
                         showReasonDialog(requests[index]);
                       }
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
                                     Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestImageGallery(requests[index])));
                                   });

                                 },
                                 child: CachedNetworkImage(
                                   imageUrl: requests[index].image!=null?requests[index].image:"https://cidco-smartcity.niua.org/wp-content/uploads/2017/08/No-image-found.jpg",
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
                               requests[index].multipleColors!=null&&requests[index].multipleColors.length>0
                                   ?
                                   Container(
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
                                   ) :Container(),
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
   showAssignUserDialog(BuildContext context,List<Dropdown> users,TrialRequests request){
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
             FlatButton(onPressed: (){
               Navigator.pop(context);
             }, child: Text("Ok"))
           ],
         );
       },
     );
   }
 }
