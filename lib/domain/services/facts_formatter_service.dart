class FactsFormatterService {
  static List<String> parseFacts(String factsText) {
    final lines = factsText.split('\n');
    final facts = <String>[];

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      // Убираем маркеры списка (-, •, * и т.д.)
      String fact = trimmedLine;
      if (fact.startsWith('-')) {
        fact = fact.substring(1).trim();
      } else if (fact.startsWith('•')) {
        fact = fact.substring(1).trim();
      } else if (fact.startsWith('*')) {
        fact = fact.substring(1).trim();
      }

      if (fact.isNotEmpty) {
        facts.add(fact);
      }
    }

    return facts;
  }

  static String formatFacts(List<String> facts) {
    return facts.map((fact) => '• $fact').join('\n');
  }

  static List<String> getPreviewFacts(List<String> facts, {int count = 2}) {
    return facts.take(count).toList();
  }

  static bool shouldShowExpandButton(List<String> facts, {int threshold = 2}) {
    return facts.length > threshold;
  }
}
