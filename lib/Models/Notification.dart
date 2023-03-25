class NotificationObject{
  String? id;
  String? content;
  String? receiver;
  String? idObject;
  String? sender;
  DateTime? createDate;
  NotificationObject({this.id,this.content,this.receiver,this.idObject,this.sender,this.createDate});
  NotificationObject.fromJson(Map<String, dynamic> json)
      : id = json['Id'],
        content = json['Content'],
        receiver = json['Receiver'],
        idObject = json['ObjectId'],
        sender = json['Sender'],
        createDate = json['CreateDate'].toDate();
  Map<String, dynamic> toJson() => {
        'Id': id,
        'Content': content,
        'Receiver':receiver,
        'Sender':sender,
        'ObjectId':idObject,
        "CreateDate":createDate,
      };

}