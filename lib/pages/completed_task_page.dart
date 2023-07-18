import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive/hive.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:zenify/Animations/fade_animation.dart';
import 'package:intl/intl.dart';
import 'package:zenify/utils/database.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:zenify/redux/actions.dart';
import 'package:zenify/redux/states/navigation_state.dart';
import 'package:zenify/widgets/delete_cnfrm_dialogue.dart';
import 'dart:developer';

class CompletedTaskPage extends StatefulWidget {
  const CompletedTaskPage({super.key});

  @override
  State<CompletedTaskPage> createState() => _CompletedTaskPageState();
}

class _CompletedTaskPageState extends State<CompletedTaskPage>
    with TickerProviderStateMixin {
  final _zenifyData = Hive.box('zenifyData');
  ZenifyDatabase db = ZenifyDatabase();

  static final GlobalKey<ScaffoldState> _completedTasksScaffoldKey =
      GlobalKey<ScaffoldState>();
  static final GlobalKey<LiquidPullToRefreshState>
      _completedTasksRefreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();

  final String dateString =
      DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal());
  final now = DateTime.now();

  late ValueNotifier<List<dynamic>> _completedTasks =
      ValueNotifier<List<dynamic>>([]);
  late List<dynamic> temp = [];

  late final AnimationController _opacityControllerCompletedTasks =
      AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..forward();

  late final Animation<double> _opacityAnimationCompletedTasks =
      CurvedAnimation(
    parent: _opacityControllerCompletedTasks,
    curve: Curves.easeIn,
  );

  String _extractedDay(DateTime day) {
    return DateFormat('yyyy-MM-dd').format(day.toLocal());
  }

  @override
  void initState() {
    if (_zenifyData.get("userDetails") == null) {
      db.saveUserDetails();
    } else {
      db.getUserDetails();
    }

    if (_zenifyData.get("tasks") == null) {
      db.getTasks();
    } else {
      db.getTasks();
    }

    temp = [...db.tasks[dateString]];
    log(temp.toString());
    temp.sort((a, b) => a["time"].compareTo(b["time"]) < 0 ? -1 : 1);
    _completedTasks = ValueNotifier<List<dynamic>>(temp);

    temp = [];

    for (int i = 0; i < db.tasks[dateString].length; i++) {
      if (db.tasks[dateString][i]["isDone"] == true) {
        temp.add(db.tasks[dateString][i]);
      }
    }

    super.initState();
  }

  @override
  void dispose() {
    _completedTasks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _completedTasksScaffoldKey,
      backgroundColor: HexColor("#102844"),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, HexColor("#102844")],
                tileMode: TileMode.mirror,
              ).createShader(
                Rect.fromLTRB(0, 0, rect.width, rect.height),
              );
            },
            blendMode: BlendMode.srcOver,
            child: Container(
              decoration: BoxDecoration(
                color: HexColor("#102844"),
                image: const DecorationImage(
                  image: AssetImage("assets/Backgrounds/dark-bg.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          LiquidPullToRefresh(
            key: _completedTasksRefreshIndicatorKey,
            springAnimationDurationInMilliseconds: 300,
            height: 150,
            color: Colors.transparent,
            backgroundColor: HexColor("#102844"),
            borderWidth: 0,
            onRefresh: () async {
              db.getTasks();
              setState(() {});
              await Future.delayed(const Duration(seconds: 2));
              _completedTasksRefreshIndicatorKey.currentState?.show();
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
                    child(),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget child() {
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 45),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    FadeAnimation(
                      1,
                      -20,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            color: Colors.transparent,
                            child: Center(
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  size: 20,
                                  color: Colors.white,
                                  weight: 900,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ),
                          Container(
                            width: 225,
                            color: Colors.transparent,
                            child: Text(
                              "Take a look at your completed tasks!",
                              style: GoogleFonts.quicksand(
                                textStyle: TextStyle(
                                    color: HexColor("#e8e8e8"),
                                    fontSize: 25,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ],
            ),
            // Tasks List...
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: FadeAnimation(
                4,
                0,
                (_completedTasks.value.isEmpty)
                    ? Container(
                        width: double.infinity,
                        height: 150,
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: HexColor("#f6f6f6").withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 250,
                                child: Text(
                                  "You haven't completed any tasks yet!",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.quicksand(
                                    textStyle: TextStyle(
                                        color: HexColor("#e8e8e8"),
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              StoreConnector<NavigationState, int>(
                                converter: (store) => store.state.tabIndex,
                                builder: (context, int stateNavigationIndex) =>
                                    ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    StoreProvider.of<NavigationState>(context)
                                        .dispatch(
                                      UpdateNavigationIndexAction(1),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: HexColor("#046ab7"),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 10),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(25),
                                        bottomRight: Radius.circular(25),
                                        bottomLeft: Radius.circular(25),
                                      ),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.forward_rounded,
                                    color: HexColor("#f79729"),
                                  ),
                                  label: const Text(
                                    "Go Schedule One!",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height,
                        child: SingleChildScrollView(
                          child: SizedBox(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height,
                            child: FadeTransition(
                              opacity: CurvedAnimation(
                                parent: _opacityAnimationCompletedTasks,
                                curve: Curves.easeIn,
                              ),
                              child: ValueListenableBuilder<List<dynamic>>(
                                valueListenable: _completedTasks,
                                builder: (context, value, _) {
                                  return ListView(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    clipBehavior: Clip.antiAlias,
                                    children: List.generate(
                                      value.length,
                                      (int index) {
                                        if (temp.contains(value[index]) ==
                                            false) {
                                          return Container();
                                        }
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 12.0,
                                          ),
                                          child: Container(
                                            clipBehavior: Clip.antiAlias,
                                            padding: const EdgeInsets.only(
                                                bottom: 10, left: 12.0),
                                            width: 275,
                                            decoration: BoxDecoration(
                                              color: HexColor("#f6f6f6")
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Texts...
                                                Container(
                                                  width: 210,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 12.0,
                                                          bottom: 4.0,
                                                          left: 0.0,
                                                          right: 0.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            color: Colors
                                                                .transparent,
                                                            width: 140,
                                                            child: Text(
                                                              '${value[index]["title"]}',
                                                              style: GoogleFonts
                                                                  .quicksand(
                                                                textStyle: TextStyle(
                                                                    color: HexColor(
                                                                        "#e8e8e8"),
                                                                    fontSize:
                                                                        22.5,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 4.5,
                                                                    left: 8),
                                                            child: Text(
                                                              DateFormat.jm()
                                                                  .format(value[
                                                                          index]
                                                                      ["time"]),
                                                              style: GoogleFonts
                                                                  .lato(
                                                                textStyle: const TextStyle(
                                                                    color: Colors
                                                                        .amberAccent,
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 8.0),
                                                      Text(
                                                        '${value[index]["desc"]}',
                                                        style: GoogleFonts.lato(
                                                          textStyle: TextStyle(
                                                              color: HexColor(
                                                                  "#e8e8e8"),
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Actions...
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 12.0,
                                                          right: 12.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Transform.scale(
                                                        scale: 1,
                                                        child: Container(
                                                          width: 30,
                                                          height: 30,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: HexColor(
                                                                    "#102844")
                                                                .withOpacity(
                                                                    0.4),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: Center(
                                                            child: IconButton(
                                                              onPressed: () {
                                                                showConformDeleteDialog(
                                                                  context,
                                                                  _extractedDay(
                                                                    value[index]
                                                                        [
                                                                        "time"],
                                                                  ),
                                                                  () {
                                                                    final snackBar =
                                                                        SnackBar(
                                                                      duration: const Duration(
                                                                          milliseconds:
                                                                              200),
                                                                      content:
                                                                          Text(
                                                                        'Deleted Successfully!',
                                                                        style: GoogleFonts
                                                                            .lato(
                                                                          textStyle: TextStyle(
                                                                              color: HexColor("#e8e8e8"),
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.w400),
                                                                        ),
                                                                      ),
                                                                    );
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                            snackBar);
                                                                  },
                                                                  index,
                                                                  onValue: (_) {
                                                                    setState(
                                                                        () {
                                                                      _completedTasks
                                                                          .value
                                                                          .removeAt(
                                                                              index);
                                                                    });
                                                                  },
                                                                );
                                                              },
                                                              icon: Icon(
                                                                Icons
                                                                    .delete_forever,
                                                                color: HexColor(
                                                                    "#e8e8e8"),
                                                                size: 15,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
