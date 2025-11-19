import 'package:hive/hive.dart';
import '../models/summary.dart';
import 'package:uuid/uuid.dart';

class SummaryRepository {
  static const _boxName = 'summaries';
  final Box<Summary> _box;

  SummaryRepository._(this._box);

  // factory to open existing box (box must already be opened in main)
  factory SummaryRepository() {
    final box = Hive.box<Summary>(_boxName);
    return SummaryRepository._(box);
  }

  Future<Summary> saveSummary({
    String? id,
    required String title,
    String? sourceUrl,
    required String content,
    String language = 'en',
  }) async {
    final _id = id ?? const Uuid().v4();
    final summary = Summary(
      id: _id,
      title: title,
      sourceUrl: sourceUrl,
      content: content,
      language: language,
      createdAt: DateTime.now(),
    );
    await _box.put(_id, summary);
    return summary;
  }

  List<Summary> listSummaries() {
    return _box.values.toList().cast<Summary>()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Summary? getSummary(String id) => _box.get(id);

  Future<void> deleteSummary(String id) async => await _box.delete(id);

  Future<void> clearAll() async => await _box.clear();
}
