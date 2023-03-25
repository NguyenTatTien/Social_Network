// ignore: file_names
class Like{
  String? id;
  String? postId;
  String? userId;
   DateTime? createDate;
  Like({this.id,this.postId,this.userId,this.createDate});
  Like.fromJson(Map<String, dynamic> json)
      : id = json['Id'],
        postId = json['PostId'],
        userId = json['UserId'],
        createDate = json['CreateDate'].toDate();
      
  Map<String, dynamic> toJson() => {
        'Id': id,
        'PostId': postId,
        'UserId':userId,
        'CreateDate':createDate
      };
}