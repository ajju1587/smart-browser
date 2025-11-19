import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/ai_repository_stub.dart';
import '../../../di/providers.dart';
import '../models/summary.dart';

class AiSummaryWidget extends ConsumerStatefulWidget {
  final String text;
  final String? sourceUrl;
  const AiSummaryWidget({required this.text, this.sourceUrl, Key? key}) : super(key: key);

  @override
  ConsumerState<AiSummaryWidget> createState() => _AiSummaryWidgetState();
}

class _AiSummaryWidgetState extends ConsumerState<AiSummaryWidget> {
  String? _summary;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _requestSummary();
  }

  Future<void> _requestSummary() async {
    setState(() => _loading = true);
    final repo = ref.read(aiRepositoryProvider);
    final s = await repo.summarize(widget.text);

    // Save summary into Hive using SummaryRepository
    final summaryRepo = ref.read(summaryRepositoryProvider);
    final title = _createTitleFromText(widget.text);
    final saved = await summaryRepo.saveSummary(
      title: title,
      sourceUrl: widget.sourceUrl,
      content: s,
      language: 'en',
    );

    setState(() {
      _summary = s;
      _loading = false;
    });

    // optional: show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved summary: ${saved.title}')));
    }
  }

  String _createTitleFromText(String text) {
    final t = text.trim();
    if (t.isEmpty) return 'Untitled summary';
    final firstLine = t.split(RegExp(r'\\n+')).first.trim();
    return firstLine.length > 60 ? firstLine.substring(0, 60) + '...' : firstLine;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Summary')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(padding: const EdgeInsets.all(12.0), child: Text(_summary ?? 'No summary')),
    );
  }
}
