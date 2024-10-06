// ignore_for_file: file_names

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'songModelAdapter.g.dart';

@HiveType(typeId: 0)
class SongType extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String uri;

  @HiveField(3)
  String artist;

  SongType({
    required this.id,
    required this.title,
    required this.uri,
    required this.artist,
  });
}
