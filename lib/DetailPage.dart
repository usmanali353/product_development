import 'dart:typed_data';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Model/RemarksHistory.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/Utils/Utils.dart';
import 'package:share_plus/share_plus.dart';
import 'Model/RequestColorImages.dart';
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
   List<String> colorsNames=[];
   List<String> imageUrl=[];
   List<RemarksHistory> clientRemarks=[];
  @override
  void initState() {
    print(request.requestId.toString());
   for(int i=0;i<request.multipleColorNames.length;i++) {
     setState(() {
       colorsNames.add(request.multipleColorNames[i].colorName);
     });
   }
   setState(() {
     if(request.multipleColorNames!=null&&request.multipleColorNames.length>0){
       for(int i=0;i<request.multipleColorNames.length;i++){
         if(widget.request.multipleColorNames[i].colorImage!=null){
           imageUrl.add(widget.request.multipleColorNames[i].colorImage);
         }
         if(request.multipleColorNames[i].colorimages!=null&&request.multipleColorNames[i].colorimages.length>0){
           for(RequestColorImages img in request.multipleColorNames[i].colorimages) {
            // colorNames.add(request.multipleColorNames[i].colorName);
             imageUrl.add(img.colorImages);
           }
         }
       }
       //print(colorNames.toString());
     }else if(request.multipleColors!=null&&request.multipleColors.length>0){
       for(int i=0;i<request.multipleColors.length;i++){
         if(widget.request.multipleColors[i].colorImage!=null){
           imageUrl.add(widget.request.multipleColors[i].colorImage);
         }
         if(request.multipleColors[i].colorimages!=null&&request.multipleColors[i].colorimages.length>0){
           for(RequestColorImages img in request.multipleColors[i].colorimages) {
            // colorNames.add(request.multipleColors[i].colorName);
             imageUrl.add(img.colorImages);
           }
         }
       }
      // print(colorNames.toString());
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
          child: Stack(
            children: <Widget>[
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RequestImageGallery(request)));
                },
                child: Container(
                  //color: Color(0xFF004c4c),
                  height: MediaQuery.of(context).size.height/5,
                  width: MediaQuery.of(context).size.width,
                 decoration: BoxDecoration(
                   image: DecorationImage(
                     image: NetworkImage(request.image!=null?request.image:"http://anokha.world/images/not-found.png"),
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
                                title: Text("Market",style: TextStyle(fontWeight: FontWeight.bold),),
                                subtitle: Text(request.marketName!=null?request.marketName:''),
                              ),
                              Divider(),
                              ListTile(
                                title: Text("Request Date",style: TextStyle(fontWeight: FontWeight.bold),),
                                subtitle: Text(DateFormat("dd MMMM yyyy").format(DateTime.parse(request.date))??''),
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
                                    title: Text("Sample Production Target Start Date",style: TextStyle(fontWeight: FontWeight.bold),),
                                    subtitle: Text(DateFormat("dd MMMM yyyy").format(DateTime.parse(request.targetStartDate))),
                                  ),
                                  Divider(),
                                ],
                              ):Container(),
                              request.targetEndDate!=null?Column(
                                children: <Widget>[
                                  ListTile(
                                    title: Text("Sample Production Target End Date",style: TextStyle(fontWeight: FontWeight.bold),),
                                    subtitle: Text(DateFormat("dd MMMM yyyy").format(DateTime.parse(request.targetEndDate))),
                                  ),
                                  Divider(),
                                ],
                              ):Container(),
                              request.actualStartDate!=null?Column(
                                children: <Widget>[
                                  ListTile(
                                    title: Text("Sample Production Actual Start Date",style: TextStyle(fontWeight: FontWeight.bold),),
                                    subtitle: Text(DateFormat("dd MMMM yyyy").format(DateTime.parse(request.actualStartDate))),
                                  ),
                                  Divider(),
                                ],
                              ):Container(),
                              request.actualEndDate!=null?Column(
                                children: <Widget>[
                                  ListTile(
                                    title: Text("Sample Production Actual End Date",style: TextStyle(fontWeight: FontWeight.bold),),
                                    subtitle: Text(DateFormat("dd MMMM yyyy").format(DateTime.parse(request.actualEndDate))),
                                  ),
                                  Divider(),
                                ],
                              ):Container(),
                              request.multipleClientNames!=null&&request.multipleClientNames.length>0?Column(
                                children: <Widget>[
                                  ListTile(
                                    title: Text("Clients",style: TextStyle(fontWeight: FontWeight.bold),),
                                    subtitle: Text(request.multipleClientNames.toString().replaceAll("[", "").replaceAll("]", "")),
                                  ),
                                  Divider(),
                                ],
                              ):Container(),
                              request.modelName!=null?Column(
                                children: <Widget>[
                                  ListTile(
                                    title: Text("Samples Model Name",style: TextStyle(fontWeight: FontWeight.bold),),
                                    subtitle: Text(request.modelName),
                                  ),
                                  Divider(),
                                ],
                              ):Container(),
                              request.modelCode!=null?Column(
                                children: <Widget>[
                                  ListTile(
                                    title: Text("Samples Model Code",style: TextStyle(fontWeight: FontWeight.bold),),
                                    subtitle: Text(request.modelCode!=null?request.modelCode:''),
                                  ),
                                  Divider(),
                                ],
                              ):Container(),
                              request.newModelName!=null&&request.newModelCode!=null?Column(
                                children: [
                                  ListTile(
                                    title: Text("Production Model Name",style: TextStyle(fontWeight: FontWeight.bold),),
                                    subtitle: Text(request.newModelName),
                                  ),
                                  Divider(),
                                  ListTile(
                                    title: Text("Production Model Code",style: TextStyle(fontWeight: FontWeight.bold),),
                                    subtitle: Text(request.newModelCode),
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
                                title: Text("Design Topology", style: TextStyle(
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
                                    for ( var images in imageUrl) images!=null?CachedNetworkImage(imageUrl:images,width: 100,height: 100,placeholder:(context,url)=>Container(width: 80,height: 80,child: Center(child: CircularProgressIndicator(),),),):Container(),
                                  ],
                                )
                              ),
                              Divider(),
                              ListTile(
                                title: Text("Technology", style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                ),),
                                subtitle: Text(request.technologyName!=null?request.technologyName:""),
                              ),
                              Divider(),
                              ListTile(
                                title: Text("Structure", style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),),
                                subtitle: Text(request.structureName!=null?request.structureName:""),
                              ),
                              Divider(),
                              ListTile(
                                title: Text("Edge", style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                ),),
                                subtitle: Text(request.edgeName!=null?request.edgeName:""),
                              ),
                              Divider(),
                              ListTile(
                                title: Text("Classification", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),),
                                subtitle: Text(request.classificationName!=null?request.classificationName:""),
                              ),
                              Divider(),
                              ListTile(
                                title: Text("Suitability", style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                ),),
                                subtitle: Text(request.multipleSuitabilityNames.toString().replaceAll("[", "").replaceAll("]", "")),
                              ),
                              Divider(),
                              request.qrcodeImage!=null?Column(
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
                                              child: CachedNetworkImage(imageUrl:request.qrcodeImage!=null?request.qrcodeImage:"http://anokha.world/images/not-found.png",width: 100,height: 100,placeholder: (context,url)=>Container(width: 80,height:80,child: Center(child: CircularProgressIndicator()),),)
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            MaterialButton(
                                              onPressed: (){
                                                Utils.urlToFile(context,request.qrcodeImage).then((file){
                                                  Share.shareFiles([file.path], text:request.newModelName!=null?'Qr Code for Model '+request.newModelName:request.modelName!=null?'Qr Code for Model '+request.modelName:"Scan this QR Code to Get Details of the Model");
                                                });
                                              },
                                              child: Text("Share",style: TextStyle(color: Colors.white),),
                                              color: Color(0xFF004c4c),
                                            ),
                                            MaterialButton(
                                              onPressed: ()async{
                                                final doc = pw.Document();
                                                RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
                                                var image = await boundary.toImage();
                                                ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
                                                Uint8List pngBytes = byteData.buffer.asUint8List();
                                                final PdfImage img = PdfImage.file(doc.document, bytes: pngBytes);
                                                final  imgLogo = await imageFromAssetBundle("Assets/img/AC.png");
                                                doc.addPage(pw.Page(
                                                    build: (pw.Context context) {
                                                      return pw.Column(
                                                        children: [
                                                          pw.Center(
                                                              child: pw.Image(imgLogo,width: 150,height:150)
                                                          ),
                                                          pw.Padding(padding: pw.EdgeInsets.all(8.0)),
                                                          pw.Center(
                                                              child: pw.Image(pw.ImageProxy(img),width: 100,height: 100)
                                                          ),
                                                          pw.Padding(padding: pw.EdgeInsets.all(8.0)),
                                                          pw.Center(
                                                              child: pw.Text("Please Scan this QR Code to get Details of this Model",style: pw.TextStyle(fontSize: 15),)
                                                          ),
                                                        ]
                                                      );
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
          ),
        ));

  }

}

