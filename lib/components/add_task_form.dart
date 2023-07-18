import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zenify/utils/database.dart';

class AddTaskForm extends StatefulWidget {
  final String dateString;
  const AddTaskForm({super.key, required this.dateString});

  @override
  State<AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
  final GlobalKey<FormState> _addTaskFormKey = GlobalKey<FormState>();

  DateTime now = DateTime.now();
  late Time _time;

  late final String dateString;
  bool showError = false;

  final _zenifyData = Hive.box('zenifyData');
  ZenifyDatabase db = ZenifyDatabase();

  Map<String, dynamic> taskData = {
    "title": "",
    "desc": "",
    "time": DateTime.now(),
    "isDone": false,
  };

  void onTimeChanged(Time newTime) {
    setState(() {
      _time = newTime;
    });
  }

  @override
  void initState() {
    if (_zenifyData.get("tasks") == null) {
      db.getTasks();
    } else {
      db.getTasks();
    }

    dateString = widget.dateString;

    _time = Time(hour: now.hour, minute: now.minute, second: now.second);

    super.initState();
  }

  void handleSubmit() {
    _addTaskFormKey.currentState!.save();

    if (db.tasks[dateString] != null) {
      db.addTaskItem(dateString, taskData);
    } else {
      db.addTask(dateString, [taskData]);
    }
  }

  final snackBar = SnackBar(
    duration: const Duration(milliseconds: 200),
    content: Text(
      'Added Successfully!',
      style: GoogleFonts.lato(
        textStyle: TextStyle(
            color: HexColor("#e8e8e8"),
            fontSize: 15,
            fontWeight: FontWeight.w400),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _addTaskFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              !showError
                  ? Container()
                  : SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          "Enter the details of the task",
                          style: TextStyle(
                            color: Colors.red.shade400,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
              SizedBox(
                width: 320,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Title & Time",
                          style: TextStyle(
                            color: HexColor("#f6f6f6"),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 8, bottom: 16),
                          child: SizedBox(
                            width: 260,
                            height: 50,
                            child: TextFormField(
                              onChanged: (value) => {
                                setState(() {
                                  taskData["title"] = value;
                                })
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: "Enter the gist of the task",
                                prefixIcon: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: SizedBox(
                                    width: 16,
                                    child: Icon(
                                      Icons.title,
                                      color: HexColor("#f79729"),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: HexColor("#f79729"),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            showPicker(
                              showSecondSelector: true,
                              context: context,
                              blurredBackground: false,
                              barrierColor: Colors.black.withOpacity(0.5),
                              value: _time,
                              onChange: onTimeChanged,
                              minuteInterval: TimePickerInterval.FIVE,
                              onChangeDateTime: (DateTime dateTime) {
                                setState(() {
                                  taskData["time"] = dateTime;
                                });
                              },
                            ),
                          );
                        },
                        icon: const Icon(Icons.timer),
                        color: HexColor("#102844"),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 320,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Description",
                      style: TextStyle(
                        color: HexColor("#f6f6f6"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: SizedBox(
                        width: 320,
                        child: TextFormField(
                          onChanged: (value) => {
                            setState(() {
                              taskData["desc"] = value;
                            })
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "";
                            }
                            return null;
                          },
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: "Enter the description of the task",
                            hintMaxLines: 4,
                            prefixIcon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Container(
                                padding: const EdgeInsets.only(bottom: 50),
                                child: SizedBox(
                                  width: 16,
                                  child: Icon(
                                    Icons.description,
                                    color: HexColor("#f79729"),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_addTaskFormKey.currentState?.validate() == true) {
                      setState(() {
                        showError = false;
                        handleSubmit();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      });
                    } else {
                      setState(() {
                        showError = true;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HexColor("#6721ff"),
                    minimumSize: const Size(double.infinity, 56),
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
                    Icons.add_box,
                    color: HexColor("#f79729"),
                  ),
                  label: const Text(
                    "Add Task",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
