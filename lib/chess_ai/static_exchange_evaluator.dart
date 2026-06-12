import 'board_evaluator.dart';
import 'board_helper.dart';

class StaticExchangeEvaluator {
  final BoardEvaluator evaluator;

  StaticExchangeEvaluator(this.evaluator);

  int evaluateCapture({
    required List<int> board,
    required int from,
    required int to,
    required int movingPiece,
  }) {
    final int capturedPiece = board[to];

    if (capturedPiece == 0) {
      return 0;
    }

    final int gain =
        evaluator.pieceValue(capturedPiece).abs() -
            evaluator.pieceValue(movingPiece).abs();

    final bool targetDefended = isSquareAttackedBySide(
      board,
      to,
      byWhite: capturedPiece > 0,
    );

    if (!targetDefended) {
      return evaluator.pieceValue(capturedPiece).abs();
    }

    return gain;
  }

  bool isBadCapture({
    required List<int> board,
    required int from,
    required int to,
    required int movingPiece,
  }) {
    final int capturedPiece = board[to];

    if (capturedPiece == 0) {
      return false;
    }

    final int attackerValue = evaluator.pieceValue(movingPiece).abs();
    final int victimValue = evaluator.pieceValue(capturedPiece).abs();

    final bool targetDefended = isSquareAttackedBySide(
      board,
      to,
      byWhite: capturedPiece > 0,
    );

    if (!targetDefended) {
      return false;
    }

    return attackerValue > victimValue + 120;
  }

  bool isSquareAttackedBySide(
      List<int> board,
      int targetIndex, {
        required bool byWhite,
      }) {
    for (int i = 0; i < 64; i++) {
      final int piece = board[i];

      if (piece == 0) continue;
      if ((piece > 0) != byWhite) continue;

      if (_pieceAttacksSquare(board, i, piece, targetIndex)) {
        return true;
      }
    }

    return false;
  }

  bool _pieceAttacksSquare(
      List<int> board,
      int fromIndex,
      int piece,
      int targetIndex,
      ) {
    final int fromRow = BoardHelper.getRow(fromIndex);
    final int fromCol = BoardHelper.getCol(fromIndex);
    final int targetRow = BoardHelper.getRow(targetIndex);
    final int targetCol = BoardHelper.getCol(targetIndex);

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
        return _pathClear(board, fromRow, fromCol, targetRow, targetCol);

      case 4:
        if (fromRow != targetRow && fromCol != targetCol) return false;
        return _pathClear(board, fromRow, fromCol, targetRow, targetCol);

      case 5:
        final bool diagonal = rowDiff.abs() == colDiff.abs();
        final bool straight = fromRow == targetRow || fromCol == targetCol;

        if (!diagonal && !straight) return false;
        return _pathClear(board, fromRow, fromCol, targetRow, targetCol);

      case 6:
        return rowDiff.abs() <= 1 && colDiff.abs() <= 1;

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
    final int rowStep = (toRow - fromRow).sign;
    final int colStep = (toCol - fromCol).sign;

    int row = fromRow + rowStep;
    int col = fromCol + colStep;

    while (row != toRow || col != toCol) {
      final int index = BoardHelper.getIndex(row, col);

      if (board[index] != 0) {
        return false;
      }

      row += rowStep;
      col += colStep;
    }

    return true;
  }
}