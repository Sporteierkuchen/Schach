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

  String moveName(AiMove move) {
    return '${BoardHelper.indexToCoord(move.fromIndex)}'
        '${BoardHelper.indexToCoord(move.toIndex)}';
  }

  AiMove? findMoveIterative({
    required MinimaxEngine engine,
    required AiGameState state,
    required int maxDepth,
    required int timeLimitMs,
  }) {
    final Stopwatch stopwatch = Stopwatch()..start();

    AiMove? bestMove;

    for (int depth = 1; depth <= maxDepth; depth++) {
      if (stopwatch.elapsedMilliseconds >= timeLimitMs) {
        break;
      }

      final AiMove? move = engine.findBestMoveTimed(
        state: state,
        depth: depth,
        stopwatch: stopwatch,
        timeLimitMs: timeLimitMs,
      );

      if (move == null) {
        break;
      }

      bestMove = move;

      final bool isMateScore =
          move.score.abs() > MinimaxEngine.mateScore - 10000;

      if (isMateScore) {
        break;
      }
    }

    stopwatch.stop();

    return bestMove;
  }

  test('KI findet Matt in 3 für Weiß (1)', () {
    final engine = createEngine();
    final generator = MoveGenerator();

    final state = TestPositions.mateInThreeWhite1();

    final List<String> playedMoves = [];

    int whiteMoveCount = 0;

    for (int ply = 0; ply < 6; ply++) {

      final move = findMoveIterative(
        engine: engine,
        state: state,
        maxDepth: 7,
        timeLimitMs: 8000,
      );

      expect(
        move,
        isNotNull,
        reason: 'Keine legale Engine-Antwort bei Ply $ply',
      );

      playedMoves.add(moveName(move!));

      engine.makeMoveInPlaceForTest(
        state: state,
        move: move,
      );

      if (!state.isWhiteTurn) {
        whiteMoveCount++;
      }

      print('Ply $ply: ${playedMoves.last}');
      print('Line so far: ${playedMoves.join(' ')}');

      final isMate = generator.isCheckmate(
        state: state,
      );

      if (isMate) {
        print('Matt gefunden nach: ${playedMoves.join(' ')}');

        expect(
          whiteMoveCount,
          lessThanOrEqualTo(3),
          reason: 'Matt kam zu spät. Linie: ${playedMoves.join(' ')}',
        );

        return;
      }

      if (whiteMoveCount >= 3 && state.isWhiteTurn == false) {
        fail(
          'Nach 3 weißen Zügen kein Matt. Linie: ${playedMoves.join(' ')}',
        );
      }
    }

    fail(
      'Kein Matt innerhalb von 3 weißen Zügen gefunden. Linie: ${playedMoves.join(' ')}',
    );
  });

  test('KI findet Matt in 3 für Weiß (2)', () {
    final engine = createEngine();
    final generator = MoveGenerator();

    final state = TestPositions.mateInThreeWhite2();

    final List<String> playedMoves = [];

    int whiteMoveCount = 0;

    for (int ply = 0; ply < 6; ply++) {

      final move = findMoveIterative(
        engine: engine,
        state: state,
        maxDepth: 7,
        timeLimitMs: 8000,
      );

      expect(
        move,
        isNotNull,
        reason: 'Keine legale Engine-Antwort bei Ply $ply',
      );

      playedMoves.add(moveName(move!));

      engine.makeMoveInPlaceForTest(
        state: state,
        move: move,
      );

      if (!state.isWhiteTurn) {
        whiteMoveCount++;
      }

      print('Ply $ply: ${playedMoves.last}');
      print('Line so far: ${playedMoves.join(' ')}');

      final isMate = generator.isCheckmate(
        state: state,
      );

      if (isMate) {
        print('Matt gefunden nach: ${playedMoves.join(' ')}');

        expect(
          whiteMoveCount,
          lessThanOrEqualTo(3),
          reason: 'Matt kam zu spät. Linie: ${playedMoves.join(' ')}',
        );

        return;
      }

      if (whiteMoveCount >= 3 && state.isWhiteTurn == false) {
        fail(
          'Nach 3 weißen Zügen kein Matt. Linie: ${playedMoves.join(' ')}',
        );
      }
    }

    fail(
      'Kein Matt innerhalb von 3 weißen Zügen gefunden. Linie: ${playedMoves.join(' ')}',
    );
  });

