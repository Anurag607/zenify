import 'package:flutter/material.dart';
import 'package:zenify/utils/colors.dart';

class Task {
  IconData? iconData;
  String? title;
  Color? bgColor;
  Color? iconColor;
  Color? btnColor;
  num? left;
  num? done;
  List<Map<String, dynamic>>? desc;
  bool isLast;

  Task({
    this.iconData,
    this.title,
    this.bgColor,
    this.iconColor,
    this.btnColor,
    this.left,
    this.done,
    this.desc,
    this.isLast = false,
  });

  static List<Task> generateTasks() {
    return [
      Task(
          iconData: Icons.person_outlined,
          bgColor: kYellowLight,
          iconColor: kYellowDark,
          btnColor: kYellow,
          left: 3,
          done: 1,
          desc: [
            {
              'time': '9:00 AM',
              'title': 'Go for a walk with dog',
              'slot': '9:00 AM - 10:00 AM',
              'tlColor': kRedDark,
              'bgColor': kRedLight,
            },
            {
              'time': '10:00 AM',
              'title': 'Shot on Dribble',
              'slot': '10:00 AM - 12:00 AM',
              'tlColor': kBlueDark,
              'bgColor': kBlueLight,
            },
            {
              'time': '11:00 AM',
              'title': '',
              'slot': '',
              'tlColor': Colors.grey.withOpacity(0.3),
            },
            {
              'time': '12:00 AM',
              'title': '',
              'slot': '',
              'tlColor': Colors.grey.withOpacity(0.3),
            },
            {
              'time': '1:00 PM',
              'title': 'Call with client',
              'slot': '1:00 PM - 2:00 PM',
              'tlColor': kYellowDark,
              'bgColor': kYellowLight,
            },
            {
              'time': '2:00 PM',
              'title': '',
              'slot': '',
              'tlColor': Colors.grey.withOpacity(0.3),
            },
            {
              'time': '3:00 PM',
              'title': '',
              'slot': '',
              'tlColor': Colors.grey.withOpacity(0.3),
            },
          ]),
    ];
  }
}
