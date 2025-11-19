import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class CacheManager {
  // Save snapshots (HTML/text) keyed by url hash
  Future<String> _cacheDirPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/cache';
    final d = Directory(path);
    if (!await d.exists()) await d.create(recursive: true);
    return path;
  }

  String _hash(String input) {
    return sha1.convert(utf8.encode(input)).toString();
  }

  Future<void> saveSnapshot(String url, String content) async {
    final path = await _cacheDirPath();
    final id = _hash(url);
    final file = File('$path/$id.html');
    await file.writeAsString(content);
  }

  Future<String?> loadSnapshot(String url) async {
    final path = await _cacheDirPath();
    final id = _hash(url);
    final file = File('\$path/$id.html');
    if (await file.exists()) return await file.readAsString();
    return null;
  }

  Future<List<String>> listCachedUrls() async {
    final path = await _cacheDirPath();
    final d = Directory(path);
    if (!await d.exists()) return [];
    final files = d.listSync().whereType<File>().toList();
    // We don't store url -> hash reverse mapping; return filenames
    return files.map((f) => f.path).toList();
  }
}
