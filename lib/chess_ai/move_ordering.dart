import 'package:schach/chess_ai/search_heuristics.dart';

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

      final bool targetIsDefended =
      _isSquareDefendedByOpponent(
        board,
        to,
        piece > 0,
      );

      if (targetIsDefended) {
        final int exchangeLoss =
            attackerValue - victimValue;

        if (exchangeLoss > 0) {
          score -= exchangeLoss * 12;
        } else {
          score += 30;
        }
      }
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

  bool _isSquareDefendedByOpponent(
      List<int> board,
      int targetIndex,
      bool movingPieceIsWhite,
      ) {
    for (int i = 0; i < 64; i++) {
      final int piece = board[i];

      if (piece == 0) continue;

      final bool pieceIsWhite = piece > 0;

      if (pieceIsWhite == movingPieceIsWhite) {
        continue;
      }

      if (_pieceControlsSquare(
        board,
        i,
        piece,
        targetIndex,
      )) {
        return true;
      }
    }

    return false;
  }

  bool _pieceControlsSquare(
      List<int> board,
      int fromIndex,
      int piece,
      int targetIndex,
      ) {
    final int fromRow = fromIndex ~/ 8;
    final int fromCol = fromIndex % 8;

    final int targetRow = targetIndex ~/ 8;
    final int targetCol = targetIndex % 8;

    final int rowDiff = targetRow - fromRow;
    final int colDiff = targetCol - fromCol;

    switch (piece.abs()) {
      case 1:
        final int direction = piece > 0 ? -1 : 1;
        return rowDiff == direction && colDiff.abs() == 1;

      case 2:
        return (rowDiff.abs() == 2 && colDiff.abs() == 1) ||
            (rowDiff.abs() == 1 && colDiff.abs() == 2);

      case 3:
        if (rowDiff.abs() != colDiff.abs()) return false;
        return _pathClear(
          board,
          fromRow,
          fromCol,
          targetRow,
          targetCol,
        );

      case 4:
        if (fromRow != targetRow && fromCol != targetCol) return false;
        return _pathClear(
          board,
          fromRow,
          fromCol,
          targetRow,
          targetCol,
        );

      case 5:
        final bool diagonal =
            rowDiff.abs() == colDiff.abs();

        final bool straight =
            fromRow == targetRow ||
                fromCol == targetCol;

        if (!diagonal && !straight) return false;

        return _pathClear(
          board,
          fromRow,
          fromCol,
          targetRow,
          targetCol,
        );

      case 6:
        return rowDiff.abs() <= 1 &&
            colDiff.abs() <= 1;

      default:
        return false;
    }
  }

  bool _pathClear(
      List<int> board,
      int fromRow,
      int fromCol,
      int toRow,
      int toCol,
      ) {
    final int rowStep =
        (toRow - fromRow).sign;

    final int colStep =
        (toCol - fromCol).sign;

    int row = fromRow + rowStep;
    int col = fromCol + colStep;

    while (row != toRow || col != toCol) {
      final int index = row * 8 + col;

      if (board[index] != 0) {
        return false;
      }

      row += rowStep;
      col += colStep;
    }

    return true;
  }

}