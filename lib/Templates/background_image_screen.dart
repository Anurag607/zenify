import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:zenify/utils/database.dart';

class BackgroundImageScreen extends StatelessWidget {
  final String bgImageURL;
  final String shaderMaskColor;
  final Widget child;
  const BackgroundImageScreen(
      {required this.bgImageURL,
      required this.shaderMaskColor,
      required this.child,
      super.key});

  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  static final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();

  static final ZenifyDatabase db = ZenifyDatabase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: HexColor(shaderMaskColor),
        body: Stack(
          fit: StackFit.expand,
          children: [
            ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, HexColor(shaderMaskColor)],
                  tileMode: TileMode.mirror,
                ).createShader(
                  Rect.fromLTRB(0, 0, rect.width, rect.height),
                );
              },
              blendMode: BlendMode.srcOver,
              child: Container(
                decoration: BoxDecoration(
                  color: HexColor(shaderMaskColor),
                  image: DecorationImage(
                      image: AssetImage(bgImageURL), fit: BoxFit.cover),
                ),
              ),
            ),
            LiquidPullToRefresh(
              key: _refreshIndicatorKey,
              springAnimationDurationInMilliseconds: 300,
              height: 150,
              color: Colors.transparent,
              backgroundColor: HexColor(shaderMaskColor),
              borderWidth: 0,
              onRefresh: () async {
                db.getTasks();
                await Future.delayed(const Duration(seconds: 2));
                _refreshIndicatorKey.currentState?.show();
              },
              showChildOpacityTransition: true,
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                    clipBehavior: Clip.antiAlias,
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        child,
                      ],
                    )),
              ),
            )
          ],
        ));
  }
}
