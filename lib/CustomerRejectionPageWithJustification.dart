import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Model/TrialRequests.dart';
import 'package:productdevelopment/RequestImagesGallery.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Model/Dropdown.dart';
import 'Model/Request.dart';
import 'Model/RequestSuggestions.dart';
import 'Network_Operations/Network_Operations.dart';
import 'Search/RequestSearch.dart';
import 'Utils/Utils.dart';
class CustomerRejectionPageWithJustification extends StatefulWidget {
  int isJustifiable;
  String title;
  String startDate,endDate;
  CustomerRejectionPageWithJustification(this.isJustifiable,this.title,{this.startDate,this.endDate});

  @override
  _CustomerRejectionPageWithJustificationState createState() => _CustomerRejectionPageWithJustificationState();
}

class _CustomerRejectionPageWithJustificationState extends State<CustomerRejectionPageWithJustification> {

  List<TrialRequests> allRequests = [];
  var selectedSearchPreference;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool isColorsVisible=false;
  int pageNum=1;
  bool isDateBarVisible=false;
  List<DateTime> picked=[];
  DateTime initialStart=DateTime.now(),initialEnd=DateTime.now().add(Duration(days: 0));
  List<TrialRequests> requests=[];
  var req;
  List<String> clientNames=[],newModelNames=[],newModelCodes=[];
  List<Dropdown> clientDropdown=[];
  List<Request>requestsForSuggestions=[];
  var isLastPage=false;
  List<RequestSuggestions> allSuggestionsList=[];
  String token;
  PagingController<int,TrialRequests> controller = PagingController<int,TrialRequests>(firstPageKey: 1);
  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs){
      token=prefs.getString("token");
      Network_Operations.getDropDowns(context, prefs.getString("token"),"Clients").then((value){
        setState(() {
          this.clientDropdown=value;
          for(Dropdown d in clientDropdown){
            clientNames.add(d.name);
          }
        });
      });
      Network_Operations.getRequestClientsForSuggestions(context, prefs.getString("token"),just: widget.isJustifiable).then((req){
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
    // WidgetsBinding.instance
    //     .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    if(widget.startDate!=null&&widget.endDate!=null){
      setState(() {
        isDateBarVisible=true;
      });
    }
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    controller.addPageRequestListener((pageKey) {
       if(!isLastPage){
         requests.clear();
         SharedPreferences.getInstance().then((prefs) {
           Network_Operations.getTrialRequestsWithJustification(
               context,
               prefs.getString("token"),
               widget.isJustifiable,
               10,
               pageKey,
               startDate: widget.startDate,
               endDate: widget.endDate
           ).then((response) {
               req=jsonDecode(response);
               for(int i=0;i<req["response"].length;i++){
                 allRequests.add(TrialRequests.fromJson(req["response"][i]));
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
         title:Text(widget.title!=null?widget.title:"Rejections"),
         actions: _buildActions(),
           bottom: isDateBarVisible? PreferredSize(
             preferredSize: Size.fromHeight(40),
             child: Container(
               alignment: Alignment.topCenter,

               child:Center(
                 child: Padding(
                   padding: const EdgeInsets.only(bottom: 16),
                   child: Text(widget.startDate+" - "+widget.endDate,style: TextStyle(color: Colors.white),),
                 ),
               ),
             ),
           ):null
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
                 SharedPreferences.getInstance().then((prefs) {
                     Network_Operations.getTrialRequestsWithJustification(
                         context,
                         prefs.getString("token"),
                         widget.isJustifiable,
                         10,
                         pageNum,
                       startDate: widget.startDate,
                       endDate: widget.endDate
                     ).then((response) {
                       setState(() {
                         req=jsonDecode(response);
                         for(int i=0;i<req["response"].length;i++){
                           allRequests.add(TrialRequests.fromJson(req["response"][i]));
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
           child: PagedListView<int,TrialRequests>(
             pagingController: controller,
               builderDelegate: PagedChildBuilderDelegate<TrialRequests>(
                   itemBuilder:(context,allRequests,int index){
                     return Card(
                       elevation: 6,
                       child: Container(
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(10),
                           //color: Colors.teal,
                         ),
                         width: MediaQuery.of(context).size.width,
                         height: 200, //MediaQuery.of(context).size.height * 0.21,

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
                                     height: 15,
                                     child: ListView(
                                       scrollDirection: Axis.horizontal,
                                       children: [
                                         Row(
                                           children: <Widget>[
                                             for(int i=0;i<allRequests.multipleColors.length;i++)
                                               Padding(
                                                 padding: const EdgeInsets.all(2),
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
                                   ):Container(),
                                 ],
                               ),
                               VerticalDivider(color: Colors.grey,),
                               GestureDetector(
                                 onTapDown: (details)async{
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
                                     if(selectedItem=='rejectionReason'){
                                       showReasonDialog(allRequests);
                                     }else if(selectedItem=="Details"){
                                       SharedPreferences.getInstance().then((prefs){
                                         Network_Operations.getRequestById(context, prefs.getString("token"), allRequests.requestId);
                                       });
                                     }
                                   });
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
                                         child: Text(allRequests.modelName!=null?allRequests.modelName:'', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                                       ),
                                       Column(
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
                                               Text(DateFormat("yyyy-MM-dd").format(DateTime.parse(allRequests.date!=null?allRequests.date:DateTime.now().toString())))
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
                                               Text(allRequests.surfaceName!=null?requests[index].surfaceName:''),
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
                                               // Padding(
                                               //   padding: const EdgeInsets.only(top: 12),
                                               //   child: Container(
                                               //     width: 120,
                                               //     height: 30,
                                               //     child: Marquee(
                                               //       text: allRequests.multipleSizeNames
                                               //           .toString()
                                               //           .replaceAll("[", "")
                                               //           .replaceAll("]", "")
                                               //           .replaceAll(".00", ""),
                                               //       //style: TextStyle(fontWeight: FontWeight.bold),
                                               //       scrollAxis: Axis.horizontal,
                                               //       crossAxisAlignment: CrossAxisAlignment.start,
                                               //       blankSpace: 10.0,
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
                                                   padding: EdgeInsets.only(right: 8),
                                                   child: Text(allRequests.multipleSizeNames.toString().replaceAll(".00", "").replaceAll("[","").replaceAll("]", ""),maxLines: 1,overflow: TextOverflow.ellipsis,)
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
                                       Padding(
                                         padding: const EdgeInsets.only(left: 1,top: 3),
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
                                             Text(allRequests.status!=null?allRequests.status:'')
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
          await showSearch<String>(context:context,delegate:RequestSearch(allSuggestionsList,isClient:false,currentUserRoles:null,token: token,just:widget.isJustifiable ));
        },
      ),

    ];
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
