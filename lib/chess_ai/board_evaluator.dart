import 'board_helper.dart';

class BoardEvaluator {
  static const int endgameMaterialLimit = 2400;

  int evaluate(List<int> board) {
    int score = 0;

    //debugValidateTables();

    final bool endgame = _isEndgame(board);

    for (int i = 0; i < 64; i++) {
      final int piece = board[i];
      if (piece == 0) continue;

      score += pieceValue(piece);
      score += positionalBonus(piece, i, endgame);
      score += mobilityBonus(board, piece, i);
    }

    score += pawnStructureScore(board);
    score += kingSafetyScore(board, endgame);
    //score += hangingPieceScore(board);

    return score;
  }

  int pieceValue(int piece) {
    switch (piece.abs()) {
      case 1:
        return piece > 0 ? 100 : -100;
      case 2:
        return piece > 0 ? 320 : -320;
      case 3:
        return piece > 0 ? 330 : -330;
      case 4:
        return piece > 0 ? 500 : -500;
      case 5:
        return piece > 0 ? 900 : -900;
      case 6:
        return piece > 0 ? 20000 : -20000;
      default:
        return 0;
    }
  }

  int hangingPieceScore(List<int> board) {
    int score = 0;

    for (int i = 0; i < 64; i++) {
      final int piece = board[i];

      if (piece == 0) continue;
      if (piece.abs() == 6) continue;

      final bool isWhite = piece > 0;

      final int attackers = _countAttackers(
        board,
        i,
        isWhite,
      );

      if (attackers == 0) continue;

      final int defenders = _countDefenders(
        board,
        i,
        isWhite,
      );

      final int value = pieceValue(piece).abs();

      int penalty = 0;

      if (defenders == 0) {
        penalty = value ~/ 3;
      } else if (attackers > defenders) {
        penalty = value ~/ 5;
      } else {
        penalty = value ~/ 12;
      }

      if (piece.abs() == 1) {
        penalty ~/= 2;
      }

      if (isWhite) {
        score -= penalty;
      } else {
        score += penalty;
      }
    }

    return score;
  }

  int _countAttackers(
      List<int> board,
      int targetIndex,
      bool targetIsWhite,
      ) {
    int count = 0;

    for (int i = 0; i < 64; i++) {
      final int piece = board[i];

      if (piece == 0) continue;
      if ((piece > 0) == targetIsWhite) continue;

      if (_pieceControlsSquare(
        board,
        i,
        piece,
        targetIndex,
      )) {
        count++;
      }
    }

    return count;
  }

  int _countDefenders(
      List<int> board,
      int targetIndex,
      bool targetIsWhite,
      ) {
    int count = 0;

    for (int i = 0; i < 64; i++) {
      final int piece = board[i];

      if (piece == 0) continue;
      if (i == targetIndex) continue;
      if ((piece > 0) != targetIsWhite) continue;

      if (_pieceControlsSquare(
        board,
        i,
        piece,
        targetIndex,
      )) {
        count++;
      }
    }

    return count;
  }

  bool _pieceControlsSquare(
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
        final bool diagonal = rowDiff.abs() == colDiff.abs();
        final bool straight = fromRow == targetRow || fromCol == targetCol;

        if (!diagonal && !straight) return false;

        return _pathClear(
          board,
          fromRow,
          fromCol,
          targetRow,
          targetCol,
        );

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
      final int index = BoardHelper.getIndex(
        row,
        col,
      );

      if (board[index] != 0) {
        return false;
      }

      row += rowStep;
      col += colStep;
    }

