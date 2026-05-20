class BoardEvaluator {
  int evaluate(List<int> board) {
    int score = 0;

    for (int i = 0; i < 64; i++) {
      final int piece = board[i];
      if (piece == 0) continue;

      score += pieceValue(piece);
      score += positionalBonus(piece, i);
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

  int positionalBonus(int piece, int index) {
    final int row = index ~/ 8;
    final int col = index % 8;
    final int absPiece = piece.abs();

    int bonus = 0;

    if ((row == 3 || row == 4) && (col == 3 || col == 4)) {
      if (absPiece == 2 || absPiece == 3 || absPiece == 1) {
        bonus += 10;
      }
    }

    if (absPiece == 1) {
      final bool isWhite = piece > 0;
      bonus += isWhite ? (6 - row) * 4 : (row - 1) * 4;
    }

    return piece > 0 ? bonus : -bonus;
  }
}