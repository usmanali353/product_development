import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CRMDashboard extends StatefulWidget {
  @override
  _CRMDashboardState createState() => _CRMDashboardState();
}

class _CRMDashboardState extends State<CRMDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard',),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Card(
                    elevation: 8,
                    child: Container(
                      height: MediaQuery.of(context).size.height / 5.8,
                      width: MediaQuery.of(context).size.width / 2.25,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height / 8.8,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.white,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(child: FaIcon(FontAwesomeIcons.clipboardList, color: Color(0xFF004c4c), size: 40,)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text('All Requests',
                                  style: TextStyle(
                                    color: Colors.black,
                                    //fontWeight: FontWeight.bold
                                  ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height / 17.1,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Color(0xFF004c4c),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(child: Text('123455.87899875.85',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),
                            )),
                          )
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 8,
                    child: Container(
                      height: MediaQuery.of(context).size.height / 5.8,
                      width: MediaQuery.of(context).size.width / 2.25,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height / 8.8,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.white,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(child: FaIcon(FontAwesomeIcons.commentDots, color: Color(0xFF004c4c), size: 40,)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text('New Requests',
                                    style: TextStyle(
                                      color: Colors.black,
                                      //fontWeight: FontWeight.bold
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height / 17.1,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Color(0xFF004c4c),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(child: Text('123455.87899875.85',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),
                            )),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Card(
                      elevation: 8,
                      child: Container(
                        height: MediaQuery.of(context).size.height / 5.8,
                        width: MediaQuery.of(context).size.width / 2.25,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height / 8.8,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(child: FaIcon(FontAwesomeIcons.calendarAlt, color: Color(0xFF004c4c), size: 40,)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text('Samples Scheduled',
                                      style: TextStyle(
                                        color: Colors.black,
                                        //fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height / 17.1,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Color(0xFF004c4c),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(child: Text('123455.87899875.85',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              )),
                            )
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 8,
                      child: Container(
                        height: MediaQuery.of(context).size.height / 5.8,
                        width: MediaQuery.of(context).size.width / 2.25,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height / 8.8,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(child: FaIcon(FontAwesomeIcons.bell, color: Color(0xFF004c4c), size: 40,)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text('Notifications',
                                      style: TextStyle(
                                        color: Colors.black,
                                        //fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height / 17.1,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Color(0xFF004c4c),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(child: Text('123455.87899875.85',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              )),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Card(
                      elevation: 8,
                      child: Container(
                        height: MediaQuery.of(context).size.height / 5.8,
                        width: MediaQuery.of(context).size.width / 2.25,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height / 8.8,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(child: FaIcon(FontAwesomeIcons.checkSquare, color: Colors.teal.shade700, size: 40,)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text('ACMC Approved',
                                      style: TextStyle(
                                        color: Colors.black,
                                        //fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height / 17.1,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Color(0xFF004c4c),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(child: Text('123455.87899875.85',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              )),
                            )
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 8,
                      child: Container(
                        height: MediaQuery.of(context).size.height / 5.8,
                        width: MediaQuery.of(context).size.width / 2.25,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height / 8.8,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(child: FaIcon(FontAwesomeIcons.windowClose, color: Colors.teal.shade700, size: 40,)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text('ACMC Rejected',
                                      style: TextStyle(
                                        color: Colors.black,
                                        //fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height / 17.1,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Color(0xff383838),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(child: Text('123455.87899875.85',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              )),
                            )
                          ],
                        ),
                      ),
                    ),
                    // Container(
                    //   height: MediaQuery.of(context).size.height / 5.8,
                    //   width: MediaQuery.of(context).size.width / 2,
                    //   color: Colors.green,
                    // ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Card(
                      elevation: 8,
                      child: Container(
                        height: MediaQuery.of(context).size.height / 5.8,
                        width: MediaQuery.of(context).size.width / 2.25,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height / 8.8,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(child: FaIcon(FontAwesomeIcons.check, color: Color(0xFF004c4c), size: 40,)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text('Approved Models',
                                      style: TextStyle(
                                        color: Colors.black,
                                        //fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height / 17.1,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Color(0xFF004c4c),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(child: Text('123455.87899875.85',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              )),
                            )
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 8,
                      child: Container(
                        height: MediaQuery.of(context).size.height / 5.8,
                        width: MediaQuery.of(context).size.width / 2.25,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height / 8.8,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(child: FaIcon(FontAwesomeIcons.times, color: Colors.teal.shade700, size: 40,)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text('Rejected Models',
                                      style: TextStyle(
                                        color: Colors.black,
                                        //fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height / 17.1,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Color(0xff383838),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(child: Text('123455.87899875.85',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              )),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Card(
                      elevation: 8,
                      child: Container(
                        height: MediaQuery.of(context).size.height / 5.8,
                        width: MediaQuery.of(context).size.width / 2.25,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height / 8.8,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(child: FaIcon(FontAwesomeIcons.checkCircle, color: Color(0xFF004c4c), size: 40,)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text('Customer Approved',
                                      style: TextStyle(
                                        color: Colors.black,
                                        //fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height / 17.1,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Color(0xFF004c4c),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(child: Text('123455.87899875.85',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              )),
                            )
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 8,
                      child: Container(
                        height: MediaQuery.of(context).size.height / 5.8,
                        width: MediaQuery.of(context).size.width / 2.25,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height / 8.8,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(child: FaIcon(FontAwesomeIcons.timesCircle, color: Colors.teal.shade700, size: 40,)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text('Customer Rejected',
                                      style: TextStyle(
                                        color: Colors.black,
                                        //fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height / 17.1,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Color(0xff383838),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(child: Text('123455.87899875.85',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              )),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Card(
                      elevation: 8,
                      child: Container(
                        height: MediaQuery.of(context).size.height / 5.8,
                        width: MediaQuery.of(context).size.width / 2.25,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height / 8.8,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(child: FaIcon(FontAwesomeIcons.fileExcel, color: Color(0xFF004c4c), size: 40,)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text('Justified Rejection',
                                      style: TextStyle(
                                        color: Colors.black,
                                        //fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height / 17.1,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Color(0xFF004c4c),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(child: Text('123455.87899875.85',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              )),
                            )
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 8,
                      child: Container(
                        height: MediaQuery.of(context).size.height / 5.8,
                        width: MediaQuery.of(context).size.width / 2.25,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height / 8.8,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(child: FaIcon(FontAwesomeIcons.solidFileExcel, color: Colors.teal.shade700, size: 40,)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text('Unjustified Rejection',
                                      style: TextStyle(
                                        color: Colors.black,
                                        //fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height / 17.1,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Color(0xff383838),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(child: Text('123455.87899875.85',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              )),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Card(
                      elevation: 8,
                      child: Container(
                        height: MediaQuery.of(context).size.height / 5.8,
                        width: MediaQuery.of(context).size.width / 2.25,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height / 8.8,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(child: FaIcon(FontAwesomeIcons.solidCheckSquare, color: Color(0xFF004c4c), size: 40,)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text('Production Approved',
                                      style: TextStyle(
                                        color: Colors.black,
                                        //fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height / 17.1,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Color(0xFF004c4c),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(child: Text('123455.87899875.85',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              )),
                            )
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 8,
                      child: Container(
                        height: MediaQuery.of(context).size.height / 5.8,
                        width: MediaQuery.of(context).size.width / 2.25,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height / 8.8,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(child: FaIcon(FontAwesomeIcons.solidWindowClose, color: Colors.teal.shade700, size: 40,)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text('Production Rejected',
                                      style: TextStyle(
                                        color: Colors.black,
                                        //fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height / 17.1,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Color(0xff383838),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(child: Text('123455.87899875.85',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              )),
                            )
                          ],
                        ),
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
  }
}
