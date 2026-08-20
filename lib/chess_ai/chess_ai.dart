import 'package:schach/chess_ai/services/opening_book.dart';
import 'package:schach/chess_ai/services/opening_book_service.dart';
import 'ai_game_state.dart';
import 'ai_move.dart';
import 'board_evaluator.dart';
import 'board_helper.dart';
import 'minimax_engine.dart';
import 'move_generator.dart';
import 'move_ordering.dart';
import 'transposition_table.dart';

class ChessAi {
  final MoveGenerator moveGenerator = MoveGenerator();
  final BoardEvaluator evaluator = BoardEvaluator();
  late final MoveOrdering moveOrdering = MoveOrdering(evaluator);
  final TranspositionTable transpositionTable = TranspositionTable();

  final openingBookService = OpeningBookService();

  late final MinimaxEngine minimaxEngine = MinimaxEngine(
    moveGenerator: moveGenerator,
    evaluator: evaluator,
    moveOrdering: moveOrdering,
    transpositionTable: transpositionTable,
  );


  AiMove? getBestMove({
    required AiGameState state,
    required List<String> moveHistory,
    int timeLimitMs = 4000,
    int aiLevel = 5,
    OpeningStyle style = OpeningStyle.balanced,
  }) {
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("🤖 KI-Berechnung gestartet");
    print("TT: ${transpositionTable.size}");

    final AiMove? bookMove = openingBookService.findBookMove(
      state: state,
      moveHistory: moveHistory,
      moveGenerator: moveGenerator,
      moveOrdering: moveOrdering,
      aiLevel: aiLevel,
      style: style,
    );

    if (bookMove != null) {
      print("📖 KI spielt Eröffnungsbuchzug");
      return bookMove;
    }

    transpositionTable.nextGeneration();

    timeLimitMs = _dynamicTimeLimit(
      state: state,
      aiLevel: aiLevel,
      fallback: timeLimitMs,
    );

    print("Zeitlimit: $timeLimitMs ms");

    final Stopwatch stopwatch = Stopwatch()..start();

    AiMove? bestMove;

    /*
   * Roher Minimax-Wert des aktuell gespeicherten bestMove.
   *
   * Dieser Wert ist wichtig, damit Matt und Remis immer
   * zum tatsächlich gespeicherten Zug gehören.
   */
    int? bestMoveSearchScore;

    final int maxDepth = calculateMaxDepth(
      state.board,
    );

    print("MaxDepth: $maxDepth");

    /*
   * TT normalerweise nicht zwischen den Tiefen leeren.
   * Nur für spezielle Diagnosezwecke auf true setzen.
   */
    const bool clearTtBeforeEveryDepth = false;

    /*
   * Bewertung aus Sicht von Weiß:
   *
   * positiv = Weiß steht besser
   * negativ = Schwarz steht besser
   */
    final int rootPositionEval =
    evaluator.evaluate(state.board);

    final bool aiClearlyBehind =
    state.isWhiteTurn
        ? rootPositionEval <= -150
        : rootPositionEval >= 150;

    for (int depth = 1; depth <= maxDepth; depth++) {
      if (stopwatch.elapsedMilliseconds >= timeLimitMs) {
        break;
      }

      if (clearTtBeforeEveryDepth) {
        print(
          "🧹 TT vor Tiefe $depth leeren | "
              "Einträge: ${transpositionTable.size}",
        );

        transpositionTable.clear();
      }

      /*
     * Vollständiges Alpha-Beta-Fenster.
     *
     * Aspiration bleibt vorerst deaktiviert, weil die starken
     * nachträglichen Root-Heuristiken mit engen Bounds keine
     * zuverlässige Root-Zugauswahl erlauben.
     */
      final RootSearchResult? result =
      minimaxEngine.findBestMoveTimedResult(
        state: state,
        depth: depth,
        stopwatch: stopwatch,
        timeLimitMs: timeLimitMs,
        alpha: -MinimaxEngine.infinity,
        beta: MinimaxEngine.infinity,
      );

      /*
     * Die aktuelle Tiefe wurde nicht vollständig abgeschlossen.
     * Der Zug aus der letzten vollständig beendeten Tiefe bleibt.
     */
      if (result == null) {
        print(
          "⏱️ Tiefe $depth nicht vollständig abgeschlossen "
              "-> letzter vollständiger Zug bleibt erhalten",
        );

        break;
      }

      final AiMove resultMove = result.move;

      /*
     * Der von der Root-Suche ausgewählte Zug wird mit seinem
     * adjustedScore gespeichert.
     */
      final AiMove adjustedMove = AiMove(
        fromIndex: resultMove.fromIndex,
        toIndex: resultMove.toIndex,
        piece: resultMove.piece,
        promotionPiece: resultMove.promotionPiece,
        score: result.adjustedScore,
      );

      final bool oldIsImportantCapture =
          bestMove != null &&
              _isImportantCapture(
                state,
                bestMove,
              );

      final bool newIsImportantCapture =
      _isImportantCapture(
        state,
        adjustedMove,
      );

      /*
     * Die Capture-Stabilisierung gehört zur Root-Zugauswahl.
     * Deshalb werden hier die adjustedScores verglichen.
     */
      final bool newMoveClearlyBetter =
          bestMove == null ||
              (state.isWhiteTurn
                  ? result.adjustedScore >=
                  bestMove.score + 250
                  : result.adjustedScore <=
                  bestMove.score - 250);

      /*
     * Rettungsremis immer anhand des rohen Minimax-Werts
     * des tatsächlich ausgewählten Zuges erkennen.
     */
      final bool newMoveIsSavingDraw =
          aiClearlyBehind &&
              result.moveSearchScore == 0;

      final bool keepOldImportantCapture =
          bestMove != null &&
              oldIsImportantCapture &&
              !newIsImportantCapture &&
              !newMoveClearlyBetter &&
              !newMoveIsSavingDraw;

      if (keepOldImportantCapture) {
        print(
          "🛡️ Wichtiger Capture bleibt erhalten | "
              "Alt: ${bestMove.fromIndex}->${bestMove.toIndex} "
              "Adjusted=${bestMove.score} | "
              "Neu: ${adjustedMove.fromIndex}->"
              "${adjustedMove.toIndex} "
              "MoveSearch=${result.moveSearchScore} | "
              "BestSearch=${result.bestSearchScore} | "
              "Adjusted=${result.adjustedScore}",
        );

        /*
       * bestMove und bestMoveSearchScore gehören zusammen.
       * Deshalb darf der Suchwert des verworfenen neuen Zuges
       * hier nicht übernommen werden.
       */
      } else {
        if (newMoveIsSavingDraw) {
          print(
            "🤝 Rettungsremis übernimmt bisherigen Zug | "
                "${adjustedMove.fromIndex}->"
                "${adjustedMove.toIndex} | "
                "MoveSearchScore=${result.moveSearchScore}",
          );
        }

        bestMove = adjustedMove;
        bestMoveSearchScore = result.moveSearchScore;
      }

      print(
        "✅ Iterative Deepening Tiefe $depth fertig | "
            "Move: ${adjustedMove.fromIndex} -> "
            "${adjustedMove.toIndex} | "
            "MoveSearchScore: ${result.moveSearchScore} | "
            "BestSearchScore: ${result.bestSearchScore} | "
            "AdjustedScore: ${result.adjustedScore} | "
            "Gespeichert: "
            "${bestMove?.fromIndex} -> "
            "${bestMove?.toIndex} | "
            "Gespeicherter SearchScore: "
            "${bestMoveSearchScore ?? 'unbekannt'} | "
            "Zeit: ${stopwatch.elapsedMilliseconds} ms",
      );

      /*
     * Nur wegen des aktuell untersuchten Zuges abbrechen,
     * wenn dieser Zug auch tatsächlich als bestMove übernommen
     * wurde. Ein Mattzug darf nicht zum Abbruch führen, wenn die
     * Capture-Stabilisierung stattdessen den alten Zug behält.
     */
      final bool currentMoveWasStored =
          bestMove != null &&
              bestMove.fromIndex == adjustedMove.fromIndex &&
              bestMove.toIndex == adjustedMove.toIndex &&
              bestMove.promotionPiece ==
                  adjustedMove.promotionPiece;

      final bool currentMoveIsMate =
          result.moveSearchScore.abs() >
              MinimaxEngine.mateScore - 10000;

      if (currentMoveWasStored && currentMoveIsMate) {
        final bool winningMate =
            (state.isWhiteTurn &&
                result.moveSearchScore > 0) ||
                (!state.isWhiteTurn &&
                    result.moveSearchScore < 0);

        final int mateDistance =
            MinimaxEngine.mateScore -
                result.moveSearchScore.abs();

        if (winningMate) {
          print(
            "🏁 Gewinnende Mattlinie erkannt | "
                "MoveSearchScore: ${result.moveSearchScore} | "
                "Distanzwert: $mateDistance | "
                "Suche bis Tiefe $depth",
          );
        } else {
          print(
            "⚠️ Verlorene erzwungene Mattlinie erkannt | "
                "MoveSearchScore: ${result.moveSearchScore} | "
                "Distanzwert: $mateDistance | "
                "Suche bis Tiefe $depth",
          );
        }

        break;
      }
    }

    stopwatch.stop();

    print(
      "🏁 KI fertig | "
          "Zeit: ${stopwatch.elapsedMilliseconds} ms | "
          "TT: ${transpositionTable.size}",
    );

    if (bestMove != null) {
      print(
        "Bester Zug: "
            "${bestMove.fromIndex} -> "
            "${bestMove.toIndex} | "
            "AdjustedScore: ${bestMove.score} | "
            "MoveSearchScore: "
            "${bestMoveSearchScore ?? 'unbekannt'}",
      );
    }

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    return bestMove;
  }

