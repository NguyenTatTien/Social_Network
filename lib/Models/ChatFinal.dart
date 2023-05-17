class ChatFinal{
  String? id;
  Object? object;
  String? typeChat;
  String? chatFinalByUserId;
  String? chatFinalByUserFullName;
  String? chatContentFinal;
  DateTime? chatFinalDate;
  ChatFinal({this.id,this.object,this.typeChat,this.chatContentFinal,this.chatFinalByUserFullName,this.chatFinalByUserId,this.chatFinalDate});
   ChatFinal.fromJson(Map<String, dynamic> json)
      : id = json['Id'],
        object = json["Object"],
        typeChat = json['TypeChat'],
        chatContentFinal = json['ChatContentFinal'],
        chatFinalByUserFullName = json['ChatFinalByUserFullName'],
        chatFinalByUserId = json['ChatFinalByUserId'],
        chatFinalDate = json['ChatFinalDate'].toDate();
  Map<String, dynamic> toJson() => {
        'Id': id,
        "Object":object,
        'ChatContentFinal':chatContentFinal,
        'ChatFinalByUserFullName':chatFinalByUserFullName,
        'ChatFinalByUserId':chatFinalByUserId,
        'TypeChat':typeChat,
        'ChatFinalDate':chatFinalDate
      };

}