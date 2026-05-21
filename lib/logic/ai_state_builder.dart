
import '../chess_ai/ai_game_state.dart';
import '../components/Enums.dart';
import '../components/Move Infos.dart';
import '../components/Schachfigur.dart';
import 'board_coordinate_mapper.dart';

class AiStateBuilder {

  static AiGameState buildAiGameState({
    required List<int> brettArray,
    required List<List<Schachfigur?>> brett,

    required bool enemyMove,
    required bool isWhiteTurn,
    required bool figurenfarbe,

    required MoveInfos? moveInfos,

    required BoardCoordinateMapper mapper,
  }) {

    return AiGameState(
      board: List<int>.from(brettArray),

      isEnemyMove: enemyMove,

      isWhiteTurn: isWhiteTurn,

      playerIsWhite: figurenfarbe,

      enPassantTargetIndex:
      _getEnPassantTargetIndex(
        moveInfos,
        mapper,
      ),

      castlingRights:
      _getCastlingRights(
        brett,
      ),
    );
  }

  static int? _getEnPassantTargetIndex(
      MoveInfos? moveInfos,
      BoardCoordinateMapper mapper,
      ) {

    if (moveInfos == null) {
      return null;
    }

    final MoveInfos lastMove =
        moveInfos;

    if (lastMove.figur.art !=
        Schachfigurenart.BAUER) {

      return null;
    }

    final int rowDiff =
    (lastMove.oldRow -
        lastMove.newRow)
        .abs();

    if (rowDiff != 2) {
      return null;
    }

    final int targetRow =
        (lastMove.oldRow +
            lastMove.newRow) ~/
            2;

    final int targetCol =
        lastMove.oldCol;

    return mapper.guiToAiIndex(
      targetRow,
      targetCol,
    );
  }

  static AiCastlingRights
  _getCastlingRights(
      List<List<Schachfigur?>> brett,
      ) {

    return AiCastlingRights(

      whiteKingSide:
      _canCastleRight(
        brett,
        isWhite: true,
        kingSide: true,
      ),

      whiteQueenSide:
      _canCastleRight(
        brett,
        isWhite: true,
        kingSide: false,
      ),

      blackKingSide:
      _canCastleRight(
        brett,
        isWhite: false,
        kingSide: true,
      ),

      blackQueenSide:
      _canCastleRight(
        brett,
        isWhite: false,
        kingSide: false,
      ),
    );
  }

  static bool _canCastleRight(
      List<List<Schachfigur?>> brett, {

        required bool isWhite,
        required bool kingSide,
      }) {

    final List<int>? kingPos =
    _findKingPosition(
      brett,
      isWhite,
    );

    if (kingPos == null) {
      return false;
    }

    final Schachfigur? king =
    brett[
    kingPos[0]
    ][
    kingPos[1]
    ];

    if (king == null) {
      return false;
    }

    if (king.art !=
        Schachfigurenart.KOENIG) {

      return false;
    }

    // HIER GEÄNDERT
    if (king.hasMoved == true) {
      return false;
    }

    final int rookCol =
    kingSide
        ? 7
        : 0;

    final Schachfigur? rook =
    brett[
    kingPos[0]
    ][
    rookCol
    ];

    if (rook == null) {
      return false;
    }

    if (rook.art !=
        Schachfigurenart.TURM) {

      return false;
    }

    if (rook.istWeiss !=
        isWhite) {

      return false;
    }

    // HIER GEÄNDERT
    if (rook.hasMoved == true) {
      return false;
    }

    return true;
  }

  static List<int>?
  _findKingPosition(
      List<List<Schachfigur?>> brett,
      bool isWhite,
      ) {

    for (
    int row = 0;
    row < 8;
    row++
    ) {

      for (
      int col = 0;
      col < 8;
      col++
      ) {

        final Schachfigur? fig =
        brett[row][col];

        if (fig == null) {
          continue;
        }

        if (
        fig.art ==
            Schachfigurenart.KOENIG &&
            fig.istWeiss ==
                isWhite
        ) {

          return [
            row,
            col,
          ];
        }
      }
    }

    return null;
  }

  static void
  updateBrettArrayFromGuiBoard({

    required List<int> brettArray,

    required List<List<Schachfigur?>> brett,

    required BoardCoordinateMapper mapper,
  }) {

    for (
    int row = 0;
    row < 8;
    row++
    ) {

      for (
      int col = 0;
      col < 8;
      col++
      ) {

        final Schachfigur? fig =
        brett[row][col];

        final int aiIndex =
        mapper.guiToAiIndex(
          row,
          col,
        );

        if (fig == null) {

          brettArray[
          aiIndex
          ] = 0;

          continue;
        }

        int id =
        switch(fig.art){

          Schachfigurenart.BAUER => 1,

          Schachfigurenart.SPRINGER => 2,

          Schachfigurenart.LAEUFER => 3,

          Schachfigurenart.TURM => 4,

          Schachfigurenart.DAME => 5,

          Schachfigurenart.KOENIG => 6,
        };

        brettArray[
        aiIndex
        ] =
        fig.istWeiss
            ? id
            : -id;
      }
    }
  }

}