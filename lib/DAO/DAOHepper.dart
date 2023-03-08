

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_tot_nghiep/Models/Post.dart';
import 'package:do_an_tot_nghiep/Models/User.dart';

  // ignore: non_constant_identifier_names
   CreateData(String collection,var object) async{
    DocumentReference documentReference = FirebaseFirestore.instance.collection(collection).doc(object.id);
  
    final json = object.toJson();
    await documentReference.set(json);
  }
  // ignore: non_constant_identifier_names
  CreateNewData(String collection,var object) async{
    DocumentReference documentReference = FirebaseFirestore.instance.collection(collection).doc();
    object.id = documentReference.id;
    final json = object.toJson();
    await documentReference.set(json);
  }
  // ignore: non_constant_identifier_names
  Future<List<List<Object>>> listPost(String collection) async{
       var lsPost = <Post>[];
       var lsUserByPost = <User>[]; 
       var listObject = <List<Object>>[];
    await FirebaseFirestore.instance.collection(collection).orderBy("CreateDate",descending: true).get().then((value){value.docs.forEach((result){
        lsPost.add(Post.fromJson(result.data()));
    });});   
   for(var post in lsPost){
     var collection =  FirebaseFirestore.instance.collection("User");
          var docSnapshot =  await collection.doc(post.createBy).get();
          lsUserByPost.add(User.fromJson(docSnapshot.data()!));
   }
    listObject.add(lsPost);
    listObject.add(lsUserByPost);
    return listObject;
  }
  