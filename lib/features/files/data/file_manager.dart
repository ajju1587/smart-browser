/*
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class FileMeta {
  final String id;
  final String url;
  String? path;
  double progress;
  String status;
  String? filename; // <-- ADD THIS LINE

  FileMeta({
    required this.id,
    required this.url,
    this.path,
    this.progress = 0.0,
    this.status = 'queued',
    this.filename,
  });
}


class FileManager {
  final Dio _dio = Dio();
  final Map<String, FileMeta> _store = {};

  Future<FileMeta> startDownload(String url) async {
    final id = const Uuid().v4();
    final meta = FileMeta(id: id, url: url);
    _store[id] = meta;
    _download(id, url);
    return meta;
  }
  bool isSupportedDocument(String url) {
    final lower = url.toLowerCase().split('?').first;
    return lower.endsWith('.pdf') ||
        lower.endsWith('.docx') ||
        lower.endsWith('.pptx') ||
        lower.endsWith('.xlsx');
  }


  Future<void> _download(String id, String url) async {
    final meta = _store[id]!;
    try {
      meta.status = 'downloading';
      final dir = await getApplicationDocumentsDirectory();
      final filename = url.split('/').last;
      final savePath = '${dir.path}/$filename';
      await _dio.download(url, savePath, onReceiveProgress: (rcv, total) {
        meta.progress = total > 0 ? rcv / total : 0.0;
      });
      meta.path = savePath;
      meta.status = 'completed';
    } catch (e) {
      meta.status = 'failed';
    }
  }

  List<FileMeta> listDownloads() => _store.values.toList();
}
*/
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../models/file_meta.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';

class FileManager {
  final Dio _dio = Dio();
  final Box<FileMeta> _downloadsBox = Hive.box<FileMeta>('downloads');
  final Box<String> _historyBox = Hive.box<String>('history');
  final _supported = ['.pdf', '.docx', '.pptx', '.xlsx'];

  // Check extension-based support.
  bool isSupportedDocument(String url) {
    final u = url
        .split('?')
        .first
        .toLowerCase();
    return _supported.any((ext) => u.endsWith(ext));
  }

  // Start a web download (from URL). Stores FileMeta into Hive.
  Future<FileMeta> startDownload(String url) async {
    final id = const Uuid().v4();
    final tmpMeta = FileMeta(
      id: id,
      sourceUrl: url,
      path: '',
      name: url
          .split('/')
          .last
          .split('?')
          .first,
      size: 0,
      mime: '',
      createdAt: DateTime.now(),
      status: 'queued',
    );

    // save initial meta so UI can show queued item
    _downloadsBox.put(id, tmpMeta);

    // perform download async
    print('tmpMeta===${tmpMeta}');
    _downloadToLocal(id, url);

    return tmpMeta;
  }

  Future<void> _downloadToLocal(String id, String url) async {
    final meta = _downloadsBox.get(id);

    if (meta == null) return;
    try {
      _downloadsBox.put(id, meta..status = 'downloading');

      // try HEAD to get filename and content-type
      String filename = meta.name;
      print('meta===${meta!.id!}');
      print('meta name===${meta!.name!}');
      try {
        final head = await _dio.head(url, options: Options(followRedirects: true, validateStatus: (_) => true));
        final cd = head.headers['content-disposition']?.firstOrNull;
        if (cd != null) {
          final fnameMatch = RegExp(r'filename\\*?=([^;]+)').firstMatch(cd);
          print(' fnameMatch===${fnameMatch}');
          if (fnameMatch != null) {
            filename = fnameMatch.group(1)!.replaceAll(RegExp(r'["\"]'), '').trim();
          } else {
            final ct = head.headers['content-type']?.firstOrNull;
            if (ct != null) {
              final ext = _extensionFromContentType(ct);
              if (ext != null && !filename.contains('.')) filename = filename + ext;
            }
          }
        }
      } catch (e) {
        print('error---${e}');
      }

      final dir = await getApplicationDocumentsDirectory();
      final safeName = filename.replaceAll(RegExp(r'[^A-Za-z0-9_\.\\ -]'), '_');
      final savePath = '${dir.path}/$safeName';
      print('savePath===>>>${savePath}');

      // download with progress
      await _dio.download(url, savePath, onReceiveProgress: (rcv, total) {
        final p = total > 0 ? (rcv / total) : 0.0;
        final updated = meta..status = 'downloading';
        // size not final until completed; store progress in status if needed
        _downloadsBox.put(id, updated);
      });

      final file = File(savePath);
      final size = await file.length();
      final mime = lookupMimeType(savePath) ?? '';

      final completedMeta = FileMeta(
        id: id,
        sourceUrl: url,
        path: savePath,
        name: safeName,
        size: size,
        mime: mime,
        createdAt: DateTime.now(),
        status: 'completed',
      );
      _downloadsBox.put(id, completedMeta);
      _addToHistory(id);
    } catch (e) {
      final failed = meta..status = 'failed';
      _downloadsBox.put(id, failed);
    }
  }

