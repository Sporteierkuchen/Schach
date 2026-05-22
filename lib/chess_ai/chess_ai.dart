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
    int aiLevel=5,
    OpeningStyle style= OpeningStyle.balanced,
  }) {

    final AiMove? bookMove = openingBookService.findBookMove(
      state:state,
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

    transpositionTable.clear();

    final Stopwatch stopwatch = Stopwatch()..start();

    AiMove? bestMove;

    final int maxDepth = calculateMaxDepth(state.board);

    for (int depth = 1; depth <= maxDepth; depth++) {
      if (stopwatch.elapsedMilliseconds >= timeLimitMs) {
        break;
      }

      final AiMove? move = minimaxEngine.findBestMoveTimed(
        state: state,
        depth: depth,
        stopwatch: stopwatch,
        timeLimitMs: timeLimitMs,
      );

      if (move == null) {
        break;
      }

      bestMove = move;

      print(
        "✅ Iterative Deepening Tiefe $depth fertig | "
            "Move: ${move.fromIndex} -> ${move.toIndex} | "
            "Score: ${move.score} | "
            "Zeit: ${stopwatch.elapsedMilliseconds} ms",
      );
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

    if (pieces <= 6) return 9;
    if (pieces <= 10) return 8;
    if (pieces <= 16) return 7;
    if (pieces <= 24) return 6;

    return 5;
  }
}