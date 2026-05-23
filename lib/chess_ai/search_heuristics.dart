import 'ai_move.dart';

class SearchHeuristics {
  static const int maxPly = 128;

  final List<List<AiMove?>> killerMoves =
  List.generate(maxPly, (_) => [null, null]);

  final Map<String, int> historyScores = {};

  void clear() {
    for (int i = 0; i < maxPly; i++) {
      killerMoves[i][0] = null;
      killerMoves[i][1] = null;
    }

    historyScores.clear();
  }

  void addKillerMove(
      AiMove move,
      int ply,
      ) {
    if (ply < 0 || ply >= maxPly) return;

    final AiMove? first = killerMoves[ply][0];

    if (_sameMove(first, move)) {
      return;
    }

    killerMoves[ply][1] = killerMoves[ply][0];
    killerMoves[ply][0] = move;
  }

  bool isKillerMove(
      AiMove move,
      int ply,
      ) {
    if (ply < 0 || ply >= maxPly) return false;

    return _sameMove(killerMoves[ply][0], move) ||
        _sameMove(killerMoves[ply][1], move);
  }

  void addHistoryScore(
      AiMove move,
      int depth,
      ) {
    final String key = _historyKey(move);

    historyScores[key] =
        (historyScores[key] ?? 0) + depth * depth;
  }

  int getHistoryScore(AiMove move) {
    return historyScores[_historyKey(move)] ?? 0;
  }

  bool _sameMove(
      AiMove? a,
      AiMove b,
      ) {
    if (a == null) return false;

    return a.fromIndex == b.fromIndex &&
        a.toIndex == b.toIndex &&
        a.promotionPiece == b.promotionPiece;
  }

  String _historyKey(AiMove move) {
    return "${move.fromIndex}-${move.toIndex}-${move.promotionPiece ?? 0}";
  }
}