import 'board_helper.dart';

class BoardEvaluator {
  static const int endgameMaterialLimit = 2400;

  int evaluate(List<int> board) {
    int score = 0;

    final bool endgame = _isEndgame(board);

    // Material + Positionsbewertung + Mobilität
    for (int i = 0; i < 64; i++) {
      final int piece = board[i];

      if (piece == 0) {
        continue;
      }

      score += pieceValue(piece);
      score += positionalBonus(
        piece,
        i,
        endgame,
      );
      score += mobilityBonus(
        board,
        piece,
        i,
      );
    }

    // Bauernstruktur
    score += pawnStructureScore(board);

    // Königssicherheit (Mittelspiel)
    score += kingSafetyScore(
      board,
      endgame,
    );

    // Figuren die ungedeckt angegriffen sind
    score += hangingPieceScore(board);

    // Entwicklungsvorteile
    score += developmentScore(
      board,
      endgame,
    );

    // Türme auf offenen Linien
    score += rookFileScore(board);

    score += rookBehindPassedPawnScore(board);

    // Läuferpaar
    score += bishopPairScore(board);

    // Damenaktivität
    score += queenActivityScore(
      board,
      endgame,
    );

    // ===== Neue Endspiel-Heuristiken =====

    // König ins Zentrum führen
    score += endgameKingActivityScore(
      board,
      endgame,
    );

    // Gegnerischen König an den Rand drängen
    score += endgameKingPressureScore(
      board,
      endgame,
    );

    return score;
  }

  int endgameKingActivityScore(
      List<int> board,
      bool endgame,
      ) {
    if (!endgame) {
      return 0;
    }

    int score = 0;

    final int? whiteKing = _findKing(board, true);
    final int? blackKing = _findKing(board, false);

    if (whiteKing == null || blackKing == null) {
      return 0;
    }

    // Weiß möchte seinen König Richtung Zentrum bringen
    score += _kingCenterBonus(whiteKing);

    // Schwarz ebenfalls -> aus Weiß-Sicht negativ
    score -= _kingCenterBonus(blackKing);

    return score;
  }

  int rookBehindPassedPawnScore(List<int> board) {
    int score = 0;

    for (int i = 0; i < 64; i++) {
      final int piece = board[i];

      if (piece.abs() != 1) {
        continue;
      }

      final bool whitePawn = piece > 0;

      if (!_isPassedPawn(
        board,
        i,
        whitePawn,
      )) {
        continue;
      }

      final int pawnRow = BoardHelper.getRow(i);
      final int pawnCol = BoardHelper.getCol(i);

      final int behindDirection = whitePawn ? 1 : -1;

      for (
      int row = pawnRow + behindDirection;
      row >= 0 && row <= 7;
      row += behindDirection
      ) {
        final int index = BoardHelper.getIndex(
          row,
          pawnCol,
        );

        final int target = board[index];

        if (target == 0) {
          continue;
        }

        if (target.abs() == 4) {
          if ((target > 0) == whitePawn) {
            score += whitePawn ? 35 : -35;
          } else {
            score += whitePawn ? -25 : 25;
          }
        }

        break;
      }
    }

    return score;
  }

  bool _isPassedPawn(
      List<int> board,
      int pawnIndex,
      bool white,
      ) {
    final int enemyPawn = white ? -1 : 1;

    final int row = BoardHelper.getRow(pawnIndex);
    final int col = BoardHelper.getCol(pawnIndex);

    for (
    int r = white ? row - 1 : row + 1;
    white ? r >= 0 : r <= 7;
    r += white ? -1 : 1
    ) {
      for (int c = col - 1; c <= col + 1; c++) {
        if (c < 0 || c > 7) {
          continue;
        }

        final int index = BoardHelper.getIndex(
          r,
          c,
        );

        if (board[index] == enemyPawn) {
          return false;
        }
      }
    }

    return true;
  }

  int _kingCenterBonus(int index) {
    final int row = index ~/ 8;
    final int col = index % 8;

    final int distance = (row - 3).abs() + (col - 3).abs();

    final int bonus = (6 - distance) * 8;

    return bonus < 0 ? 0 : bonus;
  }

