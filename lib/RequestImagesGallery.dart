import'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:productdevelopment/Model/Request.dart';
class RequestImageGallery extends StatefulWidget {
  var request;

  RequestImageGallery(this.request);

  @override
  _RequestImageGalleryState createState() => _RequestImageGalleryState(request);
}

class _RequestImageGalleryState extends State<RequestImageGallery> {
  var request;
   List<String> imageUrl=[];
  _RequestImageGalleryState(this.request);
  @override
  void initState() {
    setState(() {
      imageUrl.add(request.image);
      for(int i=0;i<request.multipleImages.length;i++){
        if(request.multipleImages[i]!=null){
          imageUrl.add(request.multipleImages[i]);
        }
      }
      print(imageUrl.length);
    });

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Gallery"),),
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
          ),
        ),
      ),
    );
  }
}
