import 'package:schach/components/Enums.dart';
import 'package:schach/components/Schachfigur.dart';

class PositionValidationResult {
  final bool isValid;
  final String? message;

  const PositionValidationResult.valid()
      : isValid = true,
        message = null;

  const PositionValidationResult.invalid(this.message) : isValid = false;
}

class PositionValidator {
  PositionValidationResult validate({
    required List<List<Schachfigur?>> brett,
    required bool whiteToMove,
  }) {
    final int whiteKings = _countKings(brett, true);
    final int blackKings = _countKings(brett, false);

    if (whiteKings != 1) {
      return const PositionValidationResult.invalid(
        "Ungültige Stellung: Weiß muss genau einen König haben.",
      );
    }

    if (blackKings != 1) {
      return const PositionValidationResult.invalid(
        "Ungültige Stellung: Schwarz muss genau einen König haben.",
      );
    }

    if (_kingsTouch(brett)) {
      return const PositionValidationResult.invalid(
        "Ungültige Stellung: Die Könige dürfen nicht direkt nebeneinander stehen.",
      );
    }

    if (_hasPawnOnInvalidRank(brett)) {
      return const PositionValidationResult.invalid(
        "Ungültige Stellung: Bauern dürfen nicht auf der ersten oder letzten Reihe stehen.",
      );
    }

    if (_hasTooManyPawns(brett, true)) {
      return const PositionValidationResult.invalid(
        "Ungültige Stellung: Weiß hat mehr als 8 Bauern.",
      );
    }

    if (_hasTooManyPawns(brett, false)) {
      return const PositionValidationResult.invalid(
        "Ungültige Stellung: Schwarz hat mehr als 8 Bauern.",
      );
    }

    return const PositionValidationResult.valid();
  }

  int _countKings(List<List<Schachfigur?>> brett, bool isWhite) {
    int count = 0;

    for (final row in brett) {
      for (final fig in row) {
        if (fig != null &&
            fig.art == Schachfigurenart.KOENIG &&
            fig.istWeiss == isWhite) {
          count++;
        }
      }
    }

    return count;
  }

  bool _kingsTouch(List<List<Schachfigur?>> brett) {
    List<int>? whiteKing;
    List<int>? blackKing;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final fig = brett[row][col];

        if (fig == null || fig.art != Schachfigurenart.KOENIG) continue;

        if (fig.istWeiss) {
          whiteKing = [row, col];
        } else {
          blackKing = [row, col];
        }
      }
    }

    if (whiteKing == null || blackKing == null) return false;

    final int rowDiff = (whiteKing[0] - blackKing[0]).abs();
    final int colDiff = (whiteKing[1] - blackKing[1]).abs();

    return rowDiff <= 1 && colDiff <= 1;
  }

  bool _hasPawnOnInvalidRank(List<List<Schachfigur?>> brett) {
    for (int col = 0; col < 8; col++) {
      if (brett[0][col]?.art == Schachfigurenart.BAUER) return true;
      if (brett[7][col]?.art == Schachfigurenart.BAUER) return true;
    }

    return false;
  }

  bool _hasTooManyPawns(List<List<Schachfigur?>> brett, bool isWhite) {
    int count = 0;

    for (final row in brett) {
      for (final fig in row) {
        if (fig != null &&
            fig.art == Schachfigurenart.BAUER &&
            fig.istWeiss == isWhite) {
          count++;
        }
      }
    }

    return count > 8;
  }
}