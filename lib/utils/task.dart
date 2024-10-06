import 'dart:collection';
import 'package:table_calendar/table_calendar.dart';

/// Task class.
class Task {
  final String title;

  const Task(this.title);

  @override
  String toString() => title;
}

/// Tasks (Using a [LinkedHashMap] is highly recommended if you decide to use a map).
final kTasks = LinkedHashMap<DateTime, List<Task>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kTaskSource);

final _kTaskSource = LinkedHashMap.fromIterable(
    List.generate(50, (index) => index),
    key: (item) => DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5),
    value: (item) => List.generate(
        item % 4 + 1, (index) => Task('Task $item | ${index + 1}')))
  ..addAll({
    kToday: [
      const Task('Today\'s Task 1'),
      const Task('Today\'s Task 2'),
    ],
  });

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
// final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
// final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
final kFirstDay = DateTime(2000, 1, 1);
final kLastDay = DateTime(2050, 12, 31);
