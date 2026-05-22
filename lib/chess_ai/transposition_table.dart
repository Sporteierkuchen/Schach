enum TranspositionFlag {
  exact,
  lowerBound,
  upperBound,
}

class TranspositionEntry {
  final int depth;
  final int score;
  final TranspositionFlag flag;
  final int? bestFrom;
  final int? bestTo;
  final int? bestPromotion;

  const TranspositionEntry({
    required this.depth,
    required this.score,
    required this.flag,
    this.bestFrom,
    this.bestTo,
    this.bestPromotion,
  });
}

class TranspositionTable {
  final Map<int, TranspositionEntry> _table = {};

  TranspositionEntry? get(int key) {
    return _table[key];
  }

  void put({
    required int key,
    required int depth,
    required int score,
    required TranspositionFlag flag,
    int? bestFrom,
    int? bestTo,
    int? bestPromotion,
  }) {
    final TranspositionEntry? old = _table[key];

    if (old != null && old.depth > depth) {
      return;
    }

    _table[key] = TranspositionEntry(
      depth: depth,
      score: score,
      flag: flag,
      bestFrom: bestFrom,
      bestTo: bestTo,
      bestPromotion: bestPromotion,
    );
  }

  void clear() {
    _table.clear();
  }

  int get size => _table.length;
}