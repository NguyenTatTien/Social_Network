import 'package:flutter/material.dart';

class User {
  String? id;
  String? image;
  String? firstName;
  String? lastName;
  String? password;
  String? email;
  String? phoneNumber;
  String? address;
  DateTime? createDate;
  
  // ignore: invalid_required_positional_param
  User({this.id,this.firstName, this.lastName,this.email,this.image,this.phoneNumber,this.address,this.password,this.createDate});
    User.fromJson(Map<String, dynamic> json)
      : id = json['Id'],
        email = json['Email'],
        firstName = json['FirstName'],
        lastName = json['LastName'],
        image = json['Image'],
        password = json['Password'],
        phoneNumber = json['PhoneNumber'],
        address = json['Address'],
        createDate = json['CreateDate'];
        
  Map<String, dynamic> toJson() => {
        'Id': id,
        'Image': image,
        'FirstName':firstName,
        'LastName':lastName,
        'Passwor':password,
        'Email':email,
        "PhoneNumber":phoneNumber,
        "Address":address,
        'CreateDate':createDate
      };
}
