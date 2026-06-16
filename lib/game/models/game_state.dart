import 'package:schach/components/Move Infos.dart';
import 'package:schach/components/Schachfigur.dart';

class GameState {

  // Spielerfarbe
  bool figurenfarbe;


  // GUI-Schachbrett
  List<List<Schachfigur?>> brett;

  // Schnelle Array-Darstellung für KI
  List<int> brettArray;

  // Wer ist am Zug
  bool isWhiteTurn;


  // Letzter Zug (En Passant, Hervorhebung)
  MoveInfos? moveInfos;


  // Historie der Züge (UCI)
  List<String> moveHistory;


  // Königpositionen
  List<int> whiteKingPosition;
  List<int> blackKingPosition;


  // Geschlagene Figuren für Anzeige
  List<Schachfigur> whiteCaptured;
  List<Schachfigur> blackCaptured;


  // Remisregeln
  int halfmoveClock;
  List<int> positionHistoryKeys;


  GameState({
    required this.figurenfarbe,
    required this.brett,
    required this.brettArray,
    required this.isWhiteTurn,
    required this.moveInfos,
    required this.moveHistory,
    required this.whiteKingPosition,
    required this.blackKingPosition,
    required this.whiteCaptured,
    required this.blackCaptured,
    required this.halfmoveClock,
    required this.positionHistoryKeys,
  });


  /// Leeres Spiel erzeugen
  factory GameState.empty({
    required bool figurenfarbe,
  }) {
    return GameState(
      figurenfarbe: figurenfarbe,
      brett: List.generate(8, (_) => List.generate(8, (_) => null)),
      brettArray: List.filled(64, 0),
      isWhiteTurn: true,
      moveInfos: null,
      moveHistory: [],
      whiteKingPosition: [7, 4],
      blackKingPosition: [0, 4],
      whiteCaptured: [],
      blackCaptured: [],
      halfmoveClock: 0,
      positionHistoryKeys: [],
    );
  }
}