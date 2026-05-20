import '../components/FigurenMovesArray.dart';
import 'board_helper.dart';

class MoveGenerator {
  List<FigurenMovesArray> getAllLegalMoves({
    required List<int> board,
    required bool isEnemyMove,
    required bool isWhiteTurn,
    required int whiteKingIndex,
    required int blackKingIndex,
  }) {
    final List<FigurenMovesArray> allMoves = [];

    for (int i = 0; i < 64; i++) {
      final int piece = board[i];

      if (piece == 0) continue;

      if (!isEnemyMove && piece < 0) continue;
      if (isEnemyMove && piece > 0) continue;

      final List<int> legalTargets = getLegalMovesForPiece(
        index: i,
        piece: piece,
        board: board,
        isEnemyMove: isEnemyMove,
        isWhiteTurn: isWhiteTurn,
        whiteKingIndex: whiteKingIndex,
        blackKingIndex: blackKingIndex,
      );

      if (legalTargets.isNotEmpty) {
        allMoves.add(
          FigurenMovesArray(
            fromIndex: i,
            piece: piece,
            targetIndices: legalTargets,
          ),
        );
      }
    }

    return allMoves;
  }

  List<int> getLegalMovesForPiece({
    required int index,
    required int piece,
    required List<int> board,
    required bool isEnemyMove,
    required bool isWhiteTurn,
    required int whiteKingIndex,
    required int blackKingIndex,
  }) {
    final List<int> rawMoves = getRawMoves(
      index: index,
      piece: piece,
      board: board,
      isEnemyMove: isEnemyMove,
    );

    final List<int> legalMoves = [];

    for (final int target in rawMoves) {
      final bool safe = simulatedMoveIsSafe(
        piece: piece,
        fromIndex: index,
        toIndex: target,
        board: board,
        isEnemyMove: isEnemyMove,
        isWhiteTurn: isWhiteTurn,
        whiteKingIndex: whiteKingIndex,
        blackKingIndex: blackKingIndex,
      );

      if (safe) {
        legalMoves.add(target);
      }
    }

    return legalMoves;
  }

  bool simulatedMoveIsSafe({
    required int piece,
    required int fromIndex,
    required int toIndex,
    required List<int> board,
    required bool isEnemyMove,
    required bool isWhiteTurn,
    required int whiteKingIndex,
    required int blackKingIndex,
  }) {
    final List<int> copy = List<int>.from(board);

    BoardHelper.makeMove(copy, fromIndex, toIndex);

    int newWhiteKingIndex = whiteKingIndex;
    int newBlackKingIndex = blackKingIndex;

    if (piece == 6) {
      newWhiteKingIndex = toIndex;
    } else if (piece == -6) {
      newBlackKingIndex = toIndex;
    }

    return !isKingInCheck(
      board: copy,
      isWhiteKing: isWhiteTurn,
      isEnemyMove: isEnemyMove,
      whiteKingIndex: newWhiteKingIndex,
      blackKingIndex: newBlackKingIndex,
    );
  }

  bool isKingInCheck({
    required List<int> board,
    required bool isWhiteKing,
    required bool isEnemyMove,
    required int whiteKingIndex,
    required int blackKingIndex,
  }) {
    final int kingIndex = isWhiteKing ? whiteKingIndex : blackKingIndex;

    for (int i = 0; i < 64; i++) {
      final int piece = board[i];

      if (piece == 0) continue;

      final bool isOpponent = isEnemyMove ? piece > 0 : piece < 0;

      if (!isOpponent) continue;

      final List<int> attacks = getRawMoves(
        index: i,
        piece: piece,
        board: board,
        isEnemyMove: !isEnemyMove,
      );

      if (attacks.contains(kingIndex)) {
        return true;
      }
    }

    return false;
  }

