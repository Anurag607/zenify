import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:rive/rive.dart';
import 'package:zenify/models/menu.dart';
import 'package:zenify/redux/states/sidebar_state.dart';

class MenuBtn extends StatelessWidget {
  const MenuBtn(
      {super.key,
      required this.press,
      required this.hide,
      required this.riveOnInit});

  final VoidCallback press;
  final bool hide;
  final ValueChanged<Artboard> riveOnInit;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<SidebarMenuState, Menu>(
      converter: (store) => store.state.selectedTab,
      builder: (context, Menu selectedTab) {
        return StoreConnector<SidebarMenuState, bool>(
          converter: (store) => store.state.isClosed,
          builder: (context, bool isClosed) {
            if (isClosed) {
              // press();
            }
            return SafeArea(
              child: GestureDetector(
                onTap: () => {
                  press(),
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 12),
                  height: hide ? 40 : 0,
                  width: hide ? 40 : 0,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, 3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: RiveAnimation.asset(
                    "assets/RiveAssets/menu_button.riv",
                    onInit: riveOnInit,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
