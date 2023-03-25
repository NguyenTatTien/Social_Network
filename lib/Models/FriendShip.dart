
import 'User.dart';

class FriendShip{
  String? id;
  String? requester;
  String? addressee;
  bool? status;
  FriendShip({this.id,this.addressee,this.requester,this.status});
    FriendShip.fromJson(Map<String, dynamic> json)
      : id = json['Id'],
        requester = json['Requester'],
        addressee = json['Addressee'],
        status = json['Status'];
        
  Map<String, dynamic> toJson() => {
        'Id': id,
        'Requester': requester,
        'Addressee':addressee,
        'Status':status,
      };
}
class OtherShip{
  User? user;
  int? status;
  OtherShip({this.user,this.status});
}