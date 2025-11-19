import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/*
class BrowserTab {
  final String id;
  String url;
  double scroll = 0.0;
  bool active;
  BrowserTab({required this.id, required this.url, this.active = false});

  Map<String, dynamic> toJson() => {'id': id, 'url': url, 'scroll': scroll, 'active': active};
  static BrowserTab fromJson(Map<String, dynamic> j) => BrowserTab(id: j['id'], url: j['url'], active: j['active'] ?? false)..scroll = (j['scroll'] ?? 0.0).toDouble();
}

class TabManager {
  final List<BrowserTab> _tabs = [];

  List<BrowserTab> get tabs => List.unmodifiable(_tabs);

  BrowserTab? get activeTab => _tabs.isEmpty ? null : _tabs.firstWhere((t) => t.active, orElse: () => _tabs.first);

  Future<void> createTab(String url) async {
    for (var t in _tabs) t.active = false;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final tab = BrowserTab(id: id, url: url, active: true);
    _tabs.add(tab);
    await _saveToDisk();
  }

  Future<void> closeTab(String id) async {
    _tabs.removeWhere((t) => t.id == id);
    if (_tabs.isNotEmpty && !_tabs.any((t) => t.active)) _tabs.first.active = true;
    await _saveToDisk();
  }

  Future<void> switchTo(String id) async {
    for (var t in _tabs) t.active = t.id == id;
    await _saveToDisk();
  }

  Future<void> updateUrl(String id, String url) async {
    final t = _tabs.firstWhere((x) => x.id == id, orElse: () => throw Exception('Tab not found'));
    t.url = url;
    await _saveToDisk();
  }

  // Persistence simple JSON in app documents
  Future<File> _storageFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/tabs.json');
  }

  Future<void> _saveToDisk() async {
    try {
      final f = await _storageFile();
      final data = _tabs.map((t) => t.toJson()).toList();
      await f.writeAsString(jsonEncode(data));
    } catch (_) {}
  }

  Future<void> loadFromDisk() async {
    try {
      final f = await _storageFile();
      if (!await f.exists()) return;
      final content = await f.readAsString();
      final list = jsonDecode(content) as List<dynamic>;
      _tabs.clear();
      for (var item in list) {
        _tabs.add(BrowserTab.fromJson(item as Map<String, dynamic>));
      }
    } catch (_) {}
  }
}
*/
// lib/features/browser/data/tab_manager.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class BrowserTab {
  final String id;
  String url;
  double scroll = 0.0;
  bool active;
  BrowserTab({required this.id, required this.url, this.active = false});

  Map<String, dynamic> toJson() => {'id': id, 'url': url, 'scroll': scroll, 'active': active};
  static BrowserTab fromJson(Map<String, dynamic> j) =>
      BrowserTab(id: j['id'], url: j['url'], active: j['active'] ?? false)
        ..scroll = (j['scroll'] ?? 0.0).toDouble();
}

class TabManager extends ChangeNotifier {
  final List<BrowserTab> _tabs = [];

  List<BrowserTab> get tabs => List.unmodifiable(_tabs);

  BrowserTab? get activeTab =>
      _tabs.isEmpty ? null : _tabs.firstWhere((t) => t.active, orElse: () => _tabs.first);

  Future<void> createTab(String url) async {
    for (var t in _tabs) t.active = false;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final tab = BrowserTab(id: id, url: url, active: true);
    _tabs.add(tab);
    await _saveToDisk();
    notifyListeners();
  }

  Future<void> closeTab(String id) async {
    _tabs.removeWhere((t) => t.id == id);
    if (_tabs.isNotEmpty && !_tabs.any((t) => t.active)) _tabs.first.active = true;
    await _saveToDisk();
    notifyListeners();
  }

  Future<void> switchTo(String id) async {
    for (var t in _tabs) t.active = t.id == id;
    await _saveToDisk();
    notifyListeners();
  }

  Future<void> updateUrl(String id, String url) async {
    final t = _tabs.firstWhere((x) => x.id == id, orElse: () => throw Exception('Tab not found'));
    t.url = url;
    await _saveToDisk();
    notifyListeners();
  }

  // Persistence simple JSON in app documents
  Future<File> _storageFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/tabs.json');
  }

  Future<void> _saveToDisk() async {
    try {
      final f = await _storageFile();
      final data = _tabs.map((t) => t.toJson()).toList();
      await f.writeAsString(jsonEncode(data));
    } catch (_) {}
  }

  Future<void> loadFromDisk() async {
    try {
      final f = await _storageFile();
      if (!await f.exists()) return;
      final content = await f.readAsString();
      final list = jsonDecode(content) as List<dynamic>;
      _tabs.clear();
      for (var item in list) {
        _tabs.add(BrowserTab.fromJson(item as Map<String, dynamic>));
      }
      notifyListeners();
    } catch (_) {}
  }
}