  // Allow user to pick a local file and copy into app storage (and register metadata)
  Future<FileMeta?> pickFileAndSave() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _supported.map((s) => s.replaceFirst('.', '')).toList(),
    );
    if (result == null || result.files.isEmpty) return null;
    final pf = result.files.first;
    final srcPath = pf.path!;
    final dir = await getApplicationDocumentsDirectory();
    final safeName = pf.name.replaceAll(RegExp(r'[^A-Za-z0-9_\\.\\- ]'), '_');
    final destPath = '${dir.path}/$safeName';

    // copy the file
    await File(srcPath).copy(destPath);

    final id = const Uuid().v4();
    final meta = FileMeta(
      id: id,
      sourceUrl: null,
      path: destPath,
      name: safeName,
      size: pf.size,
      mime: lookupMimeType(destPath) ?? '',
      createdAt: DateTime.now(),
      status: 'completed',
    );

    _downloadsBox.put(id, meta);
    _addToHistory(id);
    return meta;
  }

  // List all downloaded items from Hive
  List<FileMeta> listDownloads() {
    return _downloadsBox.values.toList().cast<FileMeta>();
  }

  // Open file using platform default app
  Future<OpenResult> openFile(FileMeta meta) async {
    // mark opened in history
    print('meta.path==${meta.path}');
    _addToHistory(meta.id);
    return OpenFile.open(meta.path);
  }

  // History: maintain a simple list of file IDs (most recent at end)
  void _addToHistory(String fileId) {
    // store as newline-separated ids in the box for simplicity or use list
    final key = 'history_list';
    final existing = _historyBox.get(key);
    final ids = existing == null ? <String>[] : existing.split(',');
    ids.remove(fileId); // avoid duplicates
    ids.add(fileId);
    // keep last 200 only
    final pruned = ids.length > 200 ? ids.sublist(ids.length - 200) : ids;
    _historyBox.put(key, pruned.join(','));
  }

  // Retrieve history as FileMeta list ordered most recent first
  List<FileMeta> getHistory() {
    final key = 'history_list';
    final existing = _historyBox.get(key);
    if (existing == null || existing.isEmpty) return [];
    final ids = existing
        .split(',')
        .reversed
        .toList();
    final metas = ids.map((id) => _downloadsBox.get(id)).whereNotNull().toList();
    return metas;
  }

  // Utility: derive extension from content-type
  String? _extensionFromContentType(String ct) {
    ct = ct.toLowerCase();
    if (ct.contains('pdf')) return '.pdf';
    if (ct.contains('officedocument.word')) return '.docx';
    if (ct.contains('msword')) return '.docx';
    if (ct.contains('presentation') || ct.contains('officedocument.presentation')) return '.pptx';
    if (ct.contains('spreadsheet') || ct.contains('officedocument.spreadsheet')) return '.xlsx';
    return null;
  }

}