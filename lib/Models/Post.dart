// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String? id;
  String? postContent;
  String? postImage;
  int? likeCount;
  int? commentCount;
  String? createBy;
  DateTime? createDate;
  DateTime? updatedDate;
  Post({this.id,this.postContent,this.postImage,this.commentCount,this.likeCount,this.createBy,this.createDate,this.updatedDate});
  Post.fromJson(Map<String, dynamic> json)
      : id = json['Id'],
        postContent = json['Content'],
        postImage = json['Image'],
        likeCount = json['LikeCount'],
        commentCount = json['CommentCount'],
        createBy = json['CreateBy'],
        createDate = json['CreateDate'].toDate(),
        updatedDate = json['UpdateDate'].toDate();
        
  Map<String, dynamic> toJson() => {
        'Id': id,
        'Content': postContent,
        'Image':postImage,
        'LikeCount':likeCount,
        'commentCount':commentCount,
        'CreateBy':createBy,
        "CreateDate":createDate,
        'UpdateDate':updatedDate
      };
  
}