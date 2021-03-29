import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
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
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(widget.request.multipleColorNames[index].colorName!=null?widget.request.multipleColorNames[index].colorName:''),
                            leading: widget.request.multipleColorNames[index].colorImage!=null?Container(width: 50,height: 50,child: CachedNetworkImage(imageUrl:widget.request.multipleColorNames[index].colorImage,placeholder: (context, url) => Container(width:40,height: 40,child: Center(child: CircularProgressIndicator())),errorWidget: (context, url, error) => Icon(Icons.error,color: Colors.red,))):Container(width:50,height:50,color: Color(Utils.getColorFromHex(widget.request.multipleColorNames[index].colorCode)),),
                            onTap: (){
                              Utils.getImage().then((imageFile){
                                if(imageFile!=null){
                                  imageFile.readAsBytes().then((image){
                                    if(image!=null){
                                      setState(() {
                                        _image = File(imageFile.path);
                                        base64EncodedImage=base64Encode(image);
                                        showAddColorDialog(widget.request.multipleColorNames[index].id,base64EncodedImage,widget.request.multipleColorNames[index].colorName);
                                      });
                                    }
                                  });
                                }else{

                                }
                              });
                                //Navigator.push(context, MaterialPageRoute(builder:(context)=>addImageToColors(widget.request)));
                            },
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
  showAddColorDialog(int colorId,var base64Image,String colorName){
    showDialog(
        context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Image to Color"),
          content: Text("are you sure you want to add Image to Color $colorName?"),
          actions: [
            FlatButton(
                child: Text("Add"),
                onPressed: (){
                  SharedPreferences.getInstance().then((prefs){
                    Network_Operations.addRequestImages(context, prefs.getString("token"),colorId, base64Image).then((value){
                      Navigator.pop(context);
                      Navigator.pop(context);
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => refreshIndicatorKey.currentState.show());
                    });
                  });
                },
            ),
            FlatButton(
                child: Text("Cancel"),
                onPressed: (){
                     Navigator.pop(context);
                },
            ),
          ],
        );
      },
    );
  }
}
