import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/qrcode.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DetailPage extends StatefulWidget {
 Request request;
 DetailPage(this.request);

  @override
  _DetailPageState createState() => _DetailPageState(request);
}

class _DetailPageState extends State<DetailPage>{
   Request request;
  _DetailPageState(this.request);
  var rangeInfo;
  bool rangeInfoVisible=false;
  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs){
      Network_Operations.getRangeById(context, prefs.getString("token"), request.rangeId).then((rangeById){
        setState(() {
          this.rangeInfo=rangeById;
          if(rangeInfo!=null){
            rangeInfoVisible=true;
          }
        });
      });
    });

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Request Details"),
          actions: <Widget>[
            request.statusName=='Approved by Customer'||request.statusName=='Approved Trial'||request.statusName=='Rejected By Customer'||request.statusName=="Rejected Trial"?InkWell(
               child: Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Center(child: Text("Generate QR Code")),
               ),
              onTap: (){
                 Navigator.push(context, MaterialPageRoute(builder: (context)=>GenerateedQrcode(request.requestId)));
              },
            ):Container(),
          ],
        ),
        body: Stack(
          children: <Widget>[
            Container(
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
            Padding(
              padding: const EdgeInsets.only(top: 150, bottom: 10),
              child: Center(
                child: new Container(
                  //height: MediaQuery.of(context).size.height * 0.65,
                  //width: ,
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
                            rangeInfoVisible?Column(

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
                                          child: Image.network(rangeInfo['image'],width: 100,height: 100,),
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
                              subtitle: Text(request.multipleColorNames.toString().replaceAll("[", "").replaceAll("]", "")),
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
                            request.statusName=='Approved By Customer'||request.statusName=='Approved Trial'||request.statusName=='Rejected By Customer'||request.statusName=="Rejected Trial"?Column(
                              children: [
                                ListTile(
                                  title: Text("Qr Code", style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),),
                                  subtitle: Center(
                                    child: QrImage(
                                      data: request.requestId.toString(),
                                      version: QrVersions.auto,
                                      size: 100.0,
                                    ),
                                  ),
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

