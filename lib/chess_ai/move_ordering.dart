import '../components/FigurenMovesArray.dart';
import 'board_evaluator.dart';

class MoveOrdering {
  final BoardEvaluator evaluator;

  MoveOrdering(this.evaluator);

  List<FigurenMovesArray> orderMoves(
      List<FigurenMovesArray> moves,
      List<int> board,
      ) {
    final List<FigurenMovesArray> copy = List<FigurenMovesArray>.from(moves);

    copy.sort((a, b) {
      final int scoreA = _moveScore(a, board);
      final int scoreB = _moveScore(b, board);

      return scoreB.compareTo(scoreA);
    });

    return copy;
  }

  int _moveScore(FigurenMovesArray move, List<int> board) {
    int bestScore = 0;

    for (final int target in move.targetIndices) {
      final int capturedPiece = board[target];

      int score = 0;

      if (capturedPiece != 0) {
        score += evaluator.pieceValue(capturedPiece).abs() * 10;
        score -= evaluator.pieceValue(move.piece).abs();
      }

      if (move.piece.abs() == 1) {
        final int targetRow = target ~/ 8;
        if (targetRow == 0 || targetRow == 7) {
          score += 800;
        }
      }

      if (score > bestScore) {
        bestScore = score;
      }
    }

    return bestScore;
  }
}