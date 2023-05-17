class ChatRoom{
  String? id;
  String? userFirstById;
  String? userSecondById;
  String? userFirstByFullName;
  String? userFirstByImage;
  String? userSecondByFullName;
  String? userSecondByImage;
  bool? statusUserFirst;
  bool? statusUserSecond;
  DateTime? createDate;
  ChatRoom({this.id,this.userFirstById,this.userFirstByFullName,this.userFirstByImage,this.userSecondById,this.userSecondByFullName,this.userSecondByImage,this.statusUserFirst,this.statusUserSecond,this.createDate});
   ChatRoom.fromJson(Map<String, dynamic> json)
      : id = json['Id'],
        userFirstById = json['UserFirstById'],
        userFirstByImage = json['UserFirstByImage'],
        userFirstByFullName = json["UserFirstByFullName"],
        userSecondById = json['UserSecondById'],
        userSecondByFullName = json["UserSecondByFullName"],
        userSecondByImage = json["UserSecondByImage"],
        statusUserFirst = json['StatusUserFirst'],
        statusUserSecond = json['StatusUserSecond'],
        createDate = json['CreateDate'].toDate();
        
  Map<String, dynamic> toJson() => {
        'Id': id,
        'UserFirstById': userFirstById,
        'UserFirstByFullName': userFirstByFullName,
        'UserFirstByImage': userFirstByImage,
        'UserSecondById':userSecondById,
        'UserSecondByFullName':userSecondByFullName,
        'UserSecondByImage':userSecondByImage,
        'StatusUserFirst':statusUserFirst,
        'StatusUserSecond':statusUserFirst,
        'CreateDate':createDate,
      };
}