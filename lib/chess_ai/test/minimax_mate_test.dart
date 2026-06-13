import 'package:flutter_test/flutter_test.dart';
import 'package:schach/chess_ai/chess_ai.dart';
import 'package:schach/chess_ai/board_helper.dart';

import 'test_positions.dart';

void main() {
  test('KI findet Matt in 1 mit Turm B8 -> B1', () {
    final ai = ChessAi();
    final state = TestPositions.mateInOneBlack();

    final move = ai.getBestMove(
      state: state,
      moveHistory: [],
      timeLimitMs: 4000,
      aiLevel: 5,
    );

    expect(move, isNotNull);
    expect(move!.fromIndex, BoardHelper.getIndex(0, 1)); // b8
    expect(move.toIndex, BoardHelper.getIndex(7, 1));    // b1
  });



}