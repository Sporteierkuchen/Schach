import 'package:flutter/material.dart';

import 'package:schach/components/Enums.dart';
import 'package:schach/components/Schachfigur.dart';
import 'package:schach/components/Toast.dart';
import 'package:schach/logic/board_coordinate_mapper.dart';
import 'package:schach/logic/position_validator.dart';
import 'package:schach/models/saved_position.dart';
import 'package:schach/saved_positions_page.dart';
import 'package:schach/services/position_storage_service.dart';
import 'package:schach/spielbrett.dart';
import 'package:schach/values/colors.dart';

import 'components/Move Infos.dart';

class StellungEditor extends StatefulWidget {
  const StellungEditor({super.key});

  @override
  State<StellungEditor> createState() => _StellungEditorState();
}

class _StellungEditorState extends State<StellungEditor> {
  late List<List<Schachfigur?>> brett;
  late BoardCoordinateMapper mapper;

  Schachfigurenart selectedArt = Schachfigurenart.KOENIG;
  bool selectedIsWhite = true;
  bool deleteMode = false;

  bool playerColorWhite = true;
  bool whiteToMove = true;
  int spielModus = 0;

  bool lastMoveSelectMode = false;
  MoveInfos? editorMoveInfos;

  @override
  void initState() {
    super.initState();

    mapper = BoardCoordinateMapper(
      figurenfarbe: playerColorWhite,
    );

    _clearBoard();
  }

  void _clearBoard() {
    brett = List.generate(
      8,
          (_) => List.generate(8, (_) => null),
    );

    editorMoveInfos = null;
    lastMoveSelectMode = false;
  }

  void _onFieldTap(int row, int col) {
    if (lastMoveSelectMode) {
      _handleEnPassantSelection(row, col);
      return;
    }

    setState(() {
      if (deleteMode) {
        brett[row][col] = null;
        _clearEnPassantIfInvalid();
        return;
      }

      brett[row][col] = Schachfigur(
        art: selectedArt,
        istWeiss: selectedIsWhite,
        isEnemy: selectedIsWhite != playerColorWhite,
        hasMoved: _getDefaultHasMoved(
          art: selectedArt,
          isWhite: selectedIsWhite,
          row: row,
          col: col,
        ),
      );

      _clearEnPassantIfInvalid();
    });
  }

