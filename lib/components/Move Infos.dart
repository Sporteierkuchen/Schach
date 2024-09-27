import 'package:schach/components/Schachfigur.dart';

class MoveInfos{

  final int oldRow;
  final int oldCol;
  final int newRow;
  final int newCol;
  final Schachfigur figur;

  MoveInfos({
    required this.oldRow,
    required this.newRow,
    required this.oldCol,
    required this.newCol,
    required this.figur,
  }){



  }

}