  int endgameKingPressureScore(
      List<int> board,
      bool endgame,
      ) {
    if (!endgame) {
      return 0;
    }

    int score = 0;

    final int? whiteKing = _findKing(board, true);
    final int? blackKing = _findKing(board, false);

    if (whiteKing == null || blackKing == null) {
      return 0;
    }

    final int material = _materialOnly(board);

    // Weiß hat deutlichen Materialvorteil
    if (material > 500) {
      score += _kingEdgeBonus(blackKing);
      score += _kingDistanceBonus(
        whiteKing,
        blackKing,
      );
    }

    // Schwarz hat deutlichen Materialvorteil
    else if (material < -500) {
      score -= _kingEdgeBonus(whiteKing);
      score -= _kingDistanceBonus(
        blackKing,
        whiteKing,
      );
    }

    return score;
  }

  int _kingEdgeBonus(int index) {
    final int row = index ~/ 8;
    final int col = index % 8;

    final int distanceToEdge = [
      row,
      col,
      7 - row,
      7 - col,
    ].reduce((a, b) => a < b ? a : b);

    return (3 - distanceToEdge) * 20;
  }

  int _kingDistanceBonus(
      int strongKing,
      int weakKing,
      ) {
    final int sr = strongKing ~/ 8;
    final int sc = strongKing % 8;

    final int wr = weakKing ~/ 8;
    final int wc = weakKing % 8;

    final int distance =
        (sr - wr).abs() +
            (sc - wc).abs();

    return (14 - distance) * 4;
  }

