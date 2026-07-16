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
    int depth = 5,
  }) {
    return engine.findBestMoveTimed(
      state: state,
      depth: depth,
      stopwatch: Stopwatch()..start(),
      timeLimitMs: 10000,
    );
  }


/*  test('Diagnose: Warum zieht KI den Springer zurück?', () {
    final engine = createEngine();
    final evaluator = BoardEvaluator();
    final moveGenerator = MoveGenerator();
    final moveOrdering = MoveOrdering(evaluator);

    final state = TestPositions.springerZurueck();

    final moves = moveOrdering.orderAiMoves(
      moveGenerator.getAllLegalAiMoves(state: state),
      state.board,
    );

    print('===== DIAGNOSE SPRINGER ZURÜCK =====');
    print('Grundbewertung vor Zug: ${evaluator.evaluate(state.board)}');
    print('Legale Züge: ${moves.length}');

    for (final move in moves.take(25)) {
      final beforeScore = evaluator.evaluate(state.board);

      final undo = engine.makeMoveInPlaceForTest(
        state: state,
        move: move,
      );

      final afterScore = evaluator.evaluate(state.board);

      engine.undoMoveInPlaceForTest(
        state: state,
        undo: undo,
      );

      final diff = afterScore - beforeScore;

      print(
        '${moveName(move)} | '
            'moveOrder=${move.score} | '
            'evalNachZug=$afterScore | '
            'diff=$diff | '
            'piece=${move.piece} | '
            'capture=${state.board[move.toIndex]}',
      );
    }

    final bestMove = searchMove(
      engine: engine,
      state: state,
      depth: 5,
    );

    expect(bestMove, isNotNull);

    print('KI wählt: ${moveName(bestMove!)}');
  });*/








/*
  test('KI zieht entwickelten Springer nicht passiv zurück', () {
    final engine = createEngine();
    final state = TestPositions.springerZurueck();

    final move = searchMove(
      engine: engine,
      state: state,
      depth: 5,
    );

    expect(move, isNotNull);

    final name = moveName(move!);

    print('Gewählter Zug: $name');

    expect(
      name,
      isNot('f3g1'),
    );

    expect(
      name,
      isNot('f3h4'),
    );

    expect(
      name,
      isNot('f3d2'),
    );
  });
*/


