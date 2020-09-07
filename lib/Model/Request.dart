class Request {
  int requestId, marketId, statusId, classificationId, rangeId, technologyId,
      structureId, edgeId, surfaceId,id;
  String technicalConcentration, event,statusName,surfaceName,date,designerObservation,customerObservation,modelName,modelCode,trialDate,closeing_date,userId,classificationName,marketName,technologyName,structureName,edgeName,rangeName,client,targetStartDate,targetEndDate,actualStartDate,actualEndDate,status,qrcodeImage,clientName;
  double thickness;
  var image;
  DateTime dateTime;
  List<dynamic> multipleColors,multipleSizes,multipleDesignTopoligies,multipleSuitability,multipleDesigners,multipleColorNames,multipleSizeNames,multipleDesignTopoligyNames,multipleSuitabilityNames,multipleDesignerNames,multipleClientNames;
  Request({
    this.requestId,
    this.marketId,
    this.statusId,
    this.classificationId,
    this.rangeId,
    this.technologyId,
    this.structureId,
    this.edgeId,
    this.surfaceId,
    this.technicalConcentration,
    this.event,
    this.image,
    this.thickness,
    this.multipleColors,
    this.multipleSizes,
    this.multipleDesignTopoligies,
    this.multipleSuitability,
    this.multipleDesigners,
    this.designerObservation,
    this.customerObservation,
    this.userId,
    this.client
  });
  Map<String, dynamic> toJson() {
    var map = new Map<String, dynamic>();
    map["requestId"] = requestId;
    map["marketId"]=marketId;
    map["statusId"]=statusId;
    map["classificationId"]=classificationId;
    map["rangeId"]=rangeId;
    map["technologyId"]=technologyId;
    map["structureId"]=structureId;
    map["edgeId"]=edgeId;
    map["surfaceId"]=surfaceId;
    map["technicalConcentration"]=technicalConcentration;
    map["event"]=event;
    map["image"]=image;
    map["thickness"]=thickness;
    map["multipleColors"]=multipleColors;
    map["multipleSizes"]=multipleSizes;
    map["multipleDesignTopoligies"]=multipleDesignTopoligies;
    map["multipleSuitability"]=multipleSuitability;
    map["multipleDesigners"]=multipleDesigners;
    map["statusName"]=statusName;
    map["surfaceName"]=surfaceName;
    map["date"]=date;
    map["designerObservation"]=designerObservation;
    map["customerObservation"]=customerObservation;
    map['userId']=userId;
    map['multipleDesignTopoligyNames']=multipleDesignTopoligyNames;
    map['multipleColorNames']=multipleColorNames;
    map['multipleSizeNames']=multipleSizeNames;
    map['multipleSuitabilityNames']=multipleSuitabilityNames;
    map['multipleDesignerNames']=multipleDesignerNames;
    map['classificationName']=classificationName;
    map['marketName']=marketName;
    map['structureName']=structureName;
    map['edgeName']=edgeName;
    map['technologyName']=technologyName;
    map['rangeName']=rangeName;
    map['client']=client;
    map['modelName']=modelName;
    map['modelCode']=modelCode;
    map['targetStartDate']=targetStartDate;
    map['targetEndDate']=targetEndDate;
    map['actualStartDate']=actualStartDate;
    map['actualEndDate']=actualEndDate;
    map['status']=status;
    map['id']=id;
    map['multipleClientNames']=multipleClientNames;
    map['qrcodeImage']=qrcodeImage;
    map['clientName']=clientName;
    return map;
  }
  Request.fromMap(Map<String,dynamic> data){
    requestId=data['requestId'];
    marketId=data["marketId"];
    statusId=data["statusId"];
    classificationId=data["classificationId"];
    rangeId=data["rangeId"];
    technologyId=data["technologyId"];
    structureId=data["structureId"];
    edgeId=data["edgeId"];
    surfaceId=data["surfaceId"];
    technicalConcentration=data["technicalConcentration"];
    event=data["event"];
    image=data["image"];
    thickness=data["thickness"];
    multipleColors=data["multipleColors"];
    multipleSizes=data["multipleSizes"];
    multipleDesignTopoligies=data["multipleDesignTopoligies"];
    multipleSuitability=data["multipleSuitability"];
    statusName=data["statusName"];
    surfaceName=data["surfaceName"];
    date=data["date"];
    multipleDesigners=data["multipleDesigners"];
    designerObservation=data["designerObservation"];
    customerObservation=data["customerObservation"];
    userId=data['userId'];
    multipleSizeNames=data['multipleSizeNames'];
    multipleDesignTopoligyNames=data['multipleDesignTopoligyNames'];
    multipleColorNames=data['multipleColorNames'];
    multipleSuitabilityNames=data['multipleSuitabilityNames'];
    multipleDesignerNames=data['multipleDesignerNames'];
    classificationName=data['classificationName'];
    marketName=data['marketName'];
    edgeName=data['edgeName'];
    technologyName=data['technologyName'];
    structureName=data['structureName'];
    rangeName=data['rangeName'];
    client=data["client"];
    modelName=data["modelName"];
    modelCode=data["modelCode"];
    targetStartDate=data['targetStartDate'];
    targetEndDate=data['targetEndDate'];
    actualStartDate=data['actualStartDate'];
    actualEndDate=data['actualEndDate'];
    status=data['status'];
    id=data['id'];
    multipleClientNames=data['multipleClientNames'];
    qrcodeImage=data['qrcodeImage'];
    clientName=data['clientName'];
  }

}
