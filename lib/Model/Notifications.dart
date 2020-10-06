class Notifications {
  Notifications({
    this.userId,
    this.notificationsOfUserId,
    this.read,
    this.notificationDetails,
  });

  String userId;
  int notificationsOfUserId;
  bool read;
  NotificationDetails notificationDetails;

  factory Notifications.fromJson(Map<String, dynamic> json) => Notifications(
    userId: json["userId"],
    notificationsOfUserId: json["notificationsOfUserId"],
    read: json["read"],
    notificationDetails: NotificationDetails.fromJson(json["notificationDetails"]),
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "notificationsOfUserId": notificationsOfUserId,
    "read": read,
    "notificationDetails": notificationDetails.toJson(),
  };
}

class NotificationDetails {
  NotificationDetails({
    this.id,
    this.requestId,
    this.userId,
    this.title,
    this.body,
    this.dateTime,
  });

  int id;
  int requestId;
  String userId;
  String title;
  String body;
  DateTime dateTime;

  factory NotificationDetails.fromJson(Map<String, dynamic> json) => NotificationDetails(
    id: json["id"],
    requestId: json["requestId"],
    userId: json["userId"],
    title: json["title"],
    body: json["body"],
    dateTime: DateTime.parse(json["dateTime"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "requestId": requestId,
    "userId": userId,
    "title": title,
    "body": body,
    "dateTime": dateTime.toIso8601String(),
  };
}