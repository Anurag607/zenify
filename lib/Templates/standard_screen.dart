import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class ThemedScreen extends StatelessWidget {
  final String title;
  final Widget child;

  ThemedScreen({super.key, required this.title, required this.child});

  final List<dynamic> _gradientList = [
    [HexColor("#AD1DEB"), HexColor("#6E72FC")],
    [HexColor("#5D3FD3"), HexColor("#1FD1F9")],
    [HexColor("#B621FE"), HexColor("#1FD1F9")],
    [HexColor("#E975A8"), HexColor("#726CF8")],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: const Alignment(-1, -1),
                end: const Alignment(1, 1),
                colors: _gradientList[1]),
          ),
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height - 40,
            child: SingleChildScrollView(
                clipBehavior: Clip.antiAlias,
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 140,
                          child: Column(
                            children: [
                              const SizedBox(height: 75),
                              Text(title,
                                  style: TextStyle(
                                      fontSize: 25,
                                      color: HexColor("#f6f8fe"),
                                      fontWeight: FontWeight.bold)),
                            ],
                          )),
                      SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height - 100,
                        child: Expanded(
                            child: Container(
                          clipBehavior: Clip.antiAlias,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: HexColor("#f6f8fe"),
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(50),
                                topRight: Radius.circular(50)),
                          ),
                          child: child,
                        )),
                      )
                    ])),
          )),
    );
  }
}
