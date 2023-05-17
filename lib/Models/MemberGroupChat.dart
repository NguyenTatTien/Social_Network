class MemberGroupChat{
  String? id;
  String? groupId;
  String? userId;
  DateTime? joinDate;
  MemberGroupChat({this.id,this.groupId,this.userId,this.joinDate});
  MemberGroupChat.fromJson(Map<String, dynamic> json)
      : id = json['Id'],
        groupId = json['GroupId'],
        userId = json['UserId'],
        joinDate = json['JoinDate'].toDate();
      
  Map<String, dynamic> toJson() => {
        'Id': id,
        'GroupId': groupId,
        'UserId':userId,
        'JoinDate':joinDate
      };
}