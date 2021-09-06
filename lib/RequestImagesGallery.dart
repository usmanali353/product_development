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
      }else if(widget.request.multipleColorNames!=null&&widget.request.multipleColorNames.length>0){
        for(int i=0;i<widget.request.multipleColorNames.length;i++){
          if(widget.request.multipleColorNames[i].colorImage!=null){
            imageUrl.add(widget.request.multipleColorNames[i].colorImage);
            colorNames.add(widget.request.multipleColorNames[i].colorName);
          }
          if(widget.request.multipleColorNames[i].colorimages!=null&&widget.request.multipleColorNames[i].colorimages.length>0){
            for(RequestColorImages img in widget.request.multipleColorNames[i].colorimages) {
              colorNames.add(widget.request.multipleColorNames[i].colorName);
              imageUrl.add(img.colorImages);
            }
          }
        }

      }else if(widget.request.multipleColors!=null&&widget.request.multipleColors.length>0){
        for(int i=0;i<widget.request.multipleColors.length;i++){
          if(widget.request.multipleColors[i].colorImage!=null){
            imageUrl.add(widget.request.multipleColors[i].colorImage);
            colorNames.add(widget.request.multipleColors[i].colorName);
          }
          if(widget.request.multipleColors[i].colorimages!=null&&widget.request.multipleColors[i].colorimages.length>0){
            for(RequestColorImages img in widget.request.multipleColors[i].colorimages) {
              colorNames.add(widget.request.multipleColors[i].colorName);
              imageUrl.add(img.colorImages);
            }
          }
        }
        print(colorNames.toString());
      }
      if(imageUrl.length==0||colorNames.length==0) {
        if (widget.request.multipleColorNames != null && widget.request.multipleColorNames.length > 0) {

          for (int i = 0; i < widget.request.multipleColorNames.length; i++) {
             if(widget.request.multipleColorNames[i].colorImage!=null&&widget.colorName!=null&&widget.request.multipleColorNames[i].colorName==widget.colorName){
               imageUrl.add(widget.request.multipleColorNames[i].colorImage);
               colorNames.add(widget.request.multipleColorNames[i].colorName);
             }
          }
        }else if (widget.request.multipleColors != null && widget.request.multipleColors.length > 0) {
          for (int i = 0; i < widget.request.multipleColors.length; i++) {
            if(widget.request.multipleColors[i].colorImage!=null&&widget.colorName!=null&&widget.request.multipleColorNames[i].colorName==widget.colorName){
              imageUrl.add(widget.request.multipleColors[i].colorImage);
              colorNames.add(widget.request.multipleColors[i].colorName);
            }
          }
        }
      }

    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          title: Text((){
            if(widget.colorName!=null&&widget.images!=null){
              return widget.colorName + " "+"("+count.toString()+"/"+imageUrl.length.toString()+")";
            }else if(widget.request.multipleColorNames!=null&&widget.request.multipleColorNames.length>0&&colorNames.length>0||widget.request.multipleColors!=null&&widget.request.multipleColors.length>0&&colorNames.length>0){
              return colorNames[num]+" "+"("+count.toString()+"/"+imageUrl.length.toString()+")";
            }else if(imageUrl.length==0){
              return "Model Images";
            }
          }()),
           actions: [
             widget.colorName==null?InkWell(
               child: Center(child: Padding(
                 padding: const EdgeInsets.only(right:8.0),
                 child: Text("Upload More"),
               )),
               onTap: (){
                 Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=>RequestColorsList(widget.request)));
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
