class ShortVideo{
  String? id;
  String? content;
  String? videoURL;
  String? createById;
  String? createByName;
  String? createByImage;
  int? commentCount;
  int? likeCount;
  DateTime? createDate;
  DateTime? updatedDate;
  ShortVideo({this.id,this.content,this.videoURL,this.commentCount,this.likeCount,this.createById,this.createByName,this.createByImage,this.createDate,this.updatedDate});
  ShortVideo.fromJson(Map<String, dynamic> json)
      : id = json['Id'],
        content = json['Content'],
        videoURL = json['VideoURL'],
        likeCount = json['LikeCount'],
        commentCount = json['CommentCount'],
        createById = json['CreateById'],
        createByName = json['CreateByName'],
        createByImage = json['CreateByImage'],
        createDate = json['CreateDate'].toDate(),
        updatedDate = json['UpdateDate'].toDate();
        
  Map<String, dynamic> toJson() => {
        'Id': id,
        'Content': content,
        'VideoURL':videoURL,
        'LikeCount':likeCount,
        'CommentCount':commentCount,
        'CreateBy':createById,
        'CreateByName':createByName,
        'CreateByImage':createByImage,
        "CreateDate":createDate,
        'UpdateDate':updatedDate
      };
}