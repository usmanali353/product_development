import 'dart:typed_data';
import 'dart:ui';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/Utils/Utils.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'RequestImagesGallery.dart';

class DetailPage extends StatefulWidget {
 Request request;
 DetailPage(this.request);

  @override
  _DetailPageState createState() => _DetailPageState(request);
}

class _DetailPageState extends State<DetailPage>{
   Request request;
  _DetailPageState(this.request);
   GlobalKey globalKey = new GlobalKey();
   final doc = pw.Document();
   List<String> colorsNames=[];
   List<String> imageUrl=[];
  @override
  void initState() {
   for(int i=0;i<request.multipleColorNames.length;i++) {
     setState(() {
       colorsNames.add(request.multipleColorNames[i].colorName);
     });
   }
   setState(() {
     for(int i=0;i<request.multipleImages.length;i++){
       if(request.multipleImages[i]!=null){
         imageUrl.add(request.multipleImages[i]);
       }
     }
   });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Request Details"),
        ),
        body: Stack(
          children: <Widget>[
            InkWell(
              onTap: (){
                if(imageUrl.length>0) {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => RequestImageGallery(request)));
                }
              },
              child: Container(
                //color: Color(0xFF004c4c),
                height: MediaQuery.of(context).size.height/3,
                width: MediaQuery.of(context).size.width,
               decoration: BoxDecoration(
                 image: DecorationImage(
                   image: NetworkImage(request.image!=null?request.image:"https://cidco-smartcity.niua.org/wp-content/uploads/2017/08/No-image-found.jpg"),
                   fit: BoxFit.cover,
                 )
               ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 150, bottom: 10),
              child: Center(
                child: new Container(
                  child: new Card(
                    elevation: 6.0,
                    margin: EdgeInsets.only(right: 15.0, left: 15.0),
                      child: Scrollbar(
                        child: ListView(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top:10,bottom: 4),
                              child: Center(
                                child: Text("Request Details", style:
                                TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20
                                ),),
                              ),

                            ),
                            ListTile(
                              title: Text("Request Date",style: TextStyle(fontWeight: FontWeight.bold),),
                              subtitle: Text(DateFormat("yyyy-MM-dd").format(DateTime.parse(request.date))??''),
                            ),
                            Divider(),
                            ListTile(
                              title: Text("Technical Considerations",style: TextStyle(fontWeight: FontWeight.bold),),
                              subtitle: Text(request.technicalConcentration),
                            ),
                            Divider(),
                            ListTile(
                              title: Text("Request Status",style: TextStyle(fontWeight: FontWeight.bold),),
                              subtitle: Text(request.statusName),
                            ),
                            Divider(),
                            request.customerObservation!=null?Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text("Customer Observation",style: TextStyle(fontWeight: FontWeight.bold),),
                                  subtitle: Text(request.customerObservation),
                                ),
                                Divider(),
                              ],
                            ):Container(),
                            request.multipleDesignerNames!=null&&request.designerObservation!=null?Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text("Designers",style: TextStyle(fontWeight: FontWeight.bold),),
                                  subtitle: Text(request.multipleDesignerNames.toString().replaceAll("[", "").replaceAll("]", "")),
                                ),
                                Divider(),
                                ListTile(
                                  title: Text("Designers Observations",style: TextStyle(fontWeight: FontWeight.bold),),
                                  subtitle: Text(request.designerObservation),
                                ),
                                Divider(),
                              ],
                            ):Container(),
                            request.targetStartDate!=null?Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text("Target Start Date",style: TextStyle(fontWeight: FontWeight.bold),),
                                  subtitle: Text(DateFormat("yyyy-MM-dd").format(DateTime.parse(request.targetStartDate))),
                                ),
                                Divider(),
                              ],
                            ):Container(),
                            request.targetEndDate!=null?Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text("Target End Date",style: TextStyle(fontWeight: FontWeight.bold),),
                                  subtitle: Text(DateFormat("yyyy-MM-dd").format(DateTime.parse(request.targetEndDate))),
                                ),
                                Divider(),
                              ],
                            ):Container(),
                            request.actualStartDate!=null?Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text("Actual Start Date",style: TextStyle(fontWeight: FontWeight.bold),),
                                  subtitle: Text(DateFormat("yyyy-MM-dd").format(DateTime.parse(request.actualStartDate))),
                                ),
                                Divider(),
                              ],
                            ):Container(),
                            request.actualEndDate!=null?Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text("Actual End Date",style: TextStyle(fontWeight: FontWeight.bold),),
                                  subtitle: Text(DateFormat("yyyy-MM-dd").format(DateTime.parse(request.actualEndDate))),
                                ),
                                Divider(),
                              ],
                            ):Container(),
                            request.multipleClientNames!=null?Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text("Clients",style: TextStyle(fontWeight: FontWeight.bold),),
                                  subtitle: Text(request.multipleClientNames.toString().replaceAll("[", "").replaceAll("]", "")),
                                ),
                                Divider(),
                              ],
                            ):Container(),
                            Padding(
                              padding: EdgeInsets.only(top: 4, bottom: 4),
                            ),
                            Center(child: Text("Item Specifications",
                              style:
//                              GoogleFonts.courgette(
//                              textStyle: TextStyle(color: Colors.black, fontSize: 25),
//                            ),
                            TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                            ),
                            ),
                            ),
                           Padding(
                             padding: EdgeInsets.only(top: 4, bottom: 4),
                           ),
                           request.modelName!=null?Column(
                             children: <Widget>[
                               ListTile(
                                 title: Text("Model Name",style: TextStyle(fontWeight: FontWeight.bold),),
                                 subtitle: Text(request.modelName),
                               ),
                               Divider(),
                             ],
                           ):Container(),
                            request.modelCode!=null?Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text("Model Code",style: TextStyle(fontWeight: FontWeight.bold),),
                                  subtitle: Text(request.modelCode!=null?request.modelCode:''),
                                ),
                                Divider(),
                              ],
                            ):Container(),
                           ListTile(
                              title: Text("Surface", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                              ),),
                             subtitle: Text(request.surfaceName),
                            ),
                            Divider(),
                            ListTile(
                              title: Text("Thickness", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                              ),),
                              subtitle: Text(request.thickness.toString()),
                            ),
                            Divider(),
                            ListTile(
                              title: Text("Size", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                              ),),
                              subtitle: Text(request.multipleSizeNames.toString().replaceAll("[", "").replaceAll("]", "").replaceAll(".00", "")),
                            ),
                            Divider(),
                            request.rangeImage!=null?Column(

                              children: [
                                ListTile(
                                    title: Text("Range", style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),),
                                    subtitle: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.network(request.rangeImage,width: 100,height: 100,),
                                        ),
                                        Text(request.rangeName),
                                      ],
                                    )
                                ),
                                Divider(),
                              ],
                            ):Container(),
                            ListTile(
                              title: Text("Material", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                              ),),
                              subtitle: Text(request.multipleDesignTopoligyNames.toString().replaceAll("[", "").replaceAll("]", "")),
                            ),
                            Divider(),
                            ListTile(
                                title: Text("Color", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),),
                                subtitle: Text(colorsNames.toString().replaceAll("[","").replaceAll("]", ""))
                            ),
                            Divider(),
                            ListTile(
                              title: Text("Images", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                              ),),
                              subtitle: Wrap(
                                children: [
                                  for ( var images in request.multipleImages) images!=null?Image.network(images,width: 100,height: 100):Container(),
                                ],
                              )
                            ),
                            Divider(),
                            ListTile(
                              title: Text("Technology", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                              ),),
                              subtitle: Text(request.technologyName),
                            ),
                            Divider(),
                            ListTile(
                              title: Text("Structure", style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                              subtitle: Text(request.structureName),
                            ),
                            Divider(),
                            ListTile(
                              title: Text("Edge", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                              ),),
                              subtitle: Text(request.edgeName),
                            ),
                            Divider(),
                            ListTile(
                              title: Text("Classification", style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),),
                              subtitle: Text(request.classificationName),
                            ),
                            Divider(),
                            ListTile(
                              title: Text("Suitability", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                              ),),
                              subtitle: Text(request.multipleSuitabilityNames.toString().replaceAll("[", "").replaceAll("]", "")),
                            ),
                            Divider(),
                            request.statusName=='Approved By Customer'||request.statusName=='Approved Trial'||request.statusName=='Rejected By Customer'||request.statusName=="Rejected Trial"&&request.qrcodeImage!=null?Column(
                              children: [
                                ListTile(
                                  title: Text("Qr Code", style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),),
                                  subtitle:Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children:[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: RepaintBoundary(
                                          key: globalKey,
                                            child: Image.network(request.qrcodeImage!=null?request.qrcodeImage:"https://cidco-smartcity.niua.org/wp-content/uploads/2017/08/No-image-found.jpg",width: 100,height: 100,)
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          MaterialButton(
                                            onPressed: (){
                                              Utils.urlToFile(context,request.qrcodeImage).then((file){
                                                Share.shareFiles([file.path], text: 'Qr Code for Model '+request.modelName);
                                              });
                                            },
                                            child: Text("Share",style: TextStyle(color: Colors.white),),
                                            color: Color(0xFF004c4c),
                                          ),
                                          MaterialButton(
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
                                            child: Text("Print",style: TextStyle(color: Colors.white),),
                                            color: Color(0xFF004c4c),
                                          ),
                                        ],
                                      )

                                    ]
                                  )
                                ),
                                Divider(),
                              ],
                            ):Container(),
                          ],
                        ),
                      ),
                  ),
                ),
              ),
            ),
          ],
        ));

  }

}

