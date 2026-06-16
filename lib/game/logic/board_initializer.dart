import 'package:schach/components/Enums.dart';
import 'package:schach/components/Schachfigur.dart';
import 'package:schach/logic/ai_state_builder.dart';
import 'package:schach/logic/board_coordinate_mapper.dart';

import '../models/game_state.dart';

class BoardInitializer {
  final BoardCoordinateMapper mapper;

  BoardInitializer({
    required this.mapper,
  });

  void createStartPosition(
      GameState state,
      bool figurenfarbe,
      ) {
    state.brett = List.generate(
      8,
          (_) => List.generate(8, (_) => null),
    );

    state.brettArray = List.filled(64, 0);

    final bool f = figurenfarbe;

    for (int i = 0; i < 8; i++) {
      placePiece(state, 1, i, Schachfigurenart.BAUER, !f, true);
      placePiece(state, 6, i, Schachfigurenart.BAUER, f, false);
    }

    placePiece(state, 0, 0, Schachfigurenart.TURM, !f, true, hasMoved: false);
    placePiece(state, 0, 7, Schachfigurenart.TURM, !f, true, hasMoved: false);
    placePiece(state, 7, 0, Schachfigurenart.TURM, f, false, hasMoved: false);
    placePiece(state, 7, 7, Schachfigurenart.TURM, f, false, hasMoved: false);

    placePiece(state, 0, 1, Schachfigurenart.SPRINGER, !f, true);
    placePiece(state, 0, 6, Schachfigurenart.SPRINGER, !f, true);
    placePiece(state, 7, 1, Schachfigurenart.SPRINGER, f, false);
    placePiece(state, 7, 6, Schachfigurenart.SPRINGER, f, false);

    placePiece(state, 0, 2, Schachfigurenart.LAEUFER, !f, true);
    placePiece(state, 0, 5, Schachfigurenart.LAEUFER, !f, true);
    placePiece(state, 7, 2, Schachfigurenart.LAEUFER, f, false);
    placePiece(state, 7, 5, Schachfigurenart.LAEUFER, f, false);

    if (f) {
      placePiece(state, 0, 3, Schachfigurenart.DAME, false, true);
      placePiece(state, 7, 3, Schachfigurenart.DAME, true, false);

      placePiece(state, 0, 4, Schachfigurenart.KOENIG, false, true, hasMoved: false);
      placePiece(state, 7, 4, Schachfigurenart.KOENIG, true, false, hasMoved: false);

      state.whiteKingPosition = [7, 4];
      state.blackKingPosition = [0, 4];
    } else {
      placePiece(state, 0, 4, Schachfigurenart.DAME, true, true);
      placePiece(state, 7, 4, Schachfigurenart.DAME, false, false);

      placePiece(state, 0, 3, Schachfigurenart.KOENIG, true, true, hasMoved: false);
      placePiece(state, 7, 3, Schachfigurenart.KOENIG, false, false, hasMoved: false);

      state.whiteKingPosition = [0, 3];
      state.blackKingPosition = [7, 3];
    }

    updateBrettArrayFromGuiBoard(state);
  }

  void placePiece(
      GameState state,
      int row,
      int col,
      Schachfigurenart art,
      bool istWeiss,
      bool isEnemy, {
        bool hasMoved = false,
      }) {
    final figur = Schachfigur(
      art: art,
      istWeiss: istWeiss,
      isEnemy: isEnemy,
      hasMoved: hasMoved,
    );

    state.brett[row][col] = figur;
  }

  void updateBrettArrayFromGuiBoard(GameState state) {
    AiStateBuilder.updateBrettArrayFromGuiBoard(
      brettArray: state.brettArray,
      brett: state.brett,
      mapper: mapper,
    );
  }

  List<int> findKingPosition(
      GameState state,
      bool isWhiteKing,
      ) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final Schachfigur? fig = state.brett[row][col];

        if (fig != null &&
            fig.art == Schachfigurenart.KOENIG &&
            fig.istWeiss == isWhiteKing) {
          return [row, col];
        }
      }
    }

    throw Exception(
      "König nicht gefunden: ${isWhiteKing ? "Weiß" : "Schwarz"}",
    );
  }
}