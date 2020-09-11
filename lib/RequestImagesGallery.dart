import'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:productdevelopment/Model/Request.dart';
class RequestImageGallery extends StatefulWidget {
  Request request;

  RequestImageGallery(this.request);

  @override
  _RequestImageGalleryState createState() => _RequestImageGalleryState(request);
}

class _RequestImageGalleryState extends State<RequestImageGallery> {
  Request request;
   List<String> imageUrl=[];
  _RequestImageGalleryState(this.request);
  @override
  void initState() {
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
      appBar: AppBar(title: Text("Gallery"),),
      body: PhotoViewGallery.builder(itemCount: imageUrl.length, builder: (context,index){
        return PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(
            imageUrl[index],
          ),

          heroAttributes: PhotoViewHeroAttributes(tag: request.multipleColorNames[index].colorName),
          maxScale: PhotoViewComputedScale.contained*1,
          minScale: PhotoViewComputedScale.covered*1,
        );
      },
        scrollPhysics: BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).canvasColor
        ),
        loadingBuilder: (context,e){
         return Center(
           child: CircularProgressIndicator(),
         );
        },
      ),
    );
  }
}
