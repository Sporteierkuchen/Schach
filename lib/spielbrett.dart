import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:schach/chess_ai/ai_move.dart';
import 'package:schach/chess_ai/chess_ai.dart';
import 'package:schach/components/Dialog.dart';
import 'package:schach/components/Move%20Infos.dart';
import 'package:schach/components/Schachfigur.dart';
import 'package:schach/components/Toast.dart';
import 'package:schach/components/feld.dart';
import 'package:schach/helper/helper.dart';
import 'package:schach/spielauswahl.dart';
import 'package:schach/values/colors.dart';

import 'chess_ai/ai_game_state.dart';
import 'chess_ai/board_helper.dart';
import 'components/Enums.dart';
import 'logic/ai_state_builder.dart';
import 'logic/board_coordinate_mapper.dart';

class SpielBrett extends StatefulWidget {
  final bool figurenfarbe;
  final int spielModus;
  final List<List<Schachfigur?>>? customBrett;
  final bool? customIsWhiteTurn;
  final MoveInfos? customMoveInfos;

  const SpielBrett({
    super.key,
    required this.figurenfarbe,
    required this.spielModus,
    this.customBrett,
    this.customIsWhiteTurn,
    this.customMoveInfos,
  });

  @override
  State<SpielBrett> createState() => _SpielBrettState();
}

class _SpielBrettState extends State<SpielBrett> {
  late bool figurenfarbe;
  late int spielModus;

  late BoardCoordinateMapper mapper;

  late List<List<Schachfigur?>> brett;
  late List<int> brettArray;

  Schachfigur? ausgewaehlteFigur;

  int selectedRow = -1;
  int selectedColumn = -1;

  List<List<int>> validMoves = [];

  final List<Schachfigur> weisseFigurenRaus = [];
  final List<Schachfigur> schwarzeFigurenRaus = [];

  bool isWhiteTurn = true;
  bool checkStatus = false;
  bool pause = false;

  MoveInfos? moveInfos;
  List<String> moveHistory = [];

  late List<int> whiteKingPosition;
  late List<int> blackKingPosition;

  final ChessAi chessAi = ChessAi();

  static const bool logSimulationen = false;

  bool _isDisposed = false;
  bool _stopComputerVsComputer = false;

  @override
  void dispose() {
    _isDisposed = true;
    _stopComputerVsComputer = true;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    figurenfarbe = widget.figurenfarbe;
    spielModus = widget.spielModus;

    mapper = BoardCoordinateMapper(
      figurenfarbe: figurenfarbe,
    );

    startNewGame();
  }

  Future<void> resetGame() async {
    Navigator.pop(context);
    startNewGame();
  }

  Future<void> startNewGame() async {
    logSpiel(
        "Neues Spiel gestartet | Farbe=${figurenfarbe ? "Weiß" : "Schwarz"} | Modus=$spielModus");

    setState(() {
      _startSpielbrett();
    });

    logSpiel("Brett initialisiert");

    if (!figurenfarbe && spielModus == 0) {
      logKi("Spieler Schwarz -> KI beginnt");

      await computerMove();

      isWhiteTurn = !isWhiteTurn;
    }

    if (spielModus == -1) {
      logKi("Computer vs Computer gestartet");

      computerVsComputer();
    }
  }

  Future<void> computerVsComputer() async {
    _stopComputerVsComputer = false;

    while (!_stopComputerVsComputer && mounted && !_isDisposed) {
      logKi("Neuer KI Zug | ${isWhiteTurn ? "Weiß" : "Schwarz"} am Zug");

      final bool gameEnded = await computerMove(
        enemyMove: figurenfarbe ? !isWhiteTurn : isWhiteTurn,
      );

      if (!mounted || _isDisposed || _stopComputerVsComputer) {
        logKi(
            "ComputerVsComputer gestoppt, weil SpielBrett nicht mehr aktiv ist.");
        return;
      }

      if (gameEnded) {
        logKi("ComputerVsComputer beendet");
        _stopComputerVsComputer = true;
      } else {
        isWhiteTurn = !isWhiteTurn;
      }
    }
  }

  void _startSpielbrett() {
    brett = List.generate(
      8,
      (_) => List.generate(8, (_) => null),
    );

    brettArray = List.filled(64, 0);

    checkStatus = false;
    pause = false;
    isWhiteTurn = true;
    moveInfos = widget.customMoveInfos;
    moveHistory.clear();

    ausgewaehlteFigur = null;
    selectedRow = -1;
    selectedColumn = -1;
    validMoves = [];

    weisseFigurenRaus.clear();
    schwarzeFigurenRaus.clear();

    if (widget.customBrett != null) {
      brett = widget.customBrett!;
      brettArray = List.filled(64, 0);
      AiStateBuilder.updateBrettArrayFromGuiBoard(
        brettArray: brettArray,
        brett: brett,
        mapper: mapper,
      );

      isWhiteTurn = widget.customIsWhiteTurn ?? true;

      whiteKingPosition = _findKingPosition(true);
      blackKingPosition = _findKingPosition(false);

      return;
    }

    _setupNormalBoard();

  }

  List<int> _findKingPosition(bool isWhiteKing) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final fig = brett[row][col];

