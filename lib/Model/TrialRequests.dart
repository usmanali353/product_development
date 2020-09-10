


import 'package:productdevelopment/Model/Colors.dart';

class TrialRequests{
  int id,requestId,clientId;
  String date,surfaceName,image,clientName,modelName,modelCode,status;
  List<Colors> multipleColors;
  List<dynamic> multipleSizeNames,multipleImages;

  TrialRequests(
      {
      this.id,
      this.requestId,
      this.clientId,
      this.date,
      this.surfaceName,
      this.image,
      this.clientName,
      this.modelName,
      this.modelCode,
      this.multipleColors,
      this.multipleSizeNames,
      this.multipleImages,
        this.status,
      }
      );

}