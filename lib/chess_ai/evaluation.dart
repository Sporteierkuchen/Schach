class Evaluation {
  int evaluateArray(
      List<int> board,
      int whiteKingIndex,
      int blackKingIndex,
      ) {
    int score = 0;

    for (int i = 0; i < 64; i++) {
      final int piece = board[i];
      if (piece == 0) continue;

      score += getPieceValue(piece);
    }

    return score;
  }

  int getPieceValue(int piece) {
    switch (piece.abs()) {
      case 1:
        return piece > 0 ? 10 : -10;
      case 2:
        return piece > 0 ? 30 : -30;
      case 3:
        return piece > 0 ? 30 : -30;
      case 4:
        return piece > 0 ? 50 : -50;
      case 5:
        return piece > 0 ? 90 : -90;
      case 6:
        return piece > 0 ? 900 : -900;
      default:
        return 0;
    }
  }
}