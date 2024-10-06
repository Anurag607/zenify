import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:rive/rive.dart' as rive;
import 'package:swipe_to/swipe_to.dart' as swipe_detector;
import 'package:zenify/Templates/background_image_screen.dart';
import 'package:zenify/pages/home_page.dart';
import 'package:zenify/pages/music_page.dart';
import 'package:zenify/redux/states/navigation_state.dart';
import 'package:zenify/widgets/custom_bottomnavbar.dart' as custom_bottomnavbar;
import '../../models/menu.dart';
import 'package:zenify/components/menu_btn.dart';
import 'package:zenify/components/side_bar.dart';
import 'schedule_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  bool isSideBarOpen = false;

  Menu selectedSideMenu = sidebarMenus.first;

  late rive.SMIBool isMenuOpenInput;

  late final AnimationController _animationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 200))
    ..addListener(
      () {
        setState(() {});
      },
    );
  late final Animation<double> scalAnimation = Tween<double>(begin: 1, end: 0.8)
      .animate(CurvedAnimation(
          parent: _animationController, curve: Curves.fastOutSlowIn));

  late final Animation<double> animation = Tween<double>(begin: 0, end: 1)
      .animate(CurvedAnimation(
          parent: _animationController, curve: Curves.fastOutSlowIn));

  Widget child = Container(
    height: 1000,
    width: double.infinity,
    color: Colors.transparent,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const BackgroundImageScreen(
      bgImageURL: "assets/Backgrounds/light-bg.jfif",
      shaderMaskColor: "#102844",
      child: HomePage(),
    ),
    const BackgroundImageScreen(
      bgImageURL: "assets/Backgrounds/evening-bg.jpg",
      shaderMaskColor: "#102844",
      child: SchedulePage(),
    ),
    const MusicPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return StoreConnector<NavigationState, int>(
      converter: (store) => store.state.tabIndex,
      builder: (context, int stateNavigationIndex) => Scaffold(
        key: _scaffoldKey,
        body: swipe_detector.SwipeTo(
          iconColor: Colors.transparent,
          onRightSwipe: (details) {
            isMenuOpenInput.value = true;
            _animationController.forward();
            setState(() {
              isSideBarOpen = true;
            });
          },
          onLeftSwipe: (details) {
            isMenuOpenInput.value = false;
            _animationController.reverse();
            setState(() {
              isSideBarOpen = false;
            });
          },
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            color: Colors.transparent,
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.transparent,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(1 * animation.value -
                          30 * (animation.value) * pi / 180),
                    child: Transform.translate(
                      offset: Offset(animation.value * 265, 0),
                      child: Transform.scale(
                        scale: scalAnimation.value,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(24),
                          ),
                          child: SingleChildScrollView(
                            clipBehavior: Clip.antiAlias,
                            scrollDirection: Axis.vertical,
                            physics: const BouncingScrollPhysics(),
                            child: Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height - 50,
                              color: Colors.transparent,
                              child: _widgetOptions[stateNavigationIndex],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  width: 288,
                  height: MediaQuery.of(context).size.height,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.fastOutSlowIn,
                  left: isSideBarOpen ? 0 : -288,
                  top: 0,
                  child: SideBar(closeSidebar: () {
                    _animationController.reverse();
                    setState(
                      () {
                        isSideBarOpen = false;
                      },
                    );
                  }),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.fastOutSlowIn,
                  left: isSideBarOpen ? 220 : 0,
                  top: 16,
                  child: MenuBtn(
                    press: () {
                      isMenuOpenInput.value = !isMenuOpenInput.value;

                      if (_animationController.value == 0) {
                        _animationController.forward();
                      } else {
                        _animationController.reverse();
                      }

                      setState(
                        () {
                          isSideBarOpen = !isSideBarOpen;
                        },
                      );
                    },
                    hide: isSideBarOpen && false,
                    riveOnInit: (artboard) {
                      final controller =
                          rive.StateMachineController.fromArtboard(
                              artboard, "State Machine");

                      artboard.addController(controller!);

                      isMenuOpenInput =
                          controller.findInput<bool>("isOpen") as rive.SMIBool;
                      isMenuOpenInput.value = true;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar:
            custom_bottomnavbar.CurvedBottomNavBar(animation: animation),
      ),
    );
  }
}
