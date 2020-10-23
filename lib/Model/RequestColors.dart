


class RequestColors{
  RequestColors({
    this.id,
    this.colorId,
    this.requestId,
    this.colorImage,
    this.colorName,
    this.colorCode,
    this.showOnMain,
    this.isApi,
    this.colorImageFile,
  });

  int id;
  int colorId;
  int requestId;
  String colorImage;
  String colorName;
  String colorCode;
  dynamic showOnMain;
  dynamic isApi;
  dynamic colorImageFile;

  factory RequestColors.fromJson(Map<String, dynamic> json) => RequestColors(
    id: json["id"],
    colorId: json["colorId"],
    requestId: json["requestId"],
    colorImage: json["colorImage"],
    colorName: json["colorName"],
    colorCode: json["colorCode"],
    showOnMain: json["showOnMain"],
    isApi: json["isApi"],
    colorImageFile: json["colorImageFile"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "colorId": colorId,
    "requestId": requestId,
    "colorImage": colorImage,
    "colorName": colorName,
    "colorCode": colorCode,
    "showOnMain": showOnMain,
    "isApi": isApi,
    "colorImageFile": colorImageFile,
  };
}
