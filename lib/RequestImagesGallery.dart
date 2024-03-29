import'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:productdevelopment/Model/RequestColorImages.dart';
import 'package:productdevelopment/Network_Operations/Network_Operations.dart';
import 'package:productdevelopment/RequestColorsList.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
   List<int> requestColorIds=[],requestImageIds=[];
  _RequestImageGalleryState();
  @override
  void initState() {
    setState(() {
      if(widget.images!=null) {
        for (var images in widget.images) {
          requestColorIds.add(images.requestColorId);
          requestImageIds.add(images.id);
          imageUrl.add(images.colorImages);
        }
      }else if(widget.request.multipleColorNames!=null&&widget.request.multipleColorNames.length>0){
        for(int i=0;i<widget.request.multipleColorNames.length;i++){
          // if(widget.request.multipleColorNames[i].colorImage!=null){
          //   imageUrl.add(widget.request.multipleColorNames[i].colorImage);
          //   colorNames.add(widget.request.multipleColorNames[i].colorName);
          // }
          if(widget.request.multipleColorNames[i].colorimages!=null&&widget.request.multipleColorNames[i].colorimages.length>0){

            for(RequestColorImages img in widget.request.multipleColorNames[i].colorimages) {
              requestColorIds.add(img.requestColorId);
              requestImageIds.add(img.id);
              colorNames.add(widget.request.multipleColorNames[i].colorName);
              imageUrl.add(img.colorImages);
            }
          }
        }

      }else if(widget.request.multipleColors!=null&&widget.request.multipleColors.length>0){
        for(int i=0;i<widget.request.multipleColors.length;i++){
          // if(widget.request.multipleColors[i].colorImage!=null){
          //   imageUrl.add(widget.request.multipleColors[i].colorImage);
          //   colorNames.add(widget.request.multipleColors[i].colorName);
          // }
          if(widget.request.multipleColors[i].colorimages!=null&&widget.request.multipleColors[i].colorimages.length>0){
            for(RequestColorImages img in widget.request.multipleColors[i].colorimages) {
              requestColorIds.add(img.requestColorId);
              requestImageIds.add(img.id);
              colorNames.add(widget.request.multipleColors[i].colorName);
              imageUrl.add(img.colorImages);
            }
          }
        }
        print(colorNames.toString());
      }
      if(imageUrl.length==0||requestImageIds.length==0) {
        if (widget.request.multipleColorNames != null && widget.request.multipleColorNames.length > 0) {

          for (int i = 0; i < widget.request.multipleColorNames.length; i++) {
             if(widget.request.multipleColorNames[i].colorImage!=null){
               imageUrl.add(widget.request.multipleColorNames[i].colorImage);
               colorNames.add(widget.request.multipleColorNames[i].colorName);
             }
          }
        }else if (widget.request.multipleColors != null && widget.request.multipleColors.length > 0) {
          for (int i = 0; i < widget.request.multipleColors.length; i++) {
            if(widget.request.multipleColors[i].colorImage!=null){
              imageUrl.add(widget.request.multipleColors[i].colorImage);
              colorNames.add(widget.request.multipleColors[i].colorName);
            }
          }
        }
        print("Count when no bridge table available "+imageUrl.length.toString());
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
            imageUrl.length>0&&imageUrl.length>1&&!(imageUrl.length==0||requestImageIds.length==0)?IconButton(onPressed:(){
               if(requestImageIds.length>num&&requestColorIds.length>num){
                 SharedPreferences.getInstance().then((prefs){
                   Network_Operations.showImageOnMain(context,requestColorIds[num], requestImageIds[num],prefs.getString("token"));
                 });
               }
             }, icon:Icon(Icons.image)):Container(),

             widget.colorName==null?IconButton(
               icon: Icon(Icons.add_photo_alternate),
               onPressed: (){
                 Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=>RequestColorsList(widget.request)));
               },
             ):Container(),

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
