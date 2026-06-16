import 'package:schach/components/Enums.dart';
import 'package:schach/components/Move Infos.dart';
import 'package:schach/components/Schachfigur.dart';

import '../../helper/helper.dart';
import '../models/game_state.dart';

class MoveGenerator {

  List<List<int>> calculateValidMoves(
      int row,
      int col,
      Schachfigur? figur,
      bool checkSimulation,
      GameState state,
      ) {
    final List<List<int>> candidateMoves = calculateRawMoves(
      row,
      col,
      figur,
      state,
    );

    if (!checkSimulation) {
      return candidateMoves;
    }

    final List<List<int>> validMoves = [];

    if (figur == null) {
      return validMoves;
    }

    for (final move in candidateMoves) {
      if (isMoveSafe(
        figur,
        row,
        col,
        move[0],
        move[1],
        state,
      )) {
        validMoves.add(move);
      }
    }

    return validMoves;
  }

  List<List<int>> calculateRawMoves(
      int row,
      int col,
      Schachfigur? figur,
      GameState state,
      ) {
    final List<List<int>> candidateMoves = [];

    if (figur == null) {
      return candidateMoves;
    }

    final List<List<Schachfigur?>> brett = state.brett;
    final int direction = figur.isEnemy ? 1 : -1;

    switch (figur.art) {
      case Schachfigurenart.BAUER:
        if (isInBoard(row + direction, col) &&
            brett[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }

        if ((row == 1 && figur.isEnemy) || (row == 6 && !figur.isEnemy)) {
          if (isInBoard(row + 2 * direction, col) &&
              brett[row + 2 * direction][col] == null &&
              brett[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }

        if (isInBoard(row + direction, col - 1) &&
            brett[row + direction][col - 1] != null &&
            brett[row + direction][col - 1]!.istWeiss != figur.istWeiss) {
          candidateMoves.add([row + direction, col - 1]);
        }

        if (isInBoard(row + direction, col + 1) &&
            brett[row + direction][col + 1] != null &&
            brett[row + direction][col + 1]!.istWeiss != figur.istWeiss) {
          candidateMoves.add([row + direction, col + 1]);
        }

        if (isEnPassantPossible(figur, row, col, state)) {
          final MoveInfos? moveInfos = state.moveInfos;

          if (moveInfos != null) {
            if (moveInfos.newCol == col - 1) {
              candidateMoves.add([row + direction, col - 1]);
            } else if (moveInfos.newCol == col + 1) {
              candidateMoves.add([row + direction, col + 1]);
            }
          }
        }

        break;

      case Schachfigurenart.SPRINGER:
        final List<List<int>> knightMoves = [
          [-2, -1],
          [-2, 1],
          [-1, -2],
          [-1, 2],
          [1, -2],
          [1, 2],
          [2, -1],
          [2, 1],
        ];

        for (final move in knightMoves) {
          final int newRow = row + move[0];
          final int newCol = col + move[1];

          if (!isInBoard(newRow, newCol)) {
            continue;
          }

          final Schachfigur? target = brett[newRow][newCol];

          if (target != null) {
            if (target.istWeiss != figur.istWeiss) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }

          candidateMoves.add([newRow, newCol]);
        }

        break;

      case Schachfigurenart.LAEUFER:
        _addSlidingMoves(
          row: row,
          col: col,
          figur: figur,
          state: state,
          directions: [
            [-1, -1],
            [-1, 1],
            [1, -1],
            [1, 1],
          ],
          moves: candidateMoves,
        );

        break;

      case Schachfigurenart.TURM:
        _addSlidingMoves(
          row: row,
          col: col,
          figur: figur,
          state: state,
          directions: [
            [-1, 0],
            [1, 0],
            [0, -1],
            [0, 1],
          ],
          moves: candidateMoves,
        );

        break;

      case Schachfigurenart.DAME:
        _addSlidingMoves(
          row: row,
          col: col,
          figur: figur,
          state: state,
          directions: [
            [-1, 0],
            [1, 0],
            [0, -1],
            [0, 1],
            [-1, -1],
            [-1, 1],
            [1, -1],
            [1, 1],
          ],
          moves: candidateMoves,
        );

        break;

      case Schachfigurenart.KOENIG:
        final List<List<int>> kingMoves = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ];

        for (final move in kingMoves) {
          final int newRow = row + move[0];
          final int newCol = col + move[1];

          if (!isInBoard(newRow, newCol)) {
            continue;
          }

          final Schachfigur? target = brett[newRow][newCol];

          if (target != null) {
            if (target.istWeiss != figur.istWeiss) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }

          candidateMoves.add([newRow, newCol]);
        }

        if (isShortCastlePossible(figur, state)) {
          if (figur.isEnemy && figur.istWeiss && row == 0 && col == 3) {
            if (canCastleSafely(figur, row, col, 1, state)) {
              candidateMoves.add([0, 1]);
            }
          } else if (figur.isEnemy && !figur.istWeiss && row == 0 && col == 4) {
            if (canCastleSafely(figur, row, col, 6, state)) {
              candidateMoves.add([0, 6]);
            }
          } else if (!figur.isEnemy && figur.istWeiss && row == 7 && col == 4) {
            if (canCastleSafely(figur, row, col, 6, state)) {
              candidateMoves.add([7, 6]);
            }
          } else if (!figur.isEnemy && !figur.istWeiss && row == 7 && col == 3) {
            if (canCastleSafely(figur, row, col, 1, state)) {
              candidateMoves.add([7, 1]);
            }
          }
        }

        if (isLongCastlePossible(figur, state)) {
          if (figur.isEnemy && figur.istWeiss && row == 0 && col == 3) {
            if (canCastleSafely(figur, row, col, 5, state)) {
              candidateMoves.add([0, 5]);
            }
          } else if (figur.isEnemy && !figur.istWeiss && row == 0 && col == 4) {
            if (canCastleSafely(figur, row, col, 2, state)) {
              candidateMoves.add([0, 2]);
            }
          } else if (!figur.isEnemy && figur.istWeiss && row == 7 && col == 4) {
            if (canCastleSafely(figur, row, col, 2, state)) {
              candidateMoves.add([7, 2]);
            }
          } else if (!figur.isEnemy && !figur.istWeiss && row == 7 && col == 3) {
            if (canCastleSafely(figur, row, col, 5, state)) {
              candidateMoves.add([7, 5]);
            }
          }
        }

        break;
    }

    return candidateMoves;
  }

  void _addSlidingMoves({
    required int row,
    required int col,
    required Schachfigur figur,
    required GameState state,
    required List<List<int>> directions,
    required List<List<int>> moves,
  }) {
    for (final direction in directions) {
      int i = 1;

      while (true) {
        final int newRow = row + i * direction[0];
        final int newCol = col + i * direction[1];

        if (!isInBoard(newRow, newCol)) {
          break;
        }

        final Schachfigur? target = state.brett[newRow][newCol];

        if (target != null) {
          if (target.istWeiss != figur.istWeiss) {
            moves.add([newRow, newCol]);
          }
          break;
        }

        moves.add([newRow, newCol]);
        i++;
      }
    }
  }

  bool isMoveSafe(
      Schachfigur figur,
      int startRow,
      int startCol,
      int endRow,
      int endCol,
      GameState state,
      ) {
    final List<List<Schachfigur?>> brett = state.brett;

    final Schachfigur? originalDestinationPiece = brett[endRow][endCol];

    List<int>? originalKingPosition;

    if (figur.art == Schachfigurenart.KOENIG) {
      originalKingPosition = figur.istWeiss
          ? List<int>.from(state.whiteKingPosition)
          : List<int>.from(state.blackKingPosition);

      if (figur.istWeiss) {
        state.whiteKingPosition = [endRow, endCol];
      } else {
        state.blackKingPosition = [endRow, endCol];
      }

      if ((originalKingPosition[1] - endCol).abs() == 2) {
        if (isKingInCheck(figur.istWeiss, state)) {
          if (figur.istWeiss) {
            state.whiteKingPosition = originalKingPosition;
          } else {
            state.blackKingPosition = originalKingPosition;
          }

          return false;
        }
      }
    }

    bool enPassantMove = false;
    Schachfigur? enPassantCapturedPawn;

    if (figur.art == Schachfigurenart.BAUER &&
        isEnPassantPossible(figur, startRow, startCol, state) &&
        state.moveInfos?.newCol == endCol) {
      enPassantMove = true;

      final int capturedRow = state.moveInfos!.newRow;
      final int capturedCol = state.moveInfos!.newCol;

      enPassantCapturedPawn = brett[capturedRow][capturedCol];
      brett[capturedRow][capturedCol] = null;
    }

    brett[endRow][endCol] = figur;
    brett[startRow][startCol] = null;

    final bool kingInCheck = isKingInCheck(
      figur.istWeiss,
      state,
    );

    brett[startRow][startCol] = figur;
    brett[endRow][endCol] = originalDestinationPiece;

    if (figur.art == Schachfigurenart.KOENIG && originalKingPosition != null) {
      if (figur.istWeiss) {
        state.whiteKingPosition = originalKingPosition;
      } else {
        state.blackKingPosition = originalKingPosition;
      }
    }

    if (enPassantMove) {
      final int capturedRow = state.moveInfos!.newRow;
      final int capturedCol = state.moveInfos!.newCol;

      brett[capturedRow][capturedCol] = enPassantCapturedPawn;
    }

    return !kingInCheck;
  }

  bool isKingInCheck(
      bool isWhiteKing,
      GameState state,
      ) {
    final List<int> kingPosition = isWhiteKing
        ? state.whiteKingPosition
        : state.blackKingPosition;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final Schachfigur? figur = state.brett[row][col];

        if (figur == null) {
          continue;
        }

        if (figur.istWeiss == isWhiteKing) {
          continue;
        }

        final bool controlsKing = pieceControlsSquare(
          figur,
          row,
          col,
          kingPosition[0],
          kingPosition[1],
          state,
        );

        if (controlsKing) {
          return true;
        }
      }
    }

    return false;
  }

