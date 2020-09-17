import 'package:flutter/material.dart';

import 'ProductionManagerRequests.dart';
class ProductionManagerPage extends StatefulWidget {
  var currentUserRole;

  ProductionManagerPage(this.currentUserRole);

  @override
  _ProductionManagerPageState createState() => _ProductionManagerPageState(currentUserRole);
}

class _ProductionManagerPageState extends State<ProductionManagerPage> {
  var currentUserRole;

  _ProductionManagerPageState(this.currentUserRole);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
            title:Text("Model Requests"),
            bottom: TabBar(
              tabs: <Widget>[
                Tab(text: "Customer Approved",),
                Tab(text: "Production Approved",),
                Tab(text: "Production Rejected",),
              ],
            ),
        ),
        body: TabBarView(
          children: [
            ProductionManagerRequests(7,null,currentUserRole),
            ProductionManagerRequests(9,null,currentUserRole),
            ProductionManagerRequests(10,null,currentUserRole),
          ],
        ),
      ),
    );
  }
}
