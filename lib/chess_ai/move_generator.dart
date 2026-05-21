import '../components/FigurenMovesArray.dart';
import 'ai_game_state.dart';
import 'board_helper.dart';

class MoveGenerator {
  List<FigurenMovesArray> getAllLegalMoves({
    required AiGameState state,
  }) {
    final List<FigurenMovesArray> allMoves = [];

    for (int i = 0; i < 64; i++) {
      final int piece = state.board[i];

      if (piece == 0) continue;

      if (state.isWhiteTurn && piece < 0) continue;
      if (!state.isWhiteTurn && piece > 0) continue;

      final List<int> legalTargets = getLegalMovesForPiece(
        state: state,
        index: i,
        piece: piece,
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
    required AiGameState state,
    required int index,
    required int piece,
  }) {
    final List<int> rawMoves = getRawMoves(
      state: state,
      index: index,
      piece: piece,
    );

    final List<int> legalMoves = [];

    for (final int target in rawMoves) {
      final bool safe = simulatedMoveIsSafe(
        state: state,
        piece: piece,
        fromIndex: index,
        toIndex: target,
      );

      if (safe) {
        legalMoves.add(target);
      }
    }

    return legalMoves;
  }

  bool simulatedMoveIsSafe({
    required AiGameState state,
    required int piece,
    required int fromIndex,
    required int toIndex,
  }) {
    final List<int> copy = List<int>.from(state.board);

    final bool isEnPassantMove =
        piece.abs() == 1 &&
            state.enPassantTargetIndex != null &&
            toIndex == state.enPassantTargetIndex &&
            state.board[toIndex] == 0 &&
            BoardHelper.getCol(fromIndex) != BoardHelper.getCol(toIndex);

    if (isEnPassantMove) {
      final int capturedPawnIndex = piece > 0 ? toIndex + 8 : toIndex - 8;
      copy[capturedPawnIndex] = 0;
    }

    final bool isCastleMove =
        piece.abs() == 6 &&
            (BoardHelper.getCol(fromIndex) - BoardHelper.getCol(toIndex)).abs() == 2;

    BoardHelper.makeMove(copy, fromIndex, toIndex);

    if (isCastleMove) {
      _simulateCastleRookMove(
        board: copy,
        kingPiece: piece,
        fromIndex: fromIndex,
        toIndex: toIndex,
      );
    }

    int? whiteKingIndex = BoardHelper.getKingIndex(copy, true);
    int? blackKingIndex = BoardHelper.getKingIndex(copy, false);

    if (whiteKingIndex == null || blackKingIndex == null) {
      return false;
    }

    return !isKingInCheck(
      state: state.copyWith(board: copy),
      isWhiteKing: state.isWhiteTurn,
      whiteKingIndex: whiteKingIndex,
      blackKingIndex: blackKingIndex,
    );
  }

  void _simulateCastleRookMove({
    required List<int> board,
    required int kingPiece,
    required int fromIndex,
    required int toIndex,
  }) {
    final int row = BoardHelper.getRow(fromIndex);
    final int fromCol = BoardHelper.getCol(fromIndex);
    final int toCol = BoardHelper.getCol(toIndex);

    if (toCol > fromCol) {
      final int rookFrom = BoardHelper.getIndex(row, 7);
      final int rookTo = BoardHelper.getIndex(row, toCol - 1);

      board[rookTo] = board[rookFrom];
      board[rookFrom] = 0;
    } else {
      final int rookFrom = BoardHelper.getIndex(row, 0);
      final int rookTo = BoardHelper.getIndex(row, toCol + 1);

      board[rookTo] = board[rookFrom];
      board[rookFrom] = 0;
    }
  }

  bool isKingInCheck({
    required AiGameState state,
    required bool isWhiteKing,
    required int whiteKingIndex,
    required int blackKingIndex,
  }) {
    final int kingIndex = isWhiteKing ? whiteKingIndex : blackKingIndex;

    for (int i = 0; i < 64; i++) {
      final int piece = state.board[i];

      if (piece == 0) continue;

      final bool isOpponent = isWhiteKing ? piece < 0 : piece > 0;

      if (!isOpponent) continue;

      final List<int> attacks = getRawMoves(
        state: state.copyWith(
          isEnemyMove: !state.isEnemyMove,
          isWhiteTurn: !state.isWhiteTurn,
        ),
        index: i,
        piece: piece,
        includeCastling: false,
      );

      if (attacks.contains(kingIndex)) {
        return true;
      }
    }

    return false;
  }

  List<int> getRawMoves({
    required AiGameState state,
    required int index,
    required int piece,
    bool includeCastling = true,
  }) {
    final List<int> moves = [];

    final List<int> board = state.board;
    final int row = BoardHelper.getRow(index);
    final int col = BoardHelper.getCol(index);
    final int absPiece = piece.abs();

    final bool pieceIsWhite = piece > 0;
    final int direction = pieceIsWhite ? -1 : 1;

    bool isOwnPiece(int value) {
      return value != 0 && ((value > 0 && pieceIsWhite) || (value < 0 && !pieceIsWhite));
    }

    bool isOpponentPiece(int value) {
      return value != 0 && ((value < 0 && pieceIsWhite) || (value > 0 && !pieceIsWhite));
    }

    if (absPiece == 1) {
      final int forwardRow = row + direction;

      if (forwardRow >= 0 && forwardRow < 8) {
        final int forward = BoardHelper.getIndex(forwardRow, col);

        if (board[forward] == 0) {
          moves.add(forward);

          final bool startRow = pieceIsWhite ? row == 6 : row == 1;
          final int doubleRow = row + 2 * direction;

          if (startRow && doubleRow >= 0 && doubleRow < 8) {
            final int doubleForward = BoardHelper.getIndex(doubleRow, col);

            if (board[doubleForward] == 0) {
              moves.add(doubleForward);
            }
          }
        }

        if (col > 0) {
          final int left = BoardHelper.getIndex(forwardRow, col - 1);

          if (isOpponentPiece(board[left]) || left == state.enPassantTargetIndex) {
            moves.add(left);
          }
        }

        if (col < 7) {
          final int right = BoardHelper.getIndex(forwardRow, col + 1);

          if (isOpponentPiece(board[right]) || right == state.enPassantTargetIndex) {
            moves.add(right);
          }
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
          final int target = BoardHelper.getIndex(r, c);
          final int targetPiece = board[target];

          if (targetPiece == 0) {
            moves.add(target);
          } else {
            if (isOpponentPiece(targetPiece)) {
              moves.add(target);
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

      if (includeCastling) {
        moves.addAll(
          _getCastlingMoves(
            state: state,
            kingIndex: index,
            kingPiece: piece,
          ),
        );
      }
    }

    return moves;
  }

  List<int> _getCastlingMoves({
    required AiGameState state,
    required int kingIndex,
    required int kingPiece,
  }) {
    final List<int> moves = [];

    final bool isWhiteKing = kingPiece > 0;
    final int row = BoardHelper.getRow(kingIndex);
    final int col = BoardHelper.getCol(kingIndex);

    final int? whiteKingIndex = BoardHelper.getKingIndex(state.board, true);
    final int? blackKingIndex = BoardHelper.getKingIndex(state.board, false);

    if (whiteKingIndex == null || blackKingIndex == null) return moves;

    final bool kingCurrentlyInCheck = isKingInCheck(
      state: state,
      isWhiteKing: isWhiteKing,
      whiteKingIndex: whiteKingIndex,
      blackKingIndex: blackKingIndex,
    );

    if (kingCurrentlyInCheck) return moves;

    final bool canKingSide = isWhiteKing
        ? state.castlingRights.whiteKingSide
        : state.castlingRights.blackKingSide;

    final bool canQueenSide = isWhiteKing
        ? state.castlingRights.whiteQueenSide
        : state.castlingRights.blackQueenSide;

    if (canKingSide) {
      final int target = BoardHelper.getIndex(row, col + 2);

      if (_castlePathIsFree(state.board, row, col, col + 2) &&
          _castlePathIsSafe(state, isWhiteKing, row, col, col + 2)) {
        moves.add(target);
      }
    }

    if (canQueenSide) {
      final int target = BoardHelper.getIndex(row, col - 2);

      if (_castlePathIsFree(state.board, row, col, col - 2) &&
          _castlePathIsSafe(state, isWhiteKing, row, col, col - 2)) {
        moves.add(target);
      }
    }

    return moves;
  }

  bool _castlePathIsFree(
      List<int> board,
      int row,
      int fromCol,
      int toCol,
      ) {
    final int step = toCol > fromCol ? 1 : -1;

    int col = fromCol + step;

    while (col != toCol + step) {
      final int index = BoardHelper.getIndex(row, col);

      if (board[index] != 0) return false;

      col += step;
    }

    return true;
  }

  bool _castlePathIsSafe(
      AiGameState state,
      bool isWhiteKing,
      int row,
      int fromCol,
      int toCol,
      ) {
    final int step = toCol > fromCol ? 1 : -1;

    int? whiteKingIndexNullable =
    BoardHelper.getKingIndex(state.board, true);

    int? blackKingIndexNullable =
    BoardHelper.getKingIndex(state.board, false);

    if (whiteKingIndexNullable == null ||
        blackKingIndexNullable == null) {
      return false;
    }

    int whiteKingIndex = whiteKingIndexNullable;
    int blackKingIndex = blackKingIndexNullable;

    int col = fromCol;

    while (col != toCol + step) {

      final int kingIndex =
      BoardHelper.getIndex(row, col);

      final List<int> copy =
      List<int>.from(state.board);

      copy[BoardHelper.getIndex(row, fromCol)] = 0;

      copy[kingIndex] =
      isWhiteKing ? 6 : -6;

      if (isWhiteKing) {
        whiteKingIndex = kingIndex;
      } else {
        blackKingIndex = kingIndex;
      }

      final bool check = isKingInCheck(
        state: state.copyWith(board: copy),
        isWhiteKing: isWhiteKing,
        whiteKingIndex: whiteKingIndex,
        blackKingIndex: blackKingIndex,
      );

      if (check) {
        return false;
      }

      col += step;
    }

    return true;
  }

  bool isCheckmate({
    required AiGameState state,
  }) {
    final int? whiteKingIndex = BoardHelper.getKingIndex(state.board, true);
    final int? blackKingIndex = BoardHelper.getKingIndex(state.board, false);

    if (whiteKingIndex == null || blackKingIndex == null) return false;

    final bool kingInCheck = isKingInCheck(
      state: state,
      isWhiteKing: state.isWhiteTurn,
      whiteKingIndex: whiteKingIndex,
      blackKingIndex: blackKingIndex,
    );

    if (!kingInCheck) return false;

    final moves = getAllLegalMoves(state: state);

    return moves.isEmpty;
  }

  bool isStalemate({
    required AiGameState state,
  }) {
    final int? whiteKingIndex = BoardHelper.getKingIndex(state.board, true);
    final int? blackKingIndex = BoardHelper.getKingIndex(state.board, false);

    if (whiteKingIndex == null || blackKingIndex == null) return false;

    final bool kingInCheck = isKingInCheck(
      state: state,
      isWhiteKing: state.isWhiteTurn,
      whiteKingIndex: whiteKingIndex,
      blackKingIndex: blackKingIndex,
    );

    if (kingInCheck) return false;

    final moves = getAllLegalMoves(state: state);

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