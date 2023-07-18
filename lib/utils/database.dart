import 'dart:developer';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:on_audio_query/on_audio_query.dart';

class ZenifyDatabase {
  Map<dynamic, dynamic> userDetails = {
    'name': '',
    'password': '',
  };

  int currentSongIndex = 0;
  bool hasPermission = false;

  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<dynamic> musicList = [];

  final dateFormat = DateFormat('yyyy-MM-dd hh:mm');
  final timeFormat = DateFormat.jm();
  final now = DateTime.now();

  DateTime _formatConvertor(DateTime dateTime, String time) {
    return DateTime.parse(DateFormat('yyyy-MM-dd HH:mm').format(
            DateTime.parse("${DateFormat("yyyy-MM-dd").format(dateTime)} $time")
                .toLocal()))
        .toLocal();
  }

// type: Map<DateTime, List<Map<String, dynamic>>>
  Map<dynamic, dynamic> tasks = {};

  final _zenifyData = Hive.box('zenifyData');

  // Function to clear the database...
  void clearDatabase() {
    log('Clearing database...');
    _zenifyData.clear();
  }

  // Function to get permission...
  Future<bool> requestStoragePermission() async {
    if (!kIsWeb) {
      log('Requesting storage permission...');
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }

      log(permissionStatus
          ? "requesting: Permission granted"
          : "requesting: Permission denied");

      if (permissionStatus == true) {
        return permissionStatus;
      }
    }

