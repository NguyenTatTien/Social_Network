class GroupChat{
  String? id;
  String? groupName;
  String? avatarGroup;
  String? adminId;
  String? adminFullName;
  DateTime? createDate;
  GroupChat({this.id,this.groupName,this.avatarGroup,this.adminId,this.adminFullName,this.createDate});
   GroupChat.fromJson(Map<String, dynamic> json)
      : id = json['Id'],
        groupName = json['GroupName'],
        avatarGroup = json['AvatarGroup'],
        adminId = json['AdminId'],
        adminFullName = json['AdminFullName'],
        createDate = json['CreateDate'].toDate();
        
  Map<String, dynamic> toJson() => {
        'Id': id,
        'GroupName':groupName,
        'AvatarGroup':avatarGroup,
        'AdminId':adminId,
        'AdminFullName':adminFullName,
        'CreateDate':createDate,
      };
       GroupChat.formJson2(Map<String, dynamic> json)
      : id = json['Id'],
        groupName = json['GroupName'],
        avatarGroup = json['AvatarGroup'],
        adminId = json['AdminId'],
        adminFullName = json['AdminFullName'],
        createDate = json['CreateDate'];
        
}