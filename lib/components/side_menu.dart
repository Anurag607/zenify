import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rive/rive.dart';
import 'package:zenify/redux/states/navigation_state.dart';
import 'package:zenify/redux/states/song_state.dart';
import 'package:zenify/utils/database.dart';
import '../../../models/menu.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:zenify/redux/actions.dart';
import 'package:zenify/redux/states/sidebar_state.dart';

class SideMenuCard extends StatelessWidget {
  final Menu menu;
  final VoidCallback dispatch;
  final VoidCallback press;
  final ValueChanged<Artboard> riveOnInit;
  final bool? isExpanded;

  const SideMenuCard({
    super.key,
    required this.menu,
    required this.dispatch,
    required this.press,
    required this.riveOnInit,
    this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<SidebarMenuState, Menu>(
        converter: (store) => store.state.selectedTab,
        builder: (context, Menu selectedTab) {
          if (isExpanded == true) {
            StoreProvider.of<SidebarMenuState>(context)
                .dispatch(UpdateSelectedTabAction(menu, false));
          }
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                width: selectedTab == menu ? 288 : 0,
                height: 56,
                left: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF6792FF),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  StoreProvider.of<SidebarMenuState>(context)
                      .dispatch(UpdateSelectedTabAction(menu, true));
                  dispatch();
                  press();
                },
                leading: SizedBox(
                  height: 36,
                  width: 36,
                  child: RiveAnimation.asset(
                    menu.rive.src,
                    artboard: menu.rive.artboard,
                    onInit: riveOnInit,
                  ),
                ),
                title: Text(
                  menu.title,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        });
  }
}

class SideMenu extends StatefulWidget {
  final Menu menu;
  final VoidCallback press;
  final VoidCallback dispatch;
  final ValueChanged<Artboard> riveOnInit;
  final VoidCallback closeSidebar;

