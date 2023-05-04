import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/User.dart';
import 'package:do_an_tot_nghiep/Views/Design.dart';
import 'package:do_an_tot_nghiep/Views/Profile.dart';
import 'package:do_an_tot_nghiep/Views/loginPage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  var controllerFirstName = TextEditingController();
  var controllerLastName = TextEditingController();
  var controllerEmail = TextEditingController();
  var controllerPhone = TextEditingController();
  String address = ""; 
  var controllerPassword = TextEditingController();
  String countryValue = "";
  String stateValue="";
  String cityValue = "";
  String birthDay = "Hãy chọn ngày sinh"; 
  User ?user;
  Future getUser() async{
    
     var collection = FirebaseFirestore.instance.collection("User");
     var docSnapshot =  await collection.doc(auth.FirebaseAuth.instance.currentUser!.uid).get();
    setState(() {
      user = User.fromJson(docSnapshot.data()!);
     
    });
    controllerFirstName.text = user!.firstName!;
    controllerLastName.text = user!.lastName!;
    controllerEmail.text = user!.email!;
    controllerPhone.text = user!.phoneNumber!;
    //controllerPassword.text = user!.password!;
    address = user!.address!;
    if(user!.birthDay.toString()!=""){
      birthDay = user!.birthDay!;
    }
    setState(() {
      address;
    });
    
  }
    @override
  void initState() {
    countryValue= "Viet Nam";
    stateValue= "State";
    cityValue= "City";

    user = User();
    // TODO: implement initState
    getUser();
    super.initState();
  
  }
  Future showCustomDialog()=> showDialog(context: context, builder: (context)=>AlertDialog(
    content:Container(height: 100,child:Expanded(flex: 3,child:CSCPicker(showStates: true,showCities: true,countryFilter: const [CscCountry.Vietnam,CscCountry.Vietnam,CscCountry.Vietnam],
                  onCountryChanged:(value) {
                 countryValue = value;
      			
                  },
                   onStateChanged:(value) {
                  
                     stateValue = value!=null?value.toString():"";
      		},
           onCityChanged:(value) {
                 
                     cityValue = value!=null?value.toString():"";
      		
      		}
                  ))),
                  actions:[Expanded(child: ElevatedButton(onPressed: (){
                    address = cityValue!="City"?cityValue+", "+stateValue+", "+countryValue :stateValue!="State"?stateValue+", "+countryValue:countryValue!="Viet Nam"?countryValue:"";
                    setState(() {
                      address;
                    });
                    Navigator.pop(context);
                  }, child: Text("Lưu"))),
                  Expanded(child: ElevatedButton(onPressed: (){Navigator.pop(context);}, child: Text("Thoát")))
                  ] ,
  ));
   
    


