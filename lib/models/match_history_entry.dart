import 'package:schach/components/Enums.dart';
import 'package:schach/components/Schachfigur.dart';

class MatchHistoryEntry {
  final String id;
  final DateTime createdAt;
  final bool playerColorWhite;
  final int spielModus;
  final String resultText;

  final List<String> moves;
  final List<List<List<Schachfigur?>>> boardSnapshots;

  MatchHistoryEntry({
    required this.id,
    required this.createdAt,
    required this.playerColorWhite,
    required this.spielModus,
    required this.resultText,
    required this.moves,
    required this.boardSnapshots,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "createdAt": createdAt.toIso8601String(),
      "playerColorWhite": playerColorWhite,
      "spielModus": spielModus,
      "resultText": resultText,
      "moves": moves,
      "boardSnapshots": boardSnapshots.map(_boardToJson).toList(),
    };
  }

  factory MatchHistoryEntry.fromJson(Map<String, dynamic> json) {
    return MatchHistoryEntry(
      id: json["id"],
      createdAt: DateTime.parse(json["createdAt"]),
      playerColorWhite: json["playerColorWhite"],
      spielModus: json["spielModus"],
      resultText: json["resultText"],
      moves: List<String>.from(json["moves"]),
      boardSnapshots: (json["boardSnapshots"] as List)
          .map((boardJson) => _boardFromJson(boardJson))
          .toList(),
    );
  }

  static List<Map<String, dynamic>> _boardToJson(
      List<List<Schachfigur?>> board,
      ) {
    final List<Map<String, dynamic>> pieces = [];

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final Schachfigur? fig = board[row][col];

        if (fig == null) continue;

        pieces.add({
          "row": row,
          "col": col,
          "art": fig.art.name,
          "istWeiss": fig.istWeiss,
          "isEnemy": fig.isEnemy,
          "hasMoved": fig.hasMoved ?? false,
        });
      }
    }

    return pieces;
  }

  static List<List<Schachfigur?>> _boardFromJson(dynamic json) {
    final board = List.generate(
      8,
          (_) => List.generate(8, (_) => null as Schachfigur?),
    );

    for (final item in json) {
      final int row = item["row"];
      final int col = item["col"];

      board[row][col] = Schachfigur(
        art: Schachfigurenart.values.byName(item["art"]),
        istWeiss: item["istWeiss"],
        isEnemy: item["isEnemy"],
        hasMoved: item["hasMoved"] ?? false,
      );
    }

    return board;
  }
}