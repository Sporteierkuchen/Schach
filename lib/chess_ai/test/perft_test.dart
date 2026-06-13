import 'package:flutter_test/flutter_test.dart';
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

  test('Perft Startposition Tiefe 1 = 20', () {
    final engine = createEngine();
    final state = TestPositions.startPosition();

    expect(
      engine.perft(
        state: state,
        depth: 1,
      ),
      20,
    );
  });

  test('Perft Startposition Tiefe 2 = 400', () {
    final engine = createEngine();
    final state = TestPositions.startPosition();

    expect(
      engine.perft(
        state: state,
        depth: 2,
      ),
      400,
    );
  });

  test('Perft Startposition Tiefe 3 = 8902', () {
    final engine = createEngine();
    final state = TestPositions.startPosition();

    expect(
      engine.perft(
        state: state,
        depth: 3,
      ),
      8902,
    );
  });

  test('Perft Startposition Tiefe 4 = 197281', () {
    final engine = createEngine();
    final state = TestPositions.startPosition();

    expect(
      engine.perft(
        state: state,
        depth: 4,
      ),
      197281,
    );
  });

  test('Perft Startposition Tiefe 5 = 4865609', () {
    final engine = createEngine();
    final state = TestPositions.startPosition();

    expect(
      engine.perft(
        state: state,
        depth: 5,
      ),
      4865609,
    );
  });

/*  test('Perft Startposition Tiefe 6 = 119060324', () {
    final engine = createEngine();
    final state = TestPositions.startPosition();

    expect(
      engine.perft(
        state: state,
        depth: 6,
      ),
      119060324,
    );
  });*/

  test('Perft Kiwipete Tiefe 1 = 48', () {
    final engine = createEngine();
    final state = TestPositions.kiwipetePosition();

    expect(engine.perft(state: state, depth: 1), 48);
  });

  test('Perft Kiwipete Tiefe 2 = 2039', () {
    final engine = createEngine();
    final state = TestPositions.kiwipetePosition();

    expect(engine.perft(state: state, depth: 2), 2039);
  });

/*  test('Divide Perft Kiwipete Tiefe 2 Debug', () {
    final engine = createEngine();
    final state = TestPositions.kiwipetePosition();

    final result = engine.dividePerft(
      state: state,
      depth: 2,
    );

    final keys = result.keys.toList()..sort();

    for (final key in keys) {
      print("$key: ${result[key]}");
    }

    final total = result.values.fold<int>(0, (a, b) => a + b);
    print("TOTAL: $total");
  });*/

/*  test('Kiwipete schwarze lange Rochade ist legal nach weißem Zug a2a3', () {
    final engine = createEngine();
    final generator = MoveGenerator();

    final state = TestPositions.kiwipetePosition();

    final afterA2A3 = engine.makeNextStateForTest(
      state: state,
      move: AiMove(
        fromIndex: BoardHelper.getIndex(6, 0),
        toIndex: BoardHelper.getIndex(5, 0),
        piece: 1,
        score: 0,
      ),
    );

    final moves = generator.getLegalMovesForPiece(
      state: afterA2A3,
      index: BoardHelper.getIndex(0, 4),
      piece: -6,
    );

    print(
      moves.map((m) => BoardHelper.indexToCoord(m)).toList(),
    );

    expect(
      moves,
      contains(BoardHelper.getIndex(0, 2)), // e8c8
    );
  });*/

/*  test('Debug Kiwipete schwarze Antworten nach a2a3', () {
    final engine = createEngine();
    final generator = MoveGenerator();

    final state = TestPositions.kiwipetePosition();

    final afterA2A3 = engine.makeNextStateForTest(
      state: state,
      move: AiMove(
        fromIndex: BoardHelper.getIndex(6, 0), // a2
        toIndex: BoardHelper.getIndex(5, 0),   // a3
        piece: 1,
        score: 0,
      ),
    );

    final moves = generator.getAllLegalAiMoves(
      state: afterA2A3,
    );

    final moveNames = moves
        .map((m) =>
    "${BoardHelper.indexToCoord(m.fromIndex)}${BoardHelper.indexToCoord(m.toIndex)}")
        .toList()
      ..sort();

    print("COUNT: ${moveNames.length}");

    for (final m in moveNames) {
      print(m);
    }
  });*/

  test('Perft Kiwipete Tiefe 3 = 97862', () {
    final engine = createEngine();
    final state = TestPositions.kiwipetePosition();

    expect(engine.perft(state: state, depth: 3), 97862);
  });

  test('Perft Kiwipete Tiefe 4 = 4085603', () {
    final engine = createEngine();
    final state = TestPositions.kiwipetePosition();

    expect(engine.perft(state: state, depth: 4), 4085603);
  });

}