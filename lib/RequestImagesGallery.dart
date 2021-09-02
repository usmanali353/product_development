import'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:productdevelopment/Model/RequestColorImages.dart';
import 'package:productdevelopment/RequestColorsList.dart';
class RequestImageGallery extends StatefulWidget {
  List<RequestColorImages> images;
  String colorName;
  var request;
  RequestImageGallery(this.request,{this.images,this.colorName});

  @override
  _RequestImageGalleryState createState() => _RequestImageGalleryState();
}

class _RequestImageGalleryState extends State<RequestImageGallery> {
  var request;
  int num=0,count=1;
   List<String> imageUrl=[],colorNames=[];
  _RequestImageGalleryState();
  @override
  void initState() {
    setState(() {
      if(widget.images!=null) {
        for (var images in widget.images) {
          imageUrl.add(images.colorImages);
        }
      }
      // if(request.multipleColorNames!=null&&request.multipleColorNames.length>0){
      //   for(int i=0;i<request.multipleColorNames.length;i++){
      //     if(request.multipleColorNames[i].colorImage!=null){
      //       colorNames.add(request.multipleColorNames[i].colorName);
      //       imageUrl.add(request.multipleColorNames[i].colorImage);
      //     }
      //   }
      // }else if(request.multipleColors!=null&&request.multipleColors.length>0){
      //   for(int i=0;i<request.multipleColors.length;i++){
      //     if(request.multipleColors[i].colorImage!=null){
      //       colorNames.add(request.multipleColors[i].colorName);
      //       imageUrl.add(request.multipleColors[i].colorImage);
      //     }
      //   }
      // }

    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          title: Text((){
            if(widget.colorName!=null){
              return widget.colorName + " "+"("+count.toString()+"/"+imageUrl.length.toString()+")";
            }
          }()),
           actions: [
             widget.colorName!=null?InkWell(
               child: Center(child: Padding(
                 padding: const EdgeInsets.only(right:8.0),
                 child: Text("Upload More"),
               )),
               onTap: (){
                 Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=>RequestColorsList(request)));
               },
             ):Container()
           ],
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: PhotoViewGallery.builder(itemCount: imageUrl.length, builder: (context,index){
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(
                imageUrl[index],
              ),
            );
          },
            scrollPhysics: BouncingScrollPhysics(),
            backgroundDecoration: BoxDecoration(
              color: Colors.black
            ),
            loadingBuilder: (context,e){
             return Center(
               child: CircularProgressIndicator(),
             );
            },
            onPageChanged: (pageno){
            setState(() {
              this.num=pageno;
              this.count=pageno+1;
            });
            },
          ),
        ),
      ),
    );
  }
}
