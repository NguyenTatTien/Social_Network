// ignore: file_names
class Like{
  String? id;
  String? objectId;
  String? userId;
  int? type;
  String?objectType;
  DateTime? createDate;
  Like({this.id,this.objectId,this.userId,this.type,this.objectType,this.createDate});
  Like.fromJson(Map<String, dynamic> json)
      : id = json['Id'],
        objectId = json['ObjectId'],
        userId = json['UserId'],
        type = json['Type'],
        objectType = json["ObjectType"],
        createDate = json['CreateDate'].toDate();
      
  Map<String, dynamic> toJson() => {
        'Id': id,
        'ObjectId': objectId,
        'UserId':userId,
        "Type":type,
        "ObjectType":objectType,
        'CreateDate':createDate
      };
}