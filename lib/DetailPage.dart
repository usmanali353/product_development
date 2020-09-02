import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/qrcode.dart';


class DetailPage extends StatefulWidget {
 Request request;
 DetailPage(this.request);

  @override
  _DetailPageState createState() => _DetailPageState(request);
}

class _DetailPageState extends State<DetailPage>{
   Request request;
  _DetailPageState(this.request);
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Request Details"),
          actions: <Widget>[
            request.statusName=='Approved by Customer'||request.statusName=='Approved Trial'||request.statusName=='Rejected by Customer'?InkWell(
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
//              decoration: BoxDecoration(
//                image: DecorationImage(
//                  image: Icons.memory(request.image),
//                  fit: BoxFit.cover,
//                )
//              ),
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
                              padding: EdgeInsets.only(top:4,bottom: 4),
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
                              subtitle: Text(request.date??''),
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
                            request.closeing_date!=null?Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text("Closing Date",style: TextStyle(fontWeight: FontWeight.bold),),
                                  subtitle: Text(''),
                                ),
                                Divider(),
                              ],
                            ):Container(),
                            request.trialDate!=null?Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text("Trial Date",style: TextStyle(fontWeight: FontWeight.bold),),
                                  subtitle: Text(''),
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
                                  subtitle: Text(''),
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
                            ListTile(
                              title: Text("Range", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                              ),),
                              subtitle: Text(request.rangeName),
                            ),
                            Divider(),
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

