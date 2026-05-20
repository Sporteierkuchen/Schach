class AiMove {
  final int fromIndex;
  final int toIndex;
  final int piece;
  final int? promotionPiece;
  final int score;

  const AiMove({
    required this.fromIndex,
    required this.toIndex,
    required this.piece,
    this.promotionPiece,
    required this.score,
  });
}