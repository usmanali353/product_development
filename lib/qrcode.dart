import 'dart:typed_data';
import 'dart:ui';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateedQrcode extends StatefulWidget {
  var requestId;

  GenerateedQrcode(this.requestId);

  @override
  _GenerateedQR createState() => _GenerateedQR(requestId);
}

class _GenerateedQR extends State<GenerateedQrcode> {
  var requestId;
  GlobalKey globalKey = new GlobalKey();
  _GenerateedQR(this.requestId);
  final doc = pw.Document();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(title: Text("QR Code"),),
    body: Center(
     child: Column(
       mainAxisAlignment: MainAxisAlignment.center,
       children: <Widget>[
         RepaintBoundary(
           key: globalKey,
           child: QrImage(
             data: requestId.toString(),
             version: QrVersions.auto,
             size: 200.0,
           ),
         ),
         MaterialButton(
           color: Colors.teal,
           child: Text("Print",style: TextStyle(color: Colors.white),),
           onPressed: ()async{
             RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
             var image = await boundary.toImage();
             ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
             Uint8List pngBytes = byteData.buffer.asUint8List();
             final PdfImage img = await pdfImageFromImageProvider(pdf: doc.document, image: MemoryImage(pngBytes));
             doc.addPage(pw.Page(
                 build: (pw.Context context) {
                   return pw.Center(
                     child: pw.Image(img),
                   ); // Center
                 })); // Pa
             await Printing.layoutPdf(
                 onLayout: (PdfPageFormat format) async => doc.save());
           },

         )
       ],

     ),
   ),
    );
  }
}
