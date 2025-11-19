import 'package:hive/hive.dart';

part 'file_meta.g.dart'; // optional if you use build_runner; below I provide manual adapter instead

@HiveType(typeId: 0)
class FileMeta extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? sourceUrl; // original URL (if downloaded from web). null if user-picked file.

  @HiveField(2)
  String path; // local path where file is stored

  @HiveField(3)
  String name; // filename shown to user

  @HiveField(4)
  int size; // bytes

  @HiveField(5)
  String mime; // mime/type or extension hint

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  String status; // queued/downloading/completed/failed/opened

  FileMeta({
    required this.id,
    this.sourceUrl,
    required this.path,
    required this.name,
    required this.size,
    required this.mime,
    DateTime? createdAt,
    this.status = 'completed',
  }) : createdAt = createdAt ?? DateTime.now();
}