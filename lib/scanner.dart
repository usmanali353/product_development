import 'package:barcode_scan/model/model.dart';
import 'package:barcode_scan/platform_wrapper.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QRScanner extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _QRScanner_State();
  }

}

class _QRScanner_State extends State<QRScanner>{
  ScanResult barcode;
  @override
  void initState() {
    super.initState();
    scan();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF004c4c),
        title: Text("Barcode Scanner", style: TextStyle(
            color: Colors.white,
        ),),
      ),
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
             Text(barcode!=null?barcode.rawContent:'No Barcode Found')
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          scan();
        },
        child: Icon(Icons.camera_enhance),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  Future scan() async {

    try {
      barcode = (await BarcodeScanner.scan());
      print('Barcode '+barcode.rawContent);
      setState(() {
        this.barcode = barcode;
        if(barcode.rawContent!=null){

        }

      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
       Flushbar(
         message: "Camera Access not Granted",
         backgroundColor: Colors.red,
         duration: Duration(seconds: 5),
       ).show(context);
      } else {
        Flushbar(
          message: e.toString(),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ).show(context);
       // setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException{
      Flushbar(
        message: "User returned using the back-button before scanning anything",
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ).show(context);
      //setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      Flushbar(
        message: e,
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ).show(context);
     // setState(() => this.barcode = 'Unknown error: $e');
    }
    return barcode;
  }
}