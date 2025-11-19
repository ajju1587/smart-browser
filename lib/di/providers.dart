import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/ai/data/ai_repository_stub.dart';
import '../features/files/data/file_manager.dart';
import '../features/browser/data/tab_manager.dart';
import '../features/files/data/cache_manager.dart';
import '../features/ai/data/summary_repository.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepositoryStub();
});

final fileManagerProvider = Provider<FileManager>((ref) {
  return FileManager();
});

final tabManagerProvider = ChangeNotifierProvider<TabManager>((ref) {
  return TabManager();
});

final cacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager();
});
final summaryRepositoryProvider = Provider<SummaryRepository>((ref) {
  return SummaryRepository();
});
final downloadProvider = Provider<FileManager>((ref) {
  return FileManager();
});