  int _materialOnly(List<int> board) {
    int score = 0;

    for (final int piece in board) {
      score += pieceValue(piece);
    }

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

  int developmentScore(List<int> board, bool endgame) {
    if (endgame) return 0;

    int score = 0;

    // Weiße Leichtfiguren noch auf Startfeldern
    if (board[57] == 2) score -= 25; // Sb1
    if (board[62] == 2) score -= 25; // Sg1
    if (board[58] == 3) score -= 20; // Lc1
    if (board[61] == 3) score -= 20; // Lf1

    // Schwarze Leichtfiguren noch auf Startfeldern
    if (board[1] == -2) score += 25; // Sb8
    if (board[6] == -2) score += 25; // Sg8
    if (board[2] == -3) score += 20; // Lc8
    if (board[5] == -3) score += 20; // Lf8

    // König in der Mitte im Mittelspiel bestrafen
    if (board[60] == 6) score -= 35;
    if (board[4] == -6) score += 35;

    return score;
  }

  int queenActivityScore(List<int> board, bool endgame) {
    if (endgame) return 0;

    int score = 0;

    final int whiteQueen = board.indexOf(5);
    final int blackQueen = board.indexOf(-5);

    if (whiteQueen != -1) {
      final int row = BoardHelper.getRow(whiteQueen);

      // Weiße Dame zu früh weit draußen
      if (row < 5) score -= 25;
    }

    if (blackQueen != -1) {
      final int row = BoardHelper.getRow(blackQueen);

      // Schwarze Dame zu früh weit draußen
      if (row > 2) score += 25;
    }

    return score;
  }

  int bishopPairScore(List<int> board) {
    int whiteBishops = 0;
    int blackBishops = 0;

    for (final int piece in board) {
      if (piece == 3) whiteBishops++;
      if (piece == -3) blackBishops++;
    }

    int score = 0;

    if (whiteBishops >= 2) score += 35;
    if (blackBishops >= 2) score -= 35;

    return score;
  }

  int rookFileScore(List<int> board) {
    int score = 0;

    for (int i = 0; i < 64; i++) {
      final int piece = board[i];

      if (piece.abs() != 4) continue;

      final bool white = piece > 0;
      final int file = BoardHelper.getCol(i);

      bool ownPawnOnFile = false;
      bool enemyPawnOnFile = false;

      for (int row = 0; row < 8; row++) {
        final int p = board[BoardHelper.getIndex(row, file)];

        if (p == 0) continue;

        if (p.abs() == 1) {
          if ((p > 0) == white) {
            ownPawnOnFile = true;
          } else {
            enemyPawnOnFile = true;
          }
        }
      }

      int bonus = 0;

      if (!ownPawnOnFile && !enemyPawnOnFile) {
        bonus = 25; // offene Linie
      } else if (!ownPawnOnFile && enemyPawnOnFile) {
        bonus = 15; // halboffene Linie
      }

      score += white ? bonus : -bonus;
    }

    return score;
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

    final int? ownKing = _findKing(board, white);

    for (int i = 0; i < 64; i++) {
      if (board[i] != pawn) {
        continue;
      }

      final int row = BoardHelper.getRow(i);
      final int col = BoardHelper.getCol(i);

      bool blockedByEnemyPawn = false;

      for (
      int r = white ? row - 1 : row + 1;
      white ? r >= 0 : r <= 7;
      r += white ? -1 : 1
      ) {
        for (int c = col - 1; c <= col + 1; c++) {
          if (c < 0 || c > 7) {
            continue;
          }

          final int index = BoardHelper.getIndex(r, c);

          if (board[index] == enemyPawn) {
            blockedByEnemyPawn = true;
          }
        }
      }

      if (!blockedByEnemyPawn) {
        final int advance = white ? 6 - row : row - 1;

        int pawnScore = 25 + advance * advance * 6;

        if (_isEndgame(board)) {
          pawnScore += 20 + advance * 10;
        }

        if (_hasFriendlyPawnOnAdjacentFile(
          board,
          row,
          col,
          white,
        )) {
          pawnScore += 15;
        }

        if (_hasConnectedPassedPawn(
          board,
          row,
          col,
          white,
        )) {
          pawnScore += _isEndgame(board) ? 35 : 20;
        }

        if (_isPassedPawnBlockedByKing(
          board,
          row,
          col,
          white,
        )) {
          pawnScore -= _isEndgame(board) ? 45 : 25;
        }

        if (_isOutsidePassedPawn(
          board,
          col,
          white,
        )) {
          pawnScore += 20;
        }

        if (ownKing != null) {
          pawnScore += _kingSupportsPassedPawn(
            ownKing,
            row,
            col,
          );
        }

        score += pawnScore;
      }
    }

    return score;
  }

  bool _hasConnectedPassedPawn(
      List<int> board,
      int row,
      int col,
      bool white,
      ) {
    final int pawn = white ? 1 : -1;

    for (int file = col - 1; file <= col + 1; file += 2) {
      if (file < 0 || file > 7) {
        continue;
      }

      for (int r = row - 1; r <= row + 1; r++) {
        if (r < 0 || r > 7) {
          continue;
        }

        final int index = BoardHelper.getIndex(
          r,
          file,
        );

        if (board[index] != pawn) {
          continue;
        }

        if (_isPassedPawn(
          board,
          index,
          white,
        )) {
          return true;
        }
      }
    }

    return false;
  }

  bool _isPassedPawnBlockedByKing(
      List<int> board,
      int row,
      int col,
      bool white,
      ) {
    final int enemyKing = white ? -6 : 6;

    final int blockRow = white ? row - 1 : row + 1;

    if (blockRow < 0 || blockRow > 7) {
      return false;
    }

    final int blockIndex = BoardHelper.getIndex(
      blockRow,
      col,
    );

    return board[blockIndex] == enemyKing;
  }

  bool _hasFriendlyPawnOnAdjacentFile(
      List<int> board,
      int row,
      int col,
      bool white,
      ) {
    final int pawn = white ? 1 : -1;

    for (int file = col - 1; file <= col + 1; file += 2) {
      if (file < 0 || file > 7) {
        continue;
      }

      for (int r = 0; r < 8; r++) {
        if (board[BoardHelper.getIndex(r, file)] == pawn) {
          return true;
        }
      }
    }

    return false;
  }

  bool _isOutsidePassedPawn(
      List<int> board,
      int col,
      bool white,
      ) {
    final int enemyPawn = white ? -1 : 1;

    int enemyMinFile = 8;
    int enemyMaxFile = -1;

    for (int i = 0; i < 64; i++) {
      if (board[i] != enemyPawn) {
        continue;
      }

      final int file = BoardHelper.getCol(i);

      if (file < enemyMinFile) {
        enemyMinFile = file;
      }

      if (file > enemyMaxFile) {
        enemyMaxFile = file;
      }
    }

    if (enemyMaxFile == -1) {
      return true;
    }

    return col < enemyMinFile - 1 || col > enemyMaxFile + 1;
  }

  int _kingSupportsPassedPawn(
      int kingIndex,
      int pawnRow,
      int pawnCol,
      ) {
    final int kingRow = BoardHelper.getRow(kingIndex);
    final int kingCol = BoardHelper.getCol(kingIndex);

    final int distance =
        (kingRow - pawnRow).abs() +
            (kingCol - pawnCol).abs();

    if (distance <= 1) {
      return 20;
    }

    if (distance == 2) {
      return 10;
    }

    return 0;
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

  int? _findKing(
      List<int> board,
      bool white,
      ) {
    final int king = white ? 6 : -6;

    for (int i = 0; i < 64; i++) {
      if (board[i] == king) {
        return i;
      }
    }

    return null;
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