  const SideMenu({
    super.key,
    required this.menu,
    required this.dispatch,
    required this.press,
    required this.riveOnInit,
    required this.closeSidebar,
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final _zenifyData = Hive.box('zenifyData');
  ZenifyDatabase db = ZenifyDatabase();

  late Menu menu;
  late VoidCallback press;
  late VoidCallback dispatch;
  late ValueChanged<Artboard> riveOnInit;
  late VoidCallback _closeSidebar;
  late Menu selectedMenu;

  bool _isExpanded = false;
  int _currentMaxIndex = 100;
  final int _maxSongsTobeFetched = 100;

  List<dynamic> songsList = [];

  final OnAudioQuery _audioQuery = OnAudioQuery();

  final ScrollController _scrollController = ScrollController();

  void _getMoreSongs() {
    log("Getting more songs...");

    for (int i = _currentMaxIndex;
        i <= _currentMaxIndex + _maxSongsTobeFetched;
        i++) {
      if (i < db.musicList.length) {
        songsList.add(db.musicList[i]);
        _currentMaxIndex = i + 1;
      }
    }

    setState(() {});
  }

  bool _isLoading = false;

  void _fetchSongs() {
    setState(() {
      _isLoading = true;
    });

    _audioQuery.querySongs().then((value) {
      setState(() {
        _isLoading = false;
      });
      db.saveMusicList(value);
      db.loadMusicList();
      if (db.musicList.isNotEmpty) {
        setState(() {
          for (int i = 0; i < _maxSongsTobeFetched; i++) {
            songsList.add(db.musicList[i]);
          }
          // log("side_menu: ${db.musicList.length}, ${songsList.toString()}");
        });
      }
    });
  }

  @override
  void initState() {
    menu = widget.menu;
    press = widget.press;
    dispatch = widget.dispatch;
    riveOnInit = widget.riveOnInit;
    _closeSidebar = widget.closeSidebar;

    if (_zenifyData.get('musicList') == null) {
      db.fetchMusicList();
    } else {
      db.loadMusicList();
      if (db.musicList.isEmpty) {
        _fetchSongs();
      } else {
        setState(() {
          for (int i = 0; i < _maxSongsTobeFetched; i++) {
            songsList.add(db.musicList[i]);
          }
          // log("side_menu: ${db.musicList.length}, ${songsList.toString()}");
        });
      }
    }

    if (_zenifyData.get("currentSongIndex") == null) {
      db.saveCurrentSongIndex();
    } else {
      db.getCurrentSongIndex();
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreSongs();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 24),
          child: Divider(color: Colors.white24, height: 1),
        ),
        (menu.title == 'Music')
            ? ExpansionPanelList(
                elevation: 0,
                dividerColor: Colors.transparent,
                expandIconColor: Colors.white,
                expandedHeaderPadding: const EdgeInsets.only(bottom: 10),
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _isExpanded = !isExpanded;
                  });
                },
                children: List<int>.filled(1, 1).map<ExpansionPanel>(
                  (_) {
                    return ExpansionPanel(
                      isExpanded: _isExpanded,
                      backgroundColor: Colors.transparent,
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return SideMenuCard(
                          menu: menu,
                          press: press,
                          dispatch: dispatch,
                          riveOnInit: riveOnInit,
                          isExpanded: _isExpanded,
                        );
                      },
                      body: !db.hasPermission
                          ? fallbackWidget(
                              "Application doesn't have access to the Library !",
                              "Allow & Fetch",
                              db.fetchMusicList,
                            )
                          : SingleChildScrollView(
                              clipBehavior: Clip.antiAlias,
                              scrollDirection: Axis.vertical,
                              physics: const BouncingScrollPhysics(),
                              child: Container(
                                height: songsList.isNotEmpty ? 275 : 130,
                                width: 250,
                                color: Colors.transparent,
                                child: (songsList.isEmpty)
                                    ? (!_isLoading)
                                        ? fallbackWidget(
                                            "No Songs found, try scanning again !",
                                            "Scan Again",
                                            () {
                                              _fetchSongs();
                                              setState(() {
                                                _isLoading = true;
                                              });
                                            },
                                          )
                                        : const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          )
                                    : ListView.builder(
                                        controller: _scrollController,
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: songsList.length + 1,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          if (index == songsList.length) {
                                            return const Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                              ),
                                            );
                                          }

                                          return Container(
                                            width: 250,
                                            color: Colors.transparent,
                                            child: StoreConnector<
                                                NavigationState, int>(
                                              converter: (store) =>
                                                  store.state.tabIndex,
                                              builder: (context,
                                                  int stateNavigationIndex) {
                                                return Column(
                                                  children: [
                                                    ListTile(
                                                      tileColor:
                                                          Colors.transparent,
                                                      title: Text(
                                                        songsList[index]
                                                            ["title"],
                                                        style: GoogleFonts
                                                            .comfortaa(
                                                          textStyle: TextStyle(
                                                              color: HexColor(
                                                                      "#fafafa")
                                                                  .withOpacity(
                                                                      1),
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ),
                                                      subtitle: Text(
                                                        songsList[index]
                                                                ["artist"] ??
                                                            "No Artist",
                                                        style: GoogleFonts
                                                            .comfortaa(
                                                          textStyle: TextStyle(
                                                              color: HexColor(
                                                                      "#fafafa")
                                                                  .withOpacity(
                                                                      1),
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ),
                                                      trailing: IconButton(
                                                        onPressed: () {
                                                          _closeSidebar();
                                                          StoreProvider.of<
                                                                      NavigationState>(
                                                                  context)
                                                              .dispatch(
                                                            UpdateNavigationIndexAction(
                                                                2),
                                                          );
                                                          db.updateCurrentSongIndexFromValue(
                                                            index,
                                                          );
                                                          StoreProvider.of<
                                                                      SongState>(
                                                                  context)
                                                              .dispatch(
                                                            UpdateCurrentSongIndexAction(
                                                                index),
                                                          );
                                                        },
                                                        icon: Icon(
                                                          Icons
                                                              .play_circle_fill,
                                                          color: HexColor(
                                                                  "#fafafa")
                                                              .withOpacity(
                                                                  0.975),
                                                        ),
                                                      ),
                                                      leading:
                                                          QueryArtworkWidget(
                                                        controller: _audioQuery,
                                                        id: songsList[index]
                                                            ["id"],
                                                        type: ArtworkType.AUDIO,
                                                      ),
                                                    ),
                                                    const Divider(
                                                      color: Colors.white24,
                                                      height: 1,
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                    );
                  },
                ).toList(),
              )
            : SideMenuCard(
                menu: menu,
                press: press,
                dispatch: dispatch,
                riveOnInit: riveOnInit,
              ),
      ],
    );
  }

  Widget fallbackWidget(
      String message, String action, VoidCallback actionCallback) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.red[400],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.comfortaa(
              textStyle: TextStyle(
                  color: HexColor("#fafafa").withOpacity(1),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              actionCallback();
            },
            child: Text(action),
          ),
        ],
      ),
    );
  }
}
