import 'package:schach/components/Schachfigur.dart';
import 'package:schach/components/Enums.dart';


import '../models/game_state.dart';
import 'move_generator.dart';

class GameEndChecker {
  final MoveGenerator moveGenerator;

  GameEndChecker({
    required this.moveGenerator,
  });

  bool isCheckMate(bool isWhiteKing, GameState state) {
    if (!moveGenerator.isKingInCheck(isWhiteKing, state)) {
      return false;
    }

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final Schachfigur? figur = state.brett[row][col];

        if (figur == null) {
          continue;
        }

        if (figur.istWeiss != isWhiteKing) {
          continue;
        }

        final List<List<int>> moves =
        moveGenerator.calculateValidMoves(
          row,
          col,
          figur,
          true,
          state,
        );

        if (moves.isNotEmpty) {
          return false;
        }
      }
    }

    return true;
  }

  bool isStaleMate(bool isWhiteKing, GameState state) {
    if (moveGenerator.isKingInCheck(isWhiteKing, state)) {
      return false;
    }

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final Schachfigur? figur = state.brett[row][col];

        if (figur == null) {
          continue;
        }

        if (figur.istWeiss != isWhiteKing) {
          continue;
        }

        final List<List<int>> moves =
        moveGenerator.calculateValidMoves(
          row,
          col,
          figur,
          true,
          state,
        );

        if (moves.isNotEmpty) {
          return false;
        }
      }
    }

    return true;
  }

  bool isFigurenMangel(GameState state) {
    int bauernCounter = 0;
    int blackSpringerCounter = 0;
    int whiteSpringerCounter = 0;
    int blackLaeuferCounter = 0;
    int whiteLaeuferCounter = 0;
    int turmCounter = 0;
    int dameCounter = 0;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final Schachfigur? figur = state.brett[row][col];

        if (figur == null) {
          continue;
        }

        if (figur.art == Schachfigurenart.KOENIG) {
          continue;
        }

        switch (figur.art) {
          case Schachfigurenart.BAUER:
            bauernCounter++;
            break;

          case Schachfigurenart.SPRINGER:
            if (figur.istWeiss) {
              whiteSpringerCounter++;
            } else {
              blackSpringerCounter++;
            }
            break;

          case Schachfigurenart.LAEUFER:
            if (figur.istWeiss) {
              whiteLaeuferCounter++;
            } else {
              blackLaeuferCounter++;
            }
            break;

          case Schachfigurenart.TURM:
            turmCounter++;
            break;

          case Schachfigurenart.DAME:
            dameCounter++;
            break;

          case Schachfigurenart.KOENIG:
            break;
        }
      }
    }

    final int minorPieces =
        whiteSpringerCounter +
            blackSpringerCounter +
            whiteLaeuferCounter +
            blackLaeuferCounter;

    if (bauernCounter > 0 || turmCounter > 0 || dameCounter > 0) {
      return false;
    }

    if (minorPieces <= 1) {
      return true;
    }

    if (minorPieces == 2) {
      if (whiteLaeuferCounter == 1 && blackLaeuferCounter == 1) {
        return true;
      }

      if (whiteSpringerCounter == 1 && blackSpringerCounter == 1) {
        return true;
      }

      if (whiteSpringerCounter == 1 && blackLaeuferCounter == 1) {
        return false;
      }

      if (blackSpringerCounter == 1 && whiteLaeuferCounter == 1) {
        return false;
      }

      return false;
    }

    if (minorPieces == 3) {
      if (whiteSpringerCounter == 2 && blackSpringerCounter == 0) {
        return true;
      }

      if (blackSpringerCounter == 2 && whiteSpringerCounter == 0) {
        return true;
      }

      return false;
    }

    return false;
  }

  bool isFiftyMoveRule(GameState state) {
    return state.halfmoveClock >= 100;
  }

  bool isThreefoldRepetition(GameState state) {
    if (state.positionHistoryKeys.isEmpty) {
      return false;
    }

    final int currentKey = state.positionHistoryKeys.last;
    int counter = 0;

    for (int i = 0; i < state.positionHistoryKeys.length; i++) {
      if (state.positionHistoryKeys[i] == currentKey) {
        counter++;
      }
    }

    return counter >= 3;
  }
}