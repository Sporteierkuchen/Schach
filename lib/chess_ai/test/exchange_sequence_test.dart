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

  AiMove? searchMove({
    required MinimaxEngine engine,
    required AiGameState state,
    int depth = 4,
    int timeLimitMs = 12000,
  }) {
    return engine.findBestMoveTimed(
      state: state,
      depth: depth,
      stopwatch: Stopwatch()..start(),
      timeLimitMs: timeLimitMs,
    );
  }

  void diagnoseExchange({
    required String title,
    required AiGameState state,
    int depth = 4,
  }) {
    final engine = createEngine();
    final evaluator = BoardEvaluator();
    final generator = MoveGenerator();
    final ordering = MoveOrdering(evaluator);

    engine.debugRootBreakdown = true;

    final moves = ordering.orderAiMoves(
      generator.getAllLegalAiMoves(state: state),
      state.board,
    );

    final int beforeScore = evaluator.evaluate(state.board);

    print('===== $title =====');
    print('Grundbewertung: $beforeScore');
    print('Legale Züge: ${moves.length}');

    for (final move in moves.take(60)) {
      final int captured = state.board[move.toIndex];

      final undo = engine.makeMoveInPlaceForTest(
        state: state,
        move: move,
      );

      final int afterScore = evaluator.evaluate(state.board);

      engine.undoMoveInPlaceForTest(
        state: state,
        undo: undo,
      );

      print(
        '${moveName(move)} | '
            'moveOrder=${move.score} | '
            'capture=$captured | '
            'piece=${move.piece} | '
            'evalNachZug=$afterScore | '
            'diff=${afterScore - beforeScore}',
      );
    }

    final move = searchMove(
      engine: engine,
      state: state,
      depth: depth,
    );

    expect(move, isNotNull);

    print('KI wählt: ${moveName(move!)}');
  }

  test('Diagnose: Turm schlägt Springer und Folge gewinnt Material', () {
    diagnoseExchange(
      title: 'TURM SCHLÄGT SPRINGER FOLGE',
      state: TestPositions.exchangeRookTakesKnightThenWinsQueen(),
      depth: 4,
    );
  });

  test('Diagnose: Läufer schlägt Turm und Folge gewinnt Material', () {
    diagnoseExchange(
      title: 'LÄUFER SCHLÄGT TURM FOLGE',
      state: TestPositions.exchangeBishopTakesRookThenWinsQueen(),
      depth: 4,
    );
  });

  test('Diagnose: Springer schlägt Turm und Folge gewinnt Material', () {
    diagnoseExchange(
      title: 'SPRINGER SCHLÄGT TURM FOLGE',
      state: TestPositions.exchangeKnightTakesRookThenWinsQueen(),
      depth: 4,
    );
  });

  test('Diagnose: Bauer schlägt Leichtfigur und Folge gewinnt Material', () {
    diagnoseExchange(
      title: 'BAUER SCHLÄGT LEICHTFIGUR FOLGE',
      state: TestPositions.exchangePawnTakesMinorThenWinsRook(),
      depth: 4,
    );
  });

  test('Diagnose: Dame schlägt Leichtfigur schlecht vermeiden', () {
    diagnoseExchange(
      title: 'DAME SCHLÄGT LEICHTFIGUR SCHLECHT',
      state: TestPositions.badQueenTakesMinorLosesQueen(),
      depth: 4,
    );
  });
}