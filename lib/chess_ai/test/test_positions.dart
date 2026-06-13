import 'package:schach/chess_ai/ai_game_state.dart';
import 'package:schach/chess_ai/board_helper.dart';

class TestPositions {
  static AiCastlingRights noCastling() {
    return const AiCastlingRights(
      whiteKingSide: false,
      whiteQueenSide: false,
      blackKingSide: false,
      blackQueenSide: false,
    );
  }

  static AiCastlingRights whiteKingSideCastlingOnly() {
    return const AiCastlingRights(
      whiteKingSide: true,
      whiteQueenSide: false,
      blackKingSide: false,
      blackQueenSide: false,
    );
  }

  static AiGameState mateInOneBlack() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(0, 1)] = -4; // schwarzer Turm b8
    board[BoardHelper.getIndex(0, 2)] = -6; // schwarzer König c8
    board[BoardHelper.getIndex(7, 7)] = 6;  // weißer König h1
    board[BoardHelper.getIndex(6, 6)] = 1;  // weißer Bauer g2
    board[BoardHelper.getIndex(6, 7)] = 1;  // weißer Bauer h2

    return AiGameState(
      board: board,
      isEnemyMove: true,
      isWhiteTurn: false,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }

  static AiGameState whiteCanCastleKingSide() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 4)] = 6;   // Weißer König e1
    board[BoardHelper.getIndex(7, 7)] = 4;   // Weißer Turm h1
    board[BoardHelper.getIndex(0, 4)] = -6;  // Schwarzer König e8

    return AiGameState(
      board: board,
      isEnemyMove: false,
      isWhiteTurn: true,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: whiteKingSideCastlingOnly(),
    );
  }

  static AiGameState enPassantWhiteCanCapture() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 4)] = 6;   // Weißer König e1
    board[BoardHelper.getIndex(0, 4)] = -6;  // Schwarzer König e8

    board[BoardHelper.getIndex(3, 4)] = 1;   // Weißer Bauer e5
    board[BoardHelper.getIndex(3, 3)] = -1;  // Schwarzer Bauer d5

    return AiGameState(
      board: board,
      isEnemyMove: false,
      isWhiteTurn: true,
      playerIsWhite: true,
      enPassantTargetIndex: BoardHelper.getIndex(2, 3), // d6
      castlingRights: noCastling(),
    );
  }

  static AiGameState whitePromotionReady() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 7)] = 6;   // Weißer König h1
    board[BoardHelper.getIndex(0, 7)] = -6;  // Schwarzer König h8
    board[BoardHelper.getIndex(1, 0)] = 1;   // Weißer Bauer a7

    return AiGameState(
      board: board,
      isEnemyMove: false,
      isWhiteTurn: true,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }

  static AiGameState materialAdvantageWhiteQueen() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 4)] = 6;
    board[BoardHelper.getIndex(0, 4)] = -6;
    board[BoardHelper.getIndex(4, 4)] = 5;

    return AiGameState(
      board: board,
      isEnemyMove: false,
      isWhiteTurn: true,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }

  static AiGameState startPosition() {
    final board = List<int>.filled(64, 0);

    board[0] = -4;
    board[1] = -2;
    board[2] = -3;
    board[3] = -5;
    board[4] = -6;
    board[5] = -3;
    board[6] = -2;
    board[7] = -4;

    for (int i = 8; i < 16; i++) {
      board[i] = -1;
    }

    for (int i = 48; i < 56; i++) {
      board[i] = 1;
    }

    board[56] = 4;
    board[57] = 2;
    board[58] = 3;
    board[59] = 5;
    board[60] = 6;
    board[61] = 3;
    board[62] = 2;
    board[63] = 4;

    return AiGameState(
      board: board,
      isEnemyMove: false,
      isWhiteTurn: true,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: const AiCastlingRights(
        whiteKingSide: true,
        whiteQueenSide: true,
        blackKingSide: true,
        blackQueenSide: true,
      ),
    );
  }

