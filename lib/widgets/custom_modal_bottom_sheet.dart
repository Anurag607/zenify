import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class CustomBottomModalSheet {
  static void customBottomModalSheet(
      BuildContext context, double height, Widget child) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        backgroundColor: HexColor("#102844"),
        enableDrag: true,
        showDragHandle: false,
        builder: (context) {
          return Container(
            height: height,
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Stack(
              children: [
                const Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: Icon(Icons.expand_more, color: Colors.white, size: 30),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: child,
                ),
              ],
            ),
          );
        });
  }
}
