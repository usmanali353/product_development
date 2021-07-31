import'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:productdevelopment/RequestColorsList.dart';
class RequestImageGallery extends StatefulWidget {
  var request;

  RequestImageGallery(this.request);

  @override
  _RequestImageGalleryState createState() => _RequestImageGalleryState(request);
}

class _RequestImageGalleryState extends State<RequestImageGallery> {
  var request;
  int num=0,count=1;
   List<String> imageUrl=[],colorNames=[];
  _RequestImageGalleryState(this.request);
  @override
  void initState() {
    setState(() {
      if(request.multipleColorNames!=null&&request.multipleColorNames.length>0){
        for(int i=0;i<request.multipleColorNames.length;i++){
          if(request.multipleColorNames[i].colorImage!=null){
            colorNames.add(request.multipleColorNames[i].colorName);
            imageUrl.add(request.multipleColorNames[i].colorImage);
          }
        }
      }else if(request.multipleColors!=null&&request.multipleColors.length>0){
        for(int i=0;i<request.multipleColors.length;i++){
          if(request.multipleColors[i].colorImage!=null){
            colorNames.add(request.multipleColors[i].colorName);
            imageUrl.add(request.multipleColors[i].colorImage);
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
          title: Text(colorNames!=null&&colorNames.length>0?"${colorNames[num]} ("+count.toString()+"/"+imageUrl.length.toString()+")":"Gallery"),
           actions: [
             InkWell(
               child: Center(child: Padding(
                 padding: const EdgeInsets.only(right:8.0),
                 child: Text("Upload More"),
               )),
               onTap: (){
                 Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=>RequestColorsList(request)));
               },
             )
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
