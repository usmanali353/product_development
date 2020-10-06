import 'package:flutter/material.dart';
import 'package:productdevelopment/Utils/Utils.dart';
class NotificationListPage extends StatefulWidget {
  @override
  _NotificationListPageState createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  bool isVisible=false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
      ),
      body: RefreshIndicator(
        onRefresh: (){
          return Utils.check_connectivity().then((isConnected){
            if(isConnected){

            }
          });
        },
        child: Visibility(
          visible: true,
          child: ListView.builder(
            itemCount: 2,
            itemBuilder: (context,int index){
               return Padding(
                 padding: EdgeInsets.all(8),
                 child: Card(
                   elevation: 10.0,
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(15),
                   ),
                   child: ListTile(
                     title: Text("Some Title"),
                     subtitle: Text("Some notification Body"),
                     leading: Icon(Icons.notifications,color: Color(0xFF004c4c),),
                     trailing: Icon(Icons.data_usage,color: Color(0xFF004c4c)),
                   ),
                 ),
               );
            },
          ),
        ),
      ),
    );
  }
}
