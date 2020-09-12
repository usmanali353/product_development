import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:need_resume/need_resume.dart';
import 'package:productdevelopment/Login.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ModelRequests.dart';
import 'Network_Operations/Network_Operations.dart';
import 'Utils/Utils.dart';
import 'request_Model_form/Assumptions.dart';
class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends ResumableState<Dashboard> {
 var claims;
 var requestCount;
 @override
  void onResume() {
   SharedPreferences.getInstance().then((prefs){
     setState(() {
       claims=Utils.parseJwt(prefs.getString("token"));
       if(claims['role'].contains("General Manager")) {
         Network_Operations.getRequestCount(context, prefs.getString("token")).then((requestCountMap){
           setState(() {
             this.requestCount=requestCountMap['statuses'];
           });
         });
       }else{
         Network_Operations.getRequestCountIndividualUser(context,prefs.getString("token")).then((requestCountMap){
           setState(() {
             this.requestCount=requestCountMap['statuses'];
           });
         });
       }
     });

   });
    super.onResume();
  }
 @override
  void initState() {
    SharedPreferences.getInstance().then((prefs){
      setState(() {
        claims=Utils.parseJwt(prefs.getString("token"));
        if(claims['role'].contains("General Manager")) {
          Network_Operations.getRequestCount(context, prefs.getString("token")).then((requestCountMap){
            setState(() {
              this.requestCount=requestCountMap['statuses'];
            });
          });
        }else{
          Network_Operations.getRequestCountIndividualUser(context,prefs.getString("token")).then((requestCountMap){
            setState(() {
              this.requestCount=requestCountMap['statuses'];
            });
          });
        }
      });

    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Container(
              color: Color(0xEBECF0),
              alignment: Alignment.topCenter,
              child: DrawerHeader(
                child:  Image.asset("Assets/img/AC.png",width: 200,height: 200,),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                   ListTile(
                     title: Text("Add Model Request"),
                     leading: Icon(Icons.add),
                     onTap: (){
                       Navigator.push(context,MaterialPageRoute(builder: (context)=>Assumptions()));
                     },
                   ),
                  Divider(),
                  ListTile(
                    title: Text("Scan Barcode"),
                    leading: Icon(FontAwesomeIcons.barcode),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>QRScanner()));
                    },
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Sign Out"),
                    leading: Icon(FontAwesomeIcons.signOutAlt),
                    onTap: (){
                     SharedPreferences.getInstance().then((prefs){
                       prefs.remove("token");
                       Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=>Login()),(Route<dynamic> route) => false);
                     });
                    },
                  ),

                ],
              ),
            )
          ],
        ),
      ),
      appBar: AppBar(title: Text("Dashboard"),),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top:16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(margin: EdgeInsets.only(left: 17),
                    child: Text("Model Requests", style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),)
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 15),
          ),
          //Delivery Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              InkWell(
                onTap:(){
                  push(context, MaterialPageRoute(builder: (context)=>ModelRequests(1)));
                },
                child: Card(
                  elevation: 10,
                  child: Container(
                    height: 130,
                    //width: 185,
                    width: MediaQuery.of(context).size.width * 0.45 ,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Color(0xFF004c4c),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          //margin: EdgeInsets.only(left: 12),
                          child: Text("Requested",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 5, right: 5),
                          height: 30,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey.shade100,
                          ),
                          child: Center(
                            child: Container(
                              //margin: EdgeInsets.only(left: 10,top: 5),
                              child: Text(requestCount!=null&&requestCount['New Request']!=null?requestCount['New Request'].toString():"0", style: TextStyle(color:Color(0xFF004c4c),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold
                              ),

                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Weekly Deliveries
              InkWell(
                onTap: (){
                  push(context, MaterialPageRoute(builder: (context)=>ModelRequests(2)));
                },
                child: Card(
                  elevation: 10,
                  child: Container(
                    height: 130,
                    width: MediaQuery.of(context).size.width * 0.45 ,
                    //width: MediaQuery.of(context).size.width /2.2 ,
                    //width: 185,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color(0xFF004c4c),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          //margin: EdgeInsets.only(left: 12),
                          child: Text('ACMC Approved',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        Container(
                          //padding: EdgeInsets.all(3),
                          margin: EdgeInsets.only(left: 5, right: 5),

                          height: 30,
                          width: 145,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey.shade100,
                          ),
                          child: Center(
                            child: Container(
                              //margin: EdgeInsets.only(left: 10,top: 5),
                              child: Text(requestCount!=null&&requestCount['Approved By GM']!=null?requestCount['Approved By GM'].toString():"0",
                                style: TextStyle(
                                    color:Colors.teal.shade800,
                                    //Color(0xFF004c4c),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),

                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.0),
          ),
          InkWell(
            onTap: (){
             push(context, MaterialPageRoute(builder: (context)=>ModelRequests(3)));
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0,right:8.0),
              child: Card(
                elevation: 10,
                child: Container(
                  // margin: EdgeInsets.only(left: 12.5,right: 12.5),
                  height: 130,
                  width: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 12),
                        child: Text("ACMC Rejected",
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      Container(
                        //margin: EdgeInsets.only(left: 10, top: 5,bottom: 5),
                        height: 30,
                        width: MediaQuery.of(context).size.width *0.35,
                        //width: 145,
                        decoration: BoxDecoration(

                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomLeft: Radius.circular(15)
                          ),
                          color: Color(0xFF004c4c),
                        ),
                        child: Container(margin: EdgeInsets.only(left: 10,top: 5),
                          child: Text(requestCount!=null&&requestCount['Rejected By GM']!=null?requestCount['Rejected By GM'].toString():"0",
                            style: TextStyle(
                                color:Colors.white,
                                //Color(0xFF004c4c),
                                fontSize: 15,
                                fontWeight: FontWeight.bold
                            ),

                          ),
                        ),
                      ),
                    ],
                  ),

                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 15),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              //Today Deliveries
              InkWell(
                onTap:(){
                  push(context, MaterialPageRoute(builder: (context)=>ModelRequests(4)));
                },
                child: Card(
                  elevation: 10,
                  child: Container(
                    height: 130,
                    //width: 185,
                    width: MediaQuery.of(context).size.width * 0.45 ,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color(0xFF004c4c),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          //margin: EdgeInsets.only(left: 12),
                          child: Text("Samples Scheduled",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 5, right: 5),
                          height: 30,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey.shade100,
                          ),
                          child: Center(
                            child: Container(
                              //margin: EdgeInsets.only(left: 10,top: 5),
                              child: Text(requestCount!=null&&requestCount['Samples Scheduled']!=null?requestCount['Samples Scheduled'].toString():"0", style: TextStyle(color:Color(0xFF004c4c),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold
                              ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Weekly Deliveries
              InkWell(
                onTap: (){
                 push(context, MaterialPageRoute(builder: (context)=>ModelRequests(5)));
                },
                child: Card(
                  elevation: 10,
                  child: Container(
                    height: 130,
                    width: MediaQuery.of(context).size.width * 0.45 ,
                    //width: MediaQuery.of(context).size.width /2.2 ,
                    //width: 185,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color(0xFF004c4c),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          //margin: EdgeInsets.only(left: 12),
                          child: Text('Approved for Trial',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        Container(
                          //padding: EdgeInsets.all(3),
                          margin: EdgeInsets.only(left: 5, right: 5),
                          height: 30,
                          width: 145,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey.shade100,
                          ),
                          child: Center(
                            child: Container(
                              //margin: EdgeInsets.only(left: 10,top: 5),
                              child: Text(requestCount!=null&&requestCount['Approved Trial']!=null?requestCount['Approved Trial'].toString():"0",
                                style: TextStyle(
                                    color:Colors.teal.shade800,
                                    //Color(0xFF004c4c),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.0),
          ),
          InkWell(
            onTap: (){
            push(context, MaterialPageRoute(builder: (context)=>ModelRequests(6)));
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0,right:8.0),
              child: Card(
                elevation: 10,
                child: Container(
                  // margin: EdgeInsets.only(left: 12.5,right: 12.5),
                  height: 130,
                  width: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 12),
                        child: Text("Rejected for Trial",
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      Container(
                        //margin: EdgeInsets.only(left: 10, top: 5,bottom: 5),
                        height: 30,
                        width: MediaQuery.of(context).size.width *0.35,
                        //width: 145,
                        decoration: BoxDecoration(

                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomLeft: Radius.circular(15)
                          ),
                          color: Color(0xFF004c4c),
                        ),
                        child: Container(margin: EdgeInsets.only(left: 10,top: 5),
                          child: Text(requestCount!=null&&requestCount['Rejected Trial']!=null?requestCount['Rejected Trial'].toString():"0",
                            style: TextStyle(
                                color:Colors.white,
                                //Color(0xFF004c4c),
                                fontSize: 15,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 15),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              //Today Deliveries
              InkWell(
                onTap:(){
                 push(context, MaterialPageRoute(builder: (context)=>ModelRequests(7)));
                },
                child: Card(
                  elevation: 10,
                  child: Container(
                    height: 130,
                    //width: 185,
                    width: MediaQuery.of(context).size.width * 0.45 ,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color(0xFF004c4c),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          //margin: EdgeInsets.only(left: 12),
                          child: Text("Customer Approved",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 5, right: 5),
                          height: 30,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey.shade100,
                          ),
                          child: Center(
                            child: Container(
                              //margin: EdgeInsets.only(left: 10,top: 5),
                              child: Text(requestCount!=null&&requestCount['Approved By Customer']!=null?requestCount['Approved By Customer'].toString():"0", style: TextStyle(color:Color(0xFF004c4c),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold
                              ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Weekly Deliveries
              InkWell(
                onTap: (){
                  push(context, MaterialPageRoute(builder: (context)=>ModelRequests(8)));
                },
                child: Card(
                  elevation: 10,
                  child: Container(
                    height: 130,
                    width: MediaQuery.of(context).size.width * 0.45 ,
                    //width: MediaQuery.of(context).size.width /2.2 ,
                    //width: 185,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color(0xFF004c4c),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          //margin: EdgeInsets.only(left: 12),
                          child: Text('Customer Rejected',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        Container(
                          //padding: EdgeInsets.all(3),
                          margin: EdgeInsets.only(left: 5, right: 5),
                          height: 30,
                          width: 145,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey.shade100,
                          ),
                          child: Center(
                            child: Container(
                              //margin: EdgeInsets.only(left: 10,top: 5),
                              child: Text(requestCount!=null&&requestCount['Rejected By Customer']!=null?requestCount['Rejected By Customer'].toString():"0",
                                style: TextStyle(
                                    color:Colors.teal.shade800,
                                    //Color(0xFF004c4c),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 15),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              //Today Deliveries
              InkWell(
                onTap:(){
                  push(context, MaterialPageRoute(builder: (context)=>ModelRequests(9)));
                },
                child: Card(
                  elevation: 10,
                  child: Container(
                    height: 130,
                    //width: 185,
                    width: MediaQuery.of(context).size.width * 0.45 ,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color(0xFF004c4c),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          //margin: EdgeInsets.only(left: 12),
                          child: Text("Production Approved",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 5, right: 5),
                          height: 30,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey.shade100,
                          ),
                          child: Center(
                            child: Container(
                              //margin: EdgeInsets.only(left: 10,top: 5),
                              child: Text(requestCount!=null&&requestCount['Approved For Production']!=null?requestCount['Approved For Production'].toString():"0", style: TextStyle(color:Color(0xFF004c4c),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold
                              ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Weekly Deliveries
              InkWell(
                onTap: (){
                 push(context, MaterialPageRoute(builder: (context)=>ModelRequests(10)));
                },
                child: Card(
                  elevation: 10,
                  child: Container(
                    height: 130,
                    width: MediaQuery.of(context).size.width * 0.45 ,
                    //width: MediaQuery.of(context).size.width /2.2 ,
                    //width: 185,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color(0xFF004c4c),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          //margin: EdgeInsets.only(left: 12),
                          child: Text('Production Rejected',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        Container(
                          //padding: EdgeInsets.all(3),
                          margin: EdgeInsets.only(left: 5, right: 5),
                          height: 30,
                          width: 145,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey.shade100,
                          ),
                          child: Center(
                            child: Container(
                              //margin: EdgeInsets.only(left: 10,top: 5),
                              child: Text(requestCount!=null&&requestCount['Rejected For Production']!=null?requestCount['Rejected For Production'].toString():"0",
                                style: TextStyle(
                                    color:Colors.teal.shade800,
                                    //Color(0xFF004c4c),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
}
