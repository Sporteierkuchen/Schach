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

  List<AiMove> flattenAndOrderMoves(
      List<FigurenMovesArray> groupedMoves,
      List<int> board, {
        int? hashFrom,
        int? hashTo,
        int? hashPromotion,
        SearchHeuristics? heuristics,
        int ply = 0,
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

            final int moveScore = _scoreMove(
              board,
              group.fromIndex,
              target,
              group.piece,
              promotionPiece,
              hashFrom,
              hashTo,
              hashPromotion,
              heuristics,
              ply,
            );

            moves.add(
              AiMove(
                fromIndex: group.fromIndex,
                toIndex: target,
                piece: group.piece,
                promotionPiece: promotionPiece,
                score: moveScore,
              ),
            );
          }
        } else {
          final int moveScore = _scoreMove(
            board,
            group.fromIndex,
            target,
            group.piece,
            null,
            hashFrom,
            hashTo,
            hashPromotion,
            heuristics,
            ply,
          );

          moves.add(
            AiMove(
              fromIndex: group.fromIndex,
              toIndex: target,
              piece: group.piece,
              promotionPiece: null,
              score: moveScore,
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
      SearchHeuristics? heuristics,
      int ply,
      ) {
    int score = 0;

    // 1. Hash-Move aus Transposition Table immer zuerst prüfen
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

    // 2. Killer Moves
    if (heuristics != null && heuristics.isKillerMove(tempMove, ply)) {
      score += 500000;
    }

    // 3. History Heuristic
    if (heuristics != null) {
      score += heuristics.getHistoryScore(tempMove);
    }

    final int captured = board[to];

    // 4. Schlagzüge mit SEE bewerten
    if (captured != 0) {
      final int victimValue = evaluator.pieceValue(captured).abs();
      final int attackerValue = evaluator.pieceValue(piece).abs();

      // MVV-LVA: wertvolle Figur schlagen, billige Figur bevorzugen
      score += victimValue * 10 - attackerValue;

      final int seeScore = see.evaluateCapture(
        board: board,
        from: from,
        to: to,
        movingPiece: piece,
      );

      // Guter Tausch wird stark bevorzugt
      score += seeScore * 8;

      final bool badCapture = see.isBadCapture(
        board: board,
        from: from,
        to: to,
        movingPiece: piece,
      );

      // Schlechter Tausch sehr weit nach hinten
      if (badCapture) {
        score -= 8000;
      }

      // Kleine Figur schlägt große/gleichwertige Figur
      if (attackerValue <= victimValue) {
        score += 300;
      }
    }

    // 5. Promotionen bevorzugen
    if (promotionPiece != null) {
      score += evaluator.pieceValue(promotionPiece).abs();

      if (promotionPiece.abs() == 5) {
        score += 500;
      }
    }

    // 6. Zentrum leicht bevorzugen
    final int toRow = to ~/ 8;
    final int toCol = to % 8;

    if ((toRow == 3 || toRow == 4) && (toCol == 3 || toCol == 4)) {
      score += 20;
    }

    return score;
  }
}