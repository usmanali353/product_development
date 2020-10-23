import 'package:productdevelopment/Model/RequestColors.dart';
import 'package:flutter/material.dart';

class AssignedRejectedModels{
  String surfaceName,clientName,requestDate,modelName,currentAction,image,userAssigned;
  List<String> multipleSizeNames;
  List<dynamic> multipleImages,multipleReasons;
  List<RequestColors> multipleColors;
  int id,requestId;
  AssignedRejectedModels({
    this.id,
    this.surfaceName,
    this.clientName,
    this.requestDate,
    this.modelName,
    this.currentAction,
    this.multipleSizeNames,
    this.multipleImages,
    this.image,
    this.requestId,
    this.multipleReasons,
    this.multipleColors,
    this.userAssigned
  });
  factory AssignedRejectedModels.fromJson(Map<String, dynamic> json) => AssignedRejectedModels(
    id: json["id"],
    requestId: json["requestId"],
    requestDate: json["date"],
    surfaceName: json["surfaceName"],
    image: json["image"],
    clientName: json["clientName"],
    modelName: json["modelName"],
    multipleColors: List<RequestColors>.from(json["multipleColors"].map((x) => RequestColors.fromJson(x))),
    multipleSizeNames: List<String>.from(json["multipleSizeNames"].map((x) => x)),
    multipleImages: List<dynamic>.from(json["multipleImages"].map((x) => x)),
    userAssigned: json["userAssigned"],
    currentAction: json["currentAction"],
    multipleReasons: json["multipleReasons"],
  );

}