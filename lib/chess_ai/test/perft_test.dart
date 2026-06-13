import 'package:flutter_test/flutter_test.dart';
import 'package:schach/chess_ai/board_evaluator.dart';
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

    expect(engine.perft(state: state, depth: 1), 20);
  });

  test('Perft Startposition Tiefe 2 = 400', () {
    final engine = createEngine();
    final state = TestPositions.startPosition();

    expect(engine.perft(state: state, depth: 2), 400);
  });

  test('Perft Startposition Tiefe 3 = 8902', () {
    final engine = createEngine();
    final state = TestPositions.startPosition();

    expect(engine.perft(state: state, depth: 3), 8902);
  });

  test('Perft Startposition Tiefe 4 = 197281', () {
    final engine = createEngine();
    final state = TestPositions.startPosition();

    expect(engine.perft(state: state, depth: 4), 197281);
  });

  test('Perft Startposition Tiefe 5 = 4865609', () {
    final engine = createEngine();
    final state = TestPositions.startPosition();

    expect(engine.perft(state: state, depth: 5), 4865609);
  });

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

  test('Perft Spezialstellungen Tiefe 3 laufen stabil', () {
    final engine = createEngine();

    final positions = [
      TestPositions.enPassantWhiteCanCapture(),
      TestPositions.illegalEnPassantBecauseKingWouldBeInCheck(),
      TestPositions.whitePromotionReady(),
      TestPositions.blackPromotionReady(),
      TestPositions.whiteCanCastleKingSide(),
    ];

    for (int i = 0; i < positions.length; i++) {
      final nodes = engine.perft(
        state: positions[i],
        depth: 3,
      );

      expect(
        nodes > 0,
        true,
        reason: 'Spezialstellung Index $i erzeugt keine Knoten',
      );
    }
  });
}