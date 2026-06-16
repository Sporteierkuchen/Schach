import 'package:schach/components/Schachfigur.dart';
import 'package:schach/models/match_history_entry.dart';

class MatchRecorder {
  late String id;
  late DateTime createdAt;
  late bool playerColorWhite;
  late int spielModus;

  final List<String> moves = [];
  final List<List<List<Schachfigur?>>> boardSnapshots = [];

  void start({
    required bool playerColorWhite,
    required int spielModus,
    required List<List<Schachfigur?>> initialBoard,
  }) {
    id = DateTime.now().microsecondsSinceEpoch.toString();
    createdAt = DateTime.now();
    this.playerColorWhite = playerColorWhite;
    this.spielModus = spielModus;

    moves.clear();
    boardSnapshots.clear();

    boardSnapshots.add(copyBoard(initialBoard));
  }

  void addMove({
    required String move,
    required List<List<Schachfigur?>> board,
  }) {
    moves.add(move);
    boardSnapshots.add(copyBoard(board));
  }

  MatchHistoryEntry createEntry({
    required String resultText,
  }) {
    return MatchHistoryEntry(
      id: id,
      createdAt: createdAt,
      playerColorWhite: playerColorWhite,
      spielModus: spielModus,
      resultText: resultText,
      moves: List<String>.from(moves),
      boardSnapshots: boardSnapshots.map(copyBoard).toList(),
    );
  }

  static List<List<Schachfigur?>> copyBoard(
      List<List<Schachfigur?>> board,
      ) {
    return List.generate(
      8,
          (row) => List.generate(
        8,
            (col) {
          final Schachfigur? fig = board[row][col];

          if (fig == null) return null;

          return Schachfigur(
            art: fig.art,
            istWeiss: fig.istWeiss,
            isEnemy: fig.isEnemy,
            hasMoved: fig.hasMoved,
          );
        },
      ),
    );
  }
}