import 'dart:math';

import 'package:flutter/material.dart';
import 'package:schach/components/Dialog.dart';
import 'package:schach/components/FigurenMoves.dart';
import 'package:schach/components/Move%20Infos.dart';
import 'package:schach/components/Schachfigur.dart';
import 'package:schach/components/Toast.dart';
import 'package:schach/components/feld.dart';
import 'package:schach/helper/helper.dart';
import 'package:schach/spielauswahl.dart';
import 'package:schach/values/colors.dart';

import 'components/Enums.dart';

class SpielBrett extends StatefulWidget {

  bool figurenfarbe;
  SpielBrett({super.key, required this.figurenfarbe});

  @override
  State<SpielBrett> createState() => _SpielBrettState();
}

class _SpielBrettState extends State<SpielBrett> {

  late bool figurenfarbe; //false=schwarz true=weiß

  late List<List<Schachfigur?>> brett;

  Schachfigur? ausgewaehlteFigur;

  int selectedRow = -1;
  int selectedColumn = -1;

  List<List<int>> validMoves = [];

  List<Schachfigur> weisseFigurenRaus = [];
  List<Schachfigur> schwarzeFigurenRaus = [];

  bool isWhiteTurn = true;

  MoveInfos? moveInfos;

  late List<int> whiteKingPosition;
  late List<int> blackKingPosition;
  bool checkStatus = false;

  @override
  void initState() {

    figurenfarbe = widget.figurenfarbe;

    _startSpielbrett();

    if(figurenfarbe == false){
      computerMove();
      isWhiteTurn = !isWhiteTurn;
    }

  }

  void _startSpielbrett() {
    List<List<Schachfigur?>> neuesBrett =
        List.generate(8, (index) => List.generate(8, (index) => null));

    //
    //          column
    //
    //       0 1 2 3 4 5 6 7
    // row   1
    //       2
    //       3
    //       4
    //       5
    //       6
    //       7

    for (int i = 0; i < 8; i++) {
      neuesBrett[1][i] = Schachfigur(
          art: Schachfigurenart.BAUER,
          istWeiss: figurenfarbe ? false : true,
          isEnemy: true);
      neuesBrett[6][i] = Schachfigur(
          art: Schachfigurenart.BAUER,
          istWeiss: figurenfarbe ? true : false,
          isEnemy: false);
    }

    neuesBrett[0][0] = Schachfigur(
        art: Schachfigurenart.TURM,
        istWeiss: figurenfarbe ? false : true,
        isEnemy: true);
    neuesBrett[0][7] = Schachfigur(
        art: Schachfigurenart.TURM,
        istWeiss: figurenfarbe ? false : true,
        isEnemy: true);
    neuesBrett[7][0] = Schachfigur(
        art: Schachfigurenart.TURM,
        istWeiss: figurenfarbe ? true : false,
        isEnemy: false);
    neuesBrett[7][7] = Schachfigur(
        art: Schachfigurenart.TURM,
        istWeiss: figurenfarbe ? true : false,
        isEnemy: false);

    neuesBrett[0][1] = Schachfigur(
        art: Schachfigurenart.SPRINGER,
        istWeiss: figurenfarbe ? false : true,
        isEnemy: true);
    neuesBrett[0][6] = Schachfigur(
        art: Schachfigurenart.SPRINGER,
        istWeiss: figurenfarbe ? false : true,
        isEnemy: true);
    neuesBrett[7][1] = Schachfigur(
        art: Schachfigurenart.SPRINGER,
        istWeiss: figurenfarbe ? true : false,
        isEnemy: false);
    neuesBrett[7][6] = Schachfigur(
        art: Schachfigurenart.SPRINGER,
        istWeiss: figurenfarbe ? true : false,
        isEnemy: false);

    neuesBrett[0][2] = Schachfigur(
        art: Schachfigurenart.LAEUFER,
        istWeiss: figurenfarbe ? false : true,
        isEnemy: true);
    neuesBrett[0][5] = Schachfigur(
        art: Schachfigurenart.LAEUFER,
        istWeiss: figurenfarbe ? false : true,
        isEnemy: true);
    neuesBrett[7][2] = Schachfigur(
        art: Schachfigurenart.LAEUFER,
        istWeiss: figurenfarbe ? true : false,
        isEnemy: false);
    neuesBrett[7][5] = Schachfigur(
        art: Schachfigurenart.LAEUFER,
        istWeiss: figurenfarbe ? true : false,
        isEnemy: false);

    if (figurenfarbe) {
      neuesBrett[0][3] = Schachfigur(
          art: Schachfigurenart.DAME, istWeiss: false, isEnemy: true);
      neuesBrett[7][3] = Schachfigur(
          art: Schachfigurenart.DAME, istWeiss: true, isEnemy: false);
      neuesBrett[0][4] = Schachfigur(
          art: Schachfigurenart.KOENIG, istWeiss: false, isEnemy: true);
      neuesBrett[7][4] = Schachfigur(
          art: Schachfigurenart.KOENIG, istWeiss: true, isEnemy: false);

    whiteKingPosition = [7,4];
    blackKingPosition = [0,4];

    } else {
      neuesBrett[0][4] = Schachfigur(
          art: Schachfigurenart.DAME, istWeiss: true, isEnemy: true);
      neuesBrett[7][4] = Schachfigur(
          art: Schachfigurenart.DAME, istWeiss: false, isEnemy: false);
      neuesBrett[0][3] = Schachfigur(
          art: Schachfigurenart.KOENIG, istWeiss: true, isEnemy: true);
      neuesBrett[7][3] = Schachfigur(
          art: Schachfigurenart.KOENIG, istWeiss: false, isEnemy: false);

      whiteKingPosition = [0,3];
      blackKingPosition = [7,3];

    }


    //   neuesBrett[2][0] = Schachfigur(
    //       art: Schachfigurenart.BAUER,
    //       istWeiss: figurenfarbe,
    //       isEnemy: false);
    //
    //
    //
    //
    // if (figurenfarbe) {
    //
    //   neuesBrett[0][0] = Schachfigur(
    //       art: Schachfigurenart.KOENIG, istWeiss: false, isEnemy: true);
    //   neuesBrett[3][0] = Schachfigur(
    //       art: Schachfigurenart.KOENIG, istWeiss: true, isEnemy: false);
    //
    //   whiteKingPosition = [3,0];
    //   blackKingPosition = [0,0];
    //
    // } else {
    //
    //
    //   neuesBrett[0][0] = Schachfigur(
    //       art: Schachfigurenart.KOENIG, istWeiss: true, isEnemy: true);
    //   neuesBrett[3][0] = Schachfigur(
    //       art: Schachfigurenart.KOENIG, istWeiss: false, isEnemy: false);
    //
    //   whiteKingPosition = [0,0];
    //   blackKingPosition = [3,0];
    //
    // }
    //



    checkStatus= false;
    weisseFigurenRaus.clear();
    schwarzeFigurenRaus.clear();
    isWhiteTurn=true;
    moveInfos= null;

    brett = neuesBrett;
  }

