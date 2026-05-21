import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schach/models/saved_position.dart';
import 'package:schach/services/position_storage_service.dart';

enum SavedPositionSortMode {
  newestFirst,
  oldestFirst,
  nameAsc,
  nameDesc,
}

class SavedPositionsPage extends StatefulWidget {
  const SavedPositionsPage({super.key});

  @override
  State<SavedPositionsPage> createState() => _SavedPositionsPageState();
}

class _SavedPositionsPageState extends State<SavedPositionsPage> {
  List<SavedPosition> positions = [];
  String searchText = "";
  SavedPositionSortMode sortMode = SavedPositionSortMode.newestFirst;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    positions = await PositionStorageService.loadPositions();

    if (!mounted) return;

    setState(() {});
  }

  List<SavedPosition> get filteredPositions {
    final String query = searchText.trim().toLowerCase();

    List<SavedPosition> result = positions.where((pos) {
      if (query.isEmpty) return true;

      return pos.name.toLowerCase().contains(query);
    }).toList();

    switch (sortMode) {
      case SavedPositionSortMode.newestFirst:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;

      case SavedPositionSortMode.oldestFirst:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;

      case SavedPositionSortMode.nameAsc:
        result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;

      case SavedPositionSortMode.nameDesc:
        result.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
    }

    return result;
  }

  Future<void> _confirmDelete(SavedPosition position) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Stellung löschen?"),
          content: Text(
            "Möchtest du die Stellung „${position.name}“ wirklich löschen?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Abbrechen"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
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

    if (shouldDelete != true) return;

    await PositionStorageService.deletePosition(position.id);
    await _load();
  }

  void _logJson(SavedPosition position) {
    const JsonEncoder encoder = JsonEncoder.withIndent("  ");
    final String jsonText = encoder.convert(position.toJson());

    debugPrint("===== Gespeicherte Stellung: ${position.name} =====");
    debugPrint(jsonText);
    debugPrint("===== Ende Stellung =====");
  }

  String _formatDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, "0");

    return "${two(date.day)}.${two(date.month)}.${date.year} "
        "${two(date.hour)}:${two(date.minute)}";
  }

  String _modeText(int mode) {
    if (mode == 0) return "Gegen Computer";
    if (mode == 1) return "Gegen Spieler";
    if (mode == -1) return "Computer vs Computer";

    return "Modus $mode";
  }

  @override
  Widget build(BuildContext context) {
    final List<SavedPosition> visiblePositions = filteredPositions;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gespeicherte Stellungen"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Nach Name suchen",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                const Text("Sortieren: "),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<SavedPositionSortMode>(
                    value: sortMode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: SavedPositionSortMode.newestFirst,
                        child: Text("Neueste zuerst"),
                      ),
                      DropdownMenuItem(
                        value: SavedPositionSortMode.oldestFirst,
                        child: Text("Älteste zuerst"),
                      ),
                      DropdownMenuItem(
                        value: SavedPositionSortMode.nameAsc,
                        child: Text("Name A-Z"),
                      ),
                      DropdownMenuItem(
                        value: SavedPositionSortMode.nameDesc,
                        child: Text("Name Z-A"),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        sortMode = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: visiblePositions.isEmpty
                ? const Center(
              child: Text("Keine gespeicherten Stellungen gefunden."),
            )
                : ListView.builder(
              itemCount: visiblePositions.length,
              itemBuilder: (context, index) {
                final SavedPosition pos = visiblePositions[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(
                      pos.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Am Zug: ${pos.whiteToMove ? "Weiß" : "Schwarz"}\n"
                          "Modus: ${_modeText(pos.spielModus)}\n"
                          "Gespeichert: ${_formatDate(pos.createdAt)}",
                    ),
                    isThreeLine: true,
                    onTap: () {
                      Navigator.pop(context, pos);
                    },
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          tooltip: "JSON loggen",
                          icon: const Icon(Icons.code),
                          onPressed: () => _logJson(pos),
                        ),
                        IconButton(
                          tooltip: "Löschen",
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () => _confirmDelete(pos),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}