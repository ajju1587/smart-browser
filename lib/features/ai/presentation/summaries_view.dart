import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/summary_repository.dart';
import '../models/summary.dart';
import '../../../di/providers.dart';

class SummariesView extends ConsumerWidget {
  const SummariesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final repo = ref.read(summaryRepositoryProvider);
    // summaries = repo.listSummaries();
    final repo = ref.read(downloadProvider);
    final summaries = repo.listDownloads();

    return Scaffold(
      appBar: AppBar(title: const Text('Summaries')),
      body: summaries.isEmpty
          ? const Center(child: Text('No saved File yet.'))
          : ListView.builder(
        itemCount: summaries.length,
        itemBuilder: (context, index) {
          final s = summaries[index];
          return ListTile(
            title: Text(s.name),
            subtitle: Text('${s.sourceUrl ?? 'Local'} • ${s.createdAt.toLocal()}'),
            onTap: () {
              //Navigator.of(context).push(MaterialPageRoute(builder: (_) => SummaryDetailView(summary: s)));
            },
            trailing: IconButton(
              icon: const Icon(Icons.remove_red_eye_sharp),
              onPressed: () async {
                await repo.openFile(s);
                // force rebuild: using setState not available here - simple approach: pop+push or use Riverpod + state
                (context as Element).reassemble();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Open')));
              },
            ),
          );
        },
      ),
    );
  }
}

class SummaryDetailView extends StatelessWidget {
  final Summary summary;
  const SummaryDetailView({required this.summary, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(summary.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(child: Text(summary.content)),
      ),
    );
  }
}
