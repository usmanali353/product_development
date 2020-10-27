import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Model/TrialRequests.dart';
import 'package:productdevelopment/RequestImagesGallery.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Network_Operations/Network_Operations.dart';
import 'Utils/Utils.dart';
class CustomerRejectionPageWithJustification extends StatefulWidget {
  int isJustifiable;

  CustomerRejectionPageWithJustification(this.isJustifiable);

  @override
  _CustomerRejectionPageWithJustificationState createState() => _CustomerRejectionPageWithJustificationState();
}

class _CustomerRejectionPageWithJustificationState extends State<CustomerRejectionPageWithJustification> {

  List<TrialRequests> allRequests = [];
  var isListVisible = false;
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _searchQuery;
  bool _isSearching = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  String searchQuery = "Search query";
  bool isColorsVisible=false;
  int pageNum=1,searchPageNum=1;
  List<TrialRequests> requests=[];
  var req;
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
       body: RefreshIndicator(
         key: _refreshIndicatorKey,
         onRefresh: (){
           return Utils.check_connectivity().then((isConnected){
             if(isConnected){
               SharedPreferences.getInstance().then((prefs) {
                 if(!_isSearching){
                   Network_Operations.getTrialRequestsWithJustification(
                       context, prefs.getString("token"),widget.isJustifiable, 10, pageNum).then((response) {
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
                     });
                   });
                 }else{
                   Network_Operations.getTrialRequestsWithJustificationSearchable(context, prefs.getString("token"),widget.isJustifiable, 10, searchPageNum,searchQuery).then((response) {
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
                 height: 175, //MediaQuery.of(context).size.height * 0.21,

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
                     ],
                   ),
                 ),

               ),
             );
           }),
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
            Network_Operations.getTrialRequestsWithJustificationSearchable(context,prefs.getString("token"),widget.isJustifiable,10,searchPageNum,query).then((response){
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
            const Text('All Requests'),
          ],
        ),
      ),
    );
  }
}
