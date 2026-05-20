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

  late final MinimaxEngine minimaxEngine = MinimaxEngine(
    moveGenerator: moveGenerator,
    evaluator: evaluator,
    moveOrdering: moveOrdering,
    transpositionTable: transpositionTable,
  );

  AiMove? getBestMove({
    required List<int> board,
    required bool isEnemyMove,
    required bool isWhiteTurn,
  }) {
    transpositionTable.clear();

    final int depth = calculateDynamicDepth(board);

    return minimaxEngine.findBestMove(
      board: List<int>.from(board),
      depth: depth,
      isEnemyMove: isEnemyMove,
      isWhiteTurn: isWhiteTurn,
    );
  }

  int calculateDynamicDepth(List<int> board) {
    final int pieces = board.where((piece) => piece != 0).length;

    if (pieces <= 6) return 6;
    if (pieces <= 10) return 5;
    if (pieces <= 16) return 4;

    return 3;
  }
}