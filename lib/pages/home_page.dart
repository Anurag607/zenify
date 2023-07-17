import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive/hive.dart';
import 'package:zenify/Animations/fade_animation.dart';
import 'package:intl/intl.dart';
import 'package:zenify/utils/database.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:zenify/redux/actions.dart';
import 'package:zenify/redux/states/navigation_state.dart';

class TaskCardContent extends StatelessWidget {
  final String title;
  final String desc;
  final DateTime time;

  const TaskCardContent(
      {super.key, required this.title, required this.desc, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 275,
          height: 100,
          color: Colors.transparent,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Container(
              width: 210,
              padding: const EdgeInsets.only(
                  top: 12.0, bottom: 4.0, left: 12.0, right: 0.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: const Color.fromRGBO(0, 0, 0, 0),
                        width: 190,
                        child: Text(
                          title,
                          style: GoogleFonts.quicksand(
                            textStyle: TextStyle(
                                color: HexColor("#e8e8e8"),
                                fontSize: 19,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 4.5, left: 8),
                        child: Text(
                          DateFormat.jm().format(time),
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                                color: Colors.amberAccent,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    desc,
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                          color: HexColor("#e8e8e8"),
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _zenifyData = Hive.box('zenifyData');
  ZenifyDatabase db = ZenifyDatabase();

  final String dateString =
      DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal());
  final now = DateTime.now();

  bool noMoreTasks = true;
  List<Map<dynamic, dynamic>> todayTasks = [];

  late Map<dynamic, dynamic> upcomingTask;
  int upcomingTaskIndex = 0;

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

    todayTasks = [...db.tasks[dateString]];
    todayTasks.sort((a, b) => a["time"].compareTo(b["time"]) < 0 ? -1 : 1);

    for (var index = 0; index < db.tasks[dateString].length; index++) {
      if (db.tasks[dateString][index]["time"].compareTo(now) > 0) {
        upcomingTask = db.tasks[dateString][index];
        upcomingTaskIndex = index + 1;
        noMoreTasks = false;
        break;
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                        // Greeting...
                        FadeAnimation(
                          1,
                          -20,
                          Text(
                            "Welcome, ${db.userDetails["name"]}",
                            style: GoogleFonts.quicksand(
                              textStyle: TextStyle(
                                  color: HexColor("#e8e8e8"),
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        // Today's day and Date...
                        FadeAnimation(
                          3,
                          -10,
                          Text(
                            DateFormat.yMMMMEEEEd().format(DateTime.now()),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        // Today's first Task...
                        FadeAnimation(
                          3,
                          -10,
                          Container(
                              padding: const EdgeInsets.only(left: 12.5),
                              child: Container(
                                  width: 300,
                                  padding: const EdgeInsets.only(bottom: 12.5),
                                  decoration: BoxDecoration(
                                    color: HexColor("#f6f6f6").withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(
                                            top: 12.5, left: 12.5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 2),
                                              child: Icon(
                                                  Icons.access_time_rounded,
                                                  color: Colors.amber.shade400,
                                                  size: 20),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "Upcoming Task",
                                              style: GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                    color:
                                                        Colors.amber.shade400,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w900),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      (noMoreTasks)
                                          ? Container(
                                              padding: const EdgeInsets.only(
                                                  top: 12.5, left: 12.5),
                                              child: Text(
                                                "No more tasks remaining for today!",
                                                style: GoogleFonts.quicksand(
                                                  textStyle: TextStyle(
                                                      color:
                                                          HexColor("#e8e8e8"),
                                                      fontSize: 19,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            )
                                          : TaskCardContent(
                                              title: upcomingTask["title"],
                                              desc: upcomingTask["desc"],
                                              time: upcomingTask["time"]),
                                    ],
                                  ))),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.225,
                ),
                // Tasks List...
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: FadeAnimation(
                    4,
                    0,
                    (upcomingTaskIndex == todayTasks.length - 1 || noMoreTasks)
                        ? Container(
                            width: double.infinity,
                            height: 150,
                            padding: const EdgeInsets.only(top: 0, bottom: 25),
                            decoration: BoxDecoration(
                              color: HexColor("#f6f6f6").withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "No more tasks for today!",
                                    style: GoogleFonts.quicksand(
                                      textStyle: TextStyle(
                                          color: HexColor("#e8e8e8"),
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  StoreConnector<NavigationState, int>(
                                    converter: (store) => store.state.tabIndex,
                                    builder:
                                        (context, int stateNavigationIndex) =>
                                            ElevatedButton.icon(
                                      onPressed: () {
                                        StoreProvider.of<NavigationState>(
                                                context)
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
                                        "Go to Schedule Page",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("What do you need to do today?",
                                  style: GoogleFonts.quicksand(
                                    textStyle: TextStyle(
                                        color: HexColor("#e8e8e8")
                                            .withOpacity(0.9),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  )),
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 125,
                                child: ListView(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  children: List.generate(todayTasks.length,
                                      (int index) {
                                    return (index <= upcomingTaskIndex)
                                        ? Container()
                                        : Row(
                                            children: [
                                              Container(
                                                width: 275,
                                                height: 125,
                                                padding: const EdgeInsets.only(
                                                    top: 0, bottom: 25),
                                                decoration: BoxDecoration(
                                                  color: HexColor("#f6f6f6")
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: TaskCardContent(
                                                    title: todayTasks[index]
                                                        ["title"],
                                                    desc: todayTasks[index]
                                                        ["desc"],
                                                    time: todayTasks[index]
                                                        ["time"]),
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                            ],
                                          );
                                  }),
                                ),
                              ),
                            ],
                          ),
                  ),
                )
              ],
            )));
  }
}