  List<int> getRawMoves({
    required int index,
    required int piece,
    required List<int> board,
    required bool isEnemyMove,
  }) {
    final List<int> moves = [];

    final int row = BoardHelper.getRow(index);
    final int col = BoardHelper.getCol(index);
    final int absPiece = piece.abs();

    final int direction = isEnemyMove ? 1 : -1;

    bool isOwnPiece(int value) {
      return value != 0 &&
          ((value < 0 && isEnemyMove) || (value > 0 && !isEnemyMove));
    }

    bool isOpponentPiece(int value) {
      return value != 0 &&
          ((value < 0 && !isEnemyMove) || (value > 0 && isEnemyMove));
    }

    if (absPiece == 1) {
      final int forward = BoardHelper.getIndex(row + direction, col);

      if (BoardHelper.isIndexInBoard(forward) && board[forward] == 0) {
        moves.add(forward);

        final bool startRow =
            (isEnemyMove && row == 1) || (!isEnemyMove && row == 6);

        final int doubleForward =
        BoardHelper.getIndex(row + 2 * direction, col);

        if (startRow &&
            BoardHelper.isIndexInBoard(doubleForward) &&
            board[doubleForward] == 0) {
          moves.add(doubleForward);
        }
      }

      if (col > 0) {
        final int left = BoardHelper.getIndex(row + direction, col - 1);
        if (BoardHelper.isIndexInBoard(left) && isOpponentPiece(board[left])) {
          moves.add(left);
        }
      }

      if (col < 7) {
        final int right = BoardHelper.getIndex(row + direction, col + 1);
        if (BoardHelper.isIndexInBoard(right) &&
            isOpponentPiece(board[right])) {
          moves.add(right);
        }
      }
    }

    if (absPiece == 2) {
      const List<List<int>> offsets = [
        [-2, -1],
        [-2, 1],
        [-1, -2],
        [-1, 2],
        [1, -2],
        [1, 2],
        [2, -1],
        [2, 1],
      ];

      for (final offset in offsets) {
        final int r = row + offset[0];
        final int c = col + offset[1];

        if (r < 0 || r > 7 || c < 0 || c > 7) continue;

        final int target = BoardHelper.getIndex(r, c);

        if (!isOwnPiece(board[target])) {
          moves.add(target);
        }
      }
    }

    if (absPiece == 3 || absPiece == 4 || absPiece == 5) {
      final List<List<int>> directions = [];

      if (absPiece == 3 || absPiece == 5) {
        directions.addAll([
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ]);
      }

      if (absPiece == 4 || absPiece == 5) {
        directions.addAll([
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
        ]);
      }

      for (final dir in directions) {
        int r = row + dir[0];
        int c = col + dir[1];

        while (r >= 0 && r < 8 && c >= 0 && c < 8) {
          final int targetIndex = BoardHelper.getIndex(r, c);
          final int targetPiece = board[targetIndex];

          if (targetPiece == 0) {
            moves.add(targetIndex);
          } else {
            if (isOpponentPiece(targetPiece)) {
              moves.add(targetIndex);
            }
            break;
          }

          r += dir[0];
          c += dir[1];
        }
      }
    }

    if (absPiece == 6) {
      const List<List<int>> directions = [
        [-1, -1],
        [-1, 0],
        [-1, 1],
        [0, -1],
        [0, 1],
        [1, -1],
        [1, 0],
        [1, 1],
      ];

      for (final dir in directions) {
        final int r = row + dir[0];
        final int c = col + dir[1];

        if (r < 0 || r > 7 || c < 0 || c > 7) continue;

        final int target = BoardHelper.getIndex(r, c);

        if (!isOwnPiece(board[target])) {
          moves.add(target);
        }
      }
    }

    return moves;
  }

  bool isCheckmate({
    required List<int> board,
    required bool isEnemyMove,
    required bool isWhiteTurn,
    required int whiteKingIndex,
    required int blackKingIndex,
  }) {
    final bool kingInCheck = isKingInCheck(
      board: board,
      isWhiteKing: isWhiteTurn,
      isEnemyMove: isEnemyMove,
      whiteKingIndex: whiteKingIndex,
      blackKingIndex: blackKingIndex,
    );

    if (!kingInCheck) return false;

    final moves = getAllLegalMoves(
      board: board,
      isEnemyMove: isEnemyMove,
      isWhiteTurn: isWhiteTurn,
      whiteKingIndex: whiteKingIndex,
      blackKingIndex: blackKingIndex,
    );

    return moves.isEmpty;
  }

  bool isStalemate({
    required List<int> board,
    required bool isEnemyMove,
    required bool isWhiteTurn,
    required int whiteKingIndex,
    required int blackKingIndex,
  }) {
    final bool kingInCheck = isKingInCheck(
      board: board,
      isWhiteKing: isWhiteTurn,
      isEnemyMove: isEnemyMove,
      whiteKingIndex: whiteKingIndex,
      blackKingIndex: blackKingIndex,
    );

    if (kingInCheck) return false;

    final moves = getAllLegalMoves(
      board: board,
      isEnemyMove: isEnemyMove,
      isWhiteTurn: isWhiteTurn,
      whiteKingIndex: whiteKingIndex,
      blackKingIndex: blackKingIndex,
    );

    return moves.isEmpty;
  }

  bool isInsufficientMaterial(List<int> board) {
    final List<int> figures = board.where((f) => f != 0).toList();

    if (figures.every((f) => f.abs() == 6)) return true;

    if (figures.length == 3) {
      return figures.any((f) => f.abs() == 2 || f.abs() == 3);
    }

    return false;
  }
}