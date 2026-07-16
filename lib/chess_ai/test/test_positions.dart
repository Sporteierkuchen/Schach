import 'package:schach/chess_ai/ai_game_state.dart';
import 'package:schach/chess_ai/board_helper.dart';
import 'package:schach/logic/board_coordinate_mapper.dart';


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

  static AiGameState mateInThreeWhite1() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(0, 5)] = 5;

    board[BoardHelper.getIndex(2, 0)] = 3;
    board[BoardHelper.getIndex(2, 5)] = 1;

    board[BoardHelper.getIndex(3, 3)] = -6;
    board[BoardHelper.getIndex(3, 6)] = 1;

    board[BoardHelper.getIndex(4, 5)] = -1;

    board[BoardHelper.getIndex(5, 0)] = 1;
    board[BoardHelper.getIndex(5, 5)] = 2;
    board[BoardHelper.getIndex(5, 7)] = 1;

    board[BoardHelper.getIndex(7, 0)] = 6;

    return AiGameState(
      board: board,
      isEnemyMove: false,
      isWhiteTurn: true,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );

  }

  static AiGameState mateInThreeWhite2() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(0, 0)] = 2;

    board[BoardHelper.getIndex(1, 0)] = -1;
    board[BoardHelper.getIndex(1, 6)] = 5;
    board[BoardHelper.getIndex(1, 7)] = -2;

    board[BoardHelper.getIndex(2, 4)] = -6;
    board[BoardHelper.getIndex(2, 7)] = 3;

    board[BoardHelper.getIndex(3, 2)] = 1;
    board[BoardHelper.getIndex(3, 6)] = -1;

    board[BoardHelper.getIndex(4, 1)] = 1;
    board[BoardHelper.getIndex(4, 7)] = -1;

    board[BoardHelper.getIndex(5, 2)] = 2;
    board[BoardHelper.getIndex(5, 5)] = 1;

    board[BoardHelper.getIndex(6, 0)] = 6;
    board[BoardHelper.getIndex(6, 3)] = 1;
    board[BoardHelper.getIndex(6, 6)] = 1;

    return AiGameState(
      board: board,
      isEnemyMove: false,
      isWhiteTurn: true,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );

  }


  static AiGameState mateInFourBlack() {
    final board = List<int>.filled(64, 0);

    final mapper = BoardCoordinateMapper(
      figurenfarbe: false, // gespeicherte Stellung aus Sicht Schwarz
    );

    void put(int row, int col, int piece) {
      board[mapper.guiToAiIndex(row, col)] = piece;
    }

    // Weiß
    put(0, 0, 6); // Weißer König
    put(0, 2, 4); // Weißer Turm
    put(0, 3, 4); // Weißer Turm
    put(0, 5, 5); // Weiße Dame
    put(0, 7, 3); // Weißer Läufer
    put(1, 1, 1); // Weißer Bauer
    put(2, 6, 1); // Weißer Bauer
    put(3, 2, 2); // Weißer Springer
    put(3, 3, 3); // Weißer Läufer
    put(3, 7, 1); // Weißer Bauer

    // Schwarz
    put(2, 2, -2); // Schwarzer Springer
    put(3, 1, -2); // Schwarzer Springer
    put(3, 4, -1); // Schwarzer Bauer
    put(4, 7, -1); // Schwarzer Bauer
    put(5, 1, -1); // Schwarzer Bauer
    put(5, 5, -1); // Schwarzer Bauer
    put(6, 0, -1); // Schwarzer Bauer
    put(6, 1, -3); // Schwarzer Läufer
    put(6, 2, -4); // Schwarzer Turm
    put(6, 6, -1); // Schwarzer Bauer
    put(7, 0, -6); // Schwarzer König
    put(7, 3, -4); // Schwarzer Turm
    put(7, 4, -5); // Schwarze Dame

    return AiGameState(
      board: board,
      isWhiteTurn: false,
      isEnemyMove: false,
      playerIsWhite: false,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }


  static AiGameState smotheredMateInFiveBlack() {
    final board = List<int>.filled(64, 0);

    final mapper = BoardCoordinateMapper(
      figurenfarbe: false, // gespeicherte Stellung aus Sicht Schwarz
    );

    void put(int row, int col, int piece) {
      board[mapper.guiToAiIndex(row, col)] = piece;
    }

    // Weiß
    put(0, 5, 4); // Weißer Turm
    put(0, 6, 6); // Weißer König

    put(1, 6, 1); // Weißer Bauer
    put(1, 7, 1); // Weißer Bauer

    // Schwarz
    put(3, 6, -2); // Schwarzer Springer

    put(6, 1, -5); // Schwarze Dame
    put(7, 1, -6); // Schwarzer König



    return AiGameState(
      board: board,
      isWhiteTurn: false,
      isEnemyMove: false,
      playerIsWhite: false,
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

  static AiGameState springerZurueck() {
    final board = List<int>.filled(64, 0);

    final mapper = BoardCoordinateMapper(
      figurenfarbe: false,
    );

    void put(int row, int col, int piece) {
      board[mapper.guiToAiIndex(row, col)] = piece;
    }

    put(0, 0, 4); // Weiß TURM
    put(0, 2, 3); // Weiß LAEUFER
    put(0, 3, 6); // Weiß KOENIG
    put(0, 4, 5); // Weiß DAME
    put(0, 5, 3); // Weiß LAEUFER
    put(0, 6, 2); // Weiß SPRINGER
    put(0, 7, 4); // Weiß TURM
    put(1, 0, 1); // Weiß BAUER
    put(1, 1, 1); // Weiß BAUER
    put(1, 2, 1); // Weiß BAUER
    put(1, 3, 1); // Weiß BAUER
    put(1, 6, 1); // Weiß BAUER
    put(1, 7, 1); // Weiß BAUER
    put(2, 2, 2); // Weiß SPRINGER
    put(3, 1, -3); // Schwarz LAEUFER
    put(3, 4, 1); // Weiß BAUER
    put(3, 5, -1); // Schwarz BAUER
    put(6, 0, -1); // Schwarz BAUER
    put(6, 1, -1); // Schwarz BAUER
    put(6, 2, -1); // Schwarz BAUER
    put(6, 3, -1); // Schwarz BAUER
    put(6, 5, -1); // Schwarz BAUER
    put(6, 6, -1); // Schwarz BAUER
    put(6, 7, -1); // Schwarz BAUER
    put(7, 0, -4); // Schwarz TURM
    put(7, 1, -2); // Schwarz SPRINGER
    put(7, 2, -3); // Schwarz LAEUFER
    put(7, 3, -6); // Schwarz KOENIG
    put(7, 4, -5); // Schwarz DAME
    put(7, 6, -2); // Schwarz SPRINGER
    put(7, 7, -4); // Schwarz TURM

    return AiGameState(
      board: board,
      isWhiteTurn: true,
      isEnemyMove: true,
      playerIsWhite: false,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }


  static AiGameState laeufernichtschlagen() {
    final board = List<int>.filled(64, 0);

    final mapper = BoardCoordinateMapper(
      figurenfarbe: false,
    );

    void put(int row, int col, int piece) {
      board[mapper.guiToAiIndex(row, col)] = piece;
    }

    put(0, 0, 4); // Weiß TURM
    put(0, 2, 3); // Weiß LAEUFER
    put(0, 4, 4); // Weiß TURM
    put(0, 5, 6); // Weiß KOENIG
    put(1, 0, 1); // Weiß BAUER
    put(1, 1, 1); // Weiß BAUER
    put(1, 2, 1); // Weiß BAUER
    put(1, 3, 1); // Weiß BAUER
    put(1, 6, 1); // Weiß BAUER
    put(1, 7, 1); // Weiß BAUER
    put(2, 2, 2); // Weiß SPRINGER
    put(2, 4, 5); // Weiß DAME
    put(2, 7, -3); // Schwarz LAEUFER
    put(3, 2, 3); // Weiß LAEUFER
    put(3, 3, -2); // Schwarz SPRINGER
    put(3, 4, -1); // Schwarz BAUER
    put(4, 2, -3); // Schwarz LAEUFER
    put(4, 4, -1); // Schwarz BAUER
    put(5, 3, -1); // Schwarz BAUER
    put(5, 5, -2); // Schwarz SPRINGER
    put(5, 7, -1); // Schwarz BAUER
    put(6, 0, -1); // Schwarz BAUER
    put(6, 1, -1); // Schwarz BAUER
    put(6, 2, -1); // Schwarz BAUER
    put(6, 5, -1); // Schwarz BAUER
    put(7, 0, -4); // Schwarz TURM
    put(7, 3, -6); // Schwarz KOENIG
    put(7, 4, -5); // Schwarz DAME
    put(7, 6, -4); // Schwarz TURM

    return AiGameState(
      board: board,
      isWhiteTurn: true,
      isEnemyMove: true,
      playerIsWhite: false,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }















  static AiGameState queenTradeWhenAhead() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 6)] = 6;   // Weiß Kg1
    board[BoardHelper.getIndex(0, 6)] = -6;  // Schwarz Kg8

    board[BoardHelper.getIndex(3, 3)] = 5;   // Weiß Dame d5
    board[BoardHelper.getIndex(3, 4)] = -5;  // Schwarz Dame e5

    board[BoardHelper.getIndex(7, 0)] = 4;   // Weiß Turm a1
    board[BoardHelper.getIndex(0, 0)] = -4;  // Schwarz Turm a8

    board[BoardHelper.getIndex(6, 0)] = 1;
    board[BoardHelper.getIndex(6, 1)] = 1;
    board[BoardHelper.getIndex(6, 2)] = 1;
    board[BoardHelper.getIndex(1, 0)] = -1;
    board[BoardHelper.getIndex(1, 1)] = -1;

    // Weiß hat einen Bauern mehr und sollte Damentausch mögen.

    return AiGameState(
      board: board,
      isWhiteTurn: true,
      isEnemyMove: false,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }

  static AiGameState queenTradeBadDuringAttack() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 6)] = 6;   // Weiß Kg1
    board[BoardHelper.getIndex(0, 6)] = -6;  // Schwarz Kg8

    board[BoardHelper.getIndex(3, 7)] = 5;   // Weiß Dame h5
    board[BoardHelper.getIndex(1, 5)] = -5;  // Schwarz Dame f7

    board[BoardHelper.getIndex(4, 2)] = 3;   // Weiß Läufer c4
    board[BoardHelper.getIndex(5, 6)] = 2;   // Weiß Springer g3
    board[BoardHelper.getIndex(1, 6)] = -1;  // Schwarz Bauer g7
    board[BoardHelper.getIndex(1, 7)] = -1;  // Schwarz Bauer h7

    // Weiß hat Angriffsidee gegen König. Damentausch sollte nicht automatisch bevorzugt werden.

    return AiGameState(
      board: board,
      isWhiteTurn: true,
      isEnemyMove: false,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }

  static AiGameState rookTradeWhenAhead() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 6)] = 6;
    board[BoardHelper.getIndex(0, 6)] = -6;

    board[BoardHelper.getIndex(3, 3)] = 4;   // Weiß Turm d5
    board[BoardHelper.getIndex(3, 4)] = -4;  // Schwarz Turm e5

    board[BoardHelper.getIndex(6, 0)] = 1;
    board[BoardHelper.getIndex(6, 1)] = 1;
    board[BoardHelper.getIndex(6, 2)] = 1;
    board[BoardHelper.getIndex(1, 0)] = -1;

    // Weiß klar vorne, Turmtausch ist gut.

    return AiGameState(
      board: board,
      isWhiteTurn: true,
      isEnemyMove: false,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }

  static AiGameState activePieceShouldNotTradePassivePiece() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 6)] = 6;   // Weiß Kg1
    board[BoardHelper.getIndex(0, 6)] = -6;  // Schwarz Kg8

    board[BoardHelper.getIndex(3, 4)] = 2;   // Weißer aktiver Springer e5
    board[BoardHelper.getIndex(2, 2)] = -2;  // Schwarzer Springer c6

    board[BoardHelper.getIndex(6, 3)] = 1;   // Weiß Bauer d2
    board[BoardHelper.getIndex(6, 4)] = 1;   // Weiß Bauer e2
    board[BoardHelper.getIndex(1, 3)] = -1;  // Schwarz Bauer d7
    board[BoardHelper.getIndex(1, 4)] = -1;  // Schwarz Bauer e7

    // Weiß kann Sxc6 spielen, aber tauscht aktive Figur gegen passive Figur.
    // Besser wäre Entwicklung / Bauernzug / Springer aktiv halten.

    return AiGameState(
      board: board,
      isWhiteTurn: true,
      isEnemyMove: false,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }

  static AiGameState simpleExchangeWinsMaterial() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 6)] = 6;
    board[BoardHelper.getIndex(0, 6)] = -6;

    board[BoardHelper.getIndex(4, 3)] = 3;    // Weiß Läufer d4
    board[BoardHelper.getIndex(3, 4)] = -2;   // Schwarz Springer e5
    board[BoardHelper.getIndex(2, 5)] = -4;   // Schwarz Turm f6

    board[BoardHelper.getIndex(5, 2)] = 5;    // Weiß Dame c3 unterstützt
    board[BoardHelper.getIndex(1, 0)] = -1;
    board[BoardHelper.getIndex(6, 0)] = 1;

    // Weiß kann Schlagfolge starten und Material gewinnen.

    return AiGameState(
      board: board,
      isWhiteTurn: true,
      isEnemyMove: false,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }




  static AiGameState passivePieceShouldTradeActivePiece() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 6)] = 6;   // Weiß Kg1
    board[BoardHelper.getIndex(0, 6)] = -6;  // Schwarz Kg8

    board[BoardHelper.getIndex(5, 3)] = 2;   // Weißer passiver Springer d3
    board[BoardHelper.getIndex(3, 4)] = -2;  // Schwarzer aktiver Springer e5

    board[BoardHelper.getIndex(6, 2)] = 1;
    board[BoardHelper.getIndex(6, 5)] = 1;
    board[BoardHelper.getIndex(1, 2)] = -1;
    board[BoardHelper.getIndex(1, 5)] = -1;

    return AiGameState(
      board: board,
      isWhiteTurn: true,
      isEnemyMove: false,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }

  static AiGameState avoidQueenTradeWhenBehind() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 6)] = 6;
    board[BoardHelper.getIndex(0, 6)] = -6;

    board[BoardHelper.getIndex(3, 3)] = 5;    // Weiß Dame d5
    board[BoardHelper.getIndex(3, 4)] = -5;   // Schwarz Dame e5

    board[BoardHelper.getIndex(0, 0)] = -4;   // Schwarz extra Turm
    board[BoardHelper.getIndex(6, 0)] = 1;
    board[BoardHelper.getIndex(1, 0)] = -1;

    // Weiß ist materiell schlechter, sollte Damentausch eher vermeiden.

    return AiGameState(
      board: board,
      isWhiteTurn: true,
      isEnemyMove: false,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }

  static AiGameState avoidRookTradeWhenBehind() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 6)] = 6;
    board[BoardHelper.getIndex(0, 6)] = -6;

    board[BoardHelper.getIndex(3, 3)] = 4;    // Weiß Turm d5
    board[BoardHelper.getIndex(3, 4)] = -4;   // Schwarz Turm e5

    board[BoardHelper.getIndex(0, 0)] = -4;   // Schwarz extra Turm

    board[BoardHelper.getIndex(6, 0)] = 1;
    board[BoardHelper.getIndex(1, 0)] = -1;

    // Weiß ist materiell schlechter, sollte Turmtausch eher vermeiden.

    return AiGameState(
      board: board,
      isWhiteTurn: true,
      isEnemyMove: false,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }

  static AiGameState queenTradeWhenOwnKingUnsafe() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 6)] = 6;    // Weiß Kg1
    board[BoardHelper.getIndex(0, 6)] = -6;   // Schwarz Kg8

    board[BoardHelper.getIndex(5, 7)] = 5;    // Weiß Dame h3
    board[BoardHelper.getIndex(3, 7)] = -5;   // Schwarz Dame h5

    board[BoardHelper.getIndex(6, 6)] = 1;    // Weiß Bauer g2
    // h-Bauer fehlt -> König luftig
    board[BoardHelper.getIndex(1, 6)] = -1;
    board[BoardHelper.getIndex(1, 7)] = -1;

    // Damentausch Qxh5 sollte wegen unsicherem König gut sein.

    return AiGameState(
      board: board,
      isWhiteTurn: true,
      isEnemyMove: false,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }

  static AiGameState avoidTradeWhenDefenderNeeded() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 6)] = 6;    // Weiß Kg1
    board[BoardHelper.getIndex(0, 6)] = -6;   // Schwarz Kg8

    board[BoardHelper.getIndex(5, 5)] = 2;    // Weiß Springer f3 deckt h2/g1
    board[BoardHelper.getIndex(3, 4)] = -2;   // Schwarz Springer e5

    board[BoardHelper.getIndex(1, 7)] = -5;   // Schwarze Dame h7
    board[BoardHelper.getIndex(6, 7)] = 1;    // Weiß Bauer h2
    board[BoardHelper.getIndex(6, 6)] = 1;    // Weiß Bauer g2

    // Springer f3 erfüllt defensive Aufgaben.
    // Tausch Nxe5 kann gefährlich sein.

    return AiGameState(
      board: board,
      isWhiteTurn: true,
      isEnemyMove: false,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }

  static AiGameState badExchangeLosesMaterial() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 6)] = 6;   // Weiß Kg1
    board[BoardHelper.getIndex(0, 6)] = -6;  // Schwarz Kg8

    board[BoardHelper.getIndex(4, 3)] = 3;    // Weiß Läufer d4
    board[BoardHelper.getIndex(3, 4)] = -2;   // Schwarz Springer e5

    board[BoardHelper.getIndex(2, 5)] = -4;   // Schwarz Turm f6
    board[BoardHelper.getIndex(1, 4)] = -5;   // Schwarz Dame e7 unterstützt e5/f6

    board[BoardHelper.getIndex(5, 2)] = 5;    // Weiß Dame c3
    board[BoardHelper.getIndex(6, 0)] = 1;
    board[BoardHelper.getIndex(1, 0)] = -1;

    // Weiß kann Bxe5 spielen, aber nach weiterer Schlagfolge
    // sollte der Abtausch ungünstig sein.

    return AiGameState(
      board: board,
      isWhiteTurn: true,
      isEnemyMove: false,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }

  static AiGameState schlagen() {
    final board = List<int>.filled(64, 0);

    final mapper = BoardCoordinateMapper(
      figurenfarbe: true,
    );

    void put(int row, int col, int piece) {
      board[mapper.guiToAiIndex(row, col)] = piece;
    }

    put(0, 2, -6); // Schwarz KOENIG
    put(1, 0, -1); // Schwarz BAUER
    put(1, 1, -1); // Schwarz BAUER
    put(2, 4, -5); // Schwarz DAME
    put(3, 3, -1); // Schwarz BAUER
    put(4, 1, 1); // Weiß BAUER
    put(4, 2, 1); // Weiß BAUER
    put(4, 3, 1); // Weiß BAUER
    put(4, 4, -2); // Schwarz SPRINGER
    put(5, 3, 5); // Weiß DAME
    put(5, 6, -4); // Schwarz TURM
    put(6, 0, 1); // Weiß BAUER
    put(6, 6, 1); // Weiß BAUER
    put(7, 4, 4); // Weiß TURM
    put(7, 6, 6); // Weiß KOENIG

    return AiGameState(
      board: board,
      isWhiteTurn: true,
      isEnemyMove: false,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }




  static AiGameState exchangeRookTakesKnightThenWinsQueen() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 6)] = 6;
    board[BoardHelper.getIndex(0, 6)] = -6;

    board[BoardHelper.getIndex(7, 4)] = 4;   // Weiß Turm e1
    board[BoardHelper.getIndex(4, 4)] = -2;  // Schwarz Springer e4
    board[BoardHelper.getIndex(2, 4)] = -5;  // Schwarz Dame e6

    board[BoardHelper.getIndex(5, 3)] = 5;   // Weiß Dame d3
    board[BoardHelper.getIndex(5, 6)] = -4;  // Schwarz Turm g3

    return AiGameState(
      board: board,
      isWhiteTurn: true,
      isEnemyMove: false,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }

  static AiGameState exchangeBishopTakesRookThenWinsQueen() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 6)] = 6;
    board[BoardHelper.getIndex(0, 6)] = -6;

    board[BoardHelper.getIndex(4, 2)] = 3;   // Weiß Läufer c4
    board[BoardHelper.getIndex(3, 5)] = -4;  // Schwarz Turm f5
    board[BoardHelper.getIndex(2, 6)] = -5;  // Schwarz Dame g6

    board[BoardHelper.getIndex(5, 3)] = 4;   // Weiß Turm d3
    board[BoardHelper.getIndex(1, 0)] = -1;
    board[BoardHelper.getIndex(6, 0)] = 1;

    // Idee: Bxf5 gewinnt Turm. Falls ...Qxf5, Rxd8/ähnlich später.
    // Erst Diagnose, ggf. Erwartungszug anpassen.

    return AiGameState(
      board: board,
      isWhiteTurn: true,
      isEnemyMove: false,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }

  static AiGameState exchangeKnightTakesRookThenWinsQueen() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 6)] = 6;
    board[BoardHelper.getIndex(0, 6)] = -6;

    board[BoardHelper.getIndex(4, 4)] = 2;   // Weiß Springer e4
    board[BoardHelper.getIndex(2, 5)] = -4;  // Schwarz Turm f6
    board[BoardHelper.getIndex(2, 3)] = -5;  // Schwarz Dame d6

    board[BoardHelper.getIndex(5, 2)] = 4;   // Weiß Turm c3
    board[BoardHelper.getIndex(6, 0)] = 1;
    board[BoardHelper.getIndex(1, 0)] = -1;

    return AiGameState(
      board: board,
      isWhiteTurn: true,
      isEnemyMove: false,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }

  static AiGameState exchangePawnTakesMinorThenWinsRook() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 6)] = 6;
    board[BoardHelper.getIndex(0, 6)] = -6;

    board[BoardHelper.getIndex(4, 3)] = 1;   // Weiß Bauer d4
    board[BoardHelper.getIndex(3, 4)] = -2;  // Schwarz Springer e5
    board[BoardHelper.getIndex(2, 5)] = -4;  // Schwarz Turm f6

    board[BoardHelper.getIndex(5, 2)] = 5;   // Weiß Dame c3
    board[BoardHelper.getIndex(6, 0)] = 1;
    board[BoardHelper.getIndex(1, 0)] = -1;

    return AiGameState(
      board: board,
      isWhiteTurn: true,
      isEnemyMove: false,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }

  static AiGameState badQueenTakesMinorLosesQueen() {
    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 6)] = 6;
    board[BoardHelper.getIndex(0, 6)] = -6;

    board[BoardHelper.getIndex(5, 3)] = 5;   // Weiß Dame d3
    board[BoardHelper.getIndex(4, 4)] = -2;  // Schwarz Springer e4

    board[BoardHelper.getIndex(2, 6)] = -3;  // Schwarz Läufer g6 deckt e4/f5
    board[BoardHelper.getIndex(0, 0)] = -4;  // Schwarz Turm a8
    board[BoardHelper.getIndex(7, 0)] = 4;   // Weiß Turm a1

    // Dame sollte nicht einfach Dxe4 spielen, wenn sie danach taktisch verliert.

    return AiGameState(
      board: board,
      isWhiteTurn: true,
      isEnemyMove: false,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: noCastling(),
    );
  }



}