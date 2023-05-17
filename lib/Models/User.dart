import 'dart:ffi';

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
  String? birthDay;
  DateTime? createDate;
  bool? status;
  String? token;
  
  // ignore: invalid_required_positional_param
  User({this.id,this.firstName, this.lastName,this.email,this.image,this.phoneNumber,this.birthDay,this.address,this.password,this.createDate,this.status});
    User.fromJson(Map<String, dynamic> json)
      : id = json['Id'],
        email = json['Email'],
        firstName = json['FirstName'],
        lastName = json['LastName'],
        image = json['Image'],
        password = json['Password'],
        phoneNumber = json['PhoneNumber'],
        address = json['Address'],
        birthDay = json['BirthDay'],
        status = json['Status'],
        token = json['Token'],
        createDate = json['CreateDate'].toDate();
        
  Map<String, dynamic> toJson() => {
        'Id': id,
        'Image': image,
        'FirstName':firstName,
        'LastName':lastName,
        'Password':password,
        'Email':email,
        "PhoneNumber":phoneNumber,
        "Address":address,
        "BirthDay":birthDay,
        'CreateDate':createDate,
        'Status':status,
        'Token':token
      };
       User.fromJson2(Map<String, dynamic> json)
      : id = json['Id'],
        email = json['Email'],
        firstName = json['FirstName'],
        lastName = json['LastName'],
        image = json['Image'],
        password = json['Password'],
        phoneNumber = json['PhoneNumber'],
        address = json['Address'],
        birthDay = json['BirthDay'],
        status = json['Status'],
        token = json['Token'],
        createDate = json['CreateDate'];
}
