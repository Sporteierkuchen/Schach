import 'ai_game_state.dart';

class ZobristHasher {
  static final List<List<int>> _pieceSquareKeys = _createPieceSquareKeys();
  static final List<int> _castlingKeys = _createKeys(4, 100000);
  static final List<int> _enPassantKeys = _createKeys(8, 200000);
  static const int whiteTurnKey = 0x1f2e3d4c;

  static int hash(AiGameState state) {
    return hashFromValues(
      board: state.board,
      isWhiteTurn: state.isWhiteTurn,
      enPassantTargetIndex: state.enPassantTargetIndex,
      castlingRights: state.castlingRights,
    );
  }

  static int hashFromValues({
    required List<int> board,
    required bool isWhiteTurn,
    required int? enPassantTargetIndex,
    required AiCastlingRights castlingRights,
  }) {
    int h = 0;

    for (int i = 0; i < 64; i++) {
      final int piece = board[i];
      if (piece == 0) continue;
      h ^= pieceSquareKey(piece, i);
    }

    if (isWhiteTurn) h ^= whiteTurnKey;

    h ^= castlingHash(castlingRights);
    h ^= enPassantHash(enPassantTargetIndex);

    return h;
  }

  static int pieceSquareKey(int piece, int square) {
    return _pieceSquareKeys[_pieceToIndex(piece)][square];
  }

  static int enPassantHash(int? index) {
    if (index == null) return 0;
    return _enPassantKeys[index % 8];
  }

  static int castlingHash(AiCastlingRights rights) {
    int h = 0;

    if (rights.whiteKingSide) h ^= _castlingKeys[0];
    if (rights.whiteQueenSide) h ^= _castlingKeys[1];
    if (rights.blackKingSide) h ^= _castlingKeys[2];
    if (rights.blackQueenSide) h ^= _castlingKeys[3];

    return h;
  }

  static int _pieceToIndex(int piece) {
    switch (piece) {
      case 1: return 0;
      case 2: return 1;
      case 3: return 2;
      case 4: return 3;
      case 5: return 4;
      case 6: return 5;
      case -1: return 6;
      case -2: return 7;
      case -3: return 8;
      case -4: return 9;
      case -5: return 10;
      case -6: return 11;
      default:
        throw ArgumentError("Ungültige Figur: $piece");
    }
  }

  static List<List<int>> _createPieceSquareKeys() {
    final List<List<int>> keys = [];
    int seed = 123456789;

    for (int p = 0; p < 12; p++) {
      final List<int> pieceKeys = [];

      for (int s = 0; s < 64; s++) {
        seed = _nextSeed(seed);
        pieceKeys.add(seed);
      }

      keys.add(pieceKeys);
    }

    return keys;
  }

  static List<int> _createKeys(int count, int startSeed) {
    final List<int> keys = [];
    int seed = startSeed;

    for (int i = 0; i < count; i++) {
      seed = _nextSeed(seed);
      keys.add(seed);
    }

    return keys;
  }

  static int _nextSeed(int seed) {
    return (seed * 1103515245 + 12345) & 0x7fffffff;
  }
}