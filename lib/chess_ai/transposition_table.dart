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

  final int generation;

  const TranspositionEntry({
    required this.depth,
    required this.score,
    required this.flag,
    required this.generation,
    this.bestFrom,
    this.bestTo,
    this.bestPromotion,
  });
}

class TranspositionTable {
  static const int maxEntries = 300000;

  final Map<int, TranspositionEntry> _table = {};

  int _generation = 0;

  void nextGeneration() {
    _generation++;
  }

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

    if (old != null) {
      final bool oldIsDeeper = old.depth > depth;
      final bool oldIsCurrentGeneration = old.generation == _generation;

      if (oldIsDeeper && oldIsCurrentGeneration) {
        return;
      }
    }

    if (_table.length >= maxEntries && old == null) {
      _cleanupOldEntries();

      if (_table.length >= maxEntries) {
        return;
      }
    }

    _table[key] = TranspositionEntry(
      depth: depth,
      score: score,
      flag: flag,
      generation: _generation,
      bestFrom: bestFrom,
      bestTo: bestTo,
      bestPromotion: bestPromotion,
    );
  }

  void _cleanupOldEntries() {
    final List<int> keysToRemove = [];

    _table.forEach((key, entry) {
      final bool isOld = entry.generation < _generation;
      final bool isShallow = entry.depth <= 2;

      if (isOld || isShallow) {
        keysToRemove.add(key);
      }
    });

    for (final int key in keysToRemove) {
      _table.remove(key);
    }

    if (_table.length < maxEntries) {
      return;
    }

    final List<MapEntry<int, TranspositionEntry>> entries =
    _table.entries.toList();

    entries.sort((a, b) {
      final int generationCompare =
      a.value.generation.compareTo(b.value.generation);

      if (generationCompare != 0) {
        return generationCompare;
      }

      return a.value.depth.compareTo(b.value.depth);
    });

    final int removeCount = maxEntries ~/ 4;

    for (int i = 0; i < removeCount && i < entries.length; i++) {
      _table.remove(entries[i].key);
    }
  }

  void clear() {
    _table.clear();
  }

  int get size => _table.length;

  int get generation => _generation;
}