Widget _entryField(String title,var controller, {bool isPassword = false}) {
    return Expanded(flex: 3,child: Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: 
          TextField(
              controller:controller ,
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: const Color(0xfff3f3f4),
                  filled: true,hintText: title))
        
      
    ));
  }
  void updateProfile(){
          user!.firstName = controllerFirstName.text;
          user!.lastName = controllerLastName.text;
          user!.email = controllerEmail.text;
          user!.phoneNumber = controllerPhone.text;
          //user!.password = controllerPassword.text;
          user!.birthDay = birthDay;
          // ignore: prefer_interpolation_to_compose_strings
          if(stateValue!="State"){
            user!.address = address!=""?address:user!.address;
          }
          
          
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(body:
      Container(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
      children:<Widget> [
       Stack(
                  children: <Widget>[
                    Container(
                        height: 120,
                        width: 120,
                        margin: const EdgeInsets.only(
                            left: 0, right: 0, top: 20, bottom: 5),
                        padding: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: const Color.fromARGB(255, 0, 207, 142), width: 2),
                            borderRadius: BorderRadius.circular(100)),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            '${user!.image}'
                          ),
                        )),
                       
                        Positioned(
                              bottom: 0,
                              right: 0, //give the values according to your requirement
                              child: InkWell(onTap: () async{
                              FilePickerResult? result = await FilePicker.platform.pickFiles();
              // ignore: unnecessary_null_comparison
             
                                if(result!=null)
                                {
                                  final file = File(result.files.first.path!);
                                  // ignore: curly_braces_in_flow_control_structures, use_build_context_synchronously
                                   var firebaseStorage =  FirebaseStorage.instance.ref().child("image/${auth.FirebaseAuth.instance.currentUser!.uid}/${DateTime.now().toString()}");
                                    if( user!.image != "https://firebasestorage.googleapis.com/v0/b/project-cb943.appspot.com/o/image%2FlogoPreson%2FUnknown_person.jpg?alt=media&token=061d880a-9464-41e4-af7e-c259aedcaef7"){
                                       await firebaseStorage.child(user!.image!).delete();
                                    }
                                    await firebaseStorage.putFile(file);
                                    user!.image = await firebaseStorage.getDownloadURL();
                                    updateData("User", user);
                                    setState(() {
                                      user;
                                    });
                                }
                            }, child:Material(
                                  color: mainColor,
                                  elevation: 10,
                                  borderRadius: BorderRadius.circular(100),
                                  child: const Padding(
                                    padding: EdgeInsets.all(3.0),
                                    child: Icon(
                                      Icons.camera,
                                      size: 45,
                                      color: Colors.white,
                                    ),
                                  )),)
                            )
                  ],
                ),
      SizedBox(height: 10,),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        const Expanded (child:Text("Tên:"),flex: 1,),
        _entryField("Nhập tên",controllerFirstName)
      ],),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        // ignore: sort_child_properties_last
        const Expanded (child:Text("Họ:"),flex: 1,),
        _entryField("Nhập họ",controllerLastName)
      ],),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded (child:Text("Email:"),flex: 1,),
        _entryField("Email",controllerEmail)
      ],),
      Row(crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded (child:Text("Số điện thoại:"),flex: 1,),
        _entryField("Nhập số điện thoại",controllerPhone)
       
      ],),
      Row(crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded (child:Text("Địa chỉ:"),flex: 1,),
       
        	// Expanded(flex: 3,child:CSCPicker(showStates: true,showCities: true,countryFilter: const [CscCountry.Vietnam,CscCountry.Vietnam,CscCountry.Vietnam],
          //         onCountryChanged:(value) {
          //        countryValue = value;
          
              Expanded(child:InkWell(onTap: (){ showCustomDialog();},child:TextField(enabled: false,controller: TextEditingController(),decoration: InputDecoration(hintText: address,border: InputBorder.none,fillColor: Color(0xfff3f3f4),filled: true),)),flex: 3,)
      			
      		
      ],),
      // Row(crossAxisAlignment: CrossAxisAlignment.center,
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     const Expanded (child:Text("Password:"),flex: 1,),
      //   _entryField("Password",controllerPassword,isPassword: true)
      
      // ],),
      Row(crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded (flex: 1,child:Text("Ngày sinh:"),),
          Expanded(flex: 3,child:TextButton(
    onPressed: () {
        DatePicker.showDatePicker(context,
                              showTitleActions: true,
                              minTime: DateTime(1900, 1,1),
                              maxTime: DateTime(2024, 1, 1), onConfirm: (date) {
                              setState(() {
                                birthDay = DateFormat('dd/MM/yyyy').format(date).toString();
                              });
                          }, currentTime: DateTime.now(), locale: LocaleType.vi);
    },
    child: Text(
        '${birthDay}',
        style: TextStyle(color: Colors.blue,fontSize: 17),
    )))
      
      ],),
       
    ],),)
    ),
    bottomNavigationBar: Padding(

        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Container(
          height: 50,
          child:
          ElevatedButton(
          onPressed: () {
                updateProfile();
                updateData("User",user);
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(user!.id)));
               
          },
          
          style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(mainColor)), child: const Text("Lưu",style: TextStyle(fontSize: 17),)
        ),
      ),
    ));
  }
}