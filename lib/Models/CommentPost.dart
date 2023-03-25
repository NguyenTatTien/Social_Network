// ignore: file_names
class CommentPost{
   String? id;
   String? postId;
   String? userId;
   String? parentId;
   String? content;
   String? receiver;
   DateTime? createDate;
  CommentPost({this.id,this.postId,this.userId,this.parentId,this.content,this.receiver,this.createDate});
  CommentPost.fromJson(Map<String, dynamic> json)
      : id = json['Id'],
        postId = json['PostId'],
        userId = json['UserId'],
        parentId = json['ParentId'],
        receiver = json['Receiver'],
        content = json['Content'],
        createDate = json['CreateDate'].toDate();
  Map<String, dynamic> toJson() => {
        'Id': id,
        'PostId': postId,
        'UserId':userId,
        'ParentId':parentId,
        "Receiver":receiver,
        'Content':content,
        "CreateDate":createDate,
      };
}