  bool isEnPassantPossible(
      Schachfigur figur,
      int row,
      int col,
      GameState state,
      ) {
    final MoveInfos? moveInfos = state.moveInfos;

    if (moveInfos == null) {
      return false;
    }

    if (!figur.isEnemy &&
        row == 3 &&
        moveInfos.newRow == 3 &&
        (moveInfos.newCol == col - 1 || moveInfos.newCol == col + 1) &&
        moveInfos.oldRow == 1 &&
        moveInfos.figur.art == Schachfigurenart.BAUER &&
        moveInfos.figur.isEnemy) {
      return true;
    }

    if (figur.isEnemy &&
        row == 4 &&
        moveInfos.newRow == 4 &&
        (moveInfos.newCol == col - 1 || moveInfos.newCol == col + 1) &&
        moveInfos.oldRow == 6 &&
        moveInfos.figur.art == Schachfigurenart.BAUER &&
        !moveInfos.figur.isEnemy) {
      return true;
    }

    return false;
  }

  bool isShortCastlePossible(
      Schachfigur king,
      GameState state,
      ) {
    final List<List<Schachfigur?>> brett = state.brett;

    if (king.hasMoved == true) {
      return false;
    }

    if (king.isEnemy) {
      if (king.istWeiss &&
          brett[0][0] != null &&
          brett[0][0]!.art == Schachfigurenart.TURM &&
          brett[0][0]!.hasMoved == false) {
        return brett[0][2] == null && brett[0][1] == null;
      }

      if (!king.istWeiss &&
          brett[0][7] != null &&
          brett[0][7]!.art == Schachfigurenart.TURM &&
          brett[0][7]!.hasMoved == false) {
        return brett[0][5] == null && brett[0][6] == null;
      }
    } else {
      if (king.istWeiss &&
          brett[7][7] != null &&
          brett[7][7]!.art == Schachfigurenart.TURM &&
          brett[7][7]!.hasMoved == false) {
        return brett[7][5] == null && brett[7][6] == null;
      }

      if (!king.istWeiss &&
          brett[7][0] != null &&
          brett[7][0]!.art == Schachfigurenart.TURM &&
          brett[7][0]!.hasMoved == false) {
        return brett[7][2] == null && brett[7][1] == null;
      }
    }

    return false;
  }

