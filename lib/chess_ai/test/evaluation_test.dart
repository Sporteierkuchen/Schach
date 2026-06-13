import 'package:flutter_test/flutter_test.dart';
import 'package:schach/chess_ai/board_evaluator.dart';

import 'test_positions.dart';

void main() {
  test('Evaluator bewertet weiße Dame Vorteil positiv', () {
    final evaluator = BoardEvaluator();
    final state = TestPositions.materialAdvantageWhiteQueen();

    final score = evaluator.evaluate(state.board);

    expect(score, greaterThan(800));
  });

  test('Evaluator ist aus schwarzer Sicht negativ bei weißem Materialvorteil', () {
    final evaluator = BoardEvaluator();
    final state = TestPositions.materialAdvantageWhiteQueen();

    final score = evaluator.evaluate(state.board);

    expect(score, lessThan(20000));
  });
}