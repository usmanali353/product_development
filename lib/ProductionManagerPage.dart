import 'package:flutter/material.dart';

import 'ProductionManagerRequests.dart';
class ProductionManagerPage extends StatefulWidget {
  @override
  _ProductionManagerPageState createState() => _ProductionManagerPageState();
}

class _ProductionManagerPageState extends State<ProductionManagerPage> {
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
            ProductionManagerRequests(7),
            ProductionManagerRequests(9),
            ProductionManagerRequests(10),
          ],
        ),
      ),
    );
  }
}
