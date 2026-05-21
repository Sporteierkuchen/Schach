import 'package:schach/components/Enums.dart';
import 'package:schach/components/Schachfigur.dart';

import '../components/Move Infos.dart';

class SavedPosition {
  final String id;
  final String name;
  final List<List<Schachfigur?>> brett;
  final bool playerColorWhite;
  final bool whiteToMove;
  final int spielModus;
  final MoveInfos? moveInfos;
  final DateTime createdAt;

  SavedPosition({
    required this.id,
    required this.name,
    required this.brett,
    required this.playerColorWhite,
    required this.whiteToMove,
    required this.spielModus,
    required this.moveInfos,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "playerColorWhite": playerColorWhite,
      "whiteToMove": whiteToMove,
      "spielModus": spielModus,
      "createdAt": createdAt.toIso8601String(),
      "board": _boardToJson(),
      "moveInfos": _moveInfosToJson(),
    };
  }

  factory SavedPosition.fromJson(Map<String, dynamic> json) {
    return SavedPosition(
      id: json["id"],
      name: json["name"],
      playerColorWhite: json["playerColorWhite"],
      whiteToMove: json["whiteToMove"],
      spielModus: json["spielModus"],
      createdAt: DateTime.parse(json["createdAt"]),
      brett: _boardFromJson(json["board"]),
      moveInfos: _moveInfosFromJson(json["moveInfos"]),
    );
  }

  List<Map<String, dynamic>> _boardToJson() {
    final List<Map<String, dynamic>> pieces = [];

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final fig = brett[row][col];

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

  static List<List<Schachfigur?>> _boardFromJson(List<dynamic> json) {
    final board = List.generate(
      8,
          (_) => List.generate(8, (_) => null as Schachfigur?),
    );

    for (final item in json) {
      final row = item["row"];
      final col = item["col"];

      board[row][col] = Schachfigur(
        art: Schachfigurenart.values.byName(item["art"]),
        istWeiss: item["istWeiss"],
        isEnemy: item["isEnemy"],
        hasMoved: item["hasMoved"] ?? false,
      );
    }

    return board;
  }

  Map<String, dynamic>? _moveInfosToJson() {
    if (moveInfos == null) return null;

    return {
      "oldRow": moveInfos!.oldRow,
      "oldCol": moveInfos!.oldCol,
      "newRow": moveInfos!.newRow,
      "newCol": moveInfos!.newCol,
      "figurArt": moveInfos!.figur.art.name,
      "figurIstWeiss": moveInfos!.figur.istWeiss,
      "figurIsEnemy": moveInfos!.figur.isEnemy,
    };
  }

  static MoveInfos? _moveInfosFromJson(dynamic json) {
    if (json == null) return null;

    return MoveInfos(
      oldRow: json["oldRow"],
      oldCol: json["oldCol"],
      newRow: json["newRow"],
      newCol: json["newCol"],
      figur: Schachfigur(
        art: Schachfigurenart.values.byName(json["figurArt"]),
        istWeiss: json["figurIstWeiss"],
        isEnemy: json["figurIsEnemy"],
      ),
    );
  }
}