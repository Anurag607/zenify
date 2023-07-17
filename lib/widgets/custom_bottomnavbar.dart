import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ionicons/Ionicons.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:zenify/redux/actions.dart';
import 'package:zenify/redux/states/navigation_state.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class CurvedBottomNavBar extends StatefulWidget {
  final Animation<double> animation;
  const CurvedBottomNavBar({super.key, required this.animation});

  @override
  State<CurvedBottomNavBar> createState() => _CurvedBottomNavBarState();
}

class _CurvedBottomNavBarState extends State<CurvedBottomNavBar>
    with SingleTickerProviderStateMixin {
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  late AnimationController _animationController;
  late Animation<double> scalAnimation;
  late Animation<double> animation;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200))
      ..addListener(
        () {
          setState(() {});
        },
      );
    scalAnimation = Tween<double>(begin: 1, end: 0.8).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn));
    animation = widget.animation;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, 100 * animation.value),
      child: SafeArea(
        child: StoreConnector<NavigationState, int>(
          converter: (store) => store.state.tabIndex,
          builder: (context, int stateNavigationIndex) => CurvedNavigationBar(
            key: _bottomNavigationKey,
            index: stateNavigationIndex,
            height: 60,
            color: HexColor('#051d35'),
            backgroundColor: HexColor('#102844'),
            buttonBackgroundColor: HexColor("#102844"),
            animationCurve: Curves.easeInOut,
            animationDuration: const Duration(milliseconds: 300),
            onTap: (selectedIndex) => {
              StoreProvider.of<NavigationState>(context).dispatch(
                UpdateNavigationIndexAction(selectedIndex),
              ),
            },
            letIndexChange: (index) => true,
            items: [
              Icon(Ionicons.home, color: HexColor("#f6f8fe"), size: 30),
              Icon(Ionicons.calendar, color: HexColor("#f6f8fe"), size: 30),
              Icon(Ionicons.musical_note, color: HexColor("#f6f8fe"), size: 30),
            ],
          ),
        ),
      ),
    );
  }
}
