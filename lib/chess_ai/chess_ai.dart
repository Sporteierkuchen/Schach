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

/*  print("State: ${state.debugString}");
    print("MoveHistory Strings: ${moveHistory.length}");
    print("HistoryKeys: ${state.positionHistory.length}");
    print("HalfmoveClock: ${state.halfmoveClock}");
    print("CurrentKey: ${state.zobristKey}");
    print("TT vor Clear: ${transpositionTable.size}");*/

/*    print("TT vor Clear: ${transpositionTable.size}");

    //transpositionTable.clear();

    print("TT nach Clear: ${transpositionTable.size}");*/

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

    final int maxDepth = calculateMaxDepth(state.board);

    print("MaxDepth: $maxDepth");

    int previousScore = 0;

    for (int depth = 1; depth <= maxDepth; depth++) {
      if (stopwatch.elapsedMilliseconds >= timeLimitMs) {
        break;
      }

      int window = depth <= 3 ? MinimaxEngine.infinity : 150;

      AiMove? move;

      while (true) {
        final int alpha = previousScore - window;
        final int beta = previousScore + window;

        move = minimaxEngine.findBestMoveTimed(
          state: state,
          depth: depth,
          stopwatch: stopwatch,
          timeLimitMs: timeLimitMs,
          alpha: alpha,
          beta: beta,
        );

        if (move == null) {
          break;
        }

        final bool isMateScore =
            move.score.abs() > MinimaxEngine.mateScore - 10000;

        if (isMateScore) {
          break;
        }

        if (stopwatch.elapsedMilliseconds >= timeLimitMs) {
          break;
        }

        final bool failLow = move.score <= alpha;
        final bool failHigh = move.score >= beta;

        if (!failLow && !failHigh) {
          break;
        }

        window *= 2;

        if (window >= MinimaxEngine.infinity ~/ 2) {
          break;
        }

        print(
          "🔁 Aspiration Retry Tiefe $depth | "
              "Score: ${move.score} | "
              "Neues Fenster: ±$window",
        );
      }

      if (move == null) {
        break;
      }

      final bool oldIsImportantCapture =
          bestMove != null && _isImportantCapture(state, bestMove);

      final bool newIsImportantCapture =
      _isImportantCapture(state, move);

      if (
      bestMove != null &&
          oldIsImportantCapture &&
          !newIsImportantCapture &&
          move.score < bestMove.score + 250
      ) {
        print(
          "🛡️ Wichtiger Capture bleibt erhalten | "
              "Alt: ${bestMove.fromIndex}->${bestMove.toIndex} "
              "Score=${bestMove.score} | "
              "Neu: ${move.fromIndex}->${move.toIndex} "
              "Score=${move.score}",
        );
      } else {
        bestMove = move;
        previousScore = move.score;
      }

      print(
        "✅ Iterative Deepening Tiefe $depth fertig | "
            "Move: ${move.fromIndex} -> ${move.toIndex} | "
            "Score: ${move.score} | "
            "Zeit: ${stopwatch.elapsedMilliseconds} ms",
      );

      if (move.score.abs() > MinimaxEngine.mateScore - 10000) {
        final bool winningMate =
            (state.isWhiteTurn && move.score > 0) ||
                (!state.isWhiteTurn && move.score < 0);

        final int mateDistance = MinimaxEngine.mateScore - move.score.abs();

        if (winningMate) {
          print(
            "🏁 Gewinnende Mattlinie erkannt | "
                "Score: ${move.score} | "
                "Distanzwert: $mateDistance | "
                "Suche bis Tiefe $depth",
          );
        } else {
          print(
            "⚠️ Verlorene erzwungene Mattlinie erkannt | "
                "Score: ${move.score} | "
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
        "Bester Zug: ${bestMove.fromIndex} -> ${bestMove.toIndex} | "
            "Score: ${bestMove.score}",
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