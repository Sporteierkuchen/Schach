class BoardCoordinateMapper {

  final bool figurenfarbe;

  BoardCoordinateMapper({
    required this.figurenfarbe,
  });

  // ==========================
  // GUI -> Anzeige
  // ==========================

  String koordinatenAnzeige(
      int row,
      int col,
      ) {
    return squareLabelForGuiPosition(
      row,
      col,
    );
  }

  String squareLabelForGuiPosition(
      int row,
      int col,
      ) {
    return "${fileLabelForGuiCol(col)}"
        "${rankLabelForGuiRow(row)}";
  }

  String fileLabelForGuiCol(int col) {

    const List<String> filesWhite = [
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H",
    ];

    const List<String> filesBlack = [
      "H",
      "G",
      "F",
      "E",
      "D",
      "C",
      "B",
      "A",
    ];

    return figurenfarbe
        ? filesWhite[col]
        : filesBlack[col];
  }

  String rankLabelForGuiRow(int row) {

    if (figurenfarbe) {
      return "${8 - row}";
    }

    return "${row + 1}";
  }

  // ==========================
  // GUI -> AI
  // ==========================

  int guiToAiIndex(
      int row,
      int col,
      ) {

    if (figurenfarbe) {
      return row * 8 + col;
    }

    final int aiRow = 7 - row;
    final int aiCol = 7 - col;

    return aiRow * 8 + aiCol;
  }

  // ==========================
  // AI -> GUI
  // ==========================

  List<int> aiIndexToGuiPosition(
      int index,
      ) {

    final int aiRow = index ~/ 8;
    final int aiCol = index % 8;

    if (figurenfarbe) {
      return [
        aiRow,
        aiCol,
      ];
    }

    return [
      7 - aiRow,
      7 - aiCol,
    ];
  }

  // ==========================
  // GUI -> Label direkt
  // ==========================

  String aiIndexToLabel(
      int index,
      ) {

    final List<int> pos =
    aiIndexToGuiPosition(index);

    return koordinatenAnzeige(
      pos[0],
      pos[1],
    );
  }

  // ==========================
  // Label -> GUI
  // ==========================

  List<int>? labelToGuiPosition(
      String label,
      ) {

    if (label.length != 2) {
      return null;
    }

    final String file =
    label[0].toUpperCase();

    final int? rank =
    int.tryParse(label[1]);

    if (rank == null) {
      return null;
    }

    List<String> files =
    figurenfarbe
        ? [
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H",
    ]
        : [
      "H",
      "G",
      "F",
      "E",
      "D",
      "C",
      "B",
      "A",
    ];

    int col =
    files.indexOf(file);

    if (col == -1) {
      return null;
    }

    int row =
    figurenfarbe
        ? 8 - rank
        : rank - 1;

    if (row < 0 ||
        row > 7 ||
        col < 0 ||
        col > 7) {
      return null;
    }

    return [
      row,
      col,
    ];
  }
}