import 'package:flutter_test/flutter_test.dart';
import 'package:schach/chess_ai/board_evaluator.dart';
import 'package:schach/chess_ai/minimax_engine.dart';
import 'package:schach/chess_ai/move_generator.dart';
import 'package:schach/chess_ai/move_ordering.dart';
import 'package:schach/chess_ai/transposition_table.dart';

import 'test_positions.dart';

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

  test('Divide Perft Startposition Tiefe 2', () {
    final engine = createEngine();
    final state = TestPositions.startPosition();

    final result = engine.dividePerft(
      state: state,
      depth: 2,
    );

    expect(result['a2a3'], 20);
    expect(result['a2a4'], 20);
    expect(result['b2b3'], 20);
    expect(result['b2b4'], 20);
    expect(result['c2c3'], 20);
    expect(result['c2c4'], 20);
    expect(result['d2d3'], 20);
    expect(result['d2d4'], 20);
    expect(result['e2e3'], 20);
    expect(result['e2e4'], 20);
    expect(result['f2f3'], 20);
    expect(result['f2f4'], 20);
    expect(result['g2g3'], 20);
    expect(result['g2g4'], 20);
    expect(result['h2h3'], 20);
    expect(result['h2h4'], 20);

    expect(result['b1a3'], 20);
    expect(result['b1c3'], 20);
    expect(result['g1f3'], 20);
    expect(result['g1h3'], 20);

    expect(
      result.values.fold<int>(0, (sum, value) => sum + value),
      400,
    );
  });

  test('Divide Perft Startposition Tiefe 3 Summe = 8902', () {
    final engine = createEngine();
    final state = TestPositions.startPosition();

    final result = engine.dividePerft(
      state: state,
      depth: 3,
    );

    final int total =
    result.values.fold<int>(0, (sum, value) => sum + value);

    print("===== DIVIDE PERFT DEPTH 3 =====");

    final sortedKeys = result.keys.toList()..sort();

    for (final key in sortedKeys) {
      print("$key: ${result[key]}");
    }

    print("TOTAL: $total");

    expect(total, 8902);
  });
}