        if (fig != null &&
            fig.art == Schachfigurenart.KOENIG &&
            fig.istWeiss == isWhiteKing) {
          return [row, col];
        }
      }
    }

    throw Exception(
        "König nicht gefunden: ${isWhiteKing ? "Weiß" : "Schwarz"}");
  }

  void _setupNormalBoard() {
    final bool f = figurenfarbe;

    for (int i = 0; i < 8; i++) {
      _platziereFigur(1, i, Schachfigurenart.BAUER, !f, true);
      _platziereFigur(6, i, Schachfigurenart.BAUER, f, false);
    }

    _platziereFigur(0, 0, Schachfigurenart.TURM, !f, true, hasMoved: false);
    _platziereFigur(0, 7, Schachfigurenart.TURM, !f, true, hasMoved: false);
    _platziereFigur(7, 0, Schachfigurenart.TURM, f, false, hasMoved: false);
    _platziereFigur(7, 7, Schachfigurenart.TURM, f, false, hasMoved: false);

    _platziereFigur(0, 1, Schachfigurenart.SPRINGER, !f, true);
    _platziereFigur(0, 6, Schachfigurenart.SPRINGER, !f, true);
    _platziereFigur(7, 1, Schachfigurenart.SPRINGER, f, false);
    _platziereFigur(7, 6, Schachfigurenart.SPRINGER, f, false);

    _platziereFigur(0, 2, Schachfigurenart.LAEUFER, !f, true);
    _platziereFigur(0, 5, Schachfigurenart.LAEUFER, !f, true);
    _platziereFigur(7, 2, Schachfigurenart.LAEUFER, f, false);
    _platziereFigur(7, 5, Schachfigurenart.LAEUFER, f, false);

    if (f) {
      _platziereFigur(0, 3, Schachfigurenart.DAME, false, true);
      _platziereFigur(7, 3, Schachfigurenart.DAME, true, false);

      _platziereFigur(
        0,
        4,
        Schachfigurenart.KOENIG,
        false,
        true,
        hasMoved: false,
      );

      _platziereFigur(
        7,
        4,
        Schachfigurenart.KOENIG,
        true,
        false,
        hasMoved: false,
      );

      whiteKingPosition = [7, 4];
      blackKingPosition = [0, 4];
    } else {
      _platziereFigur(0, 4, Schachfigurenart.DAME, true, true);
      _platziereFigur(7, 4, Schachfigurenart.DAME, false, false);

      _platziereFigur(
        0,
        3,
        Schachfigurenart.KOENIG,
        true,
        true,
        hasMoved: false,
      );

      _platziereFigur(
        7,
        3,
        Schachfigurenart.KOENIG,
        false,
        false,
        hasMoved: false,
      );

      whiteKingPosition = [0, 3];
      blackKingPosition = [7, 3];
    }
  }

  void _platziereFigur(
    int row,
    int col,
    Schachfigurenart art,
    bool istWeiss,
    bool isEnemy, {
    bool hasMoved = false,
  }) {
    final Schachfigur figur = Schachfigur(
      art: art,
      istWeiss: istWeiss,
      isEnemy: isEnemy,
      hasMoved: hasMoved,
    );

    brett[row][col] = figur;
    brettArray[mapper.guiToAiIndex(row, col)] =
        istWeiss ? _figurCode(art) : -_figurCode(art);
  }

  int _figurCode(Schachfigurenart art) {
    return switch (art) {
      Schachfigurenart.BAUER => 1,
      Schachfigurenart.SPRINGER => 2,
      Schachfigurenart.LAEUFER => 3,
      Schachfigurenart.TURM => 4,
      Schachfigurenart.DAME => 5,
      Schachfigurenart.KOENIG => 6,
    };
  }

  void figurAusgewaehlt(int row, int column) {
    setState(() {
      final Schachfigur? figur = brett[row][column];

      if (ausgewaehlteFigur == null && figur != null) {
        if (_darfFigurAuswaehlen(figur)) {
          _setAusgewaehlteFigur(row, column);
        }
      } else if (figur != null &&
          ausgewaehlteFigur != null &&
          figur.istWeiss == ausgewaehlteFigur!.istWeiss) {
        _setAusgewaehlteFigur(row, column);
      } else if (ausgewaehlteFigur != null &&
          _istGueltigesZielfeld(row, column)) {
        bewegeFigur(row, column);
      }

      if (ausgewaehlteFigur != null) {
        validMoves = calculateRealValidMoves(
          selectedRow,
          selectedColumn,
          ausgewaehlteFigur,
          true,
          brett,
          whiteKingPosition,
          blackKingPosition,
          moveInfos,
        );
      } else {
        validMoves = [];
      }
    });
  }

  bool _darfFigurAuswaehlen(Schachfigur figur) {
    if (pause) return false;
    if (figur.istWeiss != isWhiteTurn) return false;

    if (spielModus == 0) {
      return !figur.isEnemy;
    }

    if (spielModus == 1) {
      return true;
    }

    return false;
  }

  void _setAusgewaehlteFigur(
    int row,
    int column,
  ) {
    ausgewaehlteFigur = brett[row][column];

    selectedRow = row;
    selectedColumn = column;

    logSpiel("Figur ausgewählt: "
        "${brett[row][column]} "
        "${mapper.koordinatenAnzeige(row, column)}");
  }

  bool _istGueltigesZielfeld(int row, int column) {
    return validMoves.any(
      (element) => element[0] == row && element[1] == column,
    );
  }

  Future<void> bewegeFigur(int newRow, int newCol) async {
    if (ausgewaehlteFigur == null) return;

    final Schachfigur figur = ausgewaehlteFigur!;

    logSpiel("Spielerzug: "
        "$figur "
        "${mapper.koordinatenAnzeige(selectedRow, selectedColumn)}"
        " -> "
        "${mapper.koordinatenAnzeige(newRow, newCol)}");

    final int fromIndex =
    mapper.guiToAiIndex(
      selectedRow,
      selectedColumn,
    );

    final int toIndex =
    mapper.guiToAiIndex(
      newRow,
      newCol,
    );

    moveHistory.add(
      createUciMove(
        fromIndex,
        toIndex,
      ),
    );

    logSpiel(
      "History: "
          "${moveHistory.last}",
    );

    figurGeschlagenPruefung(newRow, newCol);

    if (figur.art == Schachfigurenart.KOENIG) {
      checkKingMove(figur, newRow, newCol);
    }

    if (figur.art == Schachfigurenart.TURM) {
      checkTurmMove(figur);
    }

    if (figur.art == Schachfigurenart.BAUER) {
      checkBauerMove(
        figur,
        selectedRow,
        selectedColumn,
        newRow,
        newCol,
      );

      if ((newRow == 7 && figur.isEnemy) || (newRow == 0 && !figur.isEnemy)) {
        Schachfigur? neueFigur;

        await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return DialogBauernUmwandlung(
              isWhite: figur.istWeiss,
              isEnemy: figur.isEnemy,
              onReturnValue: (value) {
                neueFigur = value;
              },
            );
          },
        );

        if (neueFigur != null) {
          ausgewaehlteFigur = neueFigur;
        }

        logSpiel("Bauer umgewandelt zu "
            "${neueFigur.toString()}");
      }
    }

    _setMoveInfos(
      selectedRow,
      selectedColumn,
      newRow,
      newCol,
      ausgewaehlteFigur!,
    );

    brett[newRow][newCol] = ausgewaehlteFigur;
    brett[selectedRow][selectedColumn] = null;

    setState(() {
      ausgewaehlteFigur = null;
      selectedRow = -1;
      selectedColumn = -1;
      validMoves = [];
    });

    AiStateBuilder.updateBrettArrayFromGuiBoard(
      brettArray: brettArray,
      brett: brett,
      mapper: mapper,
    );

    logSpiel("Brett aktualisiert");

    if (spielModus == 0) {
      if (!await checkSpielEnde()) {
        isWhiteTurn = !isWhiteTurn;

        logKi("KI wird gestartet");
        SchedulerBinding.instance.addPostFrameCallback((_) async {
          if (!await computerMove()) {
            isWhiteTurn = !isWhiteTurn;
          }
        });
      }
    } else if (spielModus == 1) {
      if (!await checkSpielEnde()) {
        isWhiteTurn = !isWhiteTurn;
      }
    }
  }

  void _setMoveInfos(
    int oldRow,
    int oldCol,
    int newRow,
    int newCol,
    Schachfigur figur,
  ) {
    moveInfos = MoveInfos(
      oldRow: oldRow,
      oldCol: oldCol,
      newRow: newRow,
      newCol: newCol,
      figur: Schachfigur(
        art: figur.art,
        istWeiss: figur.istWeiss,
        isEnemy: figur.isEnemy,
      ),
    );
  }

  void checkKingMove(
    Schachfigur king,
    int newRow,
    int newCol,
  ) {
    logSpiel("König bewegt: "
        "${king.toString()} "
        "-> ${mapper.koordinatenAnzeige(newRow, newCol)}");

    // Rochade prüfen

    if (!king.isEnemy &&
        king.istWeiss &&
        isRochade(whiteKingPosition[1], newCol)) {
      logSpiel("Weiße Rochade erkannt");

      if (isShortCastle(newCol)) {
        logSpiel("Weiße kurze Rochade");

        Schachfigur rochierterTurm = brett[7][7]!;

        brett[7][5] = rochierterTurm;

        brett[7][7] = null;
      } else {
        logSpiel("Weiße lange Rochade");

        Schachfigur rochierterTurm = brett[7][0]!;

        brett[7][3] = rochierterTurm;

        brett[7][0] = null;
      }
    } else if (!king.isEnemy &&
        !king.istWeiss &&
        isRochade(blackKingPosition[1], newCol)) {
      logSpiel("Schwarze Rochade erkannt");

      if (isShortCastle(newCol)) {
        logSpiel("Schwarze kurze Rochade");

        Schachfigur rochierterTurm = brett[7][0]!;

        brett[7][2] = rochierterTurm;

        brett[7][0] = null;
      } else {
        logSpiel("Schwarze lange Rochade");

        Schachfigur rochierterTurm = brett[7][7]!;

        brett[7][4] = rochierterTurm;

        brett[7][7] = null;
      }
    } else if (king.isEnemy &&
        king.istWeiss &&
        isRochade(whiteKingPosition[1], newCol)) {
      logSpiel("Gegner weiße Rochade erkannt");

      if (isShortCastle(newCol)) {
        logSpiel("Gegner weiße kurze Rochade");

        Schachfigur rochierterTurm = brett[0][0]!;

        brett[0][2] = rochierterTurm;

        brett[0][0] = null;
      } else {
        logSpiel("Gegner weiße lange Rochade");

        Schachfigur rochierterTurm = brett[0][7]!;

        brett[0][4] = rochierterTurm;

        brett[0][7] = null;
      }
    } else if (king.isEnemy &&
        !king.istWeiss &&
        isRochade(blackKingPosition[1], newCol)) {
      logSpiel("Gegner schwarze Rochade erkannt");

      if (isShortCastle(newCol)) {
        logSpiel("Gegner schwarze kurze Rochade");

        Schachfigur rochierterTurm = brett[0][7]!;

        brett[0][5] = rochierterTurm;

        brett[0][7] = null;
      } else {
        logSpiel("Gegner schwarze lange Rochade");

        Schachfigur rochierterTurm = brett[0][0]!;

        brett[0][3] = rochierterTurm;

        brett[0][0] = null;
      }
    }

    if (king.hasMoved == false) {
      king.hasMoved = true;

      logSpiel("King.hasMoved gesetzt");
    }

    if (king.istWeiss) {
      whiteKingPosition = [newRow, newCol];
    } else {
      blackKingPosition = [newRow, newCol];
    }

    logSpiel("Neue König Position gespeichert");
  }

  void checkBauerMove(
    Schachfigur bauer,
    int row,
    int col,
    int newRow,
    int newCol,
  ) {
    if (isEnPassantPosible(bauer, row, col, moveInfos) &&
        newCol == moveInfos!.newCol) {
      logSpiel("En Passant erkannt "
          "${bauer.toString()}");

      var geschlagenerBauer = brett[moveInfos!.newRow][moveInfos!.newCol];

      logSpiel("En Passant schlägt "
          "$geschlagenerBauer");

      if (geschlagenerBauer!.istWeiss) {
        weisseFigurenRaus.add(geschlagenerBauer);
      } else {
        schwarzeFigurenRaus.add(geschlagenerBauer);
      }

      brett[moveInfos!.newRow][moveInfos!.newCol] = null;

      logSpiel("En Passant abgeschlossen");
    }
  }

  void checkTurmMove(Schachfigur turm) {
    if (turm.hasMoved == false) {
      turm.hasMoved = true;

      logSpiel("Turm bewegt -> "
          "hasMoved=true");
    }
  }

  void figurGeschlagenPruefung(
    int newRow,
    int newCol,
  ) {
    if (brett[newRow][newCol] != null) {
      var figur = brett[newRow][newCol];

      logSpiel("Figur geschlagen: "
          "$figur "
          "${mapper.koordinatenAnzeige(newRow, newCol)}");

      if (figur!.istWeiss) {
        weisseFigurenRaus.add(figur);
      } else {
        schwarzeFigurenRaus.add(figur);
      }
    }
  }

  String fileLabelForGuiCol(int col) {
    const List<String> filesWhite = ["A", "B", "C", "D", "E", "F", "G", "H"];
    const List<String> filesBlack = ["H", "G", "F", "E", "D", "C", "B", "A"];

    return figurenfarbe ? filesWhite[col] : filesBlack[col];
  }

  String rankLabelForGuiRow(int row) {
    return figurenfarbe ? "${8 - row}" : "${row + 1}";
  }

  String squareLabelForGuiPosition(int row, int col) {
    return "${fileLabelForGuiCol(col)}${rankLabelForGuiRow(row)}";
  }

  Schachfigur getSchachfigurFromCode(
      int code,
      bool isEnemy,
      bool istWeiss,
      ) {
    final int absCode = code.abs();

    final Schachfigurenart art = switch (absCode) {
      1 => Schachfigurenart.BAUER,
      2 => Schachfigurenart.SPRINGER,
      3 => Schachfigurenart.LAEUFER,
      4 => Schachfigurenart.TURM,
      5 => Schachfigurenart.DAME,
      6 => Schachfigurenart.KOENIG,
      _ => throw Exception("Unbekannter Figuren-Code: $code"),
    };

    return Schachfigur(
      art: art,
      isEnemy: isEnemy,
      istWeiss: istWeiss,
      hasMoved: false,
    );
  }

  String createUciMove(
      int fromIndex,
      int toIndex,
      ) {
    return BoardHelper.indexToCoord(fromIndex) +
        BoardHelper.indexToCoord(toIndex);
  }

  //-------------------------------------------------------------------------------------------

  Future<bool> checkSpielEnde() async {
    logSpiel("Prüfe Spielende");

    if (isCheckMate(!isWhiteTurn)) {
      logSpiel("Schachmatt erkannt");

      String text = "";
      if (isWhiteTurn == figurenfarbe) {
        text = "Du hast gewonnen!";
      } else {
        if (figurenfarbe) {
          text = "Schwarz hat gewonnen!";
        } else {
          text = "Weiß hat gewonnen!";
        }
      }
      pause = true;
      await warten(const Duration(seconds: 4, milliseconds: 500));
      pause = false;

      if (!mounted) return true;

      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return DialogSpielende(
              spielende: Spielende.SCHACHMATT,
              isWhiteTurn: isWhiteTurn,
              figurenfarbe: figurenfarbe,
              text: text,
              onTapNochmal: () {
                resetGame();
              },
              onTapBack: () async {
                Navigator.pop(context);
                await Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SpielAuswahl()));
              });
        },
      );
      return true;
    } else if (isStaleMate(!isWhiteTurn)) {
      logSpiel("Patt erkannt");

      pause = true;
      await warten(const Duration(seconds: 4, milliseconds: 500));
      pause = false;

      if (!mounted) return true;

      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return DialogSpielende(
              spielende: Spielende.REMIS,
              isWhiteTurn: isWhiteTurn,
              figurenfarbe: figurenfarbe,
              text: "Unentschieden durch Patt!",
              onTapNochmal: () {
                resetGame();
              },
              onTapBack: () async {
                Navigator.pop(context);
                await Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SpielAuswahl()));
              });
        },
      );
      return true;
    } else if (isFigurenMangel()) {
      logSpiel("Figurenmangel erkannt");

      pause = true;
      await warten(const Duration(seconds: 4, milliseconds: 500));
      pause = false;

      if (!mounted) return true;

      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return DialogSpielende(
              spielende: Spielende.REMIS,
              isWhiteTurn: isWhiteTurn,
              figurenfarbe: figurenfarbe,
              text: "Unentschieden durch Figurenmangel!",
              onTapNochmal: () {
                resetGame();
              },
              onTapBack: () async {
                Navigator.pop(context);
                await Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SpielAuswahl()));
              });
        },
      );
      return true;
    }

    if (isKingInCheck(
        !isWhiteTurn, brett, whiteKingPosition, blackKingPosition, moveInfos)) {
      logSpiel("Schach erkannt");

      checkStatus = true;
      showWarning(
          context: context,
          text: "Schach!",
          duration: const Duration(seconds: 2));
    } else {
      checkStatus = false;
    }

    return false;
  }

  List<List<int>> calculateRealValidMoves(
    int row,
    int col,
    Schachfigur? schachfigur,
    bool checkSimulation,
    List<List<Schachfigur?>> brett,
    List<int> whiteKingPosition,
    List<int> blackKingPosition,
    MoveInfos? moveInfos,
  ) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves =
        calculateRawValidMoves(row, col, schachfigur, brett, moveInfos);

    if (checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];
        if (simulatedMoveIsSave(schachfigur!, row, col, endRow, endCol, brett,
            whiteKingPosition, blackKingPosition, moveInfos)) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }

    return realValidMoves;
  }

  bool simulatedMoveIsSave(
    Schachfigur figur,
    int startRow,
    int startCol,
    int endRow,
    int endCol,
    List<List<Schachfigur?>> brett,
    List<int> whiteKingPosition,
    List<int> blackKingPosition,
    MoveInfos? moveInfos,
  ) {
    logSimulation("Simulation: "
        "${figur.toString()} "
        "${mapper.koordinatenAnzeige(startRow, startCol)}"
        " -> "
        "${mapper.koordinatenAnzeige(endRow, endCol)}");

    Schachfigur? originalDestinationPiece = brett[endRow][endCol];

    List<int>? originalKingPosition;

    if (figur.art == Schachfigurenart.KOENIG) {
      logSimulation("König Simulation");

      originalKingPosition =
          figur.istWeiss ? whiteKingPosition : blackKingPosition;

      if (figur.istWeiss) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }

      if ((originalKingPosition[1] - endCol).abs() == 2) {
        logSimulation("Rochade Simulation");

        if (isKingInCheck(figur.istWeiss, brett, whiteKingPosition,
            blackKingPosition, moveInfos)) {
          logSimulation("Rochade verboten "
              "König steht im Schach");

          return false;
        }
      }
    }

    bool enPassantMove = false;

    Schachfigur? lastPawnWhoMoves2Felder;

    if (figur.art == Schachfigurenart.BAUER &&
        isEnPassantPosible(figur, startRow, startCol, moveInfos) &&
        moveInfos?.newCol == endCol) {
      logSimulation("En Passant Simulation");

      enPassantMove = true;

      lastPawnWhoMoves2Felder = brett[moveInfos!.newRow][moveInfos.newCol];

      brett[moveInfos.newRow][moveInfos.newCol] = null;
    }

    brett[endRow][endCol] = figur;

    brett[startRow][startCol] = null;

    bool kingInCheck = isKingInCheck(
        figur.istWeiss, brett, whiteKingPosition, blackKingPosition, moveInfos);

    logSimulation("Simulation Ergebnis "
        "KingInCheck="
        "$kingInCheck");

    brett[startRow][startCol] = figur;

    brett[endRow][endCol] = originalDestinationPiece;

    if (figur.art == Schachfigurenart.KOENIG) {
      if (figur.istWeiss) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }

    if (figur.art == Schachfigurenart.BAUER && enPassantMove) {
      brett[moveInfos!.newRow][moveInfos.newCol] = lastPawnWhoMoves2Felder;
    }

    logSimulation("Simulation Ende "
        "Legal="
        "${!kingInCheck}");

    return !kingInCheck;
  }

  bool isKingInCheck(
      bool isWhiteKing,
      List<List<Schachfigur?>> brett,
      List<int> whiteKingPosition,
      List<int> blackKingPosition,
      MoveInfos? moveInfos) {
    List<int> kingposition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (brett[i][j] == null || brett[i][j]!.istWeiss == isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves = calculateRealValidMoves(
            i,
            j,
            brett[i][j],
            false,
            brett,
            whiteKingPosition,
            blackKingPosition,
            moveInfos);
        if (pieceValidMoves.any((move) =>
            move[0] == kingposition[0] && move[1] == kingposition[1])) {
          return true;
        }
      }
    }

    return false;
  }

  List<List<int>> calculateRawValidMoves(
      int row,
      int col,
      Schachfigur? schachfigur,
      List<List<Schachfigur?>> brett,
      MoveInfos? moveInfos) {
    List<List<int>> canidateMoves = [];

    if (schachfigur == null) {
      return [];
    }

    int direction = schachfigur.isEnemy ? 1 : -1;

    switch (schachfigur.art) {
      case Schachfigurenart.BAUER:
        if (isInBoard(row + direction, col) &&
            brett[row + direction][col] == null) {
          canidateMoves.add([row + direction, col]);
        }

        if ((row == 1 && schachfigur.isEnemy) ||
            (row == 6 && !schachfigur.isEnemy)) {
          if (isInBoard(row + 2 * direction, col) &&
              brett[row + 2 * direction][col] == null &&
              brett[row + direction][col] == null) {
            canidateMoves.add([row + 2 * direction, col]);
          }
        }

        if (isInBoard(row + direction, col - 1) &&
            brett[row + direction][col - 1] != null &&
            brett[row + direction][col - 1]!.istWeiss != schachfigur.istWeiss) {
          canidateMoves.add([row + direction, col - 1]);
        }

        if (isInBoard(row + direction, col + 1) &&
            brett[row + direction][col + 1] != null &&
            brett[row + direction][col + 1]!.istWeiss != schachfigur.istWeiss) {
          canidateMoves.add([row + direction, col + 1]);
        }

        //en passant
        if (isEnPassantPosible(schachfigur, row, col, moveInfos)) {
          if (!schachfigur.isEnemy) {
            if (moveInfos?.newCol == col - 1) {
              canidateMoves.add([row + direction, col - 1]);
            } else {
              canidateMoves.add([row + direction, col + 1]);
            }
          } else {
            if (moveInfos?.newCol == col - 1) {
              canidateMoves.add([row + direction, col - 1]);
            } else {
              canidateMoves.add([row + direction, col + 1]);
            }
          }
        }

        break;
      case Schachfigurenart.SPRINGER:
        var knightMoves = [
          [-2, -1], // up 2 left 1
          [-2, 1], // up 2 right 1
          [-1, -2], // up 1 left 2
          [-1, 2], // up 1 right 2
          [1, -2], // down 1 left 2
          [1, 2], // down 1 right 2
          [2, -1], // down 2 left 1
          [2, 1], // down 2 right 1
        ];

        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];

          if (!isInBoard(newRow, newCol)) {
            continue;
          }

          if (brett[newRow][newCol] != null) {
            if (brett[newRow][newCol]!.istWeiss != schachfigur.istWeiss) {
              canidateMoves.add([newRow, newCol]); // capture
            }
            continue; // blocked
          }

          canidateMoves.add([newRow, newCol]);
        }
        break;

      case Schachfigurenart.LAEUFER:
        var directions = [
          [-1, -1], // up
          [-1, 1], // down
          [1, -1], //left
          [1, 1], //right
        ];

        for (var direction in directions) {
          var i = 1;

          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }

            if (brett[newRow][newCol] != null) {
              if (brett[newRow][newCol]!.istWeiss != schachfigur.istWeiss) {
                canidateMoves.add([newRow, newCol]); // capture
              }
              break; // block
            }

            canidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;

      case Schachfigurenart.TURM:
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], //left
          [0, 1], //right
        ];

        for (var direction in directions) {
          var i = 1;

          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }

            if (brett[newRow][newCol] != null) {
              if (brett[newRow][newCol]!.istWeiss != schachfigur.istWeiss) {
                canidateMoves.add([newRow, newCol]); // kill
              }

              break; // blocked
            }
            canidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case Schachfigurenart.DAME:
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (var direction in directions) {
          var i = 1;

          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }

            if (brett[newRow][newCol] != null) {
              if (brett[newRow][newCol]!.istWeiss != schachfigur.istWeiss) {
                canidateMoves.add([newRow, newCol]); // capture
              }
              break; // blocked
            }

            canidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case Schachfigurenart.KOENIG:

        var directions = [

          [-1,0],
          [1,0],

          [0,-1],
          [0,1],

          [-1,-1],
          [-1,1],

          [1,-1],
          [1,1],
        ];

        for (var direction in directions) {

          var newRow = row + direction[0];
          var newCol = col + direction[1];

          if (!isInBoard(newRow, newCol)) {
            continue;
          }

          if (brett[newRow][newCol] != null) {

            if (brett[newRow][newCol]!.istWeiss != schachfigur.istWeiss) {
              canidateMoves.add([newRow, newCol,]);
            }
            continue;
          }

          canidateMoves.add([newRow, newCol,]);
        }

        bool safeShort = _canCastleSafely(schachfigur, row, col, col + 2);

        bool safeLong = _canCastleSafely(schachfigur, row, col, col - 2);

        // kurze Rochade
        if (schachfigur.isEnemy && schachfigur.istWeiss && isShortCastlePossible(schachfigur, brett) && safeShort && row == 0 && col == 3) {

          canidateMoves.add([0, 1,]);

        } else if (schachfigur.isEnemy && !schachfigur.istWeiss && isShortCastlePossible(schachfigur, brett) && safeShort && row == 0 && col == 4) {

          canidateMoves.add([0, 6,]);

        } else if (!schachfigur.isEnemy && schachfigur.istWeiss && isShortCastlePossible(schachfigur, brett) && safeShort && row == 7 && col == 4) {

          canidateMoves.add([7, 6,]);

        } else if (!schachfigur.isEnemy && !schachfigur.istWeiss && isShortCastlePossible(schachfigur, brett) && safeShort && row == 7 && col == 3) {

          canidateMoves.add([7, 1,]);
        }

        // lange Rochade
        if (schachfigur.isEnemy && schachfigur.istWeiss && isLongCastlePossible(schachfigur, brett) && safeLong && row == 0 && col == 3) {

          canidateMoves.add([0, 5,]);

        } else if (schachfigur.isEnemy && !schachfigur.istWeiss && isLongCastlePossible(schachfigur, brett) && safeLong && row == 0 && col == 4) {

          canidateMoves.add([0, 2,]);

        } else if (!schachfigur.isEnemy && schachfigur.istWeiss && isLongCastlePossible(schachfigur, brett) && safeLong && row == 7 && col == 4) {

          canidateMoves.add([7, 2,]);

        } else if (!schachfigur.isEnemy && !schachfigur.istWeiss && isLongCastlePossible(schachfigur, brett) && safeLong && row == 7 && col == 3) {

          canidateMoves.add([7, 5,]);
        }

        break;
      default:
        return [];
    }

    return canidateMoves;
  }

  bool isEnPassantPosible(
      Schachfigur schachfigur, int row, int col, MoveInfos? moveInfos) {
    if (!schachfigur.isEnemy &&
        row == 3 &&
        moveInfos?.newRow == 3 &&
        (moveInfos?.newCol == col - 1 || moveInfos?.newCol == col + 1) &&
        moveInfos!.oldRow == 1 &&
        moveInfos.figur.art == Schachfigurenart.BAUER &&
        moveInfos.figur.isEnemy) {
      return true;
    }

    if (schachfigur.isEnemy &&
        row == 4 &&
        moveInfos?.newRow == 4 &&
        (moveInfos?.newCol == col - 1 || moveInfos?.newCol == col + 1) &&
        moveInfos!.oldRow == 6 &&
        moveInfos.figur.art == Schachfigurenart.BAUER &&
        !moveInfos.figur.isEnemy) {
      return true;
    }
    return false;
  }

  bool isShortCastlePossible(
      Schachfigur schachfigur, List<List<Schachfigur?>> brett) {
    if (schachfigur.isEnemy && !schachfigur.hasMoved!) {
      if (schachfigur.istWeiss &&
          brett[0][0] != null &&
          brett[0][0]!.art == Schachfigurenart.TURM &&
          !brett[0][0]!.hasMoved!) {
        //Weißer König Feind 0,3
        if (brett[0][2] == null && brett[0][1] == null) {
          return true;
        }
      } else if (!schachfigur.istWeiss &&
          brett[0][7] != null &&
          brett[0][7]!.art == Schachfigurenart.TURM &&
          !brett[0][7]!.hasMoved!) {
        //Schwarzer König Feind 0,4
        if (brett[0][5] == null && brett[0][6] == null) {
          return true;
        }
      }
    } else if (!schachfigur.isEnemy && !schachfigur.hasMoved!) {
      if (schachfigur.istWeiss &&
          brett[7][7] != null &&
          brett[7][7]!.art == Schachfigurenart.TURM &&
          !brett[7][7]!.hasMoved!) {
        //Weißer König Freund 7,4
        if (brett[7][5] == null && brett[7][6] == null) {
          return true;
        }
      } else if (!schachfigur.istWeiss &&
          brett[7][0] != null &&
          brett[7][0]!.art == Schachfigurenart.TURM &&
          !brett[7][0]!.hasMoved!) {
        //Schwarzer König Freund 7,3
        if (brett[7][2] == null && brett[7][1] == null) {
          return true;
        }
      }
    }

    return false;
  }

  bool isLongCastlePossible(
      Schachfigur schachfigur, List<List<Schachfigur?>> brett) {
    if (schachfigur.isEnemy && !schachfigur.hasMoved!) {
      if (schachfigur.istWeiss &&
          brett[0][7] != null &&
          brett[0][7]!.art == Schachfigurenart.TURM &&
          !brett[0][7]!.hasMoved!) {
        //Weißer König Feind 0,3
        if (brett[0][4] == null && brett[0][5] == null && brett[0][6] == null) {
          return true;
        }
      } else if (!schachfigur.istWeiss &&
          brett[0][0] != null &&
          brett[0][0]!.art == Schachfigurenart.TURM &&
          !brett[0][0]!.hasMoved!) {
        //Schwarzer König Feind 0,4
        if (brett[0][3] == null && brett[0][2] == null && brett[0][1] == null) {
          return true;
        }
      }
    } else if (!schachfigur.isEnemy && !schachfigur.hasMoved!) {
      if (schachfigur.istWeiss &&
          brett[7][0] != null &&
          brett[7][0]!.art == Schachfigurenart.TURM &&
          !brett[7][0]!.hasMoved!) {
        //Weißer König Freund 7,4
        if (brett[7][3] == null && brett[7][2] == null && brett[7][1] == null) {
          return true;
        }
      } else if (!schachfigur.istWeiss &&
          brett[7][7] != null &&
          brett[7][7]!.art == Schachfigurenart.TURM &&
          !brett[7][7]!.hasMoved!) {
        //Schwarzer König Freund 7,3
        if (brett[7][4] == null && brett[7][5] == null && brett[7][6] == null) {
          return true;
        }
      }
    }

    return false;
  }

  bool _canCastleSafely(Schachfigur king, int row, int fromCol, int toCol,) {
    if (!isInBoard(row, fromCol)) {
      return false;
    }

    if (!isInBoard(row, toCol)) {
      return false;
    }

    if (_isSquareControlledByOpponent(row, fromCol, king.istWeiss,)) {
      return false;
    }

    final int step = toCol > fromCol ? 1 : -1;

    int col = fromCol + step;

    while (col != toCol + step) {
      if (!isInBoard(row, col)) {
        return false;
      }

      if (_isSquareControlledByOpponent(row, col, king.istWeiss,)) {
        return false;
      }

      col += step;
    }

    return true;
  }

  bool _isSquareControlledByOpponent(int targetRow, int targetCol, bool isWhiteKing,) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final Schachfigur? figur = brett[row][col];

        if (figur == null) continue;
        if (figur.istWeiss == isWhiteKing) continue;

        if (_pieceControlsSquare(figur, row, col, targetRow, targetCol,)) {
          return true;
        }
      }
    }

    return false;
  }

  bool _pieceControlsSquare(Schachfigur figur, int row, int col, int targetRow, int targetCol,) {
    final int rowDiff = targetRow - row;
    final int colDiff = targetCol - col;

    switch (figur.art) {
      case Schachfigurenart.BAUER:
        final int direction = figur.isEnemy ? 1 : -1;

        return rowDiff == direction && colDiff.abs() == 1;

      case Schachfigurenart.SPRINGER:
        return (rowDiff.abs() == 2 && colDiff.abs() == 1) ||
            (rowDiff.abs() == 1 && colDiff.abs() == 2);

      case Schachfigurenart.KOENIG:
        return rowDiff.abs() <= 1 && colDiff.abs() <= 1;

      case Schachfigurenart.LAEUFER:
        if (rowDiff.abs() != colDiff.abs()) return false;

        return _pathClear(row, col, targetRow, targetCol,);

      case Schachfigurenart.TURM:
        if (row != targetRow && col != targetCol) return false;

        return _pathClear(row, col, targetRow, targetCol,);

      case Schachfigurenart.DAME:
        final bool diagonal = rowDiff.abs() == colDiff.abs();
        final bool straight = row == targetRow || col == targetCol;

        if (!diagonal && !straight) return false;

        return _pathClear(row, col, targetRow, targetCol,);
    }
  }

  bool _pathClear(int fromRow, int fromCol, int toRow, int toCol,) {
    if (!isInBoard(fromRow, fromCol)) {
      return false;
    }

    if (!isInBoard(toRow, toCol)) {
      return false;
    }

    final int rowStep = (toRow - fromRow).sign;
    final int colStep = (toCol - fromCol).sign;

    int row = fromRow + rowStep;
    int col = fromCol + colStep;

    while (row != toRow || col != toCol) {
      if (!isInBoard(row, col)) {
        return false;
      }

      if (brett[row][col] != null) {
        return false;
      }

      row += rowStep;
      col += colStep;
    }

    return true;
  }

  bool isCheckMate(bool isWhiteKing) {
    if (!isKingInCheck(
        isWhiteKing, brett, whiteKingPosition, blackKingPosition, moveInfos)) {
      return false;
    }

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (brett[i][j] == null || brett[i][j]!.istWeiss != isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves = calculateRealValidMoves(
            i,
            j,
            brett[i][j],
            true,
            brett,
            whiteKingPosition,
            blackKingPosition,
            moveInfos);
        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }

    return true;
  }

  bool isStaleMate(bool isWhiteKing) {
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (brett[i][j] == null || brett[i][j]!.istWeiss != isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves = calculateRealValidMoves(
            i,
            j,
            brett[i][j],
            true,
            brett,
            whiteKingPosition,
            blackKingPosition,
            moveInfos);
        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }

    return true;
  }

  bool isFigurenMangel() {
    int bauernCounter = 0;
    int blackSpringerCounter = 0;
    int whiteSpringerCounter = 0;
    int blackLaeuferCounter = 0;
    int whiteLaeuferCounter = 0;
    int turmCounter = 0;
    int dameCounter = 0;

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (brett[i][j] == null ||
            brett[i][j]!.art == Schachfigurenart.KOENIG) {
          continue;
        }

        Schachfigur? figur = brett[i][j];
        switch (figur!.art) {
          case Schachfigurenart.BAUER:
            bauernCounter++;
          case Schachfigurenart.SPRINGER:
            if (figur.istWeiss) {
              whiteSpringerCounter++;
            } else {
              blackSpringerCounter++;
            }
          case Schachfigurenart.LAEUFER:
            if (figur.istWeiss) {
              whiteLaeuferCounter++;
            } else {
              blackLaeuferCounter++;
            }
          case Schachfigurenart.TURM:
            turmCounter++;
          case Schachfigurenart.DAME:
            dameCounter++;
          default:
        }
      }
    }

    if (bauernCounter == 0 &&
        turmCounter == 0 &&
        dameCounter == 0 &&
        (whiteSpringerCounter +
                blackSpringerCounter +
                whiteLaeuferCounter +
                blackLaeuferCounter <=
            2)) {
      if (blackLaeuferCounter == 2 ||
          whiteLaeuferCounter == 2 ||
          whiteLaeuferCounter + whiteLaeuferCounter == 2 ||
          blackLaeuferCounter + blackSpringerCounter == 2) {
        return false;
      }

      return true;
    }

    if (bauernCounter == 0 &&
        turmCounter == 0 &&
        dameCounter == 0 &&
        (whiteSpringerCounter +
                blackSpringerCounter +
                whiteLaeuferCounter +
                blackLaeuferCounter ==
            3)) {
      if (blackSpringerCounter == 2 || whiteSpringerCounter == 2) {
        return true;
      }

      return false;
    }

    return false;
  }

  //--------------------------------------------------------------------------------------

  Future<bool> computerMove({bool? enemyMove}) async {
    enemyMove ??= true;

    if (!mounted || _isDisposed || _stopComputerVsComputer) {
      logKi("computerMove abgebrochen: SpielBrett ist nicht mehr aktiv.");
      return true;
    }

    logKi("KI Berechnung gestartet");

    final AiGameState aiState = AiStateBuilder.buildAiGameState(
      brettArray: brettArray,
      brett: brett,
      enemyMove: true,
      isWhiteTurn: isWhiteTurn,
      figurenfarbe: figurenfarbe,
      moveInfos: moveInfos,
      mapper: mapper,
    );

    logKi("AI State: ${aiState.debugString}");

    final AiMove? aiMove = chessAi.getBestMove(
      state: aiState,
      moveHistory: moveHistory,
    );

    if (!mounted || _isDisposed || _stopComputerVsComputer) {
      logKi("computerMove nach KI-Berechnung abgebrochen.");
      return true;
    }

    if (aiMove == null) {
      logKi("Keine Züge gefunden");
      return true;
    }

    final List<int> fromPos = mapper.aiIndexToGuiPosition(aiMove.fromIndex);
    final List<int> toPos = mapper.aiIndexToGuiPosition(aiMove.toIndex);

    final int fromRow = fromPos[0];
    final int fromCol = fromPos[1];
    final int toRow = toPos[0];
    final int toCol = toPos[1];

    logKi(
      "Vorgeschlagener KI Zug: "
      "${mapper.koordinatenAnzeige(fromRow, fromCol)} -> "
      "${mapper.koordinatenAnzeige(toRow, toCol)}",
    );

    Schachfigur? figur = brett[fromRow][fromCol];

    if (figur == null) {
      const String fehler = "KI-Fehler: Keine Figur auf dem Startfeld.";
      logKi("FEHLER: Keine Figur auf Startfeld");

      if (mounted && !_isDisposed) {
        showInfo(context: context, text: fehler);
      }

      return true;
    }

    final String? legalitaetsFehler = pruefeKiZugLegalitaet(
      aiMove: aiMove,
      figur: figur,
      fromRow: fromRow,
      fromCol: fromCol,
      toRow: toRow,
      toCol: toCol,
    );

    if (legalitaetsFehler != null) {
      logKi("KI Zug abgelehnt");
      logKi(legalitaetsFehler);

      if (mounted && !_isDisposed) {
        showInfo(context: context, text: legalitaetsFehler);
      }

      return true;
    }

    logKi("KI Zug akzeptiert");

    moveHistory.add(
      createUciMove(
        aiMove.fromIndex,
        aiMove.toIndex,
      ),
    );

    logKi(
      "History KI: ${moveHistory.last}",
    );

    await warten(
      spielModus == -1
          ? const Duration(milliseconds: 2000)
          : const Duration(seconds: 1),
    );

    if (!mounted || _isDisposed || _stopComputerVsComputer) {
      logKi("computerMove nach Wartezeit abgebrochen.");
      return true;
    }

    figurGeschlagenPruefung(toRow, toCol);

    logKi(
      "Computer bewegt: ${figur.toString()} von "
      "${mapper.koordinatenAnzeige(fromRow, fromCol)} zu "
      "${mapper.koordinatenAnzeige(toRow, toCol)}",
    );

    if (figur.art == Schachfigurenart.KOENIG) {
      checkKingMove(figur, toRow, toCol);
    }

    if (figur.art == Schachfigurenart.TURM) {
      checkTurmMove(figur);
    }

    if (figur.art == Schachfigurenart.BAUER) {
      checkBauerMove(
        figur,
        fromRow,
        fromCol,
        toRow,
        toCol,
      );

      if (aiMove.promotionPiece != null) {
        figur = getSchachfigurFromCode(
          aiMove.promotionPiece!,
          figur.isEnemy,
          figur.istWeiss,
        );

        logKi("KI Bauer umgewandelt");
      }
    }

    moveInfos = MoveInfos(
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

    brett[toRow][toCol] = figur;
    brett[fromRow][fromCol] = null;

    AiStateBuilder.updateBrettArrayFromGuiBoard(
      brettArray: brettArray,
      brett: brett,
      mapper: mapper,
    );

    logKi("KI Brett aktualisiert");

    if (!mounted || _isDisposed || _stopComputerVsComputer) {
      logKi("setState übersprungen: SpielBrett nicht mehr aktiv.");
      return true;
    }

    setState(() {});

    if (!mounted || _isDisposed || _stopComputerVsComputer) {
      logKi("checkSpielEnde übersprungen: SpielBrett nicht mehr aktiv.");
      return true;
    }

    return await checkSpielEnde();
  }

  String? pruefeKiZugLegalitaet({
    required AiMove aiMove,
    required Schachfigur figur,
    required int fromRow,
    required int fromCol,
    required int toRow,
    required int toCol,
  }) {
    logKi("Prüfe KI Zug");

    if (brett[fromRow][fromCol] == null) {
      return "Auf dem Startfeld ${mapper.koordinatenAnzeige(fromRow, fromCol)} steht keine Figur.";
    }

    if (_figurCode(figur.art) != aiMove.piece.abs()) {
      return "Die Figur auf ${mapper.koordinatenAnzeige(fromRow, fromCol)} passt nicht zum KI-Zug. "
          "Erwarteter Code: ${aiMove.piece}, gefunden: ${figur.toString()}.";
    }

    final List<List<int>> erlaubteZuege = calculateRealValidMoves(
      fromRow,
      fromCol,
      figur,
      true,
      brett,
      whiteKingPosition,
      blackKingPosition,
      moveInfos,
    );

    logKi("Legale Ziele: "
        "${erlaubteZuege.map((e) => mapper.koordinatenAnzeige(e[0], e[1])).join(", ")}");

    final bool zugLegal = erlaubteZuege.any(
      (zug) => zug[0] == toRow && zug[1] == toCol,
    );

    if (!zugLegal) {
      return "${figur.toString()} darf nicht von "
          "${mapper.koordinatenAnzeige(fromRow, fromCol)} nach "
          "${mapper.koordinatenAnzeige(toRow, toCol)} ziehen, weil dieser Zug nach der Spielbrett-Logik nicht legal ist. "
          "Mögliche legale Ziele wären: ${erlaubteZuege.map((z) => mapper.koordinatenAnzeige(z[0], z[1])).join(", ")}.";
    }

    logKi("KI Zug legal");

    return null;
  }

  //--------------------------------------------------------------------------------------

  void logSpiel(String text) {
    debugPrint("[Spiel ${DateTime.now().toIso8601String()}] $text");
  }

  void logKi(String text) {
    debugPrint("[KI ${DateTime.now().toIso8601String()}] $text");
  }

  void logSimulation(String text) {
    if (!logSimulationen) return;

    debugPrint(
      "[Simulation ${DateTime.now().toIso8601String()}] $text",
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool a, b) async {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return DialogSpielabbruch(
              onTapNein: () {
                Navigator.pop(context);
              },
              onTapJa: () async {
                _stopComputerVsComputer = true;
                Navigator.pop(context);
                await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SpielAuswahl(),
                  ),
                );
              },
            );
          },
        );
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 35,
              ),
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DialogSpielabbruch(
                      onTapNein: () {
                        Navigator.pop(context);
                      },
                      onTapJa: () async {
                        _stopComputerVsComputer = true;
                        Navigator.pop(context);
                        await Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SpielAuswahl(),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  color: backgroundColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 20,
                  ),
                  child: GridView.builder(
                    itemCount: figurenfarbe
                        ? weisseFigurenRaus.length
                        : schwarzeFigurenRaus.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                    itemBuilder: (context, index) {
                      final Schachfigur figur = figurenfarbe
                          ? weisseFigurenRaus[index]
                          : schwarzeFigurenRaus[index];

                      return Image.asset(
                        figur.bild,
                        color:
                            figurenfarbe ? Colors.grey[400] : Colors.grey[800],
                      );
                    },
                  ),
                ),
              ),
              Container(
                color: backgroundColor,
                height: MediaQuery.of(context).size.width,
                child: GridView.builder(
                  itemCount: 64,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                  ),
                  itemBuilder: (context, index) {
                    final int row = index ~/ 8;
                    final int col = index % 8;

                    final bool ausgewaehlt =
                        selectedRow == row && selectedColumn == col;

                    bool isValidMove = false;
                    bool canBeTakenOut = false;

                    for (final position in validMoves) {
                      if (position[0] == row && position[1] == col) {
                        isValidMove = true;

                        if (brett[row][col] != null) {
                          canBeTakenOut = true;
                        }
                      }
                    }

                    bool lastMoveFrom = false;
                    bool lastMoveTo = false;

                    if (moveInfos != null) {
                      lastMoveFrom =
                          moveInfos!.oldRow == row && moveInfos!.oldCol == col;

                      lastMoveTo =
                          moveInfos!.newRow == row && moveInfos!.newCol == col;
                    }

                    bool kingInCheck = false;
                    bool isCheckmate = false;

                    if (isKingInCheck(
                          true,
                          brett,
                          whiteKingPosition,
                          blackKingPosition,
                          moveInfos,
                        ) &&
                        whiteKingPosition[0] == row &&
                        whiteKingPosition[1] == col) {
                      kingInCheck = true;
                    }

                    if (isKingInCheck(
                          false,
                          brett,
                          whiteKingPosition,
                          blackKingPosition,
                          moveInfos,
                        ) &&
                        blackKingPosition[0] == row &&
                        blackKingPosition[1] == col) {
                      kingInCheck = true;
                    }

                    if (isCheckMate(true) &&
                        whiteKingPosition[0] == row &&
                        whiteKingPosition[1] == col) {
                      isCheckmate = true;
                    }

                    if (isCheckMate(false) &&
                        blackKingPosition[0] == row &&
                        blackKingPosition[1] == col) {
                      isCheckmate = true;
                    }

                    final bool showRank = col == 0;
                    final bool showFile = row == 7;

                    final bool lightSquare = istWeiss(index);

                    final Color coordinateColor =
                        lightSquare ? Colors.black54 : Colors.white70;

                    return Stack(
                      children: [
                        Positioned.fill(
                          child: Feld(
                            istWeiss: lightSquare,
                            figur: brett[row][col],
                            ausgewaehlt: ausgewaehlt,
                            isValidMove: isValidMove,
                            canBeTakenOut: canBeTakenOut,
                            lastMoveFrom: lastMoveFrom,
                            lastMoveTo: lastMoveTo,
                            kingInCheck: kingInCheck,
                            isCheckmate: isCheckmate,
                            onTap: () {
                              figurAusgewaehlt(row, col);
                            },
                          ),
                        ),
                        if (showRank)
                          Positioned(
                            top: 3,
                            left: 4,
                            child: Text(
                              rankLabelForGuiRow(row),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: coordinateColor,
                              ),
                            ),
                          ),
                        if (showFile)
                          Positioned(
                            right: 4,
                            bottom: 2,
                            child: Text(
                              fileLabelForGuiCol(col),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: coordinateColor,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: backgroundColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 20,
                  ),
                  child: GridView.builder(
                    itemCount: figurenfarbe
                        ? schwarzeFigurenRaus.length
                        : weisseFigurenRaus.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                    itemBuilder: (context, index) {
                      final Schachfigur figur = figurenfarbe
                          ? schwarzeFigurenRaus[index]
                          : weisseFigurenRaus[index];

                      return Image.asset(
                        figur.bild,
                        color:
                            figurenfarbe ? Colors.grey[800] : Colors.grey[400],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
