import 'package:schach/chess_ai/ai_move.dart';
import 'package:schach/components/Move Infos.dart';
import 'package:schach/components/Schachfigur.dart';
import 'package:schach/components/Enums.dart';
import 'package:schach/logic/ai_state_builder.dart';
import 'package:schach/logic/board_coordinate_mapper.dart';
import '../models/game_state.dart';
import 'move_generator.dart';

class MoveExecutor {
  final BoardCoordinateMapper mapper;
  final MoveGenerator moveGenerator;
  final void Function(String text)? logSpiel;
  final void Function(String text)? logKi;

  MoveExecutor({
    required this.mapper,
    required this.moveGenerator,
    this.logSpiel,
    this.logKi,
  });

  void executeMove({
    required GameState state,
    required int fromRow,
    required int fromCol,
    required int toRow,
    required int toCol,
    required Schachfigur figur,
    Schachfigur? promotionFigur,
  }) {
    final bool wasCapture = state.brett[toRow][toCol] != null;

    int movedPieceCode = figur.istWeiss
        ? figurCode(figur.art)
        : -figurCode(figur.art);

    figurGeschlagenPruefung(
      state: state,
      newRow: toRow,
      newCol: toCol,
    );

    if (figur.art == Schachfigurenart.KOENIG) {
      checkKingMove(
        state: state,
        king: figur,
        newRow: toRow,
        newCol: toCol,
      );
    }

    if (figur.art == Schachfigurenart.TURM) {
      checkTurmMove(figur);
    }

    if (figur.art == Schachfigurenart.BAUER) {
      checkBauerMove(
        state: state,
        bauer: figur,
        row: fromRow,
        col: fromCol,
        newRow: toRow,
        newCol: toCol,
      );

      if (promotionFigur != null) {
        figur = promotionFigur;
        movedPieceCode = figur.istWeiss
            ? figurCode(figur.art)
            : -figurCode(figur.art);

        logSpiel?.call("Bauer umgewandelt zu $figur");
      }
    }

    state.moveInfos = MoveInfos(
      oldRow: fromRow,
      oldCol: fromCol,
      newRow: toRow,
      newCol: toCol,
      figur: Schachfigur(
        art: figur.art,
        istWeiss: figur.istWeiss,
        isEnemy: figur.isEnemy,
      ),
    );

    state.brett[toRow][toCol] = figur;
    state.brett[fromRow][fromCol] = null;

    AiStateBuilder.updateBrettArrayFromGuiBoard(
      brettArray: state.brettArray,
      brett: state.brett,
      mapper: mapper,
    );

    updateDrawHistoryAfterMove(
      state: state,
      movedPieceCode: movedPieceCode,
      wasCapture: wasCapture,
    );
  }

  void executeAiMove({
    required GameState state,
    required AiMove aiMove,
    required int fromRow,
    required int fromCol,
    required int toRow,
    required int toCol,
  }) {
    Schachfigur? figur = state.brett[fromRow][fromCol];

    if (figur == null) {
      return;
    }

    Schachfigur? promotionFigur;

    if (aiMove.promotionPiece != null) {
      promotionFigur = getSchachfigurFromCode(
        aiMove.promotionPiece!,
        figur.isEnemy,
        figur.istWeiss,
      );
    }

    executeMove(
      state: state,
      fromRow: fromRow,
      fromCol: fromCol,
      toRow: toRow,
      toCol: toCol,
      figur: figur,
      promotionFigur: promotionFigur,
    );
  }

  void checkKingMove({
    required GameState state,
    required Schachfigur king,
    required int newRow,
    required int newCol,
  }) {
    logSpiel?.call(
      "König bewegt: $king -> ${mapper.koordinatenAnzeige(newRow, newCol)}",
    );

    if (!king.isEnemy &&
        king.istWeiss &&
        isRochade(state.whiteKingPosition[1], newCol)) {
      if (isShortCastle(newCol)) {
        final Schachfigur rook = state.brett[7][7]!;
        state.brett[7][5] = rook;
        state.brett[7][7] = null;
      } else {
        final Schachfigur rook = state.brett[7][0]!;
        state.brett[7][3] = rook;
        state.brett[7][0] = null;
      }
    } else if (!king.isEnemy &&
        !king.istWeiss &&
        isRochade(state.blackKingPosition[1], newCol)) {
      if (isShortCastle(newCol)) {
        final Schachfigur rook = state.brett[7][0]!;
        state.brett[7][2] = rook;
        state.brett[7][0] = null;
      } else {
        final Schachfigur rook = state.brett[7][7]!;
        state.brett[7][4] = rook;
        state.brett[7][7] = null;
      }
    } else if (king.isEnemy &&
        king.istWeiss &&
        isRochade(state.whiteKingPosition[1], newCol)) {
      if (isShortCastle(newCol)) {
        final Schachfigur rook = state.brett[0][0]!;
        state.brett[0][2] = rook;
        state.brett[0][0] = null;
      } else {
        final Schachfigur rook = state.brett[0][7]!;
        state.brett[0][4] = rook;
        state.brett[0][7] = null;
      }
    } else if (king.isEnemy &&
        !king.istWeiss &&
        isRochade(state.blackKingPosition[1], newCol)) {
      if (isShortCastle(newCol)) {
        final Schachfigur rook = state.brett[0][7]!;
        state.brett[0][5] = rook;
        state.brett[0][7] = null;
      } else {
        final Schachfigur rook = state.brett[0][0]!;
        state.brett[0][3] = rook;
        state.brett[0][0] = null;
      }
    }

    king.hasMoved = true;

    if (king.istWeiss) {
      state.whiteKingPosition = [newRow, newCol];
    } else {
      state.blackKingPosition = [newRow, newCol];
    }
  }

