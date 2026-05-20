class BoardHelper {
  static int getRow(int index) => index ~/ 8;
  static int getCol(int index) => index % 8;
  static int getIndex(int row, int col) => row * 8 + col;

  static bool isIndexInBoard(int index) {
    return index >= 0 && index < 64;
  }

  static int? getKingIndex(List<int> board, bool isWhite) {
    final int king = isWhite ? 6 : -6;

    for (int i = 0; i < 64; i++) {
      if (board[i] == king) return i;
    }

    return null;
  }

  static void makeMove(
      List<int> board,
      int fromIndex,
      int toIndex, {
        int? promotionPiece,
      }) {
    final int piece = board[fromIndex];

    board[fromIndex] = 0;
    board[toIndex] = promotionPiece ?? piece;
  }

  static String indexToCoord(int index) {
    final int row = getRow(index);
    final int col = getCol(index);

    final String file = String.fromCharCode("a".codeUnitAt(0) + col);
    final String rank = (8 - row).toString();

    return "$file$rank";
  }

  static String indexToDisplayCoord(
      int index, {
        required bool figurenfarbe,
      }) {
    final int row = getRow(index);
    final int col = getCol(index);

    final int rank = figurenfarbe ? 8 - row : row + 1;

    const List<String> filesWhite = ["A", "B", "C", "D", "E", "F", "G", "H"];
    const List<String> filesBlack = ["H", "G", "F", "E", "D", "C", "B", "A"];

    final String file = figurenfarbe ? filesWhite[col] : filesBlack[col];

    return "$file$rank";
  }

  static String boardKey(List<int> board, bool isEnemyMove, bool isWhiteTurn) {
    return "${board.join(",")}|$isEnemyMove|$isWhiteTurn";
  }
}