    return true;
  }

  int positionalBonus(
      int piece,
      int index,
      bool endgame,
      ) {
    final int absPiece = piece.abs();
    final int tableIndex = piece > 0 ? index : _mirrorIndex(index);

    int bonus = 0;

    switch (absPiece) {
      case 1:
        bonus = _pawnTable[tableIndex];
        break;
      case 2:
        bonus = _knightTable[tableIndex];
        break;
      case 3:
        bonus = _bishopTable[tableIndex];
        break;
      case 4:
        bonus = _rookTable[tableIndex];
        break;
      case 5:
        bonus = _queenTable[tableIndex];
        break;
      case 6:
        bonus = endgame
            ? _kingEndgameTable[tableIndex]
            : _kingMiddleGameTable[tableIndex];
        break;
    }

    return piece > 0 ? bonus : -bonus;
  }

  void debugValidateTables() {
    print("pawn: ${_pawnTable.length}");
    print("knight: ${_knightTable.length}");
    print("bishop: ${_bishopTable.length}");
    print("rook: ${_rookTable.length}");
    print("queen: ${_queenTable.length}");
    print("kingMiddle: ${_kingMiddleGameTable.length}");
    print("kingEnd: ${_kingEndgameTable.length}");
  }

  int mobilityBonus(
      List<int> board,
      int piece,
      int index,
      ) {
    final int absPiece = piece.abs();

    if (absPiece == 1 || absPiece == 6) {
      return 0;
    }

    final int mobility = _countPseudoLegalTargets(
      board,
      piece,
      index,
    );

    int factor = 0;

    switch (absPiece) {
      case 2:
        factor = 4;
        break;
      case 3:
        factor = 4;
        break;
      case 4:
        factor = 2;
        break;
      case 5:
        factor = 1;
        break;
    }

    final int bonus = mobility * factor;

    return piece > 0 ? bonus : -bonus;
  }

  int pawnStructureScore(List<int> board) {
    int score = 0;

    final List<int> whiteFiles = List<int>.filled(8, 0);
    final List<int> blackFiles = List<int>.filled(8, 0);

    for (int i = 0; i < 64; i++) {
      final int piece = board[i];

      if (piece.abs() != 1) {
        continue;
      }

      final int col = BoardHelper.getCol(i);

      if (piece > 0) {
        whiteFiles[col]++;
      } else {
        blackFiles[col]++;
      }
    }

    for (int file = 0; file < 8; file++) {
      if (whiteFiles[file] > 1) {
        score -= (whiteFiles[file] - 1) * 15;
      }

      if (blackFiles[file] > 1) {
        score += (blackFiles[file] - 1) * 15;
      }

      if (whiteFiles[file] > 0) {
        final bool hasLeft = file > 0 && whiteFiles[file - 1] > 0;
        final bool hasRight = file < 7 && whiteFiles[file + 1] > 0;

        if (!hasLeft && !hasRight) {
          score -= 12;
        }
      }

      if (blackFiles[file] > 0) {
        final bool hasLeft = file > 0 && blackFiles[file - 1] > 0;
        final bool hasRight = file < 7 && blackFiles[file + 1] > 0;

        if (!hasLeft && !hasRight) {
          score += 12;
        }
      }
    }

    score += _passedPawnScore(board, true);
    score -= _passedPawnScore(board, false);

    return score;
  }

  int kingSafetyScore(
      List<int> board,
      bool endgame,
      ) {
    if (endgame) {
      return 0;
    }

    int score = 0;

    final int? whiteKing = BoardHelper.getKingIndex(board, true);
    final int? blackKing = BoardHelper.getKingIndex(board, false);

    if (whiteKing != null) {
      score += _kingPawnShieldScore(
        board,
        whiteKing,
        true,
      );
    }

    if (blackKing != null) {
      score -= _kingPawnShieldScore(
        board,
        blackKing,
        false,
      );
    }

    return score;
  }

  int _kingPawnShieldScore(
      List<int> board,
      int kingIndex,
      bool whiteKing,
      ) {
    int score = 0;

    final int row = BoardHelper.getRow(kingIndex);
    final int col = BoardHelper.getCol(kingIndex);

    final int pawnRow = whiteKing ? row - 1 : row + 1;
    final int pawnPiece = whiteKing ? 1 : -1;

    if (pawnRow < 0 || pawnRow > 7) {
      return 0;
    }

    for (int c = col - 1; c <= col + 1; c++) {
      if (c < 0 || c > 7) continue;

      final int index = BoardHelper.getIndex(
        pawnRow,
        c,
      );

      if (board[index] == pawnPiece) {
        score += 12;
      } else {
        score -= 8;
      }
    }

    if (col == 0 || col == 7) {
      score += 8;
    }

    return score;
  }

  int _passedPawnScore(
      List<int> board,
      bool white,
      ) {
    int score = 0;

    final int pawn = white ? 1 : -1;
    final int enemyPawn = white ? -1 : 1;

    for (int i = 0; i < 64; i++) {
      if (board[i] != pawn) continue;

      final int row = BoardHelper.getRow(i);
      final int col = BoardHelper.getCol(i);

      bool blockedByEnemyPawn = false;

      for (int r = white ? row - 1 : row + 1;
      white ? r >= 0 : r <= 7;
      r += white ? -1 : 1) {
        for (int c = col - 1; c <= col + 1; c++) {
          if (c < 0 || c > 7) continue;

          final int index = BoardHelper.getIndex(
            r,
            c,
          );

          if (board[index] == enemyPawn) {
            blockedByEnemyPawn = true;
          }
        }
      }

      if (!blockedByEnemyPawn) {
        final int advance = white ? 6 - row : row - 1;
        score += 20 + advance * 8;
      }
    }

    return score;
  }

  bool _isEndgame(List<int> board) {
    int materialWithoutKingsAndPawns = 0;

    for (final int piece in board) {
      switch (piece.abs()) {
        case 2:
          materialWithoutKingsAndPawns += 320;
          break;
        case 3:
          materialWithoutKingsAndPawns += 330;
          break;
        case 4:
          materialWithoutKingsAndPawns += 500;
          break;
        case 5:
          materialWithoutKingsAndPawns += 900;
          break;
      }
    }

    return materialWithoutKingsAndPawns <= endgameMaterialLimit;
  }

  int _mirrorIndex(int index) {
    final int row = BoardHelper.getRow(index);
    final int col = BoardHelper.getCol(index);

    return BoardHelper.getIndex(
      7 - row,
      col,
    );
  }

  int _countPseudoLegalTargets(
      List<int> board,
      int piece,
      int index,
      ) {
    final int absPiece = piece.abs();

    int count = 0;

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
        final int r = BoardHelper.getRow(index) + offset[0];
        final int c = BoardHelper.getCol(index) + offset[1];

        if (r < 0 || r > 7 || c < 0 || c > 7) continue;

        final int target = board[BoardHelper.getIndex(r, c)];

        if (target == 0 || _isEnemy(piece, target)) {
          count++;
        }
      }

      return count;
    }

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
      int r = BoardHelper.getRow(index) + dir[0];
      int c = BoardHelper.getCol(index) + dir[1];

      while (r >= 0 && r < 8 && c >= 0 && c < 8) {
        final int target = board[BoardHelper.getIndex(r, c)];

        if (target == 0) {
          count++;
        } else {
          if (_isEnemy(piece, target)) {
            count++;
          }

          break;
        }

        r += dir[0];
        c += dir[1];
      }
    }

    return count;
  }

  bool _isEnemy(
      int piece,
      int target,
      ) {
    return target != 0 &&
        ((piece > 0 && target < 0) || (piece < 0 && target > 0));
  }

  static const List<int> _pawnTable = [
    0, 0, 0, 0, 0, 0, 0, 0,
    50, 50, 50, 50, 50, 50, 50, 50,
    10, 10, 20, 30, 30, 20, 10, 10,
    5, 5, 10, 25, 25, 10, 5, 5,
    0, 0, 0, 20, 20, 0, 0, 0,
    5, -5, -10, 0, 0, -10, -5, 5,
    5, 10, 10, -20, -20, 10, 10, 5,
    0, 0, 0, 0, 0, 0, 0, 0,
  ];

  static const List<int> _knightTable = [
    -50, -40, -30, -30, -30, -30, -40, -50,
    -40, -20, 0, 5, 5, 0, -20, -40,
    -30, 5, 10, 15, 15, 10, 5, -30,
    -30, 0, 15, 20, 20, 15, 0, -30,
    -30, 5, 15, 20, 20, 15, 5, -30,
    -30, 0, 10, 15, 15, 10, 0, -30,
    -40, -20, 0, 0, 0, 0, -20, -40,
    -50, -40, -30, -30, -30, -30, -40, -50,
  ];

  static const List<int> _bishopTable = [
    -20, -10, -10, -10, -10, -10, -10, -20,
    -10, 5, 0, 0, 0, 0, 5, -10,
    -10, 10, 10, 10, 10, 10, 10, -10,
    -10, 0, 10, 10, 10, 10, 0, -10,
    -10, 5, 5, 10, 10, 5, 5, -10,
    -10, 0, 5, 10, 10, 5, 0, -10,
    -10, 0, 0, 0, 0, 0, 0, -10,
    -20, -10, -10, -10, -10, -10, -10, -20,
  ];

  static const List<int> _rookTable = [
    0, 0, 0, 5, 5, 0, 0, 0,
    5, 10, 10, 10, 10, 10, 10, 5,
    -5, 0, 0, 0, 0, 0, 0, -5,
    -5, 0, 0, 0, 0, 0, 0, -5,
    -5, 0, 0, 0, 0, 0, 0, -5,
    -5, 0, 0, 0, 0, 0, 0, -5,
    -5, 0, 0, 0, 0, 0, 0, -5,
    0, 0, 0, 5, 5, 0, 0, 0,
  ];

  static const List<int> _queenTable = [
    -20, -10, -10, -5, -5, -10, -10, -20,
    -10, 0, 5, 0, 0, 0, 0, -10,
    -10, 5, 5, 5, 5, 5, 0, -10,
    0, 0, 5, 5, 5, 5, 0, -5,
    -5, 0, 5, 5, 5, 5, 0, -5,
    -10, 0, 5, 5, 5, 5, 0, -10,
    -10, 0, 0, 0, 0, 0, 0, -10,
    -20, -10, -10, -5, -5, -10, -10, -20,
  ];

  static const List<int> _kingMiddleGameTable = [
    -30, -40, -40, -50, -50, -40, -40, -30,
    -30, -40, -40, -50, -50, -40, -40, -30,
    -30, -40, -40, -50, -50, -40, -40, -30,
    -30, -40, -40, -50, -50, -40, -40, -30,
    -20, -30, -30, -40, -40, -30, -30, -20,
    -10, -20, -20, -20, -20, -20, -20, -10,
    20, 20, 0, 0, 0, 0, 20, 20,
    20, 30, 10, 0, 0, 10, 30, 20,
  ];

/*  static const List<int> _kingEndgameTable = [
    -50, -30, -30, -30, -30, -30, -30, -50,
    -30, -10, 0, 0, 0, 0, -10, -30,
    -30, 0, 20, 30, 30, 20, 0, -30,
    -30, 0, 30, 40, 40, 30, 0, -30,
    -30, 0, 30, 40, 40, 30, 0, -30,
    -30, 0, 20, 30, 30, 20, 0, -30,
    -30, -10, 0, 0, 0, 0, -10, -30,
    -50, -30, -30, -30, -30, -30, -50,
  ];*/

  static const List<int> _kingEndgameTable = [
    -50, -30, -30, -30, -30, -30, -30, -50,
    -30, -10, 0, 0, 0, 0, -10, -30,
    -30, 0, 20, 30, 30, 20, 0, -30,
    -30, 0, 30, 40, 40, 30, 0, -30,
    -30, 0, 30, 40, 40, 30, 0, -30,
    -30, 0, 20, 30, 30, 20, 0, -30,
    -30, -10, 0, 0, 0, 0, -10, -30,
    -50, -30, -30, -30, -30, -30, -30, -50,
  ];

}