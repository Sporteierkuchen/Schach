import 'package:schach/components/Schachfigur.dart';

class FigurenMoves{

  final int row;
  final int col;
  Schachfigur figur;
  final List<List<int>> pieceValidMoves;

  FigurenMoves({
    required this.row,
    required this.col,
    required this.figur,
    required this.pieceValidMoves,
  });

}