  int calculateMaxDepth(List<int> board) {
    final int pieces = board.where((piece) => piece != 0).length;

    if (pieces <= 5) return 12;
    if (pieces <= 8) return 11;
    if (pieces <= 12) return 10;
    if (pieces <= 16) return 9;
    if (pieces <= 24) return 8;

    return 7;
  }

  int _baseTimeLimitForLevel(int aiLevel, int fallback) {
    if (aiLevel <= 1) return 1000;
    if (aiLevel == 2) return 2000;
    if (aiLevel == 3) return 4000;
    if (aiLevel == 4) return 6000;
    return 8000;
  }

  int _dynamicTimeLimit({
    required AiGameState state,
    required int aiLevel,
    required int fallback,
  }) {
    int time = _baseTimeLimitForLevel(aiLevel, fallback);

    final int moveCount =
        moveGenerator.getAllLegalAiMoves(state: state).length;

    final int pieces = state.board.where((p) => p != 0).length;

    if (moveCount <= 3) {
      time = (time * 0.60).round();
    } else if (moveCount <= 8) {
      time = (time * 0.80).round();
    } else if (moveCount >= 35) {
      time = (time * 1.25).round();
    }

    if (pieces <= 8) {
      time = (time * 1.30).round();
    } else if (pieces <= 14) {
      time = (time * 1.15).round();
    }

    if (_kingInCheck(state)) {
      time = (time * 1.35).round();
    }

    if (time < 500) {
      time = 500;
    }

    if (time > 15000) {
      time = 15000;
    }

    print(
      "Zeitmanagement | "
          "Moves=$moveCount | "
          "Pieces=$pieces | "
          "Zeit=$time ms",
    );

    return time;
  }

  bool _kingInCheck(AiGameState state) {
    final int? whiteKingIndex = BoardHelper.getKingIndex(state.board, true);
    final int? blackKingIndex = BoardHelper.getKingIndex(state.board, false);

    if (whiteKingIndex == null || blackKingIndex == null) {
      return false;
    }

    return moveGenerator.isKingInCheck(
      state: state,
      isWhiteKing: state.isWhiteTurn,
      whiteKingIndex: whiteKingIndex,
      blackKingIndex: blackKingIndex,
    );
  }

  bool _isImportantCapture(AiGameState state, AiMove move) {
    final int captured = state.board[move.toIndex];

    if (captured == 0) {
      return false;
    }

    final int capturedValue = evaluator.pieceValue(captured).abs();

    return capturedValue >= 500;
  }

}