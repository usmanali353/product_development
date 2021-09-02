import 'dart:convert';

import 'package:productdevelopment/Model/RequestColors.dart';



class RequestColorImages {
  RequestColorImages({
    this.id,
    this.colorImages,
    this.requestColorId,
    this.requestColor,
  });

  int id;
  String colorImages;
  int requestColorId;
  RequestColors requestColor;
 static List<RequestColorImages> requestColorImagesFromJson(String str) => List<RequestColorImages>.from(json.decode(str).map((x) => RequestColorImages.fromJson(x)));

  static String requestColorImagesToJson(List<RequestColorImages> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

  factory RequestColorImages.fromJson(Map<String, dynamic> json) => RequestColorImages(
    id: json["id"],
    colorImages: json["colorImages"],
    requestColorId: json["requestColorId"],
    requestColor: json["requestColor"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "colorImages": colorImages,
    "requestColorId": requestColorId,
    "requestColor": requestColor,
  };
}
