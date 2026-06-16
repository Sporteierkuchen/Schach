import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:schach/chess_ai/chess_ai.dart';
import 'package:schach/chess_ai/board_helper.dart';
import 'package:schach/components/Dialog.dart';
import 'package:schach/components/Move%20Infos.dart';
import 'package:schach/components/Schachfigur.dart';
import 'package:schach/components/Toast.dart';
import 'package:schach/components/Enums.dart';
import 'package:schach/game/utils/game_logger.dart';
import 'package:schach/helper/helper.dart';
import 'package:schach/pages/spielauswahl.dart';
import 'package:schach/values/colors.dart';
import '../game/controller/computer_controller.dart';
import '../game/logic/board_initializer.dart';
import '../game/logic/game_end_checker.dart';
import '../game/widgets/chess_board_widget.dart';
import '../logic/board_coordinate_mapper.dart';
import '../game/models/game_state.dart';
import '../game/logic/move_executor.dart';
import '../game/logic/move_generator.dart';

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
  late GameState gameState;

  late MoveGenerator moveGenerator;
  late MoveExecutor moveExecutor;
  late GameEndChecker gameEndChecker;
  late ComputerController computerController;
  late BoardInitializer boardInitializer;

  final ChessAi chessAi = ChessAi();

  Schachfigur? ausgewaehlteFigur;
  int selectedRow = -1;
  int selectedColumn = -1;
  List<List<int>> validMoves = [];

  bool pause = false;
  bool checkStatus = false;

  bool _isDisposed = false;
  bool _stopComputerVsComputer = false;

  @override
  void initState() {
    super.initState();

    figurenfarbe = widget.figurenfarbe;
    spielModus = widget.spielModus;

    mapper = BoardCoordinateMapper(
      figurenfarbe: figurenfarbe,
    );

    boardInitializer = BoardInitializer(
      mapper: mapper,
    );

    moveGenerator = MoveGenerator();

    gameState = GameState.empty(
      figurenfarbe: figurenfarbe,
    );

    moveExecutor = MoveExecutor(
      mapper: mapper,
      moveGenerator: moveGenerator,
      logSpiel: GameLogger.spiel,
      logKi: GameLogger.ki,
    );

    gameEndChecker = GameEndChecker(
      moveGenerator: moveGenerator,
    );

    computerController = ComputerController(
      chessAi: chessAi,
      mapper: mapper,
      moveGenerator: moveGenerator,
      moveExecutor: moveExecutor,
      logKi: GameLogger.ki,
    );

    startNewGame();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopComputerVsComputer = true;
    super.dispose();
  }

  Future<void> resetGame() async {
    Navigator.pop(context);
    await startNewGame();
  }

  bool _isComputerTurn() {
    if (spielModus != 0) return false;
    return gameState.isWhiteTurn != figurenfarbe;
  }

  Future<void> startNewGame() async {

    GameLogger.spiel(
      "Neues Spiel gestartet | Farbe=${figurenfarbe ? "Weiß" : "Schwarz"} | Modus=$spielModus",
    );

    setState(() {
      _startSpielbrett();
    });

    GameLogger.spiel("Brett initialisiert");

    if (spielModus == 0 && _isComputerTurn()) {
      GameLogger.ki("KI beginnt, weil Computer am Zug ist");

      final bool gameEnded = await computerMove();

      if (!gameEnded) {
        gameState.isWhiteTurn = !gameState.isWhiteTurn;
      }
    }

    if (spielModus == -1) {
      GameLogger.ki("Computer vs Computer gestartet");
      computerVsComputer();
    }
  }

  void _startSpielbrett() {
    gameState = GameState.empty(
      figurenfarbe: figurenfarbe,
    );

    pause = false;
    checkStatus = false;

    ausgewaehlteFigur = null;
    selectedRow = -1;
    selectedColumn = -1;
    validMoves = [];

    gameState.moveInfos = widget.customMoveInfos;

    if (widget.customBrett != null) {
      gameState.brett = widget.customBrett!;
      gameState.isWhiteTurn = widget.customIsWhiteTurn ?? true;

      boardInitializer.updateBrettArrayFromGuiBoard(
        gameState,
      );

      gameState.whiteKingPosition = boardInitializer.findKingPosition(
        gameState,
        true,
      );

      gameState.blackKingPosition = boardInitializer.findKingPosition(
        gameState,
        false,
      );

      return;
    }

    boardInitializer.createStartPosition(
      gameState,
      figurenfarbe,
    );
  }


  void figurAusgewaehlt(int row, int col) {
    setState(() {
      final Schachfigur? figur = gameState.brett[row][col];

      if (ausgewaehlteFigur == null && figur != null) {
        if (_darfFigurAuswaehlen(figur)) {
          _setAusgewaehlteFigur(row, col);
        }
      } else if (figur != null &&
          ausgewaehlteFigur != null &&
          figur.istWeiss == ausgewaehlteFigur!.istWeiss) {
        _setAusgewaehlteFigur(row, col);
      } else if (ausgewaehlteFigur != null &&
          _istGueltigesZielfeld(row, col)) {
        bewegeFigur(row, col);
      }

      if (ausgewaehlteFigur != null) {
        validMoves = moveGenerator.calculateValidMoves(
          selectedRow,
          selectedColumn,
          ausgewaehlteFigur,
          true,
          gameState,
        );
      } else {
        validMoves = [];
      }
    });
  }

  bool _darfFigurAuswaehlen(Schachfigur figur) {
    if (pause) return false;
    if (figur.istWeiss != gameState.isWhiteTurn) return false;

    if (spielModus == 0) {
      return !figur.isEnemy;
    }

    if (spielModus == 1) {
      return true;
    }

    return false;
  }

  void _setAusgewaehlteFigur(int row, int col) {
    ausgewaehlteFigur = gameState.brett[row][col];
    selectedRow = row;
    selectedColumn = col;

    GameLogger.spiel(
      "Figur ausgewählt: ${gameState.brett[row][col]} ${mapper.koordinatenAnzeige(row, col)}",
    );
  }

  bool _istGueltigesZielfeld(int row, int col) {
    return validMoves.any((move) => move[0] == row && move[1] == col);
  }

  Future<void> bewegeFigur(int newRow, int newCol) async {
    if (ausgewaehlteFigur == null) return;

    Schachfigur figur = ausgewaehlteFigur!;

    final int fromRow = selectedRow;
    final int fromCol = selectedColumn;

    final int fromIndex = mapper.guiToAiIndex(fromRow, fromCol);
    final int toIndex = mapper.guiToAiIndex(newRow, newCol);

    GameLogger.spiel(
      "Spielerzug: $figur "
          "${mapper.koordinatenAnzeige(fromRow, fromCol)} -> "
          "${mapper.koordinatenAnzeige(newRow, newCol)}",
    );

    gameState.moveHistory.add(
      BoardHelper.indexToCoord(fromIndex) + BoardHelper.indexToCoord(toIndex),
    );

    Schachfigur? promotionFigur;

    if (figur.art == Schachfigurenart.BAUER) {
      final bool promotion =
          (newRow == 7 && figur.isEnemy) || (newRow == 0 && !figur.isEnemy);

      if (promotion) {
        await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return DialogBauernUmwandlung(
              isWhite: figur.istWeiss,
              isEnemy: figur.isEnemy,
              onReturnValue: (value) {
                promotionFigur = value;
              },
            );
          },
        );
      }
    }

    moveExecutor.executeMove(
      state: gameState,
      fromRow: fromRow,
      fromCol: fromCol,
      toRow: newRow,
      toCol: newCol,
      figur: figur,
      promotionFigur: promotionFigur,
    );

    setState(() {
      ausgewaehlteFigur = null;
      selectedRow = -1;
      selectedColumn = -1;
      validMoves = [];
    });

    GameLogger.spiel("Brett aktualisiert");

    if (spielModus == 0) {
      if (!await checkSpielEnde()) {
        gameState.isWhiteTurn = !gameState.isWhiteTurn;

        SchedulerBinding.instance.addPostFrameCallback((_) async {
          final bool gameEnded = await computerMove();

          if (!gameEnded) {
            gameState.isWhiteTurn = !gameState.isWhiteTurn;
          }
        });
      }
    } else if (spielModus == 1) {
      if (!await checkSpielEnde()) {
        gameState.isWhiteTurn = !gameState.isWhiteTurn;
      }
    }
  }

  Future<bool> computerMove() async {
    if (!mounted || _isDisposed || _stopComputerVsComputer) {
      return true;
    }

    final result = await computerController.computerMove(
      state: gameState,
      figurenfarbe: figurenfarbe,
      spielModus: spielModus,
      stopComputerVsComputer: _stopComputerVsComputer,
    );

    if (!mounted || _isDisposed || _stopComputerVsComputer) {
      return true;
    }

    if (result.illegalMove && result.message != null) {
      showInfo(context: context, text: result.message!);
      return true;
    }

    if (result.aborted) {
      return true;
    }

    if (!result.success) {
      return true;
    }

    setState(() {});

    return await checkSpielEnde();
  }

  Future<void> computerVsComputer() async {
    _stopComputerVsComputer = false;

    while (!_stopComputerVsComputer && mounted && !_isDisposed) {
      GameLogger.ki("Neuer KI Zug | ${gameState.isWhiteTurn ? "Weiß" : "Schwarz"} am Zug");

      final bool gameEnded = await computerMove();

      if (!mounted || _isDisposed || _stopComputerVsComputer) {
        return;
      }

      if (gameEnded) {
        _stopComputerVsComputer = true;
      } else {
        gameState.isWhiteTurn = !gameState.isWhiteTurn;
      }
    }
  }

  Future<bool> checkSpielEnde() async {
    GameLogger.spiel("Prüfe Spielende");

    final bool opponentIsWhite = !gameState.isWhiteTurn;

    if (gameEndChecker.isCheckMate(opponentIsWhite, gameState)) {
      pause = true;
      await warten(const Duration(seconds: 4, milliseconds: 500));
      pause = false;

      if (!mounted) return true;

      String text;

      if (gameState.isWhiteTurn == figurenfarbe) {
        text = "Du hast gewonnen!";
      } else {
        text = figurenfarbe ? "Schwarz hat gewonnen!" : "Weiß hat gewonnen!";
      }

      await _showGameEndDialog(
        spielende: Spielende.SCHACHMATT,
        text: text,
      );

      return true;
    }

    if (gameEndChecker.isStaleMate(opponentIsWhite, gameState)) {
      pause = true;
      await warten(const Duration(seconds: 4, milliseconds: 500));
      pause = false;

      if (!mounted) return true;

      await _showGameEndDialog(
        spielende: Spielende.REMIS,
        text: "Unentschieden durch Patt!",
      );

      return true;
    }

    if (gameEndChecker.isFigurenMangel(gameState)) {
      pause = true;
      await warten(const Duration(seconds: 4, milliseconds: 500));
      pause = false;

      if (!mounted) return true;

      await _showGameEndDialog(
        spielende: Spielende.REMIS,
        text: "Unentschieden durch Figurenmangel!",
      );

      return true;
    }

    if (gameEndChecker.isFiftyMoveRule(gameState)) {
      await _showGameEndDialog(
        spielende: Spielende.REMIS,
        text: "Unentschieden durch 50-Züge-Regel!",
      );

      return true;
    }

    if (gameEndChecker.isThreefoldRepetition(gameState)) {
      await _showGameEndDialog(
        spielende: Spielende.REMIS,
        text: "Unentschieden durch dreifache Stellungswiederholung!",
      );

      return true;
    }

    if (moveGenerator.isKingInCheck(opponentIsWhite, gameState)) {
      checkStatus = true;

      showWarning(
        context: context,
        text: "Schach!",
        duration: const Duration(seconds: 2),
      );
    } else {
      checkStatus = false;
    }

    return false;
  }

  Future<void> _showGameEndDialog({
    required Spielende spielende,
    required String text,
  }) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return DialogSpielende(
          spielende: spielende,
          isWhiteTurn: gameState.isWhiteTurn,
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
                builder: (context) => const SpielAuswahl(),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showExitDialog() async {
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
  }

  String fileLabelForGuiCol(int col) {
    const List<String> filesWhite = ["A", "B", "C", "D", "E", "F", "G", "H"];
    const List<String> filesBlack = ["H", "G", "F", "E", "D", "C", "B", "A"];

    return figurenfarbe ? filesWhite[col] : filesBlack[col];
  }

  String rankLabelForGuiRow(int row) {
    return figurenfarbe ? "${8 - row}" : "${row + 1}";
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        await _showExitDialog();
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
                await _showExitDialog();
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
                        ? gameState.whiteCaptured.length
                        : gameState.blackCaptured.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                    itemBuilder: (context, index) {
                      final Schachfigur figur = figurenfarbe
                          ? gameState.whiteCaptured[index]
                          : gameState.blackCaptured[index];

                      return Image.asset(
                        figur.bild,
                        color: figurenfarbe
                            ? Colors.grey[400]
                            : Colors.grey[800],
                      );
                    },
                  ),
                ),
              ),

              ChessBoardWidget(
                gameState: gameState,
                moveGenerator: moveGenerator,
                gameEndChecker: gameEndChecker,
                selectedRow: selectedRow,
                selectedColumn: selectedColumn,
                validMoves: validMoves,
                fileLabelForGuiCol: fileLabelForGuiCol,
                rankLabelForGuiRow: rankLabelForGuiRow,
                onFieldTap: figurAusgewaehlt,
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
                        ? gameState.blackCaptured.length
                        : gameState.whiteCaptured.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                    itemBuilder: (context, index) {
                      final Schachfigur figur = figurenfarbe
                          ? gameState.blackCaptured[index]
                          : gameState.whiteCaptured[index];

                      return Image.asset(
                        figur.bild,
                        color: figurenfarbe
                            ? Colors.grey[800]
                            : Colors.grey[400],
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