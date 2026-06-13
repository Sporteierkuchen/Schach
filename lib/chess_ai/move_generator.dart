
import 'ai_game_state.dart';
import 'ai_move.dart';
import 'board_helper.dart';

class MoveGenerator {

  bool debugLegalMoves = false;
  bool debugCastlingOnly = false;

  List<AiMove> getAllLegalAiMoves({
    required AiGameState state,
  }) {
    final List<AiMove> moves = [];

    for (int i = 0; i < 64; i++) {
      final int piece = state.board[i];

      if (piece == 0) continue;
      if (state.isWhiteTurn && piece < 0) continue;
      if (!state.isWhiteTurn && piece > 0) continue;

      final List<int> targets = getLegalMovesForPiece(
        state: state,
        index: i,
        piece: piece,
      );

      for (final int target in targets) {
        if (_isPromotionTarget(piece, target)) {
          final List<int> promotionPieces = piece > 0
              ? [5, 4, 3, 2]
              : [-5, -4, -3, -2];

          for (final int promotionPiece in promotionPieces) {
            moves.add(
              AiMove(
                fromIndex: i,
                toIndex: target,
                piece: piece,
                promotionPiece: promotionPiece,
                score: 0,
              ),
            );
          }
        } else {
          moves.add(
            AiMove(
              fromIndex: i,
              toIndex: target,
              piece: piece,
              score: 0,
            ),
          );
        }
      }
    }

    return moves;
  }

  bool _isPromotionTarget(int piece, int targetIndex) {
    if (piece.abs() != 1) {
      return false;
    }

    final int row = BoardHelper.getRow(targetIndex);

    if (piece > 0) {
      return row == 0;
    }

    return row == 7;
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

        _logMove(
          label: "LEGAL",
          from: index,
          to: target,
          piece: piece,
        );
      } else {
        _logMove(
          label: "ILLEGAL/SIM BLOCKED",
          from: index,
          to: target,
          piece: piece,
        );
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

    return !_isSquareAttackedBySide(
      board: copy,
      targetIndex: state.isWhiteTurn ? whiteKingIndex : blackKingIndex,
      byWhite: !state.isWhiteTurn,
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

    return _isSquareAttackedBySide(
      board: state.board,
      targetIndex: kingIndex,
      byWhite: !isWhiteKing,
    );
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
      const int targetCol = 6;
      final int target = BoardHelper.getIndex(row, targetCol);

      if (_castlePathIsFree(state.board, row, col, targetCol) &&
          _castlePathIsSafe(state, isWhiteKing, row, col, targetCol)) {
        moves.add(target);
      }
    }

    if (canQueenSide) {
      const int targetCol = 2;
      final int target = BoardHelper.getIndex(row, targetCol);

      if (_castlePathIsFree(state.board, row, col, targetCol) &&
          _castlePathIsSafe(state, isWhiteKing, row, col, targetCol)) {
        moves.add(target);
      }
    }

    return moves;
  }

/*  bool _castlePathIsFree(
      List<int> board,
      int row,
      int fromCol,
      int toCol,
      ) {
    final int step = toCol > fromCol ? 1 : -1;

    int col = fromCol + step;

    while (col != toCol + step) {
      if (row < 0 || row > 7 || col < 0 || col > 7) {
        return false;
      }

      final int index = BoardHelper.getIndex(row, col);

      if (board[index] != 0) return false;

      col += step;
    }

    return true;
  }*/

  bool _castlePathIsFree(
      List<int> board,
      int row,
      int fromCol,
      int toCol,
      ) {
    // kurze Rochade: König e -> g
    // Felder zwischen König und Turm: f, g
    if (toCol == 6) {
      final int f = BoardHelper.getIndex(row, 5);
      final int g = BoardHelper.getIndex(row, 6);

      return board[f] == 0 && board[g] == 0;
    }

    // lange Rochade: König e -> c
    // Felder zwischen König und Turm: d, c, b
    // König läuft nur über d und c, aber b muss für den Turm frei sein.
    if (toCol == 2) {
      final int d = BoardHelper.getIndex(row, 3);
      final int c = BoardHelper.getIndex(row, 2);
      final int b = BoardHelper.getIndex(row, 1);

      return board[d] == 0 && board[c] == 0 && board[b] == 0;
    }

    return false;
  }

  bool _castlePathIsSafe(
      AiGameState state,
      bool isWhiteKing,
      int row,
      int fromCol,
      int toCol,
      ) {
    final int step = toCol > fromCol ? 1 : -1;

    int col = fromCol;

    while (col != toCol + step) {
      final int square = BoardHelper.getIndex(row, col);

      final bool attacked = _isSquareAttackedBySide(
        board: state.board,
        targetIndex: square,
        byWhite: !isWhiteKing,
      );

      if (attacked) {
        return false;
      }

      col += step;
    }

    return true;
  }

  bool _isSquareAttackedBySide({
    required List<int> board,
    required int targetIndex,
    required bool byWhite,
  }) {
    for (int i = 0; i < 64; i++) {
      final int piece = board[i];

      if (piece == 0) continue;
      if ((piece > 0) != byWhite) continue;

      if (_pieceAttacksSquare(
        board: board,
        fromIndex: i,
        piece: piece,
        targetIndex: targetIndex,
      )) {
        return true;
      }
    }

    return false;
  }

  bool _pieceAttacksSquare({
    required List<int> board,
    required int fromIndex,
    required int piece,
    required int targetIndex,
  }) {
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
        return _attackPathClear(board, fromRow, fromCol, targetRow, targetCol);

      case 4:
        if (fromRow != targetRow && fromCol != targetCol) return false;
        return _attackPathClear(board, fromRow, fromCol, targetRow, targetCol);

      case 5:
        final bool diagonal = rowDiff.abs() == colDiff.abs();
        final bool straight = fromRow == targetRow || fromCol == targetCol;

        if (!diagonal && !straight) return false;

        return _attackPathClear(board, fromRow, fromCol, targetRow, targetCol);

      case 6:
        return rowDiff.abs() <= 1 && colDiff.abs() <= 1;

      default:
        return false;
    }
  }

  bool _attackPathClear(
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
      if (row < 0 || row > 7 || col < 0 || col > 7) {
        return false;
      }

      final int index = BoardHelper.getIndex(row, col);

      if (board[index] != 0) {
        return false;
      }

      row += rowStep;
      col += colStep;
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

    final List<AiMove> moves = getAllLegalAiMoves(state: state);

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

    final List<AiMove> moves = getAllLegalAiMoves(state: state);

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

  void _logMove({
    required String label,
    required int from,
    required int to,
    required int piece,
  }) {
    if (!debugLegalMoves) return;

    if (debugCastlingOnly) {
      final bool isCastle =
          piece.abs() == 6 &&
              (BoardHelper.getCol(from) - BoardHelper.getCol(to)).abs() == 2;

      if (!isCastle) return;
    }

    print(
      "🧠 KI MoveGen [$label] "
          "${piece > 0 ? "Weiß" : "Schwarz"} "
          "${_pieceName(piece)}: "
          "${BoardHelper.indexToCoord(from)} -> ${BoardHelper.indexToCoord(to)}",
    );
  }

  String _pieceName(int piece) {
    switch (piece.abs()) {
      case 1:
        return "Bauer";
      case 2:
        return "Springer";
      case 3:
        return "Läufer";
      case 4:
        return "Turm";
      case 5:
        return "Dame";
      case 6:
        return "König";
      default:
        return "?";
    }
  }

}