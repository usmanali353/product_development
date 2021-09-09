import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Model/TrialRequests.dart';
import 'package:productdevelopment/RequestImagesGallery.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Model/Dropdown.dart';
import 'Model/Request.dart';
import 'Network_Operations/Network_Operations.dart';
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
  var isListVisible = false,selectedSearchPreference;
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _searchQuery;
  bool _isSearching = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  String searchQuery = "Search query";
  bool isColorsVisible=false;
  int pageNum=1,searchPageNum=1;
  bool isDateBarVisible=false;
  List<DateTime> picked=[];
  DateTime initialStart=DateTime.now(),initialEnd=DateTime.now().add(Duration(days: 0));
  List<TrialRequests> requests=[];
  var req;
  List<String> clientNames=[],newModelNames=[],newModelCodes=[];
  List<Dropdown> clientDropdown=[];
  List<Request>requestsForSuggestions=[];
  var hasMoreData=false,nextButtonVisible=false,previousButtonVisible=false;
  @override
  void initState() {
    super.initState();
    _searchQuery = TextEditingController();
    SharedPreferences.getInstance().then((prefs){
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
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    if(widget.startDate!=null&&widget.endDate!=null){
      setState(() {
        isDateBarVisible=true;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
     return Scaffold(
       key: scaffoldKey,
       appBar: AppBar(
         leading: _isSearching ? const BackButton() : null,
         title: _isSearching ? _buildSearchField() : _buildTitle(context),
         actions: _buildActions(),
           bottom: isDateBarVisible? PreferredSize(
             preferredSize: Size.fromHeight(40),
             child: Container(
               alignment: Alignment.topCenter,

               child:Center(
                 child: Padding(
                   padding: const EdgeInsets.only(bottom: 16),
                   child: Text(DateFormat("yyyy-MM-dd").format(initialStart)+" - "+DateFormat("yyyy-MM-dd").format(initialEnd),style: TextStyle(color: Colors.white),),
                 ),
               ),
             ),
           ):null
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
                         requests.clear();
                         req=jsonDecode(response);
                         for(int i=0;i<req["response"].length;i++){
                           requests.add(TrialRequests.fromJson(req["response"][i]));
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
                         if(requests.length==0) {
                           Utils.showError(context, "No Rejections Found");
                         }
                       });
                     });
                   }else{
                     Network_Operations.getTrialRequestsWithJustificationSearchable(
                         context,
                         prefs.getString("token"),
                         widget.isJustifiable,
                         10,
                         searchPageNum,
                         searchQuery,
                         startDate: widget.startDate,
                         endDate: widget.endDate
                     ).then((response) {
                       setState(() {
                         requests.clear();
                         req=jsonDecode(response);
                         for(int i=0;i<req["response"]['allAssignedRequest'].length;i++){
                           requests.add(TrialRequests.fromJson(req["response"]['allAssignedRequest'][i]['requestClientDetails']));
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
                         if(requests.length==0) {
                           Utils.showError(context, "No Rejections Found");
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
                                   for(int i=0;i<allRequests[index].multipleImages.length;i++){
                                     if(allRequests[index].multipleImages[i]!=null){
                                       imageUrl.add(allRequests[index].multipleImages[i]);
                                     }
                                   }
                                   Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestImageGallery(allRequests[index])));
                                 });

                               },
                               child: CachedNetworkImage(
                                 imageUrl: allRequests[index].image!=null?allRequests[index].image:"http://anokha.world/images/not-found.png",
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
                                  showReasonDialog(allRequests[index]);
                                }else if(selectedItem=="Details"){
                                  SharedPreferences.getInstance().then((prefs){
                                    Network_Operations.getRequestById(context, prefs.getString("token"), allRequests[index].requestId);
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
                                   child: Text(allRequests[index].modelName!=null?allRequests[index].modelName:'', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
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
                                         Text(DateFormat("yyyy-MM-dd").format(DateTime.parse(allRequests[index].date!=null?allRequests[index].date:DateTime.now().toString())))
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
                                         // Padding(
                                         //   padding: const EdgeInsets.only(top: 12),
                                         //   child: Container(
                                         //     width: 120,
                                         //     height: 30,
                                         //     child: Marquee(
                                         //       text: allRequests[index].multipleSizeNames
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
                                       Text(allRequests[index].status!=null?allRequests[index].status:'')
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
    return  Autocomplete(
        displayStringForOption: (String value){
          return value;
        },
        optionsBuilder: (TextEditingValue text){
          if(selectedSearchPreference=="searchByProductionModelName"){
            return newModelNames.where((element) => element.toLowerCase().contains(text.text));
          }else if(selectedSearchPreference=="searchByProductionModelCode"){
            return newModelCodes.where((element) => element.toLowerCase().contains(text.text));
          }else if(selectedSearchPreference=="searchByClient"){
            return clientNames.where((element) =>element.toLowerCase().contains(text.text));
          }else
            return null;
        },
        fieldViewBuilder: (BuildContext context,TextEditingController controller,FocusNode focusmode,VoidCallback func) {
           return TextField(
             controller: controller,
             focusNode: focusmode,
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
                   Network_Operations.getTrialRequestsWithJustificationSearchable(
                       context,
                       prefs.getString("token"),
                       widget.isJustifiable,
                       10,
                       searchPageNum,
                       query,
                       startDate: widget.startDate,
                       endDate: widget.endDate
                   ).then((response){
                     setState(() {
                       requests.clear();
                       req=jsonDecode(response);
                       for(int i=0;i<req["response"].length;i++){
                         requests.add(TrialRequests.fromJson(req["response"][i]));
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
                       if(requests.length==0) {
                         Utils.showError(context, "No Rejections Found");
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
        onPressed:(){
         showSearchDialog(context);
        },
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
             Text(widget.title),
          ],
        ),
      ),
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
  showSearchDialog(BuildContext context) {
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
        print(selectedSearchPreference);
        if(selectedSearchPreference=="searchByClient"){
          clientNames.clear();
          if(clientDropdown.length>0){
            setState(() {
              for(Dropdown d in clientDropdown){
                clientNames.add(d.name);
              }
            });
          }else{
            SharedPreferences.getInstance().then((prefs){
              Network_Operations.getDropDowns(context, prefs.getString("token"),"Clients").then((value){
                setState(() {
                  this.clientDropdown=value;
                  for(Dropdown d in clientDropdown){
                    clientNames.add(d.name);
                  }
                });
              });
            });
          }
          _startSearch();
          Navigator.pop(context);
        }else{
          _startSearch();
          Navigator.pop(context);
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Search By"),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile(
                title: Text("Production Model Name"),
                value: 'searchByProductionModelName',
                groupValue: selectedSearchPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedSearchPreference = choice;
                  });
                },
              ),
              RadioListTile(
                title: Text("Production Model Code"),
                value: 'searchByProductionModelCode',
                groupValue: selectedSearchPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedSearchPreference = choice;
                  });
                },
              ),
              RadioListTile(
                title: Text("Client"),
                value: 'searchByClient',
                groupValue: selectedSearchPreference,
                onChanged: (choice) {
                  setState(() {
                    this.selectedSearchPreference = choice;
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
