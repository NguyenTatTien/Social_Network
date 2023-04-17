import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/Post.dart';
import 'package:do_an_tot_nghiep/Views/message.dart';
import 'package:do_an_tot_nghiep/Views/first.dart';
import 'package:do_an_tot_nghiep/Views/status.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class MainPage extends StatelessWidget {
  static var scrollController = ScrollController();
  MainPage({super.key});
 
 
  @override
  Widget build(BuildContext context) {
       
        return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          controller: scrollController,
          child:Column(
         
          children: [
            SizedBox(height: 220,child:Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 30,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 15.0),
                        child: Text(
                          'Socio Network',
                          style: GoogleFonts.lato(
                              color: Colors.grey[700],
                              fontSize: 16,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      // ignore: unnecessary_new
                      var route = new MaterialPageRoute(
                        // ignore: unnecessary_new
                        builder: (BuildContext context) => const Message(),
                      );

                      Navigator.of(context).push(route);
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 20.0, top: 4),
                      child: Icon(Icons.link),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              // Image.asset(
              //   'images/first.png',
              //   height: 300,
              // ),
              Container(color: Colors.white, height: 125, child: Status()),
              const SizedBox(
                height: 0,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 0, right: 0),
                
                child: Divider(color: Color.fromARGB(95, 46, 46, 46),thickness: 5,),
              )])),
             
            FirstFeedIU(),
            
             
            ],
          ),
        ));
  }
}