/*  test('KI sollte geschlagene Leichtfigur zurückschlagen statt nur anzugreifen', () {
    final engine = createEngine();
    final evaluator = BoardEvaluator();
    final moveGenerator = MoveGenerator();
    final moveOrdering = MoveOrdering(evaluator);

    final state = TestPositions.laeufernichtschlagen();

    final moves = moveOrdering.orderAiMoves(
      moveGenerator.getAllLegalAiMoves(state: state),
      state.board,
    );

    print('===== DIAGNOSE LÄUFER NICHT SCHLAGEN =====');
    print('Grundbewertung vor Zug: ${evaluator.evaluate(state.board)}');
    print('Legale Züge: ${moves.length}');

    for (final move in moves.take(35)) {
      final beforeScore = evaluator.evaluate(state.board);

      final capturedPiece = state.board[move.toIndex];

      final undo = engine.makeMoveInPlaceForTest(
        state: state,
        move: move,
      );

      final afterScore = evaluator.evaluate(state.board);

      engine.undoMoveInPlaceForTest(
        state: state,
        undo: undo,
      );

      final diff = afterScore - beforeScore;

      print(
        '${moveName(move)} | '
            'moveOrder=${move.score} | '
            'evalNachZug=$afterScore | '
            'diff=$diff | '
            'piece=${move.piece} | '
            'capture=$capturedPiece',
      );
    }

    final bestMove = searchMove(
      engine: engine,
      state: state,
      depth: 5,
    );

    expect(bestMove, isNotNull);

    final name = moveName(bestMove!);

    print('KI wählt: $name');

    // Erwartung: Weiß sollte den schwarzen Läufer mit dem Bauern zurückschlagen.
    // Vermutlich ist das g2h3 oder ähnlich, je nach Mapping.
    // Falls der Print einen anderen echten Schlagzug zeigt, hier anpassen.
    expect(
      state.board[bestMove.toIndex],
      isNot(0),
      reason:
      'KI sollte hier bevorzugt eine Figur zurückschlagen, statt nur anzugreifen.',
    );
  });



  test('KI schlägt gegnerischen Läufer mit Bauern zurück', () {
    final engine = createEngine();
    final state = TestPositions.laeufernichtschlagen();

    final move = searchMove(
      engine: engine,
      state: state,
      depth: 5,
    );

    expect(move, isNotNull);

    final name = moveName(move!);

    print('Gewählter Zug: $name');

    expect(
      name,
      'b2a3',
      reason:
      'Weiß sollte den schwarzen Läufer mit dem Bauern zurückschlagen.',
    );
  });*/







  void diagnosePosition({
    required String title,
    required AiGameState state,
    int depth = 5,
    int showMoves = 40,
  }) {
    final engine = createEngine();

    engine.debugRootBreakdown = true;

    final evaluator = BoardEvaluator();
    final generator = MoveGenerator();
    final ordering = MoveOrdering(evaluator);

    final moves = ordering.orderAiMoves(
      generator.getAllLegalAiMoves(state: state),
      state.board,
    );

    final int beforeScore = evaluator.evaluate(state.board);

    print('===== $title =====');
    print('Grundbewertung: $beforeScore');
    print('Legale Züge: ${moves.length}');

    for (final move in moves.take(showMoves)) {
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

    final bestMove = searchMove(
      engine: engine,
      state: state,
      depth: depth,
    );

    expect(bestMove, isNotNull);

    print('KI wählt: ${moveName(bestMove!)}');
  }






  test('Diagnose: Damentausch bei Materialvorteil', () {
    final state = TestPositions.queenTradeWhenAhead();

    diagnosePosition(
      title: 'DAMENTAUSCH BEI MATERIALVORTEIL',
      state: state,
      depth: 4,
    );
  });

  test('KI tauscht Damen bei Materialvorteil', () {
    final engine = createEngine();
    final state = TestPositions.queenTradeWhenAhead();

    final move = searchMove(
      engine: engine,
      state: state,
      depth: 4,
    );

    expect(move, isNotNull);
    expect(moveName(move!), 'd5e5');
  });



  test('Diagnose: Dame nicht tauschen bei Angriff', () {
    final state = TestPositions.queenTradeBadDuringAttack();

    diagnosePosition(
      title: 'DAME NICHT TAUSCHEN BEI ANGRIFF',
      state: state,
      depth: 5,
    );
  });

  test('Diagnose: Turmtausch bei Materialvorteil', () {
    final state = TestPositions.rookTradeWhenAhead();

    diagnosePosition(
      title: 'TURMTAUSCH BEI MATERIALVORTEIL',
      state: state,
      depth: 5,
    );
  });

  test('KI tauscht Türme bei Materialvorteil', () {
    final engine = createEngine();
    final state = TestPositions.rookTradeWhenAhead();

    final move = searchMove(
      engine: engine,
      state: state,
      depth: 5,
    );

    expect(move, isNotNull);
    expect(moveName(move!), 'd5e5');
  });


  test('Diagnose: Schlagabtausch gewinnt Material', () {
    final state = TestPositions.simpleExchangeWinsMaterial();

    diagnosePosition(
      title: 'SCHLAGABTAUSCH GEWINNT MATERIAL',
      state: state,
      depth: 4,
    );
  });

  test('KI wählt vorteilhaften Schlagabtausch', () {
    final engine = createEngine();
    final state = TestPositions.simpleExchangeWinsMaterial();

    final move = searchMove(
      engine: engine,
      state: state,
      depth: 4,
    );

    expect(move, isNotNull);
    expect(moveName(move!), 'd4e5');
  });


  test('Diagnose: aktive Figur nicht gegen passive tauschen', () {
    final state = TestPositions.activePieceShouldNotTradePassivePiece();

    diagnosePosition(
      title: 'AKTIVE FIGUR NICHT GEGEN PASSIVE TAUSCHEN',
      state: state,
      depth: 5,
    );
  });

  test('KI tauscht aktive Figur nicht gegen passive Figur', () {
    final engine = createEngine();
    final state = TestPositions.activePieceShouldNotTradePassivePiece();

    final move = searchMove(
      engine: engine,
      state: state,
      depth: 5,
    );

    expect(move, isNotNull);

    final name = moveName(move!);

    expect(
      name,
      isNot('e5c6'),
      reason:
      'Aktiver Springer auf e5 sollte nicht ohne Grund gegen passiven Springer auf c6 getauscht werden.',
    );
  });















  test('Diagnose: passive Figur gegen aktive Figur tauschen', () {
    final state = TestPositions.passivePieceShouldTradeActivePiece();

    diagnosePosition(
      title: 'PASSIVE FIGUR GEGEN AKTIVE FIGUR TAUSCHEN',
      state: state,
      depth: 5,
    );
  });

  test('KI tauscht passive Figur gegen aktive Figur', () {
    final engine = createEngine();
    final state = TestPositions.passivePieceShouldTradeActivePiece();

    final move = searchMove(
      engine: engine,
      state: state,
      depth: 5,
    );

    expect(move, isNotNull);

    expect(
      moveName(move!),
      'd3e5',
      reason:
      'Passive eigene Figur sollte aktive gegnerische Figur abtauschen.',
    );
  });



  test('Diagnose: Damentausch vermeiden wenn materiell hinten', () {
    final state = TestPositions.avoidQueenTradeWhenBehind();

    diagnosePosition(
      title: 'DAMENTAUSCH VERMEIDEN WENN HINTEN',
      state: state,
      depth: 4,
    );
  });

  test('Diagnose: Turmtausch vermeiden wenn materiell hinten', () {
    final state = TestPositions.avoidRookTradeWhenBehind();

    diagnosePosition(
      title: 'TURMTAUSCH VERMEIDEN WENN HINTEN',
      state: state,
      depth: 5,
    );
  });

  test('Diagnose: Damentausch wenn eigener König unsicher ist', () {
    final state = TestPositions.queenTradeWhenOwnKingUnsafe();

    diagnosePosition(
      title: 'DAMENTAUSCH WENN EIGENER KÖNIG UNSICHER',
      state: state,
      depth: 4,
    );
  });

  test('Diagnose: Verteidigerfigur nicht leichtfertig tauschen', () {
    final state = TestPositions.avoidTradeWhenDefenderNeeded();

    diagnosePosition(
      title: 'VERTEIDIGERFIGUR NICHT TAUSCHEN',
      state: state,
      depth: 5,
    );
  });

  test('Diagnose: schlechten Schlagabtausch vermeiden', () {
    final state = TestPositions.badExchangeLosesMaterial();

    diagnosePosition(
      title: 'SCHLECHTEN SCHLAGABTAUSCH VERMEIDEN',
      state: state,
      depth: 6,
    );
  });


  test('KI vermeidet Schlagabtausch der Material verliert', () {
    final engine = createEngine();
    final state = TestPositions.badExchangeLosesMaterial();

    final move = searchMove(
      engine: engine,
      state: state,
      depth: 4,
    );

    expect(move, isNotNull);

    expect(
      moveName(move!),
      isNot('d4e5'),
      reason: 'KI sollte keinen Schlagabtausch starten, der Material verliert.',
    );
  });


  test('Diagnose: Schlagfolge Dame nimmt Turm und danach Turm nimmt Dame', () {
    final state = TestPositions.schlagen();

    diagnosePosition(
      title: 'SCHLAGFOLGE DAME NIMMT TURM',
      state: state,
      depth: 4,
      showMoves: 50,
    );
  });

  test('KI erkennt Schlagfolge Dame nimmt Turm und danach Turm nimmt Dame', () {
    final engine = createEngine();
    final state = TestPositions.schlagen();

    final move = searchMove(
      engine: engine,
      state: state,
      depth: 4,
    );

    expect(move, isNotNull);

    expect(
      moveName(move!),
      'd3g3',
      reason:
      'Weiß sollte Dg3 spielen: Dame schlägt Turm, danach Sxg3 und Te6 gewinnt die schwarze Dame.',
    );
  });

}