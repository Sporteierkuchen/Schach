import 'package:schach/chess_ai/search_heuristics.dart';

import '../components/FigurenMovesArray.dart';
import 'ai_move.dart';
import 'board_evaluator.dart';
import 'static_exchange_evaluator.dart';

class MoveOrdering {
  final BoardEvaluator evaluator;
  late final StaticExchangeEvaluator see;

  MoveOrdering(this.evaluator) {
    see = StaticExchangeEvaluator(evaluator);
  }

  List<AiMove> orderAiMoves(
      List<AiMove> moves,
      List<int> board, {
        int? hashFrom,
        int? hashTo,
        int? hashPromotion,
        SearchHeuristics? heuristics,
        int ply = 0,
      }) {
    final List<AiMove> orderedMoves = [];

    for (final AiMove move in moves) {
      orderedMoves.add(
        AiMove(
          fromIndex: move.fromIndex,
          toIndex: move.toIndex,
          piece: move.piece,
          promotionPiece: move.promotionPiece,
          score: _scoreMove(
            board,
            move.fromIndex,
            move.toIndex,
            move.piece,
            move.promotionPiece,
            hashFrom,
            hashTo,
            hashPromotion,
            heuristics,
            ply,
          ),
        ),
      );
    }

    orderedMoves.sort((a, b) => b.score.compareTo(a.score));

    return orderedMoves;
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
      SearchHeuristics? heuristics,
      int ply,
      ) {
    int score = 0;

    if (hashFrom == from && hashTo == to && hashPromotion == promotionPiece) {
      score += 1000000;
    }

    final AiMove tempMove = AiMove(
      fromIndex: from,
      toIndex: to,
      piece: piece,
      promotionPiece: promotionPiece,
      score: 0,
    );

    if (heuristics != null && heuristics.isKillerMove(tempMove, ply)) {
      score += 500000;
    }

    if (heuristics != null) {
      score += heuristics.getHistoryScore(tempMove);
    }

    final int captured = board[to];

    if (captured != 0) {
      final int victimValue = evaluator.pieceValue(captured).abs();
      final int attackerValue = evaluator.pieceValue(piece).abs();

      score += victimValue * 10 - attackerValue;

      final int seeScore = see.evaluateCapture(
        board: board,
        from: from,
        to: to,
        movingPiece: piece,
      );

      score += seeScore * 8;

      final bool badCapture = see.isBadCapture(
        board: board,
        from: from,
        to: to,
        movingPiece: piece,
      );

      if (badCapture) {
        score -= 8000;
      }

      if (attackerValue <= victimValue) {
        score += 300;
      }
    }

    if (promotionPiece != null) {
      score += evaluator.pieceValue(promotionPiece).abs();

      if (promotionPiece.abs() == 5) {
        score += 500;
      }
    }

    final int toRow = to ~/ 8;
    final int toCol = to % 8;

    if ((toRow == 3 || toRow == 4) && (toCol == 3 || toCol == 4)) {
      score += 20;
    }

    return score;
  }
}