  void checkBauerMove({
    required GameState state,
    required Schachfigur bauer,
    required int row,
    required int col,
    required int newRow,
    required int newCol,
  }) {
    if (moveGenerator.isEnPassantPossible(bauer, row, col, state) &&
        newCol == state.moveInfos!.newCol) {
      final Schachfigur? geschlagenerBauer =
      state.brett[state.moveInfos!.newRow][state.moveInfos!.newCol];

      if (geschlagenerBauer == null) {
        return;
      }

      if (geschlagenerBauer.istWeiss) {
        state.whiteCaptured.add(geschlagenerBauer);
      } else {
        state.blackCaptured.add(geschlagenerBauer);
      }

      state.brett[state.moveInfos!.newRow][state.moveInfos!.newCol] = null;

      logSpiel?.call("En Passant ausgeführt");
    }
  }

  void checkTurmMove(Schachfigur turm) {
    turm.hasMoved = true;
  }

  void figurGeschlagenPruefung({
    required GameState state,
    required int newRow,
    required int newCol,
  }) {
    final Schachfigur? figur = state.brett[newRow][newCol];

    if (figur == null) {
      return;
    }

    if (figur.istWeiss) {
      state.whiteCaptured.add(figur);
    } else {
      state.blackCaptured.add(figur);
    }
  }

  void updateDrawHistoryAfterMove({
    required GameState state,
    required int movedPieceCode,
    required bool wasCapture,
  }) {
    if (movedPieceCode.abs() == 1 || wasCapture) {
      state.halfmoveClock = 0;
    } else {
      state.halfmoveClock++;
    }

    final currentState = AiStateBuilder.buildAiGameState(
      brettArray: state.brettArray,
      brett: state.brett,
      enemyMove: true,
      isWhiteTurn: state.isWhiteTurn,
      figurenfarbe: state.figurenfarbe,
      moveInfos: state.moveInfos,
      mapper: mapper,
      halfmoveClock: state.halfmoveClock,
      positionHistory: List<int>.from(state.positionHistoryKeys),
    );

    state.positionHistoryKeys.add(currentState.zobristKey);

    logKi?.call(
      "DrawHistory aktualisiert | "
          "Keys=${state.positionHistoryKeys.length} | "
          "HalfmoveClock=${state.halfmoveClock}",
    );
  }

  int figurCode(Schachfigurenart art) {
    switch (art) {
      case Schachfigurenart.BAUER:
        return 1;
      case Schachfigurenart.SPRINGER:
        return 2;
      case Schachfigurenart.LAEUFER:
        return 3;
      case Schachfigurenart.TURM:
        return 4;
      case Schachfigurenart.DAME:
        return 5;
      case Schachfigurenart.KOENIG:
        return 6;
    }
  }

  Schachfigur getSchachfigurFromCode(
      int code,
      bool isEnemy,
      bool istWeiss,
      ) {
    final int absCode = code.abs();

    late Schachfigurenart art;

    switch (absCode) {
      case 1:
        art = Schachfigurenart.BAUER;
        break;
      case 2:
        art = Schachfigurenart.SPRINGER;
        break;
      case 3:
        art = Schachfigurenart.LAEUFER;
        break;
      case 4:
        art = Schachfigurenart.TURM;
        break;
      case 5:
        art = Schachfigurenart.DAME;
        break;
      case 6:
        art = Schachfigurenart.KOENIG;
        break;
      default:
        throw Exception("Unbekannter Figuren-Code: $code");
    }

    return Schachfigur(
      art: art,
      isEnemy: isEnemy,
      istWeiss: istWeiss,
      hasMoved: false,
    );
  }

  bool isRochade(int oldCol, int newCol) {
    return (oldCol - newCol).abs() == 2;
  }

  bool isShortCastle(int newCol) {
    return newCol == 1 || newCol == 6;
  }
}