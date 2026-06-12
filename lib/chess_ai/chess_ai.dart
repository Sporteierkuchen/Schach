import '../services/opening_book.dart';
import '../services/opening_book_service.dart';
import 'ai_game_state.dart';
import 'ai_move.dart';
import 'board_evaluator.dart';
import 'minimax_engine.dart';
import 'move_generator.dart';
import 'move_ordering.dart';
import 'transposition_table.dart';

class ChessAi {
  final MoveGenerator moveGenerator = MoveGenerator();
  final BoardEvaluator evaluator = BoardEvaluator();
  late final MoveOrdering moveOrdering = MoveOrdering(evaluator);
  final TranspositionTable transpositionTable = TranspositionTable();

  final openingBookService = OpeningBookService();

  late final MinimaxEngine minimaxEngine = MinimaxEngine(
    moveGenerator: moveGenerator,
    evaluator: evaluator,
    moveOrdering: moveOrdering,
    transpositionTable: transpositionTable,
  );

  AiMove? getBestMove({
    required AiGameState state,
    required List<String> moveHistory,
    int timeLimitMs = 4000,
    int aiLevel = 5,
    OpeningStyle style = OpeningStyle.balanced,
  }) {
    final AiMove? bookMove = openingBookService.findBookMove(
      state: state,
      moveHistory: moveHistory,
      moveGenerator: moveGenerator,
      moveOrdering: moveOrdering,
      aiLevel: aiLevel,
      style: style,
    );

    if (bookMove != null) {
      print("📖 KI spielt Eröffnungsbuchzug");
      return bookMove;
    }

    //transpositionTable.clear();

    timeLimitMs = _timeLimitForLevel(aiLevel, timeLimitMs);

    final Stopwatch stopwatch = Stopwatch()..start();

    AiMove? bestMove;

    final int maxDepth = calculateMaxDepth(state.board);

    int previousScore = 0;

    for (int depth = 1; depth <= maxDepth; depth++) {
      if (stopwatch.elapsedMilliseconds >= timeLimitMs) {
        break;
      }

      int window = depth <= 3 ? MinimaxEngine.infinity : 150;

      AiMove? move;

      while (true) {
        final int alpha = previousScore - window;
        final int beta = previousScore + window;

        move = minimaxEngine.findBestMoveTimed(
          state: state,
          depth: depth,
          stopwatch: stopwatch,
          timeLimitMs: timeLimitMs,
          alpha: alpha,
          beta: beta,
        );

        if (move == null) {
          break;
        }

        if (stopwatch.elapsedMilliseconds >= timeLimitMs) {
          break;
        }

        final bool failLow = move.score <= alpha;
        final bool failHigh = move.score >= beta;

        if (!failLow && !failHigh) {
          break;
        }

        window *= 2;

        if (window >= MinimaxEngine.infinity ~/ 2) {
          break;
        }

        print(
          "🔁 Aspiration Retry Tiefe $depth | "
              "Score: ${move.score} | "
              "Neues Fenster: ±$window",
        );
      }

      if (move == null) {
        break;
      }

      bestMove = move;
      previousScore = move.score;

      print(
        "✅ Iterative Deepening Tiefe $depth fertig | "
            "Move: ${move.fromIndex} -> ${move.toIndex} | "
            "Score: ${move.score} | "
            "Zeit: ${stopwatch.elapsedMilliseconds} ms",
      );

      // Wenn Matt gefunden wurde, nicht weiter suchen.
      // Tiefer suchen kann durch Timeout/Aspiration einen schlechteren Zug übernehmen.
      if (move.score.abs() > MinimaxEngine.mateScore - 10000) {
        print("🏁 Mattzug gefunden bei Tiefe $depth -> Suche beendet");
        break;
      }
    }

    stopwatch.stop();

    print(
      "🏁 KI fertig | "
          "Zeit: ${stopwatch.elapsedMilliseconds} ms | "
          "TT: ${transpositionTable.size}",
    );

    return bestMove;
  }

  int calculateMaxDepth(List<int> board) {
    final int pieces = board.where((piece) => piece != 0).length;

    if (pieces <= 5) return 12;
    if (pieces <= 8) return 11;
    if (pieces <= 12) return 10;
    if (pieces <= 16) return 9;
    if (pieces <= 24) return 8;

    return 7;
  }

  int _timeLimitForLevel(int aiLevel, int fallback) {
    if (aiLevel <= 1) return 1000;
    if (aiLevel == 2) return 2000;
    if (aiLevel == 3) return 4000;
    if (aiLevel == 4) return 6000;
    return 8000;
  }

}