    return false;
  }

  // Function to save the user details...
  void saveUserDetails() {
    log('Saving user details...');
    _zenifyData.put('userDetails', userDetails);
  }

  // Function to get the user details...
  void getUserDetails() {
    log('Getting user details...');
    userDetails = _zenifyData.get('userDetails') ?? userDetails;
  }

  void setInitialTasks() {
    log('Setting initial tasks...');
    var temp = tasks = {
      DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal()): [
        {
          'title': "Get ready for the day",
          'desc': "Brush your teeth, take a bath, etc.",
          'time': _formatConvertor(now, "07:00"),
          'isDone': false,
        },
        {
          'title': "Tidy up the room",
          'desc': "Tidy up the room and make the bed.",
          'time': _formatConvertor(now, "07:30"),
          'isDone': false,
        },
        {
          'title': "Breakfast",
          'desc': "Have breakfast in the mess before classes.",
          'time': _formatConvertor(now, "08:00"),
          'isDone': false,
        },
        {
          'title': "Complete the daily question on leeetcode",
          'desc': "Complete the daily question on leeetcode.",
          'time': _formatConvertor(now, "09:00"),
          'isDone': false,
        },
        {
          'title': "Data Science IITR Lecture 54",
          'desc':
              "Watch lecture 54 (regression models) of Data Science IITR lectures.",
          'time': _formatConvertor(now, "09:30"),
          'isDone': false,
        },
        {
          'title': "AI/ML IITR Lecture 28",
          'desc':
              "Watch lecture 28 of Fundamental mathematical concepts of AI/ML IITR lecture.",
          'time': _formatConvertor(now, "10:15"),
          'isDone': false,
        },
        {
          'title': "Lunch",
          'desc':
              "Have lunch in the mess before the afternoon classes/lab if any.",
          'time': _formatConvertor(now, "13:30"),
          'isDone': false,
        },
        {
          'title': "Project work",
          'desc':
              "Start working on any pending project or learn something new.",
          'time': _formatConvertor(now, "19:30"),
          'isDone': false,
        },
        {
          'title': "Dinner",
          'desc': "Have dinner in the mess.",
          'time': _formatConvertor(now, "20:30"),
          'isDone': false,
        },
        {
          'title': "Solve questions on leetcode",
          'desc': "Solve some questions on leetcode before sleeping.",
          'time': _formatConvertor(now, "21:30"),
          'isDone': false,
        },
      ]
    };
    _zenifyData.put('tasks', temp);
    _zenifyData.get('tasks');
  }

  // Function to update the music list...
  void fetchMusicList() async {
    musicList.clear();
    bool permissionStatus = _zenifyData.get('Permission_status') ?? false;
    log('Fetching music...');

    if (!hasPermission) {
      permissionStatus = await requestStoragePermission();

      log(permissionStatus
          ? "fetching: Permission granted"
          : "fetching: Permission denied");
    }

    var temp = [];

    if (permissionStatus == true) {
      temp = await _audioQuery.querySongs(
        sortType: null,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
      _zenifyData.put("Permission_status", permissionStatus);
    }

    musicList.clear();

    var title = <dynamic>{};

    for (final song in temp) {
      if (title.contains(song.title)) {
        continue;
      } else {
        title.add(song.title);
        musicList.add(
          {
            "title": song.title,
            "artist": song.artist,
            "uri": song.uri,
            "id": song.id,
          },
        );
      }
    }

    _zenifyData.put('musicList', musicList);
    hasPermission = _zenifyData.get('Permission_status') ?? hasPermission;
    log('Done fetching music list...');
  }

  void saveMusicList(List<dynamic> data) {
    log('Saving music list...');
    List<dynamic> temp = [];
    for (final song in data) {
      temp.add(
        {
          "title": song.title,
          "artist": song.artist,
          "uri": song.uri,
          "id": song.id,
        },
      );
    }
    List<String> param = [];
    List<dynamic> finalList = [];
    for (final song in temp) {
      if (param.contains(song["title"])) {
        continue;
      } else {
        param.add(song["title"]);
        finalList.add(song);
      }
    }
    _zenifyData.put('musicList', finalList);
  }

  // Function to load the music list...
  void loadMusicList() async {
    log('Loading music list...');
    hasPermission = _zenifyData.get('Permission_status') ?? hasPermission;
    var temp = _zenifyData.get('musicList') ?? musicList;
    var param = [];
    musicList.clear();
    for (final song in temp) {
      if (param.contains(song["title"])) {
        continue;
      } else {
        param.add(song["title"]);
        musicList.add(song);
      }
    }
    log("loading: ${musicList.length}");
  }

  // Function to update the current song index from id...
  void updateCurrentSongIndexFromId(int id) {
    log('Updating current song index from id...');
    for (int i = 0; i < musicList.length; i++) {
      if (musicList[i]['id'] == id) {
        currentSongIndex = i;
        break;
      }
    }
    _zenifyData.put('currentSongIndex', currentSongIndex);
  }

  // Function to update the current song index from value...
  void updateCurrentSongIndexFromValue(int value) {
    log('Updating current song index from value...');
    currentSongIndex = value < 0
        ? 0
        : value > musicList.length - 1
            ? musicList.length - 1
            : value;
    _zenifyData.put('currentSongIndex', currentSongIndex);
    getCurrentSongIndex();
  }

  // Function to update the current song index...
  void updateCurrentSongIndex(int offset) {
    log('Updating current song index...');
    currentSongIndex += offset;
    if (currentSongIndex < 0) currentSongIndex = 0;
    if (currentSongIndex >= musicList.length) {
      currentSongIndex = musicList.length - 1;
    }
    _zenifyData.put('currentSongIndex', currentSongIndex);
    getCurrentSongIndex();
  }

  // Function to save the current song index...
  void saveCurrentSongIndex() {
    log('Saving current song index...');
    _zenifyData.put('currentSongIndex', currentSongIndex);
  }

  // Function to get the current song index...
  void getCurrentSongIndex() {
    log('Getting current song index...');
    currentSongIndex = _zenifyData.get('currentSongIndex') ?? currentSongIndex;
  }

  // Function to update the collection of task list...
  void saveTasks() {
    log("Saving tasks...");
    _zenifyData.put('tasks', tasks);
  }

  // Function to get the collection of task list...
  void getTasks() {
    log("Getting tasks...");
    tasks = _zenifyData.get('tasks') ?? tasks;
    log(tasks.toString());
  }

  // Function to add a new task list to the collection...
  void addTask(String dateTime, List<Map<dynamic, dynamic>> task) {
    tasks[dateTime] = task;
    saveTasks();
    getTasks();
  }

  // Function to update the task status...
  void updateTaskStatus(String date, int taskIndex, bool isDone) {
    tasks[date][taskIndex]['isDone'] = isDone;
    saveTasks();
    getTasks();
  }

  // Function to delete a task item from the task list...
  void deleteTaskItem(String date, int taskIndex) {
    log("Deleting task...");
    getTasks();

    if (tasks[date].length > taskIndex) {
      log("to delete: $taskIndex, $date, ${tasks[date].length}");
      log("to delete: ${tasks[date][taskIndex].toString()}, $date");
      tasks[date].removeAt(taskIndex);
    }
    saveTasks();
    getTasks();
  }

  // Function to add a task item to the task list...
  void addTaskItem(String date, Map<dynamic, dynamic> taskItem) {
    tasks[date] = [...tasks[date], taskItem];
    saveTasks();
    getTasks();
  }

  // Function to update a certain task item in the task list...
  void updateTaskItem(
      String date, int taskIndex, Map<dynamic, dynamic> taskItem) {
    tasks[date][taskIndex] = taskItem;
    saveTasks();
    getTasks();
  }
}
