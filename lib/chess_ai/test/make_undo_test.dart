import 'package:flutter_test/flutter_test.dart';
import 'package:schach/chess_ai/ai_game_state.dart';
import 'package:schach/chess_ai/ai_move.dart';
import 'package:schach/chess_ai/board_evaluator.dart';
import 'package:schach/chess_ai/board_helper.dart';
import 'package:schach/chess_ai/minimax_engine.dart';
import 'package:schach/chess_ai/move_generator.dart';
import 'package:schach/chess_ai/move_ordering.dart';
import 'package:schach/chess_ai/test/test_positions.dart';
import 'package:schach/chess_ai/transposition_table.dart';

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

  List<int> copyBoard(List<int> board) {
    return List<int>.from(board);
  }

  void expectStateRestored({
    required AiGameState state,
    required List<int> originalBoard,
    required bool originalIsWhiteTurn,
    required bool originalIsEnemyMove,
    required int? originalEnPassant,
    required AiCastlingRights originalCastlingRights,
  }) {
    expect(state.board, originalBoard);
    expect(state.isWhiteTurn, originalIsWhiteTurn);
    expect(state.isEnemyMove, originalIsEnemyMove);
    expect(state.enPassantTargetIndex, originalEnPassant);

    expect(state.castlingRights.whiteKingSide,
        originalCastlingRights.whiteKingSide);
    expect(state.castlingRights.whiteQueenSide,
        originalCastlingRights.whiteQueenSide);
    expect(state.castlingRights.blackKingSide,
        originalCastlingRights.blackKingSide);
    expect(state.castlingRights.blackQueenSide,
        originalCastlingRights.blackQueenSide);
  }

  test('MakeUndo stellt normalen Zug exakt wieder her', () {
    final engine = createEngine();
    final state = TestPositions.startPosition();

    final originalBoard = copyBoard(state.board);
    final originalIsWhiteTurn = state.isWhiteTurn;
    final originalIsEnemyMove = state.isEnemyMove;
    final originalEnPassant = state.enPassantTargetIndex;
    final originalCastling = state.castlingRights;

    final move = AiMove(
      fromIndex: BoardHelper.getIndex(6, 4), // e2
      toIndex: BoardHelper.getIndex(4, 4),   // e4
      piece: 1,
      score: 0,
    );

    final undo = engine.makeMoveInPlaceForTest(
      state: state,
      move: move,
    );

    expect(state.board[BoardHelper.getIndex(6, 4)], 0);
    expect(state.board[BoardHelper.getIndex(4, 4)], 1);
    expect(state.isWhiteTurn, false);
    expect(state.enPassantTargetIndex, BoardHelper.getIndex(5, 4)); // e3

    engine.undoMoveInPlaceForTest(
      state: state,
      undo: undo,
    );

    expectStateRestored(
      state: state,
      originalBoard: originalBoard,
      originalIsWhiteTurn: originalIsWhiteTurn,
      originalIsEnemyMove: originalIsEnemyMove,
      originalEnPassant: originalEnPassant,
      originalCastlingRights: originalCastling,
    );
  });

  test('MakeUndo stellt En Passant exakt wieder her', () {
    final engine = createEngine();
    final state = TestPositions.enPassantWhiteCanCapture();

    final originalBoard = copyBoard(state.board);
    final originalIsWhiteTurn = state.isWhiteTurn;
    final originalIsEnemyMove = state.isEnemyMove;
    final originalEnPassant = state.enPassantTargetIndex;
    final originalCastling = state.castlingRights;

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

    expect(state.board[BoardHelper.getIndex(3, 4)], 0);
    expect(state.board[BoardHelper.getIndex(3, 3)], 0);
    expect(state.board[BoardHelper.getIndex(2, 3)], 1);

    engine.undoMoveInPlaceForTest(
      state: state,
      undo: undo,
    );

    expectStateRestored(
      state: state,
      originalBoard: originalBoard,
      originalIsWhiteTurn: originalIsWhiteTurn,
      originalIsEnemyMove: originalIsEnemyMove,
      originalEnPassant: originalEnPassant,
      originalCastlingRights: originalCastling,
    );
  });

  test('MakeUndo stellt Promotion exakt wieder her', () {
    final engine = createEngine();
    final state = TestPositions.whitePromotionReady();

    final originalBoard = copyBoard(state.board);
    final originalIsWhiteTurn = state.isWhiteTurn;
    final originalIsEnemyMove = state.isEnemyMove;
    final originalEnPassant = state.enPassantTargetIndex;
    final originalCastling = state.castlingRights;

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

    expectStateRestored(
      state: state,
      originalBoard: originalBoard,
      originalIsWhiteTurn: originalIsWhiteTurn,
      originalIsEnemyMove: originalIsEnemyMove,
      originalEnPassant: originalEnPassant,
      originalCastlingRights: originalCastling,
    );
  });

  test('MakeUndo stellt Rochade exakt wieder her', () {
    final engine = createEngine();
    final state = TestPositions.whiteCanCastleKingSide();

    final originalBoard = copyBoard(state.board);
    final originalIsWhiteTurn = state.isWhiteTurn;
    final originalIsEnemyMove = state.isEnemyMove;
    final originalEnPassant = state.enPassantTargetIndex;
    final originalCastling = state.castlingRights;

    final move = AiMove(
      fromIndex: BoardHelper.getIndex(7, 4), // e1
      toIndex: BoardHelper.getIndex(7, 6),   // g1
      piece: 6,
      score: 0,
    );

    final undo = engine.makeMoveInPlaceForTest(
      state: state,
      move: move,
    );

    expect(state.board[BoardHelper.getIndex(7, 4)], 0);
    expect(state.board[BoardHelper.getIndex(7, 6)], 6);
    expect(state.board[BoardHelper.getIndex(7, 7)], 0);
    expect(state.board[BoardHelper.getIndex(7, 5)], 4);

    engine.undoMoveInPlaceForTest(
      state: state,
      undo: undo,
    );

    expectStateRestored(
      state: state,
      originalBoard: originalBoard,
      originalIsWhiteTurn: originalIsWhiteTurn,
      originalIsEnemyMove: originalIsEnemyMove,
      originalEnPassant: originalEnPassant,
      originalCastlingRights: originalCastling,
    );
  });

  test('MakeUndo entfernt CastlingRights nach Königszug und stellt sie wieder her', () {
    final engine = createEngine();
    final state = TestPositions.startPosition();

    final originalBoard = copyBoard(state.board);
    final originalIsWhiteTurn = state.isWhiteTurn;
    final originalIsEnemyMove = state.isEnemyMove;
    final originalEnPassant = state.enPassantTargetIndex;
    final originalCastling = state.castlingRights;

    // Brett etwas freimachen, damit König theoretisch ziehen kann.
    state.board[BoardHelper.getIndex(7, 5)] = 0;

    final boardAfterSetup = copyBoard(state.board);

    final move = AiMove(
      fromIndex: BoardHelper.getIndex(7, 4), // e1
      toIndex: BoardHelper.getIndex(7, 5),   // f1
      piece: 6,
      score: 0,
    );

    final undo = engine.makeMoveInPlaceForTest(
      state: state,
      move: move,
    );

    expect(state.castlingRights.whiteKingSide, false);
    expect(state.castlingRights.whiteQueenSide, false);

    engine.undoMoveInPlaceForTest(
      state: state,
      undo: undo,
    );

    expect(state.board, boardAfterSetup);
    expect(state.isWhiteTurn, originalIsWhiteTurn);
    expect(state.isEnemyMove, originalIsEnemyMove);
    expect(state.enPassantTargetIndex, originalEnPassant);
    expect(state.castlingRights.whiteKingSide,
        originalCastling.whiteKingSide);
    expect(state.castlingRights.whiteQueenSide,
        originalCastling.whiteQueenSide);
    expect(state.castlingRights.blackKingSide,
        originalCastling.blackKingSide);
    expect(state.castlingRights.blackQueenSide,
        originalCastling.blackQueenSide);

    // optional: ursprüngliches Brett wieder auf echten Start zurücksetzen
    state.board.setAll(0, originalBoard);
  });
}