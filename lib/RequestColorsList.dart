import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/RequestImagesGallery.dart';
import 'package:productdevelopment/Utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
class RequestColorsList extends StatefulWidget {
  var request;

  RequestColorsList(this.request);

  @override
  _RequestColorsListState createState() => _RequestColorsListState();
}

class _RequestColorsListState extends State<RequestColorsList> {
  var base64EncodedImage;
  File _image;
  GlobalKey<RefreshIndicatorState> refreshIndicatorKey=GlobalKey();
  bool isVisible=false;
  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => refreshIndicatorKey.currentState.show());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:Text("Request Colors"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
                image: AssetImage('Assets/img/pattren.png'),
              )
          ),
          child: RefreshIndicator(
            key: refreshIndicatorKey,
            onRefresh: (){
              return Utils.check_connectivity().then((isConnected){
                if(isConnected){
                  SharedPreferences.getInstance().then((prefs){
                    Network_Operations.getRequestByIdNotifications(context, prefs.getString("token"),widget.request.requestId).then((requestInfo){
                      setState(() {
                        widget.request=requestInfo;
                        if(widget.request!=null){
                          isVisible=true;
                        }
                      });
                    });
                  });

                }else{
                  Utils.showError(context,"Network not Available");
                }
              });
            },
            child: Visibility(
              visible: isVisible,
              child: ListView.builder(
                  itemCount: widget.request.multipleColorNames!=null&&widget.request.multipleColorNames.length>0?widget.request.multipleColorNames.length:0,
                  itemBuilder: (context,index){
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: GestureDetector(
                        onTapDown: (details)async{
                            await showMenu(context: context,
                                position:  RelativeRect.fromLTRB(details.globalPosition.dx, details.globalPosition.dy, 0, 0),
                                items: [
                                  PopupMenuItem<String>(
                                      child: const Text('Upload Images'), value: 'uploadImages'),
                                  PopupMenuItem<String>(
                                      child: const Text('View Images'), value: 'viewImages'),
                                ]
                            ).then((selectedMenuItem){
                                  if(selectedMenuItem=="uploadImages"){
                                        Utils.getMultipleImages().then((images){
                                          SharedPreferences.getInstance().then((prefs){
                                            Network_Operations.sendiamgestoserver(context,prefs.getString("token"), images,widget.request.multipleColorNames[index].id);
                                          });
                                        });
                                  }else if(selectedMenuItem=="viewImages"){
                                    SharedPreferences.getInstance().then((prefs){
                                      Network_Operations.getImagesByColororRequest(context, prefs.getString("token"),requestColorId:widget.request.multipleColorNames[index].id).then((colorImages){
                                        if(colorImages!=null&&colorImages.length>0) {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => RequestImageGallery(widget.request, images: colorImages,colorName:widget.request.multipleColorNames[index].colorName)));
                                        }else{
                                          Utils.showError(context,"No Images Yet for this Color");
                                        }
                                      });
                                    });

                                  }

                            });
                        },
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(widget.request.multipleColorNames[index].colorName!=null?widget.request.multipleColorNames[index].colorName:''),
                              leading: Container(width:50,height:50,color: Color(Utils.getColorFromHex(widget.request.multipleColorNames[index].colorCode)),),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
