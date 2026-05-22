import '../components/FigurenMovesArray.dart';
import 'ai_move.dart';
import 'board_evaluator.dart';

class MoveOrdering {
  final BoardEvaluator evaluator;

  MoveOrdering(this.evaluator);

  List<AiMove> flattenAndOrderMoves(
      List<FigurenMovesArray> groupedMoves,
      List<int> board, {
        int? hashFrom,
        int? hashTo,
        int? hashPromotion,
      }) {
    final List<AiMove> moves = [];

    for (final FigurenMovesArray group in groupedMoves) {
      for (final int target in group.targetIndices) {
        final bool promotion =
            group.piece.abs() == 1 && (target ~/ 8 == 0 || target ~/ 8 == 7);

        if (promotion) {
          final List<int> promos = [5, 4, 3, 2];

          for (final int p in promos) {
            final int promotionPiece = group.piece > 0 ? p : -p;

            moves.add(
              AiMove(
                fromIndex: group.fromIndex,
                toIndex: target,
                piece: group.piece,
                promotionPiece: promotionPiece,
                score: _scoreMove(
                  board,
                  group.fromIndex,
                  target,
                  group.piece,
                  promotionPiece,
                  hashFrom,
                  hashTo,
                  hashPromotion,
                ),
              ),
            );
          }
        } else {
          moves.add(
            AiMove(
              fromIndex: group.fromIndex,
              toIndex: target,
              piece: group.piece,
              promotionPiece: null,
              score: _scoreMove(
                board,
                group.fromIndex,
                target,
                group.piece,
                null,
                hashFrom,
                hashTo,
                hashPromotion,
              ),
            ),
          );
        }
      }
    }

    moves.sort((a, b) {
      return b.score.compareTo(a.score);
    });

    return moves;
  }

  int _scoreMove(
      List<int> board,
      int from,
      int to,
      int piece,
      int? promotionPiece,
      int? hashFrom,
      int? hashTo,
      int? hashPromotion,
      ) {
    int score = 0;

    if (hashFrom == from && hashTo == to && hashPromotion == promotionPiece) {
      score += 1000000;
    }

    final int captured = board[to];

    if (captured != 0) {
      final int victimValue = evaluator.pieceValue(captured).abs();
      final int attackerValue = evaluator.pieceValue(piece).abs();

      score += victimValue * 10 - attackerValue;
    }

    if (promotionPiece != null) {
      score += evaluator.pieceValue(promotionPiece).abs();
    }

    final int toRow = to ~/ 8;
    final int toCol = to % 8;

    if ((toRow == 3 || toRow == 4) && (toCol == 3 || toCol == 4)) {
      score += 20;
    }

    return score;
  }
}