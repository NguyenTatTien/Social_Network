class Call{
  String? id;
  String? callerId;
  String? callerName;
  String? callerPic;
  String? receiverId;
  String? receiverName;
  String? receiverPic;
  String? channelId;
  bool? hasDialled;
  Call({this.id,this.callerId,this.callerName,this.callerPic,this.channelId,this.hasDialled,this.receiverId,this.receiverName,this.receiverPic});
  Call.fromJson(Map<String, dynamic> json)
      : id = json['Id'],
        callerId = json['CallerId'],
        callerName = json['CallerName'],
        callerPic = json['CallerPic'],
        receiverId = json['ReceiverId'],
        receiverName = json['ReceiverName'],
        receiverPic = json['ReceiverPic'],
        channelId = json['ChannelId'],
        hasDialled = json['HasDialled'];
        
  Map<String, dynamic> toJson() => {
        'Id': id,
        'CallerId': callerId,
        'CallerName':callerName,
        'CallerPic':callerPic,
        'ReceiverId':receiverId,
        'ReceiverName':receiverName,
        "ReceiverPic":receiverPic,
        "ChannelId":channelId,
        "HasDialled":hasDialled,
      };
}