import 'package:schach/chess_ai/ai_move.dart';
import 'package:schach/chess_ai/chess_ai.dart';
import 'package:schach/chess_ai/ai_game_state.dart';
import 'package:schach/components/Schachfigur.dart';
import 'package:schach/helper/helper.dart';
import 'package:schach/logic/ai_state_builder.dart';
import 'package:schach/logic/board_coordinate_mapper.dart';
import 'package:schach/chess_ai/board_helper.dart';
import '../models/game_state.dart';
import '../logic/move_executor.dart';
import '../logic/move_generator.dart';

class ComputerController {
  final ChessAi chessAi;
  final BoardCoordinateMapper mapper;
  final MoveGenerator moveGenerator;
  final MoveExecutor moveExecutor;

  final void Function(String text)? logKi;

  ComputerController({
    required this.chessAi,
    required this.mapper,
    required this.moveGenerator,
    required this.moveExecutor,
    this.logKi,
  });

  Future<ComputerMoveResult> computerMove({
    required GameState state,
    required bool figurenfarbe,
    required int spielModus,
    bool stopComputerVsComputer = false,
  }) async {
    if (stopComputerVsComputer) {
      return ComputerMoveResult.aborted("ComputerVsComputer wurde gestoppt.");
    }

    logKi?.call("KI Berechnung gestartet");

    final AiGameState aiState = AiStateBuilder.buildAiGameState(
      brettArray: state.brettArray,
      brett: state.brett,
      enemyMove: true,
      isWhiteTurn: state.isWhiteTurn,
      figurenfarbe: figurenfarbe,
      moveInfos: state.moveInfos,
      mapper: mapper,
      halfmoveClock: state.halfmoveClock,
      positionHistory: List<int>.from(state.positionHistoryKeys),
    );

    logKi?.call("AI State: ${aiState.debugString}");

    final AiMove? aiMove = chessAi.getBestMove(
      state: aiState,
      moveHistory: state.moveHistory,
    );

    if (aiMove == null) {
      return ComputerMoveResult.noMove();
    }

    final List<int> fromPos =
    mapper.aiIndexToGuiPosition(aiMove.fromIndex);

    final List<int> toPos =
    mapper.aiIndexToGuiPosition(aiMove.toIndex);

    final int fromRow = fromPos[0];
    final int fromCol = fromPos[1];
    final int toRow = toPos[0];
    final int toCol = toPos[1];

    logKi?.call(
      "Vorgeschlagener KI Zug: "
          "${mapper.koordinatenAnzeige(fromRow, fromCol)} -> "
          "${mapper.koordinatenAnzeige(toRow, toCol)}",
    );

    final Schachfigur? figur = state.brett[fromRow][fromCol];

    if (figur == null) {
      return ComputerMoveResult.illegal(
        "KI-Fehler: Auf dem Startfeld steht keine Figur.",
      );
    }

    final String? legalitaetsFehler = pruefeKiZugLegalitaet(
      state: state,
      aiMove: aiMove,
      figur: figur,
      fromRow: fromRow,
      fromCol: fromCol,
      toRow: toRow,
      toCol: toCol,
    );

    if (legalitaetsFehler != null) {
      return ComputerMoveResult.illegal(legalitaetsFehler);
    }

    logKi?.call("KI Zug akzeptiert");

    state.moveHistory.add(
      createUciMove(
        aiMove.fromIndex,
        aiMove.toIndex,
      ),
    );

    logKi?.call("History KI: ${state.moveHistory.last}");

    await warten(
      spielModus == -1
          ? const Duration(milliseconds: 2000)
          : const Duration(seconds: 1),
    );

    if (stopComputerVsComputer) {
      return ComputerMoveResult.aborted("Nach Wartezeit abgebrochen.");
    }

    moveExecutor.executeAiMove(
      state: state,
      aiMove: aiMove,
      fromRow: fromRow,
      fromCol: fromCol,
      toRow: toRow,
      toCol: toCol,
    );

    logKi?.call("KI Brett aktualisiert");

    return ComputerMoveResult.success(aiMove);
  }

  String? pruefeKiZugLegalitaet({
    required GameState state,
    required AiMove aiMove,
    required Schachfigur figur,
    required int fromRow,
    required int fromCol,
    required int toRow,
    required int toCol,
  }) {
    if (state.brett[fromRow][fromCol] == null) {
      return "Auf dem Startfeld ${mapper.koordinatenAnzeige(fromRow, fromCol)} steht keine Figur.";
    }

    if (moveExecutor.figurCode(figur.art) != aiMove.piece.abs()) {
      return "Die Figur auf ${mapper.koordinatenAnzeige(fromRow, fromCol)} passt nicht zum KI-Zug.";
    }

    final List<List<int>> erlaubteZuege =
    moveGenerator.calculateValidMoves(
      fromRow,
      fromCol,
      figur,
      true,
      state,
    );

    bool zugLegal = false;

    for (int i = 0; i < erlaubteZuege.length; i++) {
      final List<int> zug = erlaubteZuege[i];

      if (zug[0] == toRow && zug[1] == toCol) {
        zugLegal = true;
        break;
      }
    }

    if (!zugLegal) {
      return "${figur.toString()} darf nicht von "
          "${mapper.koordinatenAnzeige(fromRow, fromCol)} nach "
          "${mapper.koordinatenAnzeige(toRow, toCol)} ziehen.";
    }

    return null;
  }

  String createUciMove(
      int fromIndex,
      int toIndex,
      ) {
    return BoardHelper.indexToCoord(fromIndex) +
        BoardHelper.indexToCoord(toIndex);
  }
}

class ComputerMoveResult {
  final bool success;
  final bool gameEnded;
  final bool aborted;
  final bool illegalMove;
  final String? message;
  final AiMove? move;

  ComputerMoveResult({
    required this.success,
    required this.gameEnded,
    required this.aborted,
    required this.illegalMove,
    required this.message,
    required this.move,
  });

  factory ComputerMoveResult.success(AiMove move) {
    return ComputerMoveResult(
      success: true,
      gameEnded: false,
      aborted: false,
      illegalMove: false,
      message: null,
      move: move,
    );
  }

  factory ComputerMoveResult.noMove() {
    return ComputerMoveResult(
      success: false,
      gameEnded: true,
      aborted: false,
      illegalMove: false,
      message: "Keine legalen KI-Züge gefunden.",
      move: null,
    );
  }

  factory ComputerMoveResult.illegal(String message) {
    return ComputerMoveResult(
      success: false,
      gameEnded: true,
      aborted: false,
      illegalMove: true,
      message: message,
      move: null,
    );
  }

  factory ComputerMoveResult.aborted(String message) {
    return ComputerMoveResult(
      success: false,
      gameEnded: true,
      aborted: true,
      illegalMove: false,
      message: message,
      move: null,
    );
  }
}