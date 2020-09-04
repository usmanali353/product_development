import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Dashboard.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:shared_preferences/shared_preferences.dart';
 class TrialRequests extends StatefulWidget {

   @override
   _TrialRequestsState createState() => _TrialRequestsState();
 }

 class _TrialRequestsState extends State<TrialRequests> {
   List<Request> requests;
   bool isVisible=false;
   var selectedPreference;
   @override
  void initState() {
     SharedPreferences.getInstance().then((prefs){
       Network_Operations.getTrialRequests(context, prefs.getString("token")).then((trialRequests){
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
         child: ListView.builder(itemCount:requests!=null?requests.length:0,itemBuilder:(context,int index){
             return InkWell(
               onTap: (){
                 showTrialApprovalDialog(context,requests[index]);
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
                             Container(
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
                             //Padding(padding: EdgeInsets.only(top:2),),
                             Row(
                               children: <Widget>[
                                 Container(
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(2),
                                     color: Colors.orange.shade100,
                                     //color: Colors.teal,
                                   ),
                                   height: 10,
                                   width: 15,
                                 ),
                                 Padding(
                                   padding: EdgeInsets.only(left: 2, right: 2),
                                 ),
                                 Container(
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(2),
                                     color: Colors.grey.shade300,
                                     //color: Colors.teal,
                                   ),
                                   height: 10,
                                   width: 15,
                                 ),
                                 Padding(
                                   padding: EdgeInsets.only(left: 2, right: 2),
                                 ),
                                 Container(
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(2),
                                     color: Colors.brown.shade200,
                                     //color: Colors.teal,
                                   ),
                                   height: 10,
                                   width: 15,
                                 ),
                                 Padding(
                                   padding: EdgeInsets.only(left: 2, right: 2),
                                 ),
                                 Container(
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(2),
                                     color: Colors.brown.shade500,
                                     //color: Colors.teal,
                                   ),
                                   height: 10,
                                   width: 15,
                                 ),
                                 Padding(
                                   padding: EdgeInsets.only(left: 2, right: 2),
                                 ),
                                 Container(
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(2),
                                     color: Colors.orangeAccent.shade100,
                                     //color: Colors.teal,
                                   ),
                                   height: 10,
                                   width: 15,
                                 ),
                               ],
                             )
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
                                         Icons.layers,
                                         color: Colors.teal,
                                       ),
                                       Padding(
                                         padding: EdgeInsets.only(left: 2, right: 2),
                                       ),
                                       Text(requests[index].surfaceName!=null?requests[index].surfaceName:'')
                                     ],
                                   ),
                                   Padding(
                                     padding: EdgeInsets.only(left: 50),
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
                                       Text(requests[index].multipleSizeNames.toString().replaceAll("[", "").replaceAll("]", "").replaceAll(".00", "")),
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
             Network_Operations.approveRequestClient(context, prefs.getString("token"), request.requestId, 1);
             Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Dashboard()), (route) => false);
           });
           //Network_Operations.approveRequestClient(context, token, request.requestId, 1);
         }else if(selectedPreference=="Reject"){
           SharedPreferences.getInstance().then((prefs){
             Network_Operations.approveRequestClient(context, prefs.getString("token"), request.requestId, 0);
             Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Dashboard()), (route) => false);
           });
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
 }
