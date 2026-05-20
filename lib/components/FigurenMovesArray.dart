class FigurenMovesArray {
  final int fromIndex;                // Startposition im Array (0..63)
  final int piece;                   // Figurencode (z. B. 1 = Bauer Weiß, -2 = Springer Schwarz)
  final List<int> targetIndices;     // Zielpositionen (jeweils Array-Index)

  FigurenMovesArray({
    required this.fromIndex,
    required this.piece,
    required this.targetIndices,
  });
}
