import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zenify/utils/database.dart';

import 'package:zenify/utils/task.dart';
import 'package:zenify/components/add_task_form.dart';
import 'package:zenify/components/edit_task_form.dart';

import 'custom_modal_bottom_sheet.dart';
import 'delete_cnfrm_dialogue.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> with TickerProviderStateMixin {
  final _zenifyData = Hive.box('zenifyData');
  ZenifyDatabase db = ZenifyDatabase();

  late final ValueNotifier<List<dynamic>> _selectedTasks;
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  // Controller for navigating the calendar pages gets initialized on calendar table creation...
  late PageController _pageController;

  // Determinees the format in which calendar is viewed on device, possible options are: week, month, twoWeeks...
  CalendarFormat _calendarFormat = CalendarFormat.week;

  // Determines the range selection mode, possible options are: toggledOn, toggledOff, selected, unselected...
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

  // Variables to store the range limits...
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  String _extractedDay(DateTime day) {
    return DateFormat('yyyy-MM-dd').format(day.toLocal());
  }

  late final AnimationController _opacityControllerAddPrompt =
      AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..forward();

  late final AnimationController _opacityControllerAddTasks =
      AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..forward();

  late final Animation<double> _opacityAnimationAddPrompt = CurvedAnimation(
    parent: _opacityControllerAddPrompt,
    curve: Curves.easeIn,
  );

  late final Animation<double> _opacityAnimationAddTasks = CurvedAnimation(
    parent: _opacityControllerAddTasks,
    curve: Curves.easeIn,
  );

  // To initialize the state objects ...
  @override
  void initState() {
    // To get the user details from the database on initial render...
    if (_zenifyData.get("userDetails") == null) {
      db.saveUserDetails();
    } else {
      db.getUserDetails();
    }

    // To get the collection of task list from the database on initial render...
    if (_zenifyData.get("tasks") == null) {
      db.getTasks();
    } else {
      db.getTasks();
    }

    // To get the tasks for the selected day i.e. today (or focused day) on initial render...
    _selectedDays.add(_focusedDay.value);
    _selectedTasks = ValueNotifier(_getTasksForDay(_focusedDay.value));
    _selectedTasks.value.retainWhere((task) => !task["isDone"]);
    _selectedTasks.value
        .sort((a, b) => a["time"].compareTo(b["time"]) < 0 ? -1 : 1);

    super.initState();
  }

  // To destroy the state object ...
  @override
  void dispose() {
    _opacityControllerAddPrompt.dispose();
    _opacityControllerAddTasks.dispose();
    _focusedDay.dispose();
    _selectedTasks.dispose();
    super.dispose();
  }

  // Variable to conditionally render the close button ...
  bool get canClearSelection =>
      _selectedDays.isNotEmpty || _rangeStart != null || _rangeEnd != null;

  // List containing the task list for the selected day (single day)...
  List<dynamic> _getTasksForDay(DateTime day) {
    List<dynamic> temp = db.tasks[_extractedDay(day)] ?? [];
    if (temp.isEmpty) return temp;
    temp.retainWhere((task) => !task["isDone"]);
    return temp;
  }

  // List containing the task list for the selected days (range of day)...
  List<dynamic> _getTasksForDays(Iterable<DateTime> days) {
    return [
      for (final d in days) ..._getTasksForDay(d),
    ];
  }

  // List containing the task list for the selected range of days...
  List<dynamic> _getTasksForRange(DateTime start, DateTime end) {
    final days = daysInRange(start, end);
    return _getTasksForDays(days);
  }

  // Function running on the selection of a day...
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      // If the selected day is already selected, then remove it from the list of selected days else add it...
      if (_selectedDays.contains(selectedDay)) {
        if (_selectedDays.length > 1) {
          _selectedDays.remove(selectedDay);
        }
      } else {
        _selectedDays.add(selectedDay);
      }

      // Update the focused day...
      _focusedDay.value = _selectedDays.last;

      // Reset the range selection mode and range limits...
      _rangeStart = null;
      _rangeEnd = null;
      _rangeSelectionMode = RangeSelectionMode.toggledOff;
    });

    // Update and filter the selected tasks list...
    _selectedTasks.value = _getTasksForDays(_selectedDays);
    _selectedTasks.value.retainWhere((task) => !task["isDone"]);
    _selectedTasks.value
        .sort((a, b) => a["time"].compareTo(b["time"]) < 0 ? -1 : 1);
  }

  // Function running on the selection of a range of days...
  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      // Update the focused day...
      _focusedDay.value = focusedDay;
      // Update the range limits...
      _rangeStart = start;
      _rangeEnd = end;
      // Reset the selected days list...
      _selectedDays.clear();
      // Update the range selection mode...
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // Update the task list conditionally depending upon the range...
    if (start != null && end != null) {
      _selectedTasks.value = _getTasksForRange(start, end);
      _selectedTasks.value.retainWhere((task) => !task["isDone"]);
      _selectedTasks.value
          .sort((a, b) => a["time"].compareTo(b["time"]) < 0 ? -1 : 1);
    } else if (start != null) {
      _selectedTasks.value = _getTasksForDay(start);
      _selectedTasks.value.retainWhere((task) => !task["isDone"]);
      _selectedTasks.value
          .sort((a, b) => a["time"].compareTo(b["time"]) < 0 ? -1 : 1);
    } else if (end != null) {
      _selectedTasks.value = _getTasksForDay(end);
      _selectedTasks.value.retainWhere((task) => !task["isDone"]);
      _selectedTasks.value
          .sort((a, b) => a["time"].compareTo(b["time"]) < 0 ? -1 : 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header...
            ValueListenableBuilder<DateTime>(
              valueListenable: _focusedDay,
              builder: (context, value, _) {
                return _CalendarHeader(
                  focusedDay: value,
                  clearButtonVisible: canClearSelection,
                  onTodayButtonTap: () {
                    setState(() => _focusedDay.value = DateTime.now());
                  },
                  onClearButtonTap: () {
                    setState(() {
                      _focusedDay.value = DateTime.now();
                      _rangeStart = null;
                      _rangeEnd = null;
                      _selectedDays.clear();
                      _selectedDays.add(_focusedDay.value);
                      _selectedTasks.value = _getTasksForDay(_focusedDay.value);
                    });
                  },
                  onLeftArrowTap: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                  onRightArrowTap: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                );
              },
            ),
            // Calendar...
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: HexColor("#f6f8fe"),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x3f000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TableCalendar<dynamic>(
                firstDay: kFirstDay,
                lastDay: kLastDay,
                focusedDay: _focusedDay.value,
                headerVisible: false,
                selectedDayPredicate: (day) => _selectedDays.contains(day),
                rangeStartDay: _rangeStart,
                rangeEndDay: _rangeEnd,
                calendarFormat: _calendarFormat,
                rangeSelectionMode: _rangeSelectionMode,
                eventLoader: _getTasksForDay,
                onDaySelected: _onDaySelected,
                onRangeSelected: _onRangeSelected,
                onCalendarCreated: (controller) => _pageController = controller,
                onPageChanged: (focusedDay) => _focusedDay.value = focusedDay,
                onFormatChanged: (format) {
                  if (format == CalendarFormat.month) {
                    return;
                  }
                  if (_calendarFormat != format) {
                    setState(() => _calendarFormat = format);
                  }
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.amber[900],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.15,
        ),
        SingleChildScrollView(
          clipBehavior: Clip.antiAlias,
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.only(left: 16),
            color: Colors.transparent,
            child: Column(
              children: [
                // Add Task...
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Programmation",
                      style: GoogleFonts.quicksand(
                        textStyle: TextStyle(
                            color: HexColor("#e8e8e8").withOpacity(1),
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      width: 75,
                      decoration: BoxDecoration(
                        color: HexColor("#046ab7"),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: IconButton(
                          onPressed: () {
                            CustomBottomModalSheet.customBottomModalSheet(
                              context,
                              400,
                              AddTaskForm(
                                dateString: _extractedDay(_focusedDay.value),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.add,
                            color: HexColor("#f6f6f6").withOpacity(0.875),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 35.0),
                // Tasks Card...
                (_selectedTasks.value.isEmpty)
                    ? FadeTransition(
                        opacity: _opacityAnimationAddPrompt,
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          margin: const EdgeInsets.only(right: 10),
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
                                  "No tasks scheduled for ${DateFormat.yMd().format(_focusedDay.value) == DateFormat.yMd().format(DateTime.now()) ? "today" : "this day"}!",
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
                                ElevatedButton.icon(
                                  onPressed: () {
                                    CustomBottomModalSheet
                                        .customBottomModalSheet(
                                      context,
                                      400,
                                      AddTaskForm(
                                        dateString:
                                            _extractedDay(_focusedDay.value),
                                      ),
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
                                    Icons.schedule,
                                    color: HexColor("#f79729"),
                                  ),
                                  label: const Text(
                                    "Schedule a task",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _opacityAnimationAddTasks,
                          curve: Curves.easeIn,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 150,
                          child: ValueListenableBuilder<List<dynamic>>(
                            valueListenable: _selectedTasks,
                            builder: (context, value, _) {
                              return ListView(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                clipBehavior: Clip.antiAlias,
                                children: List.generate(
                                  value.length,
                                  (index) => Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                    ),
                                    child: Container(
                                      clipBehavior: Clip.antiAlias,
                                      padding: const EdgeInsets.only(
                                        left: 12.0,
                                      ),
                                      width: 275,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: HexColor("#f6f6f6")
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Texts...
                                          SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            physics:
                                                const BouncingScrollPhysics(),
                                            clipBehavior: Clip.antiAlias,
                                            child: Container(
                                              width: 210,
                                              padding: const EdgeInsets.only(
                                                top: 12.0,
                                                bottom: 4.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        color:
                                                            Colors.transparent,
                                                        width: 140,
                                                        child: Text(
                                                          '${value[index]["title"]}',
                                                          style: GoogleFonts
                                                              .quicksand(
                                                            textStyle: TextStyle(
                                                                color: HexColor(
                                                                    "#e8e8e8"),
                                                                fontSize: 22.5,
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
                                                              .format(
                                                                  value[index]
                                                                      ["time"]),
                                                          style:
                                                              GoogleFonts.lato(
                                                            textStyle: const TextStyle(
                                                                color: Colors
                                                                    .amberAccent,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8.0),
                                                  Text(
                                                    '${value[index]["desc"]}',
                                                    style: GoogleFonts.lato(
                                                      textStyle: TextStyle(
                                                          color: HexColor(
                                                              "#e8e8e8"),
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Actions...
                                          Container(
                                            padding: const EdgeInsets.only(
                                                top: 12.0, right: 12.0),
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
                                                    decoration: BoxDecoration(
                                                      color: HexColor("#102844")
                                                          .withOpacity(0.4),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Center(
                                                      child: IconButton(
                                                        onPressed: () {
                                                          db.updateTaskStatus(
                                                              _extractedDay(
                                                                  _focusedDay
                                                                      .value),
                                                              index,
                                                              true);
                                                          final snackBar =
                                                              SnackBar(
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        200),
                                                            content: Text(
                                                              'Completed Successfully!',
                                                              style: GoogleFonts
                                                                  .lato(
                                                                textStyle: TextStyle(
                                                                    color: HexColor(
                                                                        "#e8e8e8"),
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              ),
                                                            ),
                                                          );
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  snackBar);
                                                        },
                                                        icon: Icon(
                                                          Icons.done,
                                                          color: HexColor(
                                                              "#e8e8e8"),
                                                          size: 15,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Transform.scale(
                                                  scale: 1,
                                                  child: Container(
                                                    width: 30,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      color: HexColor("#102844")
                                                          .withOpacity(0.4),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Center(
                                                      child: IconButton(
                                                        onPressed: () {
                                                          CustomBottomModalSheet
                                                              .customBottomModalSheet(
                                                            context,
                                                            400,
                                                            EditTaskForm(
                                                              dateString:
                                                                  _extractedDay(
                                                                      _focusedDay
                                                                          .value),
                                                              taskIndex: index,
                                                            ),
                                                          );
                                                        },
                                                        icon: Icon(
                                                          Icons.edit,
                                                          color: HexColor(
                                                              "#e8e8e8"),
                                                          size: 15,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Transform.scale(
                                                  scale: 1,
                                                  child: Container(
                                                    width: 30,
                                                    height: 30,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 0.0,
                                                            bottom: 0.0,
                                                            left: 0.0,
                                                            right: 0.0),
                                                    decoration: BoxDecoration(
                                                      color: HexColor("#102844")
                                                          .withOpacity(0.4),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Center(
                                                      child: IconButton(
                                                        onPressed: () {
                                                          showConformDeleteDialog(
                                                            context,
                                                            _extractedDay(
                                                                _focusedDay
                                                                    .value),
                                                            () {
                                                              if (_selectedTasks
                                                                      .value
                                                                      .length >
                                                                  index) {
                                                                setState(() {
                                                                  _selectedTasks
                                                                      .value
                                                                      .removeAt(
                                                                          index);
                                                                });
                                                              }
                                                            },
                                                            index,
                                                            onValue: (_) {
                                                              // setState(() {});
                                                            },
                                                          );
                                                        },
                                                        icon: Icon(
                                                          Icons.delete_forever,
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
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height
            ? SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
              )
            : const SizedBox(),
      ],
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;
  final VoidCallback onTodayButtonTap;
  final VoidCallback onClearButtonTap;
  final bool clearButtonVisible;

  const _CalendarHeader({
    Key? key,
    required this.focusedDay,
    required this.onLeftArrowTap,
    required this.onRightArrowTap,
    required this.onTodayButtonTap,
    required this.onClearButtonTap,
    required this.clearButtonVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headerText = DateFormat.yMMM().format(focusedDay);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 16.0),
          SizedBox(
            child: Text(
              headerText,
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                    color: HexColor("#e8e8e8"),
                    fontSize: 30,
                    fontWeight: FontWeight.w900),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today,
                size: 20.0, color: HexColor("#e8e8e8")),
            visualDensity: VisualDensity.compact,
            onPressed: onTodayButtonTap,
          ),
          if (clearButtonVisible)
            IconButton(
              icon: Icon(Icons.clear, size: 20.0, color: HexColor("#e8e8e8")),
              visualDensity: VisualDensity.compact,
              onPressed: onClearButtonTap,
            ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.chevron_left, color: HexColor("#e8e8e8")),
            onPressed: onLeftArrowTap,
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: HexColor("#e8e8e8")),
            onPressed: onRightArrowTap,
          ),
        ],
      ),
    );
  }
}
