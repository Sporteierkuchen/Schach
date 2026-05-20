import 'package:flutter/material.dart';

import 'package:schach/components/Enums.dart';
import 'package:schach/components/Schachfigur.dart';
import 'package:schach/components/Toast.dart';
import 'package:schach/logic/position_validator.dart';
import 'package:schach/spielbrett.dart';
import 'package:schach/values/colors.dart';

class StellungEditor extends StatefulWidget {
  const StellungEditor({super.key});

  @override
  State<StellungEditor> createState() => _StellungEditorState();
}

class _StellungEditorState extends State<StellungEditor> {
  late List<List<Schachfigur?>> brett;

  Schachfigurenart selectedArt = Schachfigurenart.KOENIG;
  bool selectedIsWhite = true;
  bool deleteMode = false;

  bool playerColorWhite = true;
  bool whiteToMove = true;
  int spielModus = 0;

  @override
  void initState() {
    super.initState();
    _clearBoard();
  }

  void _clearBoard() {
    brett = List.generate(
      8,
          (_) => List.generate(8, (_) => null),
    );
  }

  void _onFieldTap(int row, int col) {
    setState(() {
      if (deleteMode) {
        brett[row][col] = null;
        return;
      }

      brett[row][col] = Schachfigur(
        art: selectedArt,
        istWeiss: selectedIsWhite,
        isEnemy: selectedIsWhite != playerColorWhite,
        hasMoved: false,
      );
    });
  }

  void _startGame() {
    final PositionValidationResult result = PositionValidator().validate(
      brett: brett,
      whiteToMove: whiteToMove,
    );

    if (!result.isValid) {
      showInfo(
        context: context,
        text: result.message ?? "Die Stellung ist ungültig.",
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SpielBrett(
          figurenfarbe: playerColorWhite,
          spielModus: spielModus,
          customBrett: _cloneBoard(brett),
          customIsWhiteTurn: whiteToMove,
        ),
      ),
    );
  }

  List<List<Schachfigur?>> _cloneBoard(List<List<Schachfigur?>> source) {
    return List.generate(8, (row) {
      return List.generate(8, (col) {
        final fig = source[row][col];

        if (fig == null) return null;

        return Schachfigur(
          art: fig.art,
          istWeiss: fig.istWeiss,
          isEnemy: fig.isEnemy,
          hasMoved: fig.hasMoved,
        );
      });
    });
  }

  String _pieceName(Schachfigurenart art) {
    switch (art) {
      case Schachfigurenart.BAUER:
        return "Bauer";
      case Schachfigurenart.SPRINGER:
        return "Springer";
      case Schachfigurenart.LAEUFER:
        return "Läufer";
      case Schachfigurenart.TURM:
        return "Turm";
      case Schachfigurenart.DAME:
        return "Dame";
      case Schachfigurenart.KOENIG:
        return "König";
    }
  }

  String _assetForPiece(Schachfigurenart art) {
    switch (art) {
      case Schachfigurenart.BAUER:
        return "assets/images/figuren/bauer.png";
      case Schachfigurenart.SPRINGER:
        return "assets/images/figuren/springer.png";
      case Schachfigurenart.LAEUFER:
        return "assets/images/figuren/laeufer.png";
      case Schachfigurenart.TURM:
        return "assets/images/figuren/turm.png";
      case Schachfigurenart.DAME:
        return "assets/images/figuren/dame.png";
      case Schachfigurenart.KOENIG:
        return "assets/images/figuren/koenig.png";
    }
  }

  Color? _fieldColor(int index) {
    final bool isWhiteField = ((index ~/ 8) + (index % 8)) % 2 == 0;
    return isWhiteField ? foregroundColor : backgroundColor;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColorSpielAuswahl,
        appBar: AppBar(
          backgroundColor: backgroundColorSpielAuswahl,
          title: const Text("Stellung aufbauen"),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _clearBoard();
                });
              },
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),

            Text(
              deleteMode
                  ? "Modus: Löschen"
                  : "Setze: ${selectedIsWhite ? "Weiß" : "Schwarz"} ${_pieceName(selectedArt)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              height: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(8),
              child: GridView.builder(
                itemCount: 64,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                ),
                itemBuilder: (context, index) {
                  final int row = index ~/ 8;
                  final int col = index % 8;
                  final Schachfigur? fig = brett[row][col];

                  return GestureDetector(
                    onTap: () => _onFieldTap(row, col),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _fieldColor(index),
                        border: Border.all(
                          color: Colors.black38,
                          width: 1,
                        ),
                      ),
                      child: fig == null
                          ? null
                          : Image.asset(
                        fig.bild,
                        color: fig.istWeiss
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    const Text(
                      "Figur auswählen",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      children: Schachfigurenart.values.map((art) {
                        final bool selected = selectedArt == art && !deleteMode;

                        return ChoiceChip(
                          selected: selected,
                          label: Text(_pieceName(art)),
                          onSelected: (_) {
                            setState(() {
                              selectedArt = art;
                              deleteMode = false;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          selected: selectedIsWhite && !deleteMode,
                          label: const Text("Weiß setzen"),
                          onSelected: (_) {
                            setState(() {
                              selectedIsWhite = true;
                              deleteMode = false;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        ChoiceChip(
                          selected: !selectedIsWhite && !deleteMode,
                          label: const Text("Schwarz setzen"),
                          onSelected: (_) {
                            setState(() {
                              selectedIsWhite = false;
                              deleteMode = false;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        ChoiceChip(
                          selected: deleteMode,
                          label: const Text("Löschen"),
                          onSelected: (_) {
                            setState(() {
                              deleteMode = true;
                            });
                          },
                        ),
                      ],
                    ),

                    const Divider(height: 30),

                    const Text(
                      "Spieloptionen",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Ich spiele: "),
                        DropdownButton<bool>(
                          value: playerColorWhite,
                          items: const [
                            DropdownMenuItem(
                              value: true,
                              child: Text("Weiß"),
                            ),
                            DropdownMenuItem(
                              value: false,
                              child: Text("Schwarz"),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              playerColorWhite = value;
                              _refreshEnemyFlags();
                            });
                          },
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Am Zug: "),
                        DropdownButton<bool>(
                          value: whiteToMove,
                          items: const [
                            DropdownMenuItem(
                              value: true,
                              child: Text("Weiß"),
                            ),
                            DropdownMenuItem(
                              value: false,
                              child: Text("Schwarz"),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              whiteToMove = value;
                            });
                          },
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Modus: "),
                        DropdownButton<int>(
                          value: spielModus,
                          items: const [
                            DropdownMenuItem(
                              value: 0,
                              child: Text("Gegen Computer"),
                            ),
                            DropdownMenuItem(
                              value: 1,
                              child: Text("Gegen Spieler"),
                            ),
                            DropdownMenuItem(
                              value: -1,
                              child: Text("Computer vs Computer"),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              spielModus = value;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        "Stellung starten",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _refreshEnemyFlags() {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final fig = brett[row][col];

        if (fig == null) continue;

        brett[row][col] = Schachfigur(
          art: fig.art,
          istWeiss: fig.istWeiss,
          isEnemy: fig.istWeiss != playerColorWhite,
          hasMoved: fig.hasMoved,
        );
      }
    }
  }
}