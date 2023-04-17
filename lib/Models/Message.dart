class Message{
  final String? content;
  final int? conversation;
  final int? sender;
  final int? receiver;
  final DateTime? createDate;
  Message({this.content,this.conversation,this.sender,this.receiver,this.createDate});
    Message.fromJson(Map<String, dynamic> json)
      : content = json['Content'],
        conversation = json['Conversation'],
        sender = json['Sender'],
        receiver = json['Receiver'],
        createDate = json['CreateDate'].toDate();
      
  Map<String, dynamic> toJson() => {
        'Content': content,
        'Conversation': conversation,
        'Sender':sender,
        "Receiver":receiver,
        'CreateDate':createDate
      };
}