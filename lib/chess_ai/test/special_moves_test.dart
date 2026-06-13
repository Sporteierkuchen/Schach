import 'package:flutter_test/flutter_test.dart';
import 'package:schach/chess_ai/ai_move.dart';
import 'package:schach/chess_ai/board_helper.dart';
import 'package:schach/chess_ai/board_evaluator.dart';
import 'package:schach/chess_ai/minimax_engine.dart';
import 'package:schach/chess_ai/move_generator.dart';
import 'package:schach/chess_ai/move_ordering.dart';
import 'package:schach/chess_ai/test/test_positions.dart';
import 'package:schach/chess_ai/transposition_table.dart';
import 'package:schach/chess_ai/ai_game_state.dart';


void main() {
  MinimaxEngine createEngine() {
    final evaluator = BoardEvaluator();

    return MinimaxEngine(
      moveGenerator: MoveGenerator(),
      evaluator: evaluator,
      moveOrdering: MoveOrdering(evaluator),
      transpositionTable: TranspositionTable(),
    );
  }

  test('En Passant entfernt den geschlagenen Bauern korrekt', () {
    final engine = createEngine();
    final state = TestPositions.enPassantWhiteCanCapture();

    final move = AiMove(
      fromIndex: BoardHelper.getIndex(3, 4), // e5
      toIndex: BoardHelper.getIndex(2, 3),   // d6
      piece: 1,
      score: 0,
    );

    final undo = engine.makeMoveInPlaceForTest(
      state: state,
      move: move,
    );

    expect(state.board[BoardHelper.getIndex(3, 3)], 0);
    expect(state.board[BoardHelper.getIndex(2, 3)], 1);

    engine.undoMoveInPlaceForTest(
      state: state,
      undo: undo,
    );

  });

  test('Promotion wandelt Bauern korrekt in Dame um', () {
    final engine = createEngine();
    final state = TestPositions.whitePromotionReady();

    final move = AiMove(
      fromIndex: BoardHelper.getIndex(1, 0), // a7
      toIndex: BoardHelper.getIndex(0, 0),   // a8
      piece: 1,
      promotionPiece: 5,
      score: 0,
    );

    final undo = engine.makeMoveInPlaceForTest(
      state: state,
      move: move,
    );

    expect(state.board[BoardHelper.getIndex(1, 0)], 0);
    expect(state.board[BoardHelper.getIndex(0, 0)], 5);

    engine.undoMoveInPlaceForTest(
      state: state,
      undo: undo,
    );

  });

  test(
    "Patt wird korrekt erkannt",
        () {

      final generator = MoveGenerator();


      final board = List<int>.filled(64,0);


      // Schwarz am Zug
      board[0] = -6; // König a8

      board[9] = 4; // Weißer Turm b7

      board[18] = 6; // Weißer König c6


      final state = AiGameState(
        board: board,
        isEnemyMove:true,
        isWhiteTurn:false,
        playerIsWhite:true,
        enPassantTargetIndex:null,
        castlingRights: TestPositions.noCastling(),
      );


      expect(
        generator.isStalemate(
          state: state,
        ),
        true,
      );
    },
  );

  test(
    "Nur zwei Könige ist Remis",
        () {

      final generator = MoveGenerator();


      final board = List<int>.filled(64,0);


      board[60] = 6;
      board[4] = -6;


      expect(
        generator.isInsufficientMaterial(board),
        true,
      );
    },
  );

  test('En Passant ist legal, wenn König dadurch nicht im Schach steht', () {
    final generator = MoveGenerator();
    final state = TestPositions.enPassantWhiteCanCapture();

    final moves = generator.getAllLegalAiMoves(state: state);

    final hasEnPassant = moves.any((m) =>
    m.fromIndex == BoardHelper.getIndex(3, 4) && // e5
        m.toIndex == BoardHelper.getIndex(2, 3) &&   // d6
        m.piece == 1);

    expect(hasEnPassant, true);
  });

  test('En Passant ist illegal, wenn dadurch der eigene König im Schach steht', () {
    final generator = MoveGenerator();
    final state = TestPositions.illegalEnPassantBecauseKingWouldBeInCheck();

    final moves = generator.getAllLegalAiMoves(state: state);

    final hasIllegalEnPassant = moves.any((m) =>
    m.fromIndex == BoardHelper.getIndex(3, 4) &&
        m.toIndex == BoardHelper.getIndex(2, 3) &&
        m.piece == 1);

    expect(hasIllegalEnPassant, false);
  });

  test('Bauer auf a7 erzeugt vier Promotionen nach a8', () {
    final generator = MoveGenerator();
    final state = TestPositions.whitePromotionReady();

    final moves = generator.getAllLegalAiMoves(state: state);

    final promotions = moves
        .where((m) =>
    m.fromIndex == BoardHelper.getIndex(1, 0) &&
        m.toIndex == BoardHelper.getIndex(0, 0))
        .map((m) => m.promotionPiece)
        .toSet();

    expect(promotions, containsAll([5, 4, 3, 2]));
    expect(promotions.length, 4);
  });

  test('Bauer auf a7 erzeugt vier Schlag-Promotionen nach b8', () {
    final generator = MoveGenerator();
    final state = TestPositions.whiteCapturePromotionReady();

    final moves = generator.getAllLegalAiMoves(state: state);

    final promotions = moves
        .where((m) =>
    m.fromIndex == BoardHelper.getIndex(1, 0) &&
        m.toIndex == BoardHelper.getIndex(0, 1))
        .map((m) => m.promotionPiece)
        .toSet();

    expect(promotions, containsAll([5, 4, 3, 2]));
    expect(promotions.length, 4);
  });

  test('Kurze Rochade ist verboten, wenn f1 angegriffen ist', () {
    final generator = MoveGenerator();

    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 4)] = 6;   // Ke1
    board[BoardHelper.getIndex(7, 7)] = 4;   // Th1
    board[BoardHelper.getIndex(0, 4)] = -6;  // Ke8

    board[BoardHelper.getIndex(5, 5)] = -4;  // Schwarzer Turm f3 greift f1 an

    final state = AiGameState(
      board: board,
      isEnemyMove: false,
      isWhiteTurn: true,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: const AiCastlingRights(
        whiteKingSide: true,
        whiteQueenSide: false,
        blackKingSide: false,
        blackQueenSide: false,
      ),
    );

    final moves = generator.getAllLegalAiMoves(state: state);

    final hasCastle = moves.any((m) =>
    m.fromIndex == BoardHelper.getIndex(7, 4) &&
        m.toIndex == BoardHelper.getIndex(7, 6));

    expect(hasCastle, false);
  });

  test('Im Schach werden nur Züge erlaubt, die das Schach aufheben', () {
    final generator = MoveGenerator();

    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(7, 4)] = 6;   // Weißer König e1
    board[BoardHelper.getIndex(0, 4)] = -6;  // Schwarzer König e8
    board[BoardHelper.getIndex(3, 4)] = -4;  // Schwarzer Turm e5 gibt Schach

    final state = AiGameState(
      board: board,
      isEnemyMove: false,
      isWhiteTurn: true,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: TestPositions.noCastling(),
    );

    final moves = generator.getAllLegalAiMoves(state: state);

    for (final move in moves) {

      final engine = createEngine();

      final undo = engine.makeMoveInPlaceForTest(
        state: state,
        move: move,
      );

      final whiteKingIndex = BoardHelper.getKingIndex(state.board, true);
      final blackKingIndex = BoardHelper.getKingIndex(state.board, false);

      expect(whiteKingIndex, isNotNull);
      expect(blackKingIndex, isNotNull);

      final stillInCheck = generator.isKingInCheck(
        state: state,
        isWhiteKing: true,
        whiteKingIndex: whiteKingIndex!,
        blackKingIndex: blackKingIndex!,
      );

      engine.undoMoveInPlaceForTest(
        state: state,
        undo: undo,
      );

      expect(stillInCheck, false);

    }
  });


  test('Schwarzer Bauer auf a2 erzeugt vier Promotionen nach a1', () {
    final generator = MoveGenerator();
    final state = TestPositions.blackPromotionReady();

    final moves = generator.getAllLegalAiMoves(state: state);

    final promotions = moves
        .where((m) =>
    m.fromIndex == BoardHelper.getIndex(6, 0) &&
        m.toIndex == BoardHelper.getIndex(7, 0))
        .map((m) => m.promotionPiece)
        .toSet();

    expect(promotions, containsAll([-5, -4, -3, -2]));
    expect(promotions.length, 4);
  });

  test('Schwarzer Bauer auf b2 erzeugt vier Schlag-Promotionen nach a1', () {
    final generator = MoveGenerator();
    final state = TestPositions.blackCapturePromotionReady();

    final moves = generator.getAllLegalAiMoves(state: state);

    final promotions = moves
        .where((m) =>
    m.fromIndex == BoardHelper.getIndex(6, 1) &&
        m.toIndex == BoardHelper.getIndex(7, 0))
        .map((m) => m.promotionPiece)
        .toSet();

    expect(promotions, containsAll([-5, -4, -3, -2]));
    expect(promotions.length, 4);
  });

  test('Schwarzes En Passant ist legal, wenn König dadurch nicht im Schach steht', () {
    final generator = MoveGenerator();
    final state = TestPositions.enPassantBlackCanCapture();

    final moves = generator.getAllLegalAiMoves(state: state);

    final hasEnPassant = moves.any((m) =>
    m.fromIndex == BoardHelper.getIndex(4, 4) && // e4
        m.toIndex == BoardHelper.getIndex(5, 3) &&   // d3
        m.piece == -1);

    expect(hasEnPassant, true);
  });

  test('Schwarze kurze Rochade ist verboten, wenn f8 angegriffen ist', () {
    final generator = MoveGenerator();

    final board = List<int>.filled(64, 0);

    board[BoardHelper.getIndex(0, 4)] = -6; // Schwarzer König e8
    board[BoardHelper.getIndex(0, 7)] = -4; // Schwarzer Turm h8
    board[BoardHelper.getIndex(7, 4)] = 6;  // Weißer König e1

    board[BoardHelper.getIndex(2, 5)] = 4;  // Weißer Turm f6 greift f8 an

    final state = AiGameState(
      board: board,
      isEnemyMove: true,
      isWhiteTurn: false,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: const AiCastlingRights(
        whiteKingSide: false,
        whiteQueenSide: false,
        blackKingSide: true,
        blackQueenSide: false,
      ),
    );

    final moves = generator.getAllLegalAiMoves(state: state);

    final hasCastle = moves.any((m) =>
    m.fromIndex == BoardHelper.getIndex(0, 4) &&
        m.toIndex == BoardHelper.getIndex(0, 6));

    expect(hasCastle, false);
  });

}