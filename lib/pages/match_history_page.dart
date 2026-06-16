import 'package:flutter/material.dart';
import 'package:schach/components/Schachfigur.dart';
import 'package:schach/components/feld.dart';
import 'package:schach/helper/helper.dart';
import 'package:schach/models/match_history_entry.dart';

import '../chess_ai/services/position_storage_service.dart';
import '../models/saved_position.dart';
import '../services/match_history_storage_service.dart';

class MatchHistoryPage extends StatefulWidget {
  const MatchHistoryPage({super.key});

  @override
  State<MatchHistoryPage> createState() => _MatchHistoryPageState();
}

class _MatchHistoryPageState extends State<MatchHistoryPage> {
  List<MatchHistoryEntry> matches = [];
  MatchHistoryEntry? selectedMatch;
  int currentMoveIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    matches = await MatchHistoryStorageService.loadMatches();

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _deleteMatch(MatchHistoryEntry match) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Partie löschen?"),
          content: Text(
            "Möchtest du diese Partie wirklich löschen?\n\n"
                "${_modeText(match.spielModus)}\n"
                "Ergebnis: ${match.resultText}\n"
                "Datum: ${_formatDate(match.createdAt)}",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Abbrechen"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Löschen"),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await MatchHistoryStorageService.deleteMatch(match.id);

    if (selectedMatch?.id == match.id) {
      selectedMatch = null;
      currentMoveIndex = 0;
    }

    await _load();
  }

  String _formatDate(DateTime date) {
    String two(int v) => v.toString().padLeft(2, "0");

    return "${two(date.day)}.${two(date.month)}.${date.year} "
        "${two(date.hour)}:${two(date.minute)}";
  }

  String _modeText(int mode) {
    if (mode == 0) return "Mensch gegen Computer";
    if (mode == 1) return "Mensch gegen Mensch";
    if (mode == -1) return "Computer vs Computer";

    return "Modus $mode";
  }

  void _previousMove() {
    if (selectedMatch == null) return;

    if (currentMoveIndex <= 0) return;

    setState(() {
      currentMoveIndex--;
    });
  }

  void _nextMove() {
    if (selectedMatch == null) return;

    if (currentMoveIndex >= selectedMatch!.boardSnapshots.length - 1) return;

    setState(() {
      currentMoveIndex++;
    });
  }

  Future<void> _saveCurrentPositionAsSavedPosition(
      MatchHistoryEntry match,
      ) async {
    final TextEditingController nameController = TextEditingController(
      text: "Stellung aus Partie ${_formatDate(DateTime.now())}",
    );

    final String? name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Stellung speichern"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Name der Stellung",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Abbrechen"),
            ),
            ElevatedButton(
              onPressed: () {
                final String value = nameController.text.trim();

                if (value.isEmpty) {
                  return;
                }

                Navigator.pop(context, value);
              },
              child: const Text("Speichern"),
            ),
          ],
        );
      },
    );

    nameController.dispose();

    if (name == null || name.trim().isEmpty) {
      return;
    }

    final SavedPosition position = SavedPosition(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      brett: match.boardSnapshots[currentMoveIndex],
      playerColorWhite: match.playerColorWhite,
      whiteToMove: currentMoveIndex % 2 == 0,
      spielModus: match.spielModus,
      moveInfos: null,
      createdAt: DateTime.now(),
    );

    await PositionStorageService.savePosition(position);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Stellung gespeichert."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (selectedMatch != null) {
      return _buildReplayView(selectedMatch!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Partiehistorie"),
      ),
      body: matches.isEmpty
          ? const Center(
        child: Text("Noch keine Partien gespeichert."),
      )
          : ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final MatchHistoryEntry match = matches[index];

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: ListTile(
              title: Text(
                "${_modeText(match.spielModus)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "Ergebnis: ${match.resultText}\n"
                    "Züge: ${match.moves.length}\n"
                    "Datum: ${_formatDate(match.createdAt)}",
              ),
              isThreeLine: true,
              onTap: () {
                setState(() {
                  selectedMatch = match;
                  currentMoveIndex = 0;
                });
              },
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () => _deleteMatch(match),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReplayView(MatchHistoryEntry match) {
    final List<List<Schachfigur?>> board =
    match.boardSnapshots[currentMoveIndex];

    String moveText = "Startposition";

    if (currentMoveIndex > 0 && currentMoveIndex <= match.moves.length) {
      moveText = match.moves[currentMoveIndex - 1];
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Partie ansehen"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              selectedMatch = null;
              currentMoveIndex = 0;
            });
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          Text(
            match.resultText,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Zug $currentMoveIndex / ${match.moves.length}   $moveText",
            style: const TextStyle(
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 12),

          _ReplayBoard(
            board: board,
            playerColorWhite: match.playerColorWhite,
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: currentMoveIndex > 0 ? _previousMove : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text("Zurück"),
              ),

              const SizedBox(width: 16),

              ElevatedButton.icon(
                onPressed: currentMoveIndex < match.boardSnapshots.length - 1
                    ? _nextMove
                    : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Weiter"),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ElevatedButton.icon(
            onPressed: () {
              _saveCurrentPositionAsSavedPosition(match);
            },
            icon: const Icon(Icons.save),
            label: const Text("Diese Stellung speichern"),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: match.moves.length,
              itemBuilder: (context, index) {
                final bool selected = currentMoveIndex == index + 1;

                return ListTile(
                  selected: selected,
                  title: Text(
                    "${index + 1}. ${match.moves[index]}",
                  ),
                  onTap: () {
                    setState(() {
                      currentMoveIndex = index + 1;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplayBoard extends StatelessWidget {
  final List<List<Schachfigur?>> board;
  final bool playerColorWhite;

  const _ReplayBoard({
    required this.board,
    required this.playerColorWhite,
  });

  String fileLabelForGuiCol(int col) {
    const List<String> filesWhite = ["A", "B", "C", "D", "E", "F", "G", "H"];
    const List<String> filesBlack = ["H", "G", "F", "E", "D", "C", "B", "A"];

    return playerColorWhite ? filesWhite[col] : filesBlack[col];
  }

  String rankLabelForGuiRow(int row) {
    return playerColorWhite ? "${8 - row}" : "${row + 1}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width,
      color: Colors.transparent,
      child: GridView.builder(
        itemCount: 64,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemBuilder: (context, index) {
          final int row = index ~/ 8;
          final int col = index % 8;

          final bool lightSquare = istWeiss(index);
          final Color coordinateColor =
          lightSquare ? Colors.black54 : Colors.white70;

          final bool showRank = col == 0;
          final bool showFile = row == 7;

          return Stack(
            children: [
              Positioned.fill(
                child: Feld(
                  istWeiss: lightSquare,
                  figur: board[row][col],
                  ausgewaehlt: false,
                  isValidMove: false,
                  canBeTakenOut: false,
                  lastMoveFrom: false,
                  lastMoveTo: false,
                  kingInCheck: false,
                  isCheckmate: false,
                  onTap: () {},
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
    );
  }
}