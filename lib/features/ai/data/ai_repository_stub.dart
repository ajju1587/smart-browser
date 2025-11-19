class AiRepository {
  Future<String> summarize(String text) async => '';
  Future<String> translate(String text, String toLang) async => '';
}

class AiRepositoryStub implements AiRepository {
  @override
  Future<String> summarize(String text) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (text.isEmpty) return 'No text found.';
    final lines = text.split(RegExp(r"\n+"));
    final first = lines.where((l) => l.trim().isNotEmpty).take(3).join(' ');
    return 'Summary (local stub): ' + first;
  }

  @override
  Future<String> translate(String text, String toLang) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'Translated($toLang): ' + text;
  }
}
