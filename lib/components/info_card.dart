import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    Key? key,
    required this.name,
  }) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.white24,
        radius: 24,
        child: Icon(
          CupertinoIcons.person,
          size: 28,
          color: Colors.white,
        ),
      ),
      title: Text(
        "Hey there,",
        style: GoogleFonts.comfortaa(
          textStyle: TextStyle(
              color: HexColor("#e8e8e8").withOpacity(0.5),
              fontSize: 12.5,
              fontWeight: FontWeight.w400),
        ),
      ),
      subtitle: Text(
        name,
        style: GoogleFonts.comfortaa(
          textStyle: TextStyle(
              color: HexColor("#e8e8e8"),
              fontSize: 22.5,
              fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}
