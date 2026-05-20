class TranspositionEntry {
  final int depth;
  final int score;

  const TranspositionEntry({
    required this.depth,
    required this.score,
  });
}

class TranspositionTable {
  final Map<String, TranspositionEntry> _table = {};

  TranspositionEntry? get(String key, int depth) {
    final TranspositionEntry? entry = _table[key];

    if (entry == null) return null;

    if (entry.depth >= depth) {
      return entry;
    }

    return null;
  }

  void put(String key, int depth, int score) {
    _table[key] = TranspositionEntry(
      depth: depth,
      score: score,
    );
  }

  void clear() {
    _table.clear();
  }
}