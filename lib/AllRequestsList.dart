import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'RequestImagesGallery.dart';
import 'Utils/Utils.dart';

class AllRequestList extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return _AllRequestListState();
  }

}
class _AllRequestListState extends State<AllRequestList>{
  List<Request> allRequests=[];
  var isListVisible=false;
  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs){
      Network_Operations.getRequestForGM(context, prefs.getString("token"),10,1).then((allRequests){
        setState(() {
          this.allRequests=allRequests;
          if(this.allRequests.length>0){
            isListVisible=true;
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
        title: Text("All Requests"),
      ),
      body:Visibility(
        visible: isListVisible,
        child: ListView.builder(
            itemCount:allRequests!=null?allRequests.length:0, itemBuilder: (context,int index)
        {
          return Card(
            elevation: 6,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                //color: Colors.teal,
              ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.21,

              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        InkWell(
                          onTap: (){
                            setState(() {
                              List<String> imageUrl=[];
                              for(int i=0;i<allRequests[index].multipleImages.length;i++){
                                if(allRequests[index].multipleImages[i]!=null){
                                  imageUrl.add(allRequests[index].multipleImages[i]);
                                }
                              }
                              imageUrl.add(allRequests[index].image);
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestImageGallery(allRequests[index])));
                            });
                          },
                          child: Container(
                            //color: Color(0xFF004c4c),
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(allRequests[index].image!=null?allRequests[index].image:"https://cidco-smartcity.niua.org/wp-content/uploads/2017/08/No-image-found.jpg"), //MemoryImage(base64Decode(products[index]['image'])),
                                  fit: BoxFit.cover,
                                )
                            ),
                          ),
                        ),
                        //Padding(padding: EdgeInsets.only(top:2),),
                        allRequests[index].multipleColorNames!=null&&allRequests[index].multipleColorNames.length>0?Row(
                          children: <Widget>[
                            for(int i=0;i<allRequests[index].multipleColorNames.length;i++)
                              Padding(
                                padding: const EdgeInsets.all(2),
                                child: Wrap(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        color: Color(Utils.getColorFromHex(allRequests[index].multipleColorNames[i].colorCode)),
                                        //color: Colors.teal,
                                      ),
                                      height: 10,
                                      width: 15,
                                    ),

                                  ],
                                ),
                              ),


                          ],
                        ):Container(),
                      ],
                    ),
                    VerticalDivider(color: Colors.grey,),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.62,
                      height: MediaQuery.of(context).size.height * 0.62,
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 6, top: 8),
                            child: Text(allRequests[index].modelName!=null?allRequests[index].modelName:'', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            //mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Row(
                                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Icon(
                                    Icons.date_range,
                                    color: Colors.teal,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 2, right: 2),
                                  ),
                                  Text(DateFormat("yyyy-MM-dd").format(DateTime.parse(allRequests[index].date)))
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 30),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.layers,
                                      color: Colors.teal,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 2, right: 2),
                                    ),
                                    Text(allRequests[index].surfaceName!=null?allRequests[index].surfaceName:'')
                                  ],

                                ),
                              ),

                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.zoom_out_map,
                                color: Colors.teal,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 2, right: 2),
                              ),
                              Text(allRequests[index].multipleSizeNames.toString().replaceAll("[", "").replaceAll("]", "").replaceAll(".00", "")),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 1),
                            child: Row(
                              //crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  Icons.done_all,
                                  //size: 14,
                                  color: Colors.teal,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 3, right: 3),
                                ),
                                Text(allRequests[index].statusName!=null?allRequests[index].statusName:'')
                              ],
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
        }),
      ),
    );
  }

}