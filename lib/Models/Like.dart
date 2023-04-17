// ignore: file_names
class Like{
  String? id;
  String? postId;
  String? userId;
  int? type;
  DateTime? createDate;
  Like({this.id,this.postId,this.userId,this.type,this.createDate});
  Like.fromJson(Map<String, dynamic> json)
      : id = json['Id'],
        postId = json['PostId'],
        userId = json['UserId'],
        type = json['Type'],
        createDate = json['CreateDate'].toDate();
      
  Map<String, dynamic> toJson() => {
        'Id': id,
        'PostId': postId,
        'UserId':userId,
        "Type":type,
        'CreateDate':createDate
      };
}