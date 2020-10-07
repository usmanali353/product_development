class ClientVisitSchedule{
  ClientVisitSchedule({
    this.id,
    this.requestId,
    this.clientId,
    this.statusId,
    this.clientVisitDate,
    this.actualClientVisitDate,
    this.status,
    this.clientName,
    this.modelCode,
    this.modelName,
  });
  int id;
  int requestId;
  String clientId;
  dynamic statusId;
  dynamic clientVisitDate;
  dynamic actualClientVisitDate;
  String status;
  String clientName;
  String modelCode;
  String modelName;
  factory ClientVisitSchedule.fromJson(Map<String, dynamic> json) => ClientVisitSchedule(
    id: json["id"],
    requestId: json["requestId"],
    clientId: json["clientId"],
    statusId: json["statusId"],
    clientVisitDate:json["clientVisitDate"],
    actualClientVisitDate: json["actualClientVisitDate"],
    status: json["status"],
    clientName: json["clientName"],
    modelCode: json["modelCode"],
    modelName: json["modelName"],
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    "requestId": requestId,
    "clientId": clientId,
    "statusId": statusId,
    "clientVisitDate": clientVisitDate,
    "actualClientVisitDate": actualClientVisitDate,
    "status": status,
    "clientName": clientName,
    "modelCode": modelCode,
    "modelName": modelName,
  };
}
