import 'package:productdevelopment/Model/Colors.dart';

class TrialRequests{
  int id;
  int requestId;
  String clientId;
  bool approved;
  String date;
  String surfaceName;
  String image;
  String qrcodeImage;
  String status;
  String clientName;
  String modelCode;
  String modelName;
  dynamic clientVisitDate;
  dynamic actualClientVisitDate;
  List<dynamic> multipleClients,allRequestClients;
  List<Colors> multipleColors;
  List<String> multipleSizeNames;
  List<dynamic> multipleImages;
  TrialRequests({
    this.id,
    this.requestId,
    this.clientId,
    this.approved,
    this.date,
    this.surfaceName,
    this.image,
    this.qrcodeImage,
    this.status,
    this.clientName,
    this.modelCode,
    this.modelName,
    this.multipleClients,
    this.multipleColors,
    this.multipleSizeNames,
    this.multipleImages,
    this.clientVisitDate,
    this.actualClientVisitDate,this.allRequestClients
  });
  factory TrialRequests.fromJson(Map<String, dynamic> json) => TrialRequests(
    id: json["id"],
    requestId: json["requestId"],
    clientId: json["clientId"],
    approved: json["approved"],
    date: json["date"],
    surfaceName: json["surfaceName"],
    image: json["image"],
    qrcodeImage: json["qrcodeImage"],
    status: json["status"],
    clientName: json["clientName"],
    modelCode: json["modelCode"],
    modelName: json["modelName"],
    multipleClients: json["multipleClients"],
    multipleColors: List<Colors>.from(json["multipleColors"].map((x) => Colors.fromJson(x))),
    multipleSizeNames: List<String>.from(json["multipleSizeNames"].map((x) => x)),
    multipleImages: List<dynamic>.from(json["multipleImages"].map((x) => x)),
    clientVisitDate:json["clientVisitDate"],
    actualClientVisitDate: json["actualClientVisitDate"],
    allRequestClients:json["allRequestClients"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "requestId": requestId,
    "clientId": clientId,
    "approved": approved,
    "date": date,
    "surfaceName": surfaceName,
    "image": image,
    "qrcodeImage": qrcodeImage,
    "status": status,
    "clientName": clientName,
    "modelCode": modelCode,
    "modelName": modelName,
    "multipleClients": multipleClients,
    "multipleColors": List<dynamic>.from(multipleColors.map((x) => x.toJson())),
    "multipleSizeNames": List<dynamic>.from(multipleSizeNames.map((x) => x)),
    "multipleImages": List<dynamic>.from(multipleImages.map((x) => x)),
    "clientVisitDate":clientVisitDate,
    "actualClientVisitDate":actualClientVisitDate,
    "allRequestClients":allRequestClients
  };
}