  bool isLongCastlePossible(
      Schachfigur king,
      GameState state,
      ) {
    final List<List<Schachfigur?>> brett = state.brett;

    if (king.hasMoved == true) {
      return false;
    }

    if (king.isEnemy) {
      if (king.istWeiss &&
          brett[0][7] != null &&
          brett[0][7]!.art == Schachfigurenart.TURM &&
          brett[0][7]!.hasMoved == false) {
        return brett[0][4] == null &&
            brett[0][5] == null &&
            brett[0][6] == null;
      }

      if (!king.istWeiss &&
          brett[0][0] != null &&
          brett[0][0]!.art == Schachfigurenart.TURM &&
          brett[0][0]!.hasMoved == false) {
        return brett[0][3] == null &&
            brett[0][2] == null &&
            brett[0][1] == null;
      }
    } else {
      if (king.istWeiss &&
          brett[7][0] != null &&
          brett[7][0]!.art == Schachfigurenart.TURM &&
          brett[7][0]!.hasMoved == false) {
        return brett[7][3] == null &&
            brett[7][2] == null &&
            brett[7][1] == null;
      }

      if (!king.istWeiss &&
          brett[7][7] != null &&
          brett[7][7]!.art == Schachfigurenart.TURM &&
          brett[7][7]!.hasMoved == false) {
        return brett[7][4] == null &&
            brett[7][5] == null &&
            brett[7][6] == null;
      }
    }

    return false;
  }

