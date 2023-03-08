import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_tot_nghiep/Models/User.dart';
import 'package:do_an_tot_nghiep/Views/Design.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

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
  var controllerAddress = TextEditingController();
  var controllerPassword = TextEditingController();
  User ?user;
  Future getUser() async{
    
     var collection = FirebaseFirestore.instance.collection("User");
     var docSnapshot =  await collection.doc(auth.FirebaseAuth.instance.currentUser!.uid).get();
    setState(() {
      user = User.fromJson(docSnapshot.data()!);
      print(user!.firstName);
    });
  }
    @override
  void initState() {
    user = User();
    // TODO: implement initState
    getUser();
   
    super.initState();
    controllerFirstName.text = user!.firstName!;
    controllerLastName.text = user!.lastName!;
    controllerEmail.text = user!.email!;
    controllerPhone.text = user!.phoneNumber!;
    controllerAddress.text = user!.address!;
    controllerPassword.text = user!.password!;
  }
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(body:
      Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
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
                        child: const CircleAvatar(
                          backgroundImage: AssetImage(
                            'assets/images/tien.jpg'
                          ),
                        )),
                       
                        Positioned(
                              bottom: 0,
                              right: 0, //give the values according to your requirement
                              child: InkWell(onTap: (){
                              
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
        const Expanded (child:Text("First Name:"),flex: 1,),
        _entryField("First Name",controllerFirstName)
      ],),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        // ignore: sort_child_properties_last
        const Expanded (child:Text("Last Name:"),flex: 1,),
        _entryField("Last Name",controllerLastName)
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
          const Expanded (child:Text("Phone:"),flex: 1,),
        _entryField("Phone",controllerPhone)
       
        
        
        
      ],),
      Row(crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded (child:Text("Address:"),flex: 1,),
        _entryField("Address",controllerAddress)
      ],),
      Row(crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded (child:Text("Passwor:"),flex: 1,),
        _entryField("Password",controllerPassword,isPassword: true)
      
      ],),
       Row(crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Expanded(child:Container(height: 50,child:ElevatedButton(onPressed: (){}, child: const Text("Save",style: TextStyle(fontSize: 17),),style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(mainColor)),)))
      ],)
    ],),)
    );
  }
}