/*  static AiGameState kiwipetePosition() {
    final board = List<int>.filled(64, 0);

    // Schwarz
    board[0] = -4;  // a8
    board[2] = -3;  // c8
    board[4] = -6;  // e8
    board[5] = -3;  // f8
    board[7] = -4;  // h8
    board[8] = -1;  // a7
    board[9] = -1;  // b7
    board[11] = -1; // d7
    board[13] = -5; // f7
    board[14] = -1; // g7
    board[15] = -1; // h7
    board[18] = -2; // c6
    board[20] = -2; // e6
    board[22] = -1; // g6
    board[28] = -1; // e5

    // Weiß
    board[36] = 1;  // e4
    board[38] = 3;  // g4
    board[42] = 2;  // c3
    board[45] = 2;  // f3
    board[48] = 1;  // a2
    board[49] = 1;  // b2
    board[51] = 1;  // d2
    board[53] = 5;  // f2
    board[54] = 1;  // g2
    board[55] = 1;  // h2
    board[56] = 4;  // a1
    board[58] = 3;  // c1
    board[60] = 6;  // e1
    board[61] = 4;  // f1

    return AiGameState(
      board: board,
      isEnemyMove: false,
      isWhiteTurn: true,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: const AiCastlingRights(
        whiteKingSide: true,
        whiteQueenSide: true,
        blackKingSide: true,
        blackQueenSide: true,
      ),
    );
  }*/

  static AiGameState kiwipetePosition() {
    final board = List<int>.filled(64, 0);

    // FEN:
    // r3k2r/p1ppqpb1/bn2pnp1/2pPN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1

    // Schwarz
    board[0] = -4;  // a8 rook
    board[4] = -6;  // e8 king
    board[7] = -4;  // h8 rook

    board[8] = -1;  // a7
    board[10] = -1; // c7
    board[11] = -1; // d7
    board[12] = -5; // e7 queen
    board[13] = -1; // f7
    board[14] = -3; // g7 bishop

    board[16] = -3; // a6 bishop
    board[17] = -2; // b6 knight
    board[20] = -1; // e6
    board[21] = -2; // f6 knight
    board[22] = -1; // g6

    //board[26] = -1; // c5
    board[27] = 1;  // d5 white pawn
    board[28] = 2;  // e5 white knight

    board[33] = -1; // b4
    board[36] = 1;  // e4

    board[42] = 2;  // c3 white knight
    board[45] = 5;  // f3 white queen
    board[47] = -1; // h3 black pawn

    board[48] = 1;  // a2
    board[49] = 1;  // b2
    board[50] = 1;  // c2
    board[51] = 3;  // d2 bishop
    board[52] = 3;  // e2 bishop
    board[53] = 1;  // f2
    board[54] = 1;  // g2
    board[55] = 1;  // h2

    board[56] = 4;  // a1 rook
    board[60] = 6;  // e1 king
    board[63] = 4;  // h1 rook

    return AiGameState(
      board: board,
      isEnemyMove: false,
      isWhiteTurn: true,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: const AiCastlingRights(
        whiteKingSide: true,
        whiteQueenSide: true,
        blackKingSide: true,
        blackQueenSide: true,
      ),
    );
  }

/*  static AiGameState illegalEnPassantBecauseKingWouldBeInCheck() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 4)] = 6;   // Weißer König e1
    board[BoardHelper.getIndex(0, 4)] = -6;  // Schwarzer König e8

    board[BoardHelper.getIndex(3, 4)] = 1;   // Weißer Bauer e5
    board[BoardHelper.getIndex(3, 3)] = -1;  // Schwarzer Bauer d5
    board[BoardHelper.getIndex(3, 0)] = -4;  // Schwarzer Turm a5

    return AiGameState(
      board: board,
      isEnemyMove: false,
      isWhiteTurn: true,
      playerIsWhite: true,
      enPassantTargetIndex: BoardHelper.getIndex(2, 3), // d6
      castlingRights: noCastling(),
    );
  }*/

  static AiGameState illegalEnPassantBecauseKingWouldBeInCheck() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(3, 7)] = 6;   // Weißer König h5
    board[BoardHelper.getIndex(0, 4)] = -6;  // Schwarzer König e8

    board[BoardHelper.getIndex(3, 4)] = 1;   // Weißer Bauer e5
    board[BoardHelper.getIndex(3, 3)] = -1;  // Schwarzer Bauer d5
    board[BoardHelper.getIndex(3, 0)] = -4;  // Schwarzer Turm a5

    return AiGameState(
      board: board,
      isEnemyMove: false,
      isWhiteTurn: true,
      playerIsWhite: true,
      enPassantTargetIndex: BoardHelper.getIndex(2, 3), // d6
      castlingRights: noCastling(),
    );
  }

  static AiGameState whiteCapturePromotionReady() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 7)] = 6;   // Weißer König h1
    board[BoardHelper.getIndex(0, 7)] = -6;  // Schwarzer König h8

    board[BoardHelper.getIndex(1, 0)] = 1;   // Weißer Bauer a7
    board[BoardHelper.getIndex(0, 1)] = -4;  // Schwarzer Turm b8

    return AiGameState(
      board: board,
      isEnemyMove: false,
      isWhiteTurn: true,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }


  static AiGameState blackPromotionReady() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(0, 7)] = -6; // Schwarzer König h8
    board[BoardHelper.getIndex(7, 7)] = 6;  // Weißer König h1

    board[BoardHelper.getIndex(6, 0)] = -1; // Schwarzer Bauer a2

    return AiGameState(
      board: board,
      isEnemyMove: true,
      isWhiteTurn: false,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }

  static AiGameState blackCapturePromotionReady() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(0, 7)] = -6; // Schwarzer König h8
    board[BoardHelper.getIndex(7, 7)] = 6;  // Weißer König h1

    board[BoardHelper.getIndex(6, 1)] = -1; // Schwarzer Bauer b2
    board[BoardHelper.getIndex(7, 0)] = 4;  // Weißer Turm a1

    return AiGameState(
      board: board,
      isEnemyMove: true,
      isWhiteTurn: false,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }

  static AiGameState enPassantBlackCanCapture() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(0, 4)] = -6; // Schwarzer König e8
    board[BoardHelper.getIndex(7, 4)] = 6;  // Weißer König e1

    board[BoardHelper.getIndex(4, 4)] = -1; // Schwarzer Bauer e4
    board[BoardHelper.getIndex(4, 3)] = 1;  // Weißer Bauer d4

    return AiGameState(
      board: board,
      isEnemyMove: true,
      isWhiteTurn: false,
      playerIsWhite: true,
      enPassantTargetIndex: BoardHelper.getIndex(5, 3), // d3
      castlingRights: noCastling(),
    );
  }

}