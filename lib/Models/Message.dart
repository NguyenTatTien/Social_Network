class Message{
  final String? message;
  final String? sendById;
  final String? sendByFullName;
  final String? sendByImage;
  final String? objectId;
  final String? type;
  final String? typeChat;
  final DateTime? createDate;
  Message({this.message,this.objectId,this.type,this.typeChat,this.sendById,this.sendByFullName,this.sendByImage,this.createDate});
    Message.fromJson(Map<String, dynamic> json)
      : message = json['Message'],
        type = json["Type"],
        sendById = json['SendById'],
        sendByFullName = json['SendByFullName'],
        sendByImage = json['SendByImage'],
        typeChat = json['TypeChat'],
        objectId = json['ObjectId'],
        createDate = json['CreateDate'].toDate();
      
  Map<String, dynamic> toJson() => {
        'Message': message,
        'Type':type,
        'SendById':sendById,
        'SendByFullName':sendByFullName,
        'SendByImage':sendByImage,
        'ObjectId':objectId,
        'TypeChat':typeChat,
        'CreateDate':createDate
      };
}