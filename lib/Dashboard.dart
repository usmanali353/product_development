import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:need_resume/need_resume.dart';
import 'package:productdevelopment/Login.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/scanner.dart';
import 'package:productdevelopment/trialRequests.dart';
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
  List<Request> newRequest=[],rejectedbyCustomer=[],rejectedbyGM=[],rejectedTrial=[],sampleScheduled=[],approvedForTrial=[],customerApproved=[],approvebyGM=[];
 var claims;
  @override
  void onResume() {
    if(resume.data.toString()=="Refresh"){
      SharedPreferences.getInstance().then((prefs){
        print(prefs.getString("token"));
        newRequest.clear();rejectedbyCustomer.clear();rejectedbyGM.clear();rejectedTrial.clear();sampleScheduled.clear();approvedForTrial.clear();customerApproved.clear();approvebyGM.clear();
         claims = Utils.parseJwt(prefs.getString("token"));
        if(claims["role"]=="General Manager"){
          Network_Operations.getRequestForGM(context, prefs.getString("token")).then((result){
            debugPrint(result.toString());
            for(int i=0; i<result.length;i++ ) {
              if (result[i].statusName =="New Request"){
                setState(() {
                  newRequest.add(result[i]);
                });
              }
              if (result[i].statusName =="Approved By GM"){
                setState(() {
                  approvebyGM.add(result[i]);
                });
              }
              if (result[i].statusName =="Approved By Customer"){
                setState(() {
                  customerApproved.add(result[i]);
                });
              }
              if (result[i].statusName =="Approved Trial"){
                setState(() {
                  approvedForTrial.add(result[i]);
                });
              }
              if (result[i].statusName =="Rejected By Customer"){
                setState(() {
                  rejectedbyCustomer.add(result[i]);
                });
              }
              if (result[i].statusName =="Rejected By GM"){
                setState(() {
                  rejectedbyGM.add(result[i]);
                });
              }
              if (result[i].statusName =="Rejected Trial"){
                setState(() {
                  rejectedTrial.add(result[i]);
                });
              }
              if (result[i].statusName =="Samples Scheduled"){
                setState(() {
                  sampleScheduled.add(result[i]);
                });
              }
            }
          });
        }else if(claims["role"]=="Sales Manager"){
          Network_Operations.getRequestByStatus(context, prefs.getString("token"),2).then((result){
            debugPrint(result.toString());
            for(int i=0; i<result.length;i++ ) {
              if (result[i].statusName =="New Request"){
                setState(() {
                  newRequest.add(result[i]);
                });
              }
              if (result[i].statusName =="Approved By GM"){
                setState(() {
                  approvebyGM.add(result[i]);
                });
              }
              if (result[i].statusName =="Approved By Customer"){
                setState(() {
                  customerApproved.add(result[i]);
                });
              }
              if (result[i].statusName =="Approved Trial"){
                setState(() {
                  approvedForTrial.add(result[i]);
                });
              }
              if (result[i].statusName =="Rejected By Customer"){
                setState(() {
                  rejectedbyCustomer.add(result[i]);
                });
              }
              if (result[i].statusName =="Rejected By GM"){
                setState(() {
                  rejectedbyGM.add(result[i]);
                });
              }
              if (result[i].statusName =="Rejected Trial"){
                setState(() {
                  rejectedTrial.add(result[i]);
                });
              }
              if (result[i].statusName =="Samples Scheduled"){
                setState(() {
                  sampleScheduled.add(result[i]);
                });
              }
            }
          });
        }else{
          Network_Operations.getRequest(context, prefs.getString("token")).then((result){
            debugPrint(result.toString());
            for(int i=0; i<result.length;i++ ) {
              if (result[i].statusName =="New Request"){
                setState(() {
                  newRequest.add(result[i]);
                });
              }
              if (result[i].statusName =="Approved By GM"){
                setState(() {
                  approvebyGM.add(result[i]);
                });
              }
              if (result[i].statusName =="Approved By Customer"){
                setState(() {
                  customerApproved.add(result[i]);
                });
              }
              if (result[i].statusName =="Approved Trial"){
                setState(() {
                  approvedForTrial.add(result[i]);
                });
              }
              if (result[i].statusName =="Rejected By Customer"){
                setState(() {
                  rejectedbyCustomer.add(result[i]);
                });
              }
              if (result[i].statusName =="Rejected By GM"){
                setState(() {
                  rejectedbyGM.add(result[i]);
                });
              }
              if (result[i].statusName =="Rejected Trial"){
                setState(() {
                  rejectedTrial.add(result[i]);
                });
              }
              if (result[i].statusName =="Samples Scheduled"){
                setState(() {
                  sampleScheduled.add(result[i]);
                });
              }
            }
          });
        }
      });
    }

    super.onResume();
  }
  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs){
       claims = Utils.parseJwt(prefs.getString("token"));
      if(claims["role"]=="General Manager"){
        Network_Operations.getRequestForGM(context, prefs.getString("token")).then((result){
          debugPrint(result.toString());
          for(int i=0; i<result.length;i++ ) {
            if (result[i].statusName =="New Request"){
              setState(() {
                newRequest.add(result[i]);
              });
            }
            if (result[i].statusName =="Approved By GM"){
              setState(() {
                approvebyGM.add(result[i]);
              });
            }
            if (result[i].statusName =="Approved By Customer"){
              setState(() {
                customerApproved.add(result[i]);
              });
            }
            if (result[i].statusName =="Approved Trial"){
              setState(() {
                approvedForTrial.add(result[i]);
              });
            }
            if (result[i].statusName =="Rejected By Customer"){
              setState(() {
                rejectedbyCustomer.add(result[i]);
              });
            }
            if (result[i].statusName =="Rejected By GM"){
              setState(() {
                rejectedbyGM.add(result[i]);
              });
            }
            if (result[i].statusName =="Rejected Trial"){
              setState(() {
                rejectedTrial.add(result[i]);
              });
            }
            if (result[i].statusName =="Samples Scheduled"){
              setState(() {
                sampleScheduled.add(result[i]);
              });
            }
          }
        });
      }else if(claims["role"]=="Sales Manager"){
        Network_Operations.getRequestByStatus(context, prefs.getString("token"),2).then((result){
          debugPrint(result.toString());
          for(int i=0; i<result.length;i++ ) {
            if (result[i].statusName =="New Request"){
              setState(() {
                newRequest.add(result[i]);
              });
            }
            if (result[i].statusName =="Approved By GM"){
              setState(() {
                approvebyGM.add(result[i]);
              });
            }
            if (result[i].statusName =="Approved By Customer"){
              setState(() {
                customerApproved.add(result[i]);
              });
            }
            if (result[i].statusName =="Approved Trial"){
              setState(() {
                approvedForTrial.add(result[i]);
              });
            }
            if (result[i].statusName =="Rejected By Customer"){
              setState(() {
                rejectedbyCustomer.add(result[i]);
              });
            }
            if (result[i].statusName =="Rejected By GM"){
              setState(() {
                rejectedbyGM.add(result[i]);
              });
            }
            if (result[i].statusName =="Rejected Trial"){
              setState(() {
                rejectedTrial.add(result[i]);
              });
            }
            if (result[i].statusName =="Samples Scheduled"){
              setState(() {
                sampleScheduled.add(result[i]);
              });
            }
          }
        });
      }else{
        Network_Operations.getRequest(context, prefs.getString("token")).then((result){
          debugPrint(result.toString());
          for(int i=0; i<result.length;i++ ) {
            if (result[i].statusName =="New Request"){
              setState(() {
                newRequest.add(result[i]);
              });
            }
            if (result[i].statusName =="Approved By GM"){
              setState(() {
                approvebyGM.add(result[i]);
              });
            }
            if (result[i].statusName =="Approved By Customer"){
              setState(() {
                customerApproved.add(result[i]);
              });
            }
            if (result[i].statusName =="Approved Trial"){
              setState(() {
                approvedForTrial.add(result[i]);
              });
            }
            if (result[i].statusName =="Rejected By Customer"){
              setState(() {
                rejectedbyCustomer.add(result[i]);
              });
            }
            if (result[i].statusName =="Rejected By GM"){
              setState(() {
                rejectedbyGM.add(result[i]);
              });
            }
            if (result[i].statusName =="Rejected Trial"){
              setState(() {
                rejectedTrial.add(result[i]);
              });
            }
            if (result[i].statusName =="Samples Scheduled"){
              setState(() {
                sampleScheduled.add(result[i]);
              });
            }
          }
        });
      }



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
       claims!=null&&claims["role"]=="Client"?Column(
          children: [
            ListTile(
              title: Text("Trial Products"),
              leading: Icon(FontAwesomeIcons.balanceScale),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>TrialRequests()));
              },
            ),
            Divider(),
          ],
        ):Container(),
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
                  push(context, MaterialPageRoute(builder: (context)=>ModelRequests(newRequest)));
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
                              child: Text(newRequest!=null?newRequest.length.toString():'0', style: TextStyle(color:Color(0xFF004c4c),
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
                  push(context, MaterialPageRoute(builder: (context)=>ModelRequests(approvebyGM)));
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
                              child: Text(approvebyGM!=null?approvebyGM.length.toString():'0',
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
             push(context, MaterialPageRoute(builder: (context)=>ModelRequests(rejectedbyGM)));
             // Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestList(null,null,customerId)));
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
                          child: Text(rejectedbyGM!=null?rejectedbyGM.length.toString():'0',
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
                  push(context, MaterialPageRoute(builder: (context)=>ModelRequests(sampleScheduled)));
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>DeliveryList((DateFormat("yyyy-MM-dd").format(DateTime.now())),customerId)));
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
                              child: Text(sampleScheduled!=null?sampleScheduled.length.toString():'0', style: TextStyle(color:Color(0xFF004c4c),
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
                 push(context, MaterialPageRoute(builder: (context)=>ModelRequests(approvedForTrial)));
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>SalesOrdersList(DateFormat("yyyy-MM-dd").format(DateTime.now()),DateFormat("yyyy-MM-dd").format(DateTime.now().add(Duration(days: 30))),customerId,DateFormat.MMMM().format(DateTime.now()).toString()+' Deliveries')));
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
                              child: Text(approvedForTrial!=null?approvedForTrial.length.toString():'0',
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
             push(context, MaterialPageRoute(builder: (context)=>ModelRequests(rejectedTrial)));
              // Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestList(null,null,customerId)));
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
                          child: Text(rejectedTrial!=null?rejectedTrial.length.toString():'0',
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
                 push(context, MaterialPageRoute(builder: (context)=>ModelRequests(customerApproved)));
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>DeliveryList((DateFormat("yyyy-MM-dd").format(DateTime.now())),customerId)));
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
                              child: Text(customerApproved!=null?customerApproved.length.toString():'0', style: TextStyle(color:Color(0xFF004c4c),
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
                  push(context, MaterialPageRoute(builder: (context)=>ModelRequests(rejectedbyCustomer)));
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>SalesOrdersList(DateFormat("yyyy-MM-dd").format(DateTime.now()),DateFormat("yyyy-MM-dd").format(DateTime.now().add(Duration(days: 30))),customerId,DateFormat.MMMM().format(DateTime.now()).toString()+' Deliveries')));
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
                              child: Text(rejectedbyCustomer!=null?rejectedbyCustomer.length.toString():'0',
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
