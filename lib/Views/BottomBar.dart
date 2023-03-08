import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: avoid_unnecessary_containers
      bottomNavigationBar:Container(child: const Padding(padding: EdgeInsets.symmetric(horizontal: 15,vertical: 20),child: GNav(
        backgroundColor: Colors.black,
        color: Colors.white,
        activeColor: Colors.white,
        tabBackgroundColor: Color.fromARGB(255, 63, 63, 63),
        padding: EdgeInsets.all(16),
        gap: 8,
        tabs:[ 
        GButton(icon: Icons.home,text: "Home",),
        GButton(icon: Icons.person_outline,text: "Friend",),
        GButton(icon: Icons.messenger_outline,text: "Message"),
        GButton(icon: Icons.tv,text: "Watch",),
        GButton(icon: Icons.notifications_none,text: "Notification",)
      ]),),)
    );
  }
}