  void figurAusgewaehlt(int row, int column) {
    setState(() {
      if (ausgewaehlteFigur == null && brett[row][column] != null) {
        if (brett[row][column]!.istWeiss == isWhiteTurn && !brett[row][column]!.isEnemy) {
          ausgewaehlteFigur = brett[row][column];
          selectedRow = row;
          selectedColumn = column;
          print(
              "Ausgewählte Figur: ${brett[row][column].toString()} ${koordinatenAnzeige(row, column)}");
        }
      } else if (brett[row][column] != null &&
          brett[row][column]!.istWeiss == ausgewaehlteFigur!.istWeiss) {
        ausgewaehlteFigur = brett[row][column];
        selectedRow = row;
        selectedColumn = column;
        print(
            "Ausgewählte Figur: ${brett[row][column].toString()} ${koordinatenAnzeige(row, column)}");
      } else if (ausgewaehlteFigur != null &&
          validMoves
              .any((element) => element[0] == row && element[1] == column)) {
        bewegeFigur(row, column);
      }

      validMoves = calculateRealValidMoves(
          selectedRow, selectedColumn, ausgewaehlteFigur,true);
    });
  }

  Future<void> bewegeFigur(int newRow, int newCol) async {

    if (brett[newRow][newCol] != null) {
      var geschlageneFigur = brett[newRow][newCol];

      if (geschlageneFigur!.istWeiss) {
        weisseFigurenRaus.add(geschlageneFigur);
      } else {
        schwarzeFigurenRaus.add(geschlageneFigur);
      }
    }

    print("Bewege: ${ausgewaehlteFigur.toString()} von ${koordinatenAnzeige(selectedRow, selectedColumn)} zu ${koordinatenAnzeige(newRow, newCol)}");

    if(ausgewaehlteFigur!.art == Schachfigurenart.KOENIG){

      if(ausgewaehlteFigur!.istWeiss){
        whiteKingPosition = [newRow,newCol];
      }
      else{
        blackKingPosition = [newRow,newCol];
      }

    }


    // en passant prüfen
    if(ausgewaehlteFigur!.art == Schachfigurenart.BAUER && isEnPassantPosible(ausgewaehlteFigur!, selectedRow, selectedColumn)){
      var geschlagenerBauer = brett[moveInfos!.newRow][moveInfos!.newCol];

      if (geschlagenerBauer!.istWeiss) {
        weisseFigurenRaus.add(geschlagenerBauer);
      } else {
        schwarzeFigurenRaus.add(geschlagenerBauer);
      }

      brett[moveInfos!.newRow][moveInfos!.newCol] = null;
    }


    moveInfos = MoveInfos(
        oldRow: selectedRow,
        oldCol: selectedColumn,
        newRow: newRow,
        newCol: newCol,
        figur: Schachfigur(art: ausgewaehlteFigur!.art, istWeiss: ausgewaehlteFigur!.istWeiss, isEnemy: ausgewaehlteFigur!.isEnemy));

    brett[newRow][newCol] = ausgewaehlteFigur;
    brett[selectedRow][selectedColumn] = null;

    setState(() {
      ausgewaehlteFigur = null;
      selectedRow = -1;
      selectedColumn = -1;
      validMoves = [];
    });


    if(isCheckMate(!isWhiteTurn)){

      String text="";
      if(isWhiteTurn == figurenfarbe){
        text="Du hast gewonnen!";
      }
      else{
        if(figurenfarbe){
          text= "Schwarz hat gewonnen!";
        }
        else{
          text= "Weiß hat gewonnen!";
        }
      }

      isWhiteTurn = !isWhiteTurn;
      await warten(const Duration(seconds: 1, milliseconds: 500));

      await  showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return DialogSpielende(spielende: Spielende.SCHACHMATT,isWhiteTurn: !isWhiteTurn, figurenfarbe: figurenfarbe, text: text, onTapNochmal:  () {resetGame();}, onTapBack:  () async {   Navigator.pop(context);
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SpielAuswahl()));});
        },
      );
      return;
    }
    else if(isStaleMate(!isWhiteTurn)){

      isWhiteTurn = !isWhiteTurn;
      await warten(const Duration(seconds: 1, milliseconds: 500));

      await  showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return DialogSpielende(spielende: Spielende.REMIS,isWhiteTurn: !isWhiteTurn, figurenfarbe: figurenfarbe, text: "Unentschieden durch Patt!", onTapNochmal:  () {resetGame();}, onTapBack:  () async {   Navigator.pop(context);
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SpielAuswahl()));});
        },
      );
      return;
    }

    if(isKingInCheck(!isWhiteTurn)){
      checkStatus = true;
      showWarning(context: context, text: "Schach!", duration: const Duration(seconds: 2));
    }
    else{
      checkStatus = false;
    }

      isWhiteTurn = !isWhiteTurn;
      await computerMove();
      isWhiteTurn = !isWhiteTurn;

  }


  List<List<int>> calculateRawValidMoves(int row, int col, Schachfigur? schachfigur) {
    List<List<int>> canidateMoves = [];

    if (schachfigur == null) {
      return [];
    }

    int direction = schachfigur.isEnemy ? 1 : -1;

    switch (schachfigur.art) {
      case Schachfigurenart.BAUER:
        if (isInBoard(row + direction, col) &&
            brett[row + direction][col] == null) {
          canidateMoves.add([row + direction, col]);
        }

        if ((row == 1 && schachfigur.isEnemy) ||
            (row == 6 && !schachfigur.isEnemy)) {
          if (isInBoard(row + 2 * direction, col) &&
              brett[row + 2 * direction][col] == null &&
              brett[row + direction][col] == null) {
            canidateMoves.add([row + 2 * direction, col]);
          }
        }

        if (isInBoard(row + direction, col - 1) &&
            brett[row + direction][col - 1] != null &&
            brett[row + direction][col - 1]!.istWeiss != schachfigur.istWeiss) {
          canidateMoves.add([row + direction, col - 1]);
        }

        if (isInBoard(row + direction, col + 1) &&
            brett[row + direction][col + 1] != null &&
            brett[row + direction][col + 1]!.istWeiss != schachfigur.istWeiss) {
          canidateMoves.add([row + direction, col + 1]);
        }

        //en passant
        if(isEnPassantPosible(schachfigur, row, col)){

          if(!schachfigur.isEnemy){
            if(moveInfos?.newCol == col-1){
              canidateMoves.add([row + direction, col -1]);
            }
            else{
              canidateMoves.add([row + direction, col +1]);
            }
          }
          else{
            if(moveInfos?.newCol == col-1){
              canidateMoves.add([row + direction, col -1]);
            }
            else{
              canidateMoves.add([row + direction, col +1]);
            }
          }

        }

        break;
      case Schachfigurenart.SPRINGER:
        var knightMoves = [
          [-2, -1], // up 2 left 1
          [-2, 1], // up 2 right 1
          [-1, -2], // up 1 left 2
          [-1, 2], // up 1 right 2
          [1, -2], // down 1 left 2
          [1, 2], // down 1 right 2
          [2, -1], // down 2 left 1
          [2, 1], // down 2 right 1
        ];

        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];

          if (!isInBoard(newRow, newCol)) {
            continue;
          }

          if (brett[newRow][newCol] != null) {
            if (brett[newRow][newCol]!.istWeiss != schachfigur.istWeiss) {
              canidateMoves.add([newRow, newCol]); // capture
            }
            continue; // blocked
          }

          canidateMoves.add([newRow, newCol]);
        }
        break;

      case Schachfigurenart.LAEUFER:
        var directions = [
          [-1, -1], // up
          [-1, 1], // down
          [1, -1], //left
          [1, 1], //right
        ];

        for (var direction in directions) {
          var i = 1;

          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }

            if (brett[newRow][newCol] != null) {
              if (brett[newRow][newCol]!.istWeiss != schachfigur.istWeiss) {
                canidateMoves.add([newRow, newCol]); // capture
              }
              break; // block
            }

            canidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;

      case Schachfigurenart.TURM:
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], //left
          [0, 1], //right
        ];

        for (var direction in directions) {
          var i = 1;

          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }

            if (brett[newRow][newCol] != null) {
              if (brett[newRow][newCol]!.istWeiss != schachfigur.istWeiss) {
                canidateMoves.add([newRow, newCol]); // kill
              }

              break; // blocked
            }
            canidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case Schachfigurenart.DAME:
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (var direction in directions) {
          var i = 1;

          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }

            if (brett[newRow][newCol] != null) {
              if (brett[newRow][newCol]!.istWeiss != schachfigur.istWeiss) {
                canidateMoves.add([newRow, newCol]); // capture
              }
              break; // blocked
            }

            canidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case Schachfigurenart.KOENIG:
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];

          if (!isInBoard(newRow, newCol)) {
            continue;
          }

          if (brett[newRow][newCol] != null) {
            if (brett[newRow][newCol]!.istWeiss != schachfigur.istWeiss) {
              canidateMoves.add([newRow, newCol]); // capture
            }
            continue; // blocked
          }

          canidateMoves.add([newRow, newCol]);
        }

        break;
      default:
        return [];
    }

    return canidateMoves;
  }

  bool isEnPassantPosible(Schachfigur schachfigur, int row, int col) {

      if (!schachfigur.isEnemy && row == 3 && moveInfos?.newRow == 3 && (moveInfos?.newCol == col-1 || moveInfos?.newCol == col+1) && moveInfos?.figur.art == Schachfigurenart.BAUER && moveInfos!.figur.isEnemy) {
        return true;
      }

      if (schachfigur.isEnemy && row == 4 && moveInfos?.newRow == 4 && (moveInfos?.newCol == col-1 || moveInfos?.newCol == col+1) && moveInfos?.figur.art == Schachfigurenart.BAUER && !moveInfos!.figur.isEnemy) {
        return true;
      }
      return false;
      }

    Future<void> computerMove() async {

      List<FigurenMoves> allPosibleEnemyMoves=[];

      for(int i = 0; i < 8; i++){
        for(int j = 0; j < 8; j++){

          if(brett[i][j] == null || !brett[i][j]!.isEnemy){
            continue;
          }

          List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, brett[i][j],true);

          if(pieceValidMoves.isNotEmpty){
            allPosibleEnemyMoves.add(FigurenMoves(row: i, col: j, figur: brett[i][j]!, pieceValidMoves: pieceValidMoves));
          }

        }
      }

      Random zufall = Random();
      FigurenMoves figurenMoves= allPosibleEnemyMoves[zufall.nextInt(allPosibleEnemyMoves.length)];
      List<int> randomMove= figurenMoves.pieceValidMoves[zufall.nextInt(figurenMoves.pieceValidMoves.length)];


      await warten(const Duration(seconds: 1, milliseconds: 500));


      if (brett[randomMove[0]][randomMove[1]] != null) {
        var geschlageneFigur = brett[randomMove[0]][randomMove[1]];

        if (geschlageneFigur!.istWeiss) {
          weisseFigurenRaus.add(geschlageneFigur);
        } else {
          schwarzeFigurenRaus.add(geschlageneFigur);
        }
      }

       print("Gegner bewegt: ${figurenMoves.figur.toString()} von ${koordinatenAnzeige(figurenMoves.row, figurenMoves.col)} zu ${koordinatenAnzeige(randomMove[0], randomMove[1])}");

      if(figurenMoves.figur.art == Schachfigurenart.KOENIG){

        if(figurenMoves.figur.istWeiss){
          whiteKingPosition = [randomMove[0],randomMove[1]];
        }
        else{
          blackKingPosition = [randomMove[0],randomMove[1]];
        }

      }


      // en passant prüfen
      if(figurenMoves.figur.art == Schachfigurenart.BAUER && isEnPassantPosible(figurenMoves.figur, figurenMoves.row, figurenMoves.col)){
        var geschlagenerBauer = brett[moveInfos!.newRow][moveInfos!.newCol];

        if (geschlagenerBauer!.istWeiss) {
          weisseFigurenRaus.add(geschlagenerBauer);
        } else {
          schwarzeFigurenRaus.add(geschlagenerBauer);
        }

        brett[moveInfos!.newRow][moveInfos!.newCol] = null;
      }


      moveInfos = MoveInfos(
          oldRow: figurenMoves.row,
          oldCol: figurenMoves.col,
          newRow: randomMove[0],
          newCol: randomMove[1],
          figur: Schachfigur(art: figurenMoves.figur.art, istWeiss: figurenMoves.figur.istWeiss, isEnemy: figurenMoves.figur.isEnemy));

      brett[randomMove[0]][randomMove[1]] = figurenMoves.figur;
      brett[figurenMoves.row][figurenMoves.col] = null;

      setState(() {});

      if(isCheckMate(!isWhiteTurn)){

        String text="";
        if(isWhiteTurn == figurenfarbe){
          text="Du hast gewonnen!";
        }
        else{
          if(figurenfarbe){
            text= "Schwarz hat gewonnen!";
          }
          else{
            text= "Weiß hat gewonnen!";
          }
        }

        await warten(const Duration(seconds: 1, milliseconds: 500));

        await  showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return DialogSpielende(spielende: Spielende.SCHACHMATT,isWhiteTurn: isWhiteTurn, figurenfarbe: figurenfarbe, text: text, onTapNochmal:  () {resetGame();}, onTapBack:  () async {   Navigator.pop(context);
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SpielAuswahl()));});
        },
        );
        return;
      }
      else if(isStaleMate(!isWhiteTurn)){

        await warten(const Duration(seconds: 1, milliseconds: 500));

        await  showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return DialogSpielende(spielende: Spielende.REMIS,isWhiteTurn: isWhiteTurn, figurenfarbe: figurenfarbe, text: "Unentschieden durch Patt!", onTapNochmal:  () {resetGame();}, onTapBack:  () async {   Navigator.pop(context);
          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SpielAuswahl()));});
        },
        );
        return;
      }


      if(isKingInCheck(!isWhiteTurn)){
        checkStatus = true;
        showWarning(context: context, text: "Schach!", duration: const Duration(seconds: 2));
      }
      else{
        checkStatus = false;
      }

    }


  List<List<int>> calculateRealValidMoves(int row, int col, Schachfigur? schachfigur, bool checkSimulation){

    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, schachfigur);

    if(checkSimulation){

      for(var move in candidateMoves){
        int endRow = move[0];
        int endCol = move[1];
        if(simulatedMoveIsSave(schachfigur!, row, col, endRow, endCol)){
          realValidMoves.add(move);
        }
      }

    }
    else{
        realValidMoves = candidateMoves;
    }

    return realValidMoves;
  }

  bool isKingInCheck(bool isWhiteKing){

    List<int> kingposition = isWhiteKing ? whiteKingPosition : blackKingPosition;

    for(int i = 0; i < 8; i++){
      for(int j = 0; j < 8; j++){

        if(brett[i][j] == null || brett[i][j]!.istWeiss == isWhiteKing){
          continue;
        }

        List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, brett[i][j],false);
        if(pieceValidMoves.any((move) => move[0] == kingposition[0] && move[1] == kingposition[1])){
          return true;
        }

      }
    }

    return false;

  }

  bool simulatedMoveIsSave(Schachfigur figur, int startRow, int startCol, int endRow, int endCol){

    Schachfigur? originalDestinationPiece = brett[endRow][endCol];

    List<int>? originalKingPosition;
    if(figur.art == Schachfigurenart.KOENIG){

      originalKingPosition= figur.istWeiss ? whiteKingPosition : blackKingPosition;

      if(figur.istWeiss){
        whiteKingPosition = [endRow,endCol];
      }
      else{
        blackKingPosition = [endRow,endCol];
      }

    }

    bool enpassantMove= false;
    Schachfigur? lastPawnWhoMoves2Felder;
    if(figur.art == Schachfigurenart.BAUER && isEnPassantPosible(figur, startRow, startCol)){
        enpassantMove= true;
        lastPawnWhoMoves2Felder = brett[moveInfos!.newRow][moveInfos!.newCol];
        brett[moveInfos!.newRow][moveInfos!.newCol] = null;
    }


    brett[endRow][endCol] = figur;
    brett[startRow][startCol] = null;

    bool kingInCheck = isKingInCheck(figur.istWeiss);

    brett[startRow][startCol] = figur;
    brett[endRow][endCol] = originalDestinationPiece;

    if(figur.art == Schachfigurenart.KOENIG){
      if(figur.istWeiss){
        whiteKingPosition = originalKingPosition!;
      }
      else{
        blackKingPosition = originalKingPosition!;
      }
    }

    if(figur.art == Schachfigurenart.BAUER && enpassantMove){
      brett[moveInfos!.newRow][moveInfos!.newCol] = lastPawnWhoMoves2Felder;
    }


    return !kingInCheck;

  }

  bool isCheckMate(bool isWhiteKing){

    if(!isKingInCheck(isWhiteKing)){
          return false;
    }

    for(int i = 0; i < 8; i++){
      for(int j = 0; j < 8; j++){

        if(brett[i][j] == null || brett[i][j]!.istWeiss != isWhiteKing){
          continue;
        }

        List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, brett[i][j],true);
        if(pieceValidMoves.isNotEmpty){
          return false;
        }

      }
    }

    return true;

  }

  bool isStaleMate(bool isWhiteKing){

    for(int i = 0; i < 8; i++){
      for(int j = 0; j < 8; j++){

        if(brett[i][j] == null || brett[i][j]!.istWeiss != isWhiteKing){
          continue;
        }

        List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, brett[i][j],true);
        if(pieceValidMoves.isNotEmpty){
          return false;
        }

      }
    }

    return true;

  }


  String koordinatenAnzeige(int row, int col) {
    if (figurenfarbe) {
      int r = 8 - row;

      String c = "";
      switch (col) {
        case 0:
          c = "A";
          break;
        case 1:
          c = "B";
          break;
        case 2:
          c = "C";
          break;
        case 3:
          c = "D";
          break;
        case 4:
          c = "E";
          break;
        case 5:
          c = "F";
          break;
        case 6:
          c = "G";
          break;
        case 7:
          c = "H";
          break;
        default:
          "";
      }

      return "$c$r";
    } else {
      int r = row + 1;

      String c = "";
      switch (col) {
        case 0:
          c = "H";
          break;
        case 1:
          c = "G";
          break;
        case 2:
          c = "F";
          break;
        case 3:
          c = "E";
          break;
        case 4:
          c = "D";
          break;
        case 5:
          c = "C";
          break;
        case 6:
          c = "B";
          break;
        case 7:
          c = "A";
          break;
        default:
          "";
      }

      return "$c$r";
    }
  }


  Future<void> resetGame() async {

    Navigator.pop(context);

    setState(() {
      _startSpielbrett();
    });

    if(figurenfarbe == false){
     await computerMove();
      isWhiteTurn = !isWhiteTurn;
    }

  }

  @override
  Widget build(BuildContext context) {

    return

      PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool a,b) async {
          await showDialog(
          context: context,
          builder: (BuildContext context) {
            return DialogSpielabbruch(
                onTapNein:() {
                  Navigator.pop(context);
                },
                onTapJa:  () async {
                  Navigator.pop(context);
                  await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SpielAuswahl()));
                }
            );
          },
          );
        },
        child: SafeArea(
          child: Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,color: Colors.black, size: 35,),
            onPressed: () async {

             await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return DialogSpielabbruch(
                      onTapNein:() {
                        Navigator.pop(context);
                      },
                      onTapJa:  () async {
                        Navigator.pop(context);
                        await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SpielAuswahl()));
                      }
                   );
                },
              );

            },
          ),
        ),

          body: Column(
            children: [
              Expanded(
                child: Container(
                  color: backgroundColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: GridView.builder(
                      itemCount: figurenfarbe
                          ? weisseFigurenRaus.length
                          : schwarzeFigurenRaus.length,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 8),
                      itemBuilder: (context, index) {
                        return Image.asset(
                          figurenfarbe
                              ? weisseFigurenRaus[index].bild
                              : schwarzeFigurenRaus[index].bild,
                          color:
                              figurenfarbe ? Colors.grey[400] : Colors.grey[800],
                        );
                      }),
                ),
              ),

             // checkStatus ? showWarning(context: context, text: "Schach!", duration: const Duration(seconds: 1)) : Container(),

              Container(
                color: backgroundColor,
                height: MediaQuery.of(context).size.width,
                child: GridView.builder(
                    itemCount: 8 * 8,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 8),
                    itemBuilder: (context, index) {

                      int row = index ~/ 8;
                      int col = index % 8;

                      bool ausgewaehlt =
                          selectedRow == row && selectedColumn == col;

                      bool isValidMove = false;
                      bool canBeTakeOut= false;
                      for (var position in validMoves) {
                        if (position[0] == row && position[1] == col) {
                          if(brett[position[0]][position[1]] != null){
                            canBeTakeOut= true;
                          }
                          isValidMove = true;
                        }
                      }

                      bool lastMoveFrom = false;
                      bool lastMoveTo = false;
                      if (moveInfos != null) {
                        lastMoveFrom =
                            moveInfos!.oldRow == row && moveInfos!.oldCol == col;
                        lastMoveTo =
                            moveInfos!.newRow == row && moveInfos!.newCol == col;
                      }

                      bool kingInCheck=false;
                      bool isCheckmate= false;
                      if( isKingInCheck(true) && whiteKingPosition[0] == row && whiteKingPosition[1] == col ){
                         kingInCheck=true;
                      }
                      if( isKingInCheck(false) && blackKingPosition[0] == row && blackKingPosition[1] == col){
                        kingInCheck=true;
                      }
                      if(isCheckMate(true) && whiteKingPosition[0] == row && whiteKingPosition[1] == col){
                        isCheckmate=true;
                      }
                      if(isCheckMate(false) && blackKingPosition[0] == row && blackKingPosition[1] == col){
                        isCheckmate=true;
                      }

                      return Feld(
                        istWeiss: istWeiss(index),
                        figur: brett[row][col],
                        ausgewaehlt: ausgewaehlt,
                        isValidMove: isValidMove,
                        canBeTakenOut: canBeTakeOut,
                        lastMoveFrom: lastMoveFrom,
                        lastMoveTo: lastMoveTo,
                        kingInCheck: kingInCheck,
                        isCheckmate: isCheckmate,
                        onTap: () {
                          figurAusgewaehlt(row, col);
                        },
                      );
                    }),
              ),
              Expanded(
                child: Container(
                  color: backgroundColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: GridView.builder(
                      itemCount: figurenfarbe
                          ? schwarzeFigurenRaus.length
                          : weisseFigurenRaus.length,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 8),
                      itemBuilder: (context, index) {
                        return Image.asset(
                          figurenfarbe
                              ? schwarzeFigurenRaus[index].bild
                              : weisseFigurenRaus[index].bild,
                          color:
                              figurenfarbe ? Colors.grey[800] : Colors.grey[400],
                        );
                      }),
                ),
              ),
            ],
          ),
              ),
        ),
      );
  }


  Future<void> warten(Duration duration) async {
    await Future.delayed(duration);
  }

}
