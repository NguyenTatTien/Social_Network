class ChatRoom{
  String? id;
  String? userFirst;
  String? userSecond;
  bool? statusUserFirst;
  bool? statusUserSecond;
  DateTime? createDate;
  ChatRoom({this.id,this.userFirst,this.userSecond,this.statusUserFirst,this.statusUserSecond,this.createDate});
   ChatRoom.fromJson(Map<String, dynamic> json)
      : id = json['Id'],
        userFirst = json['UserFirst'],
        userSecond = json['UserSecond'],
        statusUserFirst = json['StatusUserFirst'],
        statusUserSecond = json['StatusUserSecond'],
        createDate = json['CreateDate'].toDate();
        
  Map<String, dynamic> toJson() => {
        'Id': id,
        'UserFirst': userFirst,
        'UserSecond':userSecond,
        'StatusUserFirst':statusUserFirst,
        'StatusUserSecond':statusUserFirst,
        'CreateDate':createDate,
      };
}