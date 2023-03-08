// import 'package:flutter/material.dart';
// import 'package:walkthrough1/mainpage.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       home: MainPage(),
//     );
//   }f
// }

import 'package:do_an_tot_nghiep/Views/message.dart';
import 'package:do_an_tot_nghiep/Views/mainpage.dart';
import 'package:do_an_tot_nghiep/Views/meetup.dart';
import 'package:do_an_tot_nghiep/Views/notification.dart';
import 'package:do_an_tot_nghiep/Views/Guest.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'Design.dart';
/// This Widget is the main application widget.
class NavigatorView extends StatelessWidget {
  const NavigatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyNavigationBar(),
    );
  }
}

class MyNavigationBar extends StatefulWidget {
  const MyNavigationBar({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyNavigationBarState createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    MainPage(),
    const Guest(),
    const Message(),
    Watches(),
    NotificationPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar:
      //  BottomNavigationBar(
      //     items: const <BottomNavigationBarItem>[
      //       BottomNavigationBarItem(
      //           icon: Icon(
      //             Icons.home,
      //             // color: Colors.grey[500],
      //           ),
      //           label: "Home",
      //           backgroundColor: Colors.green),
      //       BottomNavigationBarItem(
      //           icon: Icon(
      //             Icons.person,
      //           ),
      //           label: "Friend",
      //           backgroundColor: Colors.yellow),
      //       BottomNavigationBarItem(
      //         icon: Icon(
      //           Icons.message,
      //         ),
      //         label: "Message",
      //         backgroundColor: Colors.blue,
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.tv),
      //         label: "Watch",
      //         backgroundColor: Colors.blue,
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Icon(
      //           Icons.notification_important_outlined,
      //         ),
      //         label: "Notification",
      //         backgroundColor: Colors.blue,
      //       ),
      //     ],
      //     type: BottomNavigationBarType.fixed,
      //     backgroundColor: Colors.white,
      //     // selectedItemColor: Colors.orange,

      //     unselectedItemColor: Colors.grey[500],
      //     selectedFontSize: 10,
      //     unselectedFontSize: 10,
      //     onTap: _onItemTapped,
      //     currentIndex: _selectedIndex,
      //     selectedItemColor: Colors.orange,
      //     iconSize: 26,
      //     elevation: 5),
      
      // ignore: avoid_unnecessary_containers
      // Container(color: Colors.black,
      // child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 10),child: GNav(
      //   backgroundColor: Colors.black,
      //   color: Colors.white,
      //   activeColor: Colors.white,
      //   tabBackgroundColor: const Color.fromARGB(255, 63, 63, 63),
      //   padding: const EdgeInsets.all(5),
      //   gap: 5,
      //   onTabChange:_onItemTapped,
      //   tabs:const [ 
      //   GButton(icon: Icons.home,text: "Home",),
      //   GButton(icon: Icons.person_outline,text: "Friend",),
      //   GButton(icon: Icons.messenger_outline,text: "Message"),
      //   GButton(icon: Icons.tv,text: "Watch",),
      //   GButton(icon: Icons.notifications_none,text: "Notification",)
      // ]),),)   
       NavigationBarTheme(data:NavigationBarThemeData(indicatorColor: mainColor.withOpacity(0.5),labelTextStyle: MaterialStateProperty.all(const TextStyle(fontSize: 10,fontWeight: FontWeight.bold,color: Colors.black))),
       child:NavigationBar(height: 60,backgroundColor: Colors.white30,animationDuration: const Duration(seconds: 1),selectedIndex: _selectedIndex,onDestinationSelected: _onItemTapped,destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: "Home",selectedIcon: Icon(Icons.home),),
        NavigationDestination(icon: Icon(Icons.person_outline), label: "Person",selectedIcon: Icon(Icons.person),),
        NavigationDestination(icon: Icon(Icons.message_outlined), label: "Message",selectedIcon: Icon(Icons.message),),
        NavigationDestination(icon: Icon(Icons.tv_outlined), label: "Watch",selectedIcon: Icon(Icons.tv),),
        NavigationDestination(icon: Icon(Icons.notifications_outlined), label: "Notification",selectedIcon: Icon(Icons.notifications),)
       ],))
       );
  }
}
