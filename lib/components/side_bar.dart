// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zenify/pages/completed_task_page.dart';
import 'package:zenify/utils/database.dart';

import '../../../models/menu.dart';
import '../../../utils/rive_utils.dart';
import '../components/info_card.dart';
import '../components/side_menu.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:zenify/redux/actions.dart';
import 'package:zenify/redux/states/navigation_state.dart';

class SideBar extends StatefulWidget {
  final VoidCallback closeSidebar;
  const SideBar({super.key, required this.closeSidebar});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  final _zenifyData = Hive.box('zenifyData');
  ZenifyDatabase db = ZenifyDatabase();

  late VoidCallback _closeSidebar;

  @override
  void initState() {
    _closeSidebar = widget.closeSidebar;

    if (_zenifyData.get("userDetails") == null) {
      db.saveUserDetails();
    } else {
      db.getUserDetails();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: 288,
        height: double.infinity,
        decoration: BoxDecoration(
          color: HexColor('#102844'),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(30),
          ),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              clipBehavior: Clip.antiAlias,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoCard(
                    name: db.userDetails["name"],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 24, top: 32, bottom: 16),
                    child: Text(
                      "Browse".toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Colors.white70),
                    ),
                  ),
                  ...sidebarMenus.map(
                    (menu) {
                      return SideMenu(
                        menu: menu,
                        dispatch: () {
                          int selectedIndex = 0;
                          if (menu.title == 'Music') {
                            selectedIndex = 2;
                          } else {
                            selectedIndex = 0;
                          }
                          StoreProvider.of<NavigationState>(context).dispatch(
                            UpdateNavigationIndexAction(selectedIndex),
                          );
                        },
                        closeSidebar: _closeSidebar,
                        press: () {
                          RiveUtils.chnageSMIBoolState(menu.rive.status!);
                        },
                        riveOnInit: (artboard) {
                          menu.rive.status = RiveUtils.getRiveInput(artboard,
                              stateMachineName: menu.rive.stateMachineName);
                        },
                      );
                    },
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 24, top: 40, bottom: 16),
                    child: Text(
                      "History".toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Colors.white70),
                    ),
                  ),
                  ...sidebarMenus2.map(
                    (menu) => StoreConnector<NavigationState, int>(
                      converter: (store) => store.state.tabIndex,
                      builder: (context, int stateNavigationIndex) => SideMenu(
                        menu: menu,
                        dispatch: () {
                          if (menu.title == "Completed Tasks") {
                            Future.delayed(const Duration(milliseconds: 210))
                                .then(
                              (_) => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CompletedTaskPage(),
                                ),
                              ),
                            );
                          }
                        },
                        closeSidebar: _closeSidebar,
                        press: () {
                          RiveUtils.chnageSMIBoolState(menu.rive.status!);
                        },
                        riveOnInit: (artboard) {
                          menu.rive.status = RiveUtils.getRiveInput(artboard,
                              stateMachineName: menu.rive.stateMachineName);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 75),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
