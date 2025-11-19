import 'package:hive/hive.dart';

part 'summary.g.dart'; // optional if you use codegen - adapter below means codegen is optional

@HiveType(typeId: 1)
class Summary extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title; // short title or headline

  @HiveField(2)
  String? sourceUrl; // url or document id

  @HiveField(3)
  String content; // full summary text

  @HiveField(4)
  String language; // e.g., 'en'

  @HiveField(5)
  DateTime createdAt;

  Summary({
    required this.id,
    required this.title,
    this.sourceUrl,
    required this.content,
    this.language = 'en',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
