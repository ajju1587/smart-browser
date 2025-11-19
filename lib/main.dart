import 'package:flutter/material.dart';
import 'app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/files/models/file_meta.dart';
import 'features/ai/models/summary.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(FileMetaAdapter());
  Hive.registerAdapter(SummaryAdapter());

  // ensure the box exists
  await Hive.openBox<FileMeta>('downloads');    // stores FileMeta objects
  await Hive.openBox<String>('history');
  await Hive.openBox<Summary>('summaries');

  runApp(const ProviderScope(child: MyApp()));
}
