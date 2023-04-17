import 'package:flutter/material.dart';
class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  late ScrollController controller;
  List<String> items = List.generate(100, (index) => 'Hello $index');

  @override
  void initState() {
    super.initState();
    controller = ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        child: ListView.builder(
          controller: controller,
          itemBuilder: (context, index) {
            return Text(items[index]);
          },
          itemCount: items.length,
        ),
      ),
    );
  }

  void _scrollListener() {
    print(controller.position.extentAfter);
    if (controller.position.extentAfter < 500) {
      print("loading.........");
      setState(() {
        items.addAll(List.generate(42, (index) => 'Inserted $index'));
      });
    }
  }
}