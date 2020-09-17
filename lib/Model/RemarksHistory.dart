

class RemarksHistory{
  int id;
  int requestId;
  int statusId;
  int requestClientId;
  String remarks;
  dynamic date;
  String remarkedBy;
  String newModelName;
  String newModelCode;
  String remarkedByName;
  String statusName;

  RemarksHistory({
    this.id,
    this.requestId,
    this.statusId,
    this.requestClientId,
    this.remarks,
    this.date,
    this.remarkedBy,
    this.newModelName,
    this.newModelCode,
    this.remarkedByName,
    this.statusName,
  });
 factory RemarksHistory.fromJson(Map<String, dynamic> json) => RemarksHistory(
   id: json["id"],
   requestId: json["requestId"],
   statusId: json["statusId"],
   requestClientId: json["requestClientId"],
   remarks: json["remarks"],
   date: json["date"],
   remarkedBy: json["remarkedBy"],
   newModelName: json["newModelName"],
   newModelCode: json["newModelCode"],
   remarkedByName: json["remarkedByName"],
   statusName: json["statusName"],
 );

 Map<String, dynamic> toJson() => {
   "id": id,
   "requestId": requestId,
   "statusId": statusId,
   "requestClientId": requestClientId,
   "remarks": remarks,
   "date": date,
   "remarkedBy": remarkedBy,
   "newModelName": newModelName,
   "newModelCode": newModelCode,
   "remarkedByName": remarkedByName,
   "statusName": statusName,
 };
}