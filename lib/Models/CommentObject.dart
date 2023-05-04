// ignore: file_names
class CommentObject{
   String? id;
   String? postId;
   String? userId;
   String? parentId;
   String? content;
   String? receiver;
   String? type;
   DateTime? createDate;
  CommentObject({this.id,this.postId,this.userId,this.parentId,this.content,this.receiver,this.type,this.createDate});
  CommentObject.fromJson(Map<String, dynamic> json)
      : id = json['Id'],
        postId = json['ObjectId'],
        userId = json['UserId'],
        parentId = json['ParentId'],
        receiver = json['Receiver'],
        content = json['Content'],
        type = json['Type'],
        createDate = json['CreateDate'].toDate();
  Map<String, dynamic> toJson() => {
        'Id': id,
        'ObjectId': postId,
        'UserId':userId,
        'ParentId':parentId,
        "Receiver":receiver,
        'Content':content,
        "Type":type,
        "CreateDate":createDate,
      };
}