  bool canCastleSafely(
      Schachfigur king,
      int row,
      int fromCol,
      int toCol,
      GameState state,
      ) {
    if (!isInBoard(row, fromCol)) {
      return false;
    }

    if (!isInBoard(row, toCol)) {
      return false;
    }

    if (isSquareControlledByOpponent(row, fromCol, king.istWeiss, state)) {
      return false;
    }

    final int step = toCol > fromCol ? 1 : -1;
    int col = fromCol + step;

    while (col != toCol + step) {
      if (!isInBoard(row, col)) {
        return false;
      }

      if (isSquareControlledByOpponent(row, col, king.istWeiss, state)) {
        return false;
      }

      col += step;
    }

    return true;
  }

  bool isSquareControlledByOpponent(
      int targetRow,
      int targetCol,
      bool isWhiteKing,
      GameState state,
      ) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final Schachfigur? figur = state.brett[row][col];

        if (figur == null) {
          continue;
        }

        if (figur.istWeiss == isWhiteKing) {
          continue;
        }

        if (pieceControlsSquare(
          figur,
          row,
          col,
          targetRow,
          targetCol,
          state,
        )) {
          return true;
        }
      }
    }

    return false;
  }

  bool pieceControlsSquare(
      Schachfigur figur,
      int row,
      int col,
      int targetRow,
      int targetCol,
      GameState state,
      ) {
    final int rowDiff = targetRow - row;
    final int colDiff = targetCol - col;

    switch (figur.art) {
      case Schachfigurenart.BAUER:
        final int direction = figur.isEnemy ? 1 : -1;

        return rowDiff == direction && colDiff.abs() == 1;

      case Schachfigurenart.SPRINGER:
        return (rowDiff.abs() == 2 && colDiff.abs() == 1) ||
            (rowDiff.abs() == 1 && colDiff.abs() == 2);

      case Schachfigurenart.KOENIG:
        return rowDiff.abs() <= 1 && colDiff.abs() <= 1;

      case Schachfigurenart.LAEUFER:
        if (rowDiff.abs() != colDiff.abs()) {
          return false;
        }

        return pathClear(row, col, targetRow, targetCol, state);

      case Schachfigurenart.TURM:
        if (row != targetRow && col != targetCol) {
          return false;
        }

        return pathClear(row, col, targetRow, targetCol, state);

      case Schachfigurenart.DAME:
        final bool diagonal = rowDiff.abs() == colDiff.abs();
        final bool straight = row == targetRow || col == targetCol;

        if (!diagonal && !straight) {
          return false;
        }

        return pathClear(row, col, targetRow, targetCol, state);
    }
  }

  bool pathClear(
      int fromRow,
      int fromCol,
      int toRow,
      int toCol,
      GameState state,
      ) {
    if (!isInBoard(fromRow, fromCol)) {
      return false;
    }

    if (!isInBoard(toRow, toCol)) {
      return false;
    }

    final int rowStep = (toRow - fromRow).sign;
    final int colStep = (toCol - fromCol).sign;

    int row = fromRow + rowStep;
    int col = fromCol + colStep;

    while (row != toRow || col != toCol) {
      if (!isInBoard(row, col)) {
        return false;
      }

      if (state.brett[row][col] != null) {
        return false;
      }

      row += rowStep;
      col += colStep;
    }

    return true;
  }

}