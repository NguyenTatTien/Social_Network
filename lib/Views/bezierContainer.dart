// ignore: file_names
import 'dart:math';
import 'package:do_an_tot_nghiep/Views/ClipperCustom.dart';
import 'package:flutter/material.dart';



class BezierContainer extends StatelessWidget {
  const BezierContainer({Key ?key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: Transform.rotate(
        angle: -pi / 3.5, 
        child: ClipPath(
        clipper: ClipPainter(),
        child: Container(
          height: MediaQuery.of(context).size.height *.5,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xffa26ce4), Color(0xff9900cc)]
              )
            ),
        ),
      ),
      )
    );
  }
}