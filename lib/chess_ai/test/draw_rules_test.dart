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

  test('halfmoveClock wird bei normalem Figurenzug erhöht', () {
    final engine = createEngine();
    final state = TestPositions.startPosition();

    final move = AiMove(
      fromIndex: BoardHelper.getIndex(7, 6), // g1
      toIndex: BoardHelper.getIndex(5, 5),   // f3
      piece: 2,
      score: 0,
    );

    final undo = engine.makeMoveInPlaceForTest(
      state: state,
      move: move,
    );

    expect(state.halfmoveClock, 1);

    engine.undoMoveInPlaceForTest(
      state: state,
      undo: undo,
    );

    expect(state.halfmoveClock, 0);
  });

  test('halfmoveClock wird bei Bauernzug auf 0 gesetzt', () {
    final engine = createEngine();
    final state = TestPositions.startPosition();

    state.halfmoveClock = 12;

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

    expect(state.halfmoveClock, 0);

    engine.undoMoveInPlaceForTest(
      state: state,
      undo: undo,
    );

    expect(state.halfmoveClock, 12);
  });

  test('positionHistory wächst nach MakeMove und wird nach Undo wieder gekürzt', () {
    final engine = createEngine();
    final state = TestPositions.startPosition();

    final originalHistoryLength = state.positionHistory.length;

    final move = AiMove(
      fromIndex: BoardHelper.getIndex(7, 6), // g1
      toIndex: BoardHelper.getIndex(5, 5),   // f3
      piece: 2,
      score: 0,
    );

    final undo = engine.makeMoveInPlaceForTest(
      state: state,
      move: move,
    );

    expect(state.positionHistory.length, originalHistoryLength + 1);
    expect(state.positionHistory.last, state.zobristKey);

    engine.undoMoveInPlaceForTest(
      state: state,
      undo: undo,
    );

    expect(state.positionHistory.length, originalHistoryLength);
  });

  test('50-Züge-Regel wird als Remis bewertet', () {
    final engine = createEngine();

    final board = List<int>.filled(64, 0);
    board[BoardHelper.getIndex(7, 4)] = 6;
    board[BoardHelper.getIndex(0, 4)] = -6;
    board[BoardHelper.getIndex(4, 4)] = 4;

    final state = AiGameState(
      board: board,
      isEnemyMove: false,
      isWhiteTurn: true,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: TestPositions.noCastling(),
      halfmoveClock: 100,
    );

    final score = engine.minimaxTimed(
      state: state,
      depth: 3,
      alpha: -MinimaxEngine.infinity,
      beta: MinimaxEngine.infinity,
      ply: 0,
      stopwatch: Stopwatch()..start(),
      timeLimitMs: 1000,
    );

    expect(score, 0);
  });

  test('Dreifache Stellungswiederholung wird als Remis/Contempt bewertet', () {
    final engine = createEngine();

    final board = List<int>.filled(64, 0);
    board[BoardHelper.getIndex(7, 4)] = 6;
    board[BoardHelper.getIndex(0, 4)] = -6;
    board[BoardHelper.getIndex(4, 4)] = 4;

    final state = AiGameState(
      board: board,
      isEnemyMove: false,
      isWhiteTurn: true,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: TestPositions.noCastling(),
      halfmoveClock: 10,
    );

    state.positionHistory.add(state.zobristKey);
    state.positionHistory.add(state.zobristKey);

    final score = engine.minimaxTimed(
      state: state,
      depth: 3,
      alpha: -MinimaxEngine.infinity,
      beta: MinimaxEngine.infinity,
      ply: 0,
      stopwatch: Stopwatch()..start(),
      timeLimitMs: 1000,
    );

    expect(score, anyOf(0, -50, 50));

  });

  test('Nur zwei Könige wird als Materialremis bewertet', () {
    final engine = createEngine();

    final board = List<int>.filled(64, 0);
    board[BoardHelper.getIndex(7, 4)] = 6;
    board[BoardHelper.getIndex(0, 4)] = -6;

    final state = AiGameState(
      board: board,
      isEnemyMove: false,
      isWhiteTurn: true,
      playerIsWhite: true,
      enPassantTargetIndex: null,
      castlingRights: TestPositions.noCastling(),
    );

    final score = engine.minimaxTimed(
      state: state,
      depth: 3,
      alpha: -MinimaxEngine.infinity,
      beta: MinimaxEngine.infinity,
      ply: 0,
      stopwatch: Stopwatch()..start(),
      timeLimitMs: 1000,
    );

    expect(score, 0);
  });
}