  void _handleEnPassantSelection(int row, int col) {
    final Schachfigur? fig = brett[row][col];

    if (fig == null || fig.art != Schachfigurenart.BAUER) {
      showInfo(
        context: context,
        text: "Tippe den Bauern an, der zuletzt zwei Felder gezogen ist.",
      );
      return;
    }

    if (!_isEnPassantCandidate(row, col)) {
      showInfo(
        context: context,
        text: "Dieser Bauer steht nicht passend für En Passant.",
      );
      return;
    }

    final String file = mapper.fileLabelForGuiCol(col);
    final String oldLabel = fig.istWeiss ? "${file}2" : "${file}7";
    final List<int>? oldPos = mapper.labelToGuiPosition(oldLabel);

    if (oldPos == null) {
      showInfo(
        context: context,
        text: "Startfeld für den letzten Bauernzug konnte nicht bestimmt werden.",
      );
      return;
    }

    setState(() {
      editorMoveInfos = MoveInfos(
        oldRow: oldPos[0],
        oldCol: oldPos[1],
        newRow: row,
        newCol: col,
        figur: Schachfigur(
          art: fig.art,
          istWeiss: fig.istWeiss,
          isEnemy: fig.isEnemy,
        ),
      );

      lastMoveSelectMode = false;
    });

    showInfo(
      context: context,
      text: "En-Passant-Information wurde gesetzt.",
    );
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
          customMoveInfos: editorMoveInfos,
        ),
      ),
    );
  }

  Future<void> _savePosition() async {
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

    final TextEditingController controller = TextEditingController();

    final String? name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Stellung speichern"),
          content: SingleChildScrollView(
            child: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: "Name der Stellung",
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Abbrechen"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text("Speichern"),
            ),
          ],
        );
      },
    );

    if (name == null || name.isEmpty) return;

    final SavedPosition position = SavedPosition(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      brett: _cloneBoard(brett),
      playerColorWhite: playerColorWhite,
      whiteToMove: whiteToMove,
      spielModus: spielModus,
      moveInfos: editorMoveInfos,
      createdAt: DateTime.now(),
    );

    try {
      await PositionStorageService.savePosition(position);
    } catch (e) {
      if (!mounted) return;

      showInfo(
        context: context,
        text: "Dieser Name ist bereits vergeben.",
      );

      return;
    }

    if (!mounted) return;

    showInfo(
      context: context,
      text: "Stellung gespeichert.",
    );
  }

  Future<void> _openSavedPositions() async {
    final SavedPosition? position = await Navigator.push<SavedPosition>(
      context,
      MaterialPageRoute(
        builder: (context) => const SavedPositionsPage(),
      ),
    );

    if (position == null) return;

    setState(() {
      brett = _cloneBoard(position.brett);
      playerColorWhite = position.playerColorWhite;
      whiteToMove = position.whiteToMove;
      spielModus = position.spielModus;
      editorMoveInfos = position.moveInfos;

      mapper = BoardCoordinateMapper(
        figurenfarbe: playerColorWhite,
      );

      _refreshEnemyFlags();
      _clearEnPassantIfInvalid();
    });
  }

  List<List<Schachfigur?>> _cloneBoard(List<List<Schachfigur?>> source) {
    return List.generate(8, (row) {
      return List.generate(8, (col) {
        final Schachfigur? fig = source[row][col];

        if (fig == null) return null;

        return Schachfigur(
          art: fig.art,
          istWeiss: fig.istWeiss,
          isEnemy: fig.istWeiss != playerColorWhite,
          hasMoved: fig.hasMoved,
        );
      });
    });
  }

  bool _getDefaultHasMoved({
    required Schachfigurenart art,
    required bool isWhite,
    required int row,
    required int col,
  }) {
    if (art == Schachfigurenart.KOENIG) {
      final String label = mapper.squareLabelForGuiPosition(row, col);

      if (isWhite && label == "E1") return false;
      if (!isWhite && label == "E8") return false;

      return true;
    }

    if (art == Schachfigurenart.TURM) {
      final String label = mapper.squareLabelForGuiPosition(row, col);

      if (isWhite && (label == "A1" || label == "H1")) return false;
      if (!isWhite && (label == "A8" || label == "H8")) return false;

      return true;
    }

    return true;
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

  Color? _fieldColor(int index) {
    final bool isWhiteField = ((index ~/ 8) + (index % 8)) % 2 == 0;
    return isWhiteField ? foregroundColor : backgroundColor;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: backgroundColorSpielAuswahl,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 4,

          title: const Text(
            "Stellung aufbauen",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),

          actions: [
            IconButton(
              tooltip: "Brett leeren",
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                setState(() {
                  _clearBoard();
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildStatusHeader(),
            _buildBoard(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    _buildEditorCard(
                      title: "Figuren",
                      child: Column(
                        children: [
                          _buildPieceSelection(),
                          const SizedBox(height: 10),
                          _buildColorAndDeleteSelection(),
                        ],
                      ),
                    ),
                    _buildEditorCard(
                      title: "Spieloptionen",
                      child: Column(
                        children: [
                          _buildPlayerColorSelection(),
                          _buildSideToMoveSelection(),
                          _buildModeSelection(),
                        ],
                      ),
                    ),
                    if (_hasAnyCastlingSetup())
                      _buildEditorCard(
                        title: "Rochade-Rechte",
                        child: _buildCastlingOptions(),
                      ),
                    if (_hasPossibleEnPassantSetup() || editorMoveInfos != null)
                      _buildEditorCard(
                        title: "En Passant",
                        child: _buildEnPassantOptions(),
                      ),
                    _buildEditorCard(
                      title: "Aktionen",
                      child: _buildActionButtons(),
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

  Widget _buildStatusHeader() {
    String text;

    if (lastMoveSelectMode) {
      text = "Tippe den Bauern an, der zuletzt zwei Felder gezogen ist.";
    } else if (deleteMode) {
      text = "Modus: Löschen";
    } else {
      text =
      "Setze: ${selectedIsWhite ? "Weiß" : "Schwarz"} ${_pieceName(selectedArt)}";
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBoard() {
    return Container(
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

          final bool showRank = col == 0;
          final bool showFile = row == 7;

          final Color? fieldColor = _fieldColor(index);
          final bool lightSquare = ((row + col) % 2 == 0);

          final Color coordinateColor =
          lightSquare ? Colors.black54 : Colors.white70;

          final bool isEnPassantCandidate =
              lastMoveSelectMode && _isEnPassantCandidate(row, col);

          final bool isSavedEnPassantPawn = editorMoveInfos != null &&
              editorMoveInfos!.newRow == row &&
              editorMoveInfos!.newCol == col;

          return GestureDetector(
            onTap: () => _onFieldTap(row, col),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isEnPassantCandidate
                          ? Colors.orangeAccent
                          : isSavedEnPassantPawn
                          ? Colors.amberAccent
                          : fieldColor,
                      border: Border.all(
                        color: Colors.black38,
                        width: 1,
                      ),
                    ),
                    child: fig == null
                        ? null
                        : Image.asset(
                      fig.bild,
                      color: fig.istWeiss ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                if (showRank)
                  Positioned(
                    top: 3,
                    left: 4,
                    child: Text(
                      mapper.rankLabelForGuiRow(row),
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
                      mapper.fileLabelForGuiCol(col),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: coordinateColor,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditorCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildPieceSelection() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: Schachfigurenart.values.map((art) {
        final bool selected = selectedArt == art && !deleteMode;

        return ChoiceChip(
          selected: selected,
          label: Text(_pieceName(art)),
          onSelected: (_) {
            setState(() {
              selectedArt = art;
              deleteMode = false;
              lastMoveSelectMode = false;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildColorAndDeleteSelection() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          selected: selectedIsWhite && !deleteMode,
          label: const Text("Weiß setzen"),
          onSelected: (_) {
            setState(() {
              selectedIsWhite = true;
              deleteMode = false;
              lastMoveSelectMode = false;
            });
          },
        ),
        ChoiceChip(
          selected: !selectedIsWhite && !deleteMode,
          label: const Text("Schwarz setzen"),
          onSelected: (_) {
            setState(() {
              selectedIsWhite = false;
              deleteMode = false;
              lastMoveSelectMode = false;
            });
          },
        ),
        ChoiceChip(
          selected: deleteMode,
          label: const Text("Löschen"),
          onSelected: (_) {
            setState(() {
              deleteMode = true;
              lastMoveSelectMode = false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPlayerColorSelection() {
    return Row(
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

              mapper = BoardCoordinateMapper(
                figurenfarbe: playerColorWhite,
              );

              _refreshEnemyFlags();
              _clearEnPassantIfInvalid();
            });
          },
        ),
      ],
    );
  }

  Widget _buildSideToMoveSelection() {
    return Row(
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
    );
  }

  Widget _buildModeSelection() {
    return Row(
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
    );
  }

  Widget _buildCastlingOptions() {
    return Column(
      children: [
        _buildCastlingSwitch(
          title: "Weiß kurze Rochade",
          isWhite: true,
          kingSide: true,
        ),
        _buildCastlingSwitch(
          title: "Weiß lange Rochade",
          isWhite: true,
          kingSide: false,
        ),
        _buildCastlingSwitch(
          title: "Schwarz kurze Rochade",
          isWhite: false,
          kingSide: true,
        ),
        _buildCastlingSwitch(
          title: "Schwarz lange Rochade",
          isWhite: false,
          kingSide: false,
        ),
      ],
    );
  }

  Widget _buildCastlingSwitch({
    required String title,
    required bool isWhite,
    required bool kingSide,
  }) {
    final bool setupAvailable = _isCastlingSetupAvailable(
      isWhite: isWhite,
      kingSide: kingSide,
    );

    if (!setupAvailable) {
      return const SizedBox.shrink();
    }

    final bool enabled = _isCastlingRightActive(
      isWhite: isWhite,
      kingSide: kingSide,
    );

    return SwitchListTile(
      dense: true,
      title: Text(title),
      subtitle: Text(
        enabled
            ? "König und Turm gelten als nicht bewegt."
            : "Rochade für diese Seite ist deaktiviert.",
      ),
      value: enabled,
      onChanged: (value) {
        setState(() {
          _setCastlingRight(
            isWhite: isWhite,
            kingSide: kingSide,
            enabled: value,
          );
        });
      },
    );
  }

  Widget _buildEnPassantOptions() {
    final bool hasSetup = _hasPossibleEnPassantSetup();

    return Column(
      children: [
        if (editorMoveInfos != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "Gesetzt: letzter Bauern-Doppelschritt nach "
                  "${mapper.koordinatenAnzeige(editorMoveInfos!.newRow, editorMoveInfos!.newCol)}",
              textAlign: TextAlign.center,
            ),
          ),
        if (hasSetup)
          ElevatedButton(
            onPressed: () {
              setState(() {
                lastMoveSelectMode = true;
                deleteMode = false;
              });

              showInfo(
                context: context,
                text: "Tippe den Bauern an, der zuletzt zwei Felder gezogen ist.",
              );
            },
            child: const Text("En Passant setzen"),
          ),
        if (editorMoveInfos != null)
          TextButton(
            onPressed: () {
              setState(() {
                editorMoveInfos = null;
                lastMoveSelectMode = false;
              });

              showInfo(
                context: context,
                text: "En-Passant-Information gelöscht.",
              );
            },
            child: const Text("En Passant löschen"),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _savePosition,
          icon: const Icon(Icons.save),
          label: const Text("Stellung speichern"),
        ),
        ElevatedButton.icon(
          onPressed: _openSavedPositions,
          icon: const Icon(Icons.folder_open),
          label: const Text("Gespeicherte Stellungen"),
        ),
        const SizedBox(height: 10),
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
      ],
    );
  }

  bool _hasAnyCastlingSetup() {
    return _isCastlingSetupAvailable(isWhite: true, kingSide: true) ||
        _isCastlingSetupAvailable(isWhite: true, kingSide: false) ||
        _isCastlingSetupAvailable(isWhite: false, kingSide: true) ||
        _isCastlingSetupAvailable(isWhite: false, kingSide: false);
  }

  bool _isCastlingSetupAvailable({
    required bool isWhite,
    required bool kingSide,
  }) {
    final String kingLabel = isWhite ? "E1" : "E8";
    final String rookLabel = isWhite
        ? kingSide
        ? "H1"
        : "A1"
        : kingSide
        ? "H8"
        : "A8";

    final Schachfigur? king = _pieceAtLabel(kingLabel);
    final Schachfigur? rook = _pieceAtLabel(rookLabel);

    return king != null &&
        rook != null &&
        king.art == Schachfigurenart.KOENIG &&
        rook.art == Schachfigurenart.TURM &&
        king.istWeiss == isWhite &&
        rook.istWeiss == isWhite;
  }

  bool _isCastlingRightActive({
    required bool isWhite,
    required bool kingSide,
  }) {
    if (!_isCastlingSetupAvailable(isWhite: isWhite, kingSide: kingSide)) {
      return false;
    }

    final String kingLabel = isWhite ? "E1" : "E8";
    final String rookLabel = isWhite
        ? kingSide
        ? "H1"
        : "A1"
        : kingSide
        ? "H8"
        : "A8";

    final Schachfigur king = _pieceAtLabel(kingLabel)!;
    final Schachfigur rook = _pieceAtLabel(rookLabel)!;

    return king.hasMoved != true && rook.hasMoved != true;
  }

  void _setCastlingRight({
    required bool isWhite,
    required bool kingSide,
    required bool enabled,
  }) {
    final String kingLabel = isWhite ? "E1" : "E8";
    final String rookLabel = isWhite
        ? kingSide
        ? "H1"
        : "A1"
        : kingSide
        ? "H8"
        : "A8";

    final List<int>? kingPos = mapper.labelToGuiPosition(kingLabel);
    final List<int>? rookPos = mapper.labelToGuiPosition(rookLabel);

    if (kingPos == null || rookPos == null) return;

    final Schachfigur? king = brett[kingPos[0]][kingPos[1]];
    final Schachfigur? rook = brett[rookPos[0]][rookPos[1]];

    if (king == null || rook == null) return;

    final bool otherSideCurrentlyActive = _isCastlingRightActive(
      isWhite: isWhite,
      kingSide: !kingSide,
    );

    final bool kingShouldBeUnmoved = enabled || otherSideCurrentlyActive;

    brett[kingPos[0]][kingPos[1]] = _copyFigurWithHasMoved(
      king,
      hasMoved: !kingShouldBeUnmoved,
    );

    brett[rookPos[0]][rookPos[1]] = _copyFigurWithHasMoved(
      rook,
      hasMoved: !enabled,
    );
  }

  Schachfigur? _pieceAtLabel(String label) {
    final List<int>? pos = mapper.labelToGuiPosition(label);

    if (pos == null) return null;

    return brett[pos[0]][pos[1]];
  }

  Schachfigur _copyFigurWithHasMoved(
      Schachfigur fig, {
        required bool hasMoved,
      }) {
    return Schachfigur(
      art: fig.art,
      istWeiss: fig.istWeiss,
      isEnemy: fig.isEnemy,
      hasMoved: hasMoved,
    );
  }

  bool _hasPossibleEnPassantSetup() {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (_isEnPassantCandidate(row, col)) {
          return true;
        }
      }
    }

    return false;
  }

  bool _isEnPassantCandidate(int row, int col) {
    final Schachfigur? fig = brett[row][col];

    if (fig == null || fig.art != Schachfigurenart.BAUER) {
      return false;
    }

    final String rank = mapper.rankLabelForGuiRow(row);

    if (fig.istWeiss && rank == "4") {
      return _hasPawnNextTo(row, col, isWhite: false);
    }

    if (!fig.istWeiss && rank == "5") {
      return _hasPawnNextTo(row, col, isWhite: true);
    }

    return false;
  }

  bool _hasPawnNextTo(
      int row,
      int col, {
        required bool isWhite,
      }) {
    return _isPawnAt(row, col - 1, isWhite) ||
        _isPawnAt(row, col + 1, isWhite);
  }

  bool _isPawnAt(
      int row,
      int col,
      bool isWhite,
      ) {
    if (row < 0 || row > 7 || col < 0 || col > 7) {
      return false;
    }

    final Schachfigur? fig = brett[row][col];

    return fig != null &&
        fig.art == Schachfigurenart.BAUER &&
        fig.istWeiss == isWhite;
  }

  void _clearEnPassantIfInvalid() {
    if (editorMoveInfos == null) return;

    final MoveInfos info = editorMoveInfos!;
    final Schachfigur? fig = brett[info.newRow][info.newCol];

    if (fig == null ||
        fig.art != Schachfigurenart.BAUER ||
        fig.istWeiss != info.figur.istWeiss) {
      editorMoveInfos = null;
    }
  }

  void _refreshEnemyFlags() {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final Schachfigur? fig = brett[row][col];

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