/*
  test('KI findet Matt in 4 für Schwarz', () {
    final engine = createEngine();
    final generator = MoveGenerator();

    final state = TestPositions.mateInFourBlack();

    final List<String> playedMoves = [];

    int blackMoveCount = 0;

    for (int ply = 0; ply < 8; ply++) {

      final move = findMoveIterative(
        engine: engine,
        state: state,
        maxDepth: 9,
        timeLimitMs: 300000,
      );

      expect(
        move,
        isNotNull,
        reason: 'Keine legale Engine-Antwort bei Ply $ply',
      );

      playedMoves.add(moveName(move!));

      // Vor dem Zug ist der Spieler am Zug
      final bool blackMoved = !state.isWhiteTurn;

      engine.makeMoveInPlaceForTest(
        state: state,
        move: move,
      );

      if (blackMoved) {
        blackMoveCount++;
      }

      print('Ply $ply: ${playedMoves.last}');
      print('Line so far: ${playedMoves.join(' ')}');

      final isMate = generator.isCheckmate(
        state: state,
      );

      if (isMate) {
        print('Matt gefunden nach: ${playedMoves.join(' ')}');

        expect(
          blackMoveCount,
          lessThanOrEqualTo(4),
          reason:
          'Schwarz brauchte mehr als 4 Züge. Linie: ${playedMoves.join(' ')}',
        );

        return;
      }

      // Nach dem 4. schwarzen Zug muss Matt gekommen sein
      if (blackMoveCount >= 4) {
        fail(
          'Nach 4 schwarzen Zügen kein Matt. Linie: ${playedMoves.join(' ')}',
        );
      }
    }

    fail(
      'Kein Matt innerhalb von 4 schwarzen Zügen gefunden. Linie: ${playedMoves.join(' ')}',
    );
  });
*/


  test('KI findet ersticktes Matt in 5 für Schwarz', () {
    final engine = createEngine();
    final generator = MoveGenerator();

    final state = TestPositions.smotheredMateInFiveBlack();

    final List<String> playedMoves = [];

    int blackMoveCount = 0;

    for (int ply = 0; ply < 10; ply++) {

      print("TEST Board: ${state.board.join(',')}");
      print("TEST Key: ${state.zobristKey}");
      print("TEST Turn: ${state.isWhiteTurn}");
      print("TEST HistoryKeys: ${state.positionHistory.length}");

      final move = findMoveIterative(
        engine: engine,
        state: state,
        maxDepth: 11,
        timeLimitMs: 300000,
      );

      expect(
        move,
        isNotNull,
        reason: 'Keine legale Engine-Antwort bei Ply $ply',
      );

      playedMoves.add(moveName(move!));

      final bool blackMoved = !state.isWhiteTurn;

      engine.makeMoveInPlaceForTest(
        state: state,
        move: move,
      );

      if (blackMoved) {
        blackMoveCount++;
      }

      print('Ply $ply: ${playedMoves.last}');
      print('Line so far: ${playedMoves.join(' ')}');

      final bool isMate = generator.isCheckmate(
        state: state,
      );

      if (isMate) {
        print('Matt gefunden nach: ${playedMoves.join(' ')}');

        expect(
          blackMoveCount,
          lessThanOrEqualTo(5),
          reason:
          'Schwarz brauchte mehr als 5 Züge. Linie: ${playedMoves.join(' ')}',
        );

        return;
      }

      if (blackMoveCount >= 5) {
        fail(
          'Nach 5 schwarzen Zügen kein Matt. Linie: ${playedMoves.join(' ')}',
        );
      }
    }

    fail(
      'Kein Matt innerhalb von 5 schwarzen Zügen gefunden. Linie: ${playedMoves.join(' ')}',
    );
  });

}