import 'package:flutter/material.dart';
import 'package:schach/components/feld.dart';
import 'package:schach/game/logic/game_end_checker.dart';
import 'package:schach/game/logic/move_generator.dart';
import 'package:schach/game/models/game_state.dart';
import 'package:schach/helper/helper.dart';

class ChessBoardWidget extends StatelessWidget {
  final GameState gameState;
  final MoveGenerator moveGenerator;
  final GameEndChecker gameEndChecker;

  final int selectedRow;
  final int selectedColumn;
  final List<List<int>> validMoves;

  final String Function(int col) fileLabelForGuiCol;
  final String Function(int row) rankLabelForGuiRow;

  final void Function(int row, int col) onFieldTap;

  const ChessBoardWidget({
    super.key,
    required this.gameState,
    required this.moveGenerator,
    required this.gameEndChecker,
    required this.selectedRow,
    required this.selectedColumn,
    required this.validMoves,
    required this.fileLabelForGuiCol,
    required this.rankLabelForGuiRow,
    required this.onFieldTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool whiteInCheck = moveGenerator.isKingInCheck(
      true,
      gameState,
    );

    final bool blackInCheck = moveGenerator.isKingInCheck(
      false,
      gameState,
    );

    final bool whiteCheckmate = gameEndChecker.isCheckMate(
      true,
      gameState,
    );

    final bool blackCheckmate = gameEndChecker.isCheckMate(
      false,
      gameState,
    );

    return Container(
      height: MediaQuery.of(context).size.width,
      child: GridView.builder(
        itemCount: 64,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemBuilder: (context, index) {
          final int row = index ~/ 8;
          final int col = index % 8;

          final bool ausgewaehlt =
              selectedRow == row && selectedColumn == col;

          bool isValidMove = false;
          bool canBeTakenOut = false;

          for (final position in validMoves) {
            if (position[0] == row && position[1] == col) {
              isValidMove = true;

              if (gameState.brett[row][col] != null) {
                canBeTakenOut = true;
              }
            }
          }

          bool lastMoveFrom = false;
          bool lastMoveTo = false;

          if (gameState.moveInfos != null) {
            lastMoveFrom =
                gameState.moveInfos!.oldRow == row &&
                    gameState.moveInfos!.oldCol == col;

            lastMoveTo =
                gameState.moveInfos!.newRow == row &&
                    gameState.moveInfos!.newCol == col;
          }

          bool kingInCheck = false;
          bool isCheckmate = false;

          if (whiteInCheck &&
              gameState.whiteKingPosition[0] == row &&
              gameState.whiteKingPosition[1] == col) {
            kingInCheck = true;
          }

          if (blackInCheck &&
              gameState.blackKingPosition[0] == row &&
              gameState.blackKingPosition[1] == col) {
            kingInCheck = true;
          }

          if (whiteCheckmate &&
              gameState.whiteKingPosition[0] == row &&
              gameState.whiteKingPosition[1] == col) {
            isCheckmate = true;
          }

          if (blackCheckmate &&
              gameState.blackKingPosition[0] == row &&
              gameState.blackKingPosition[1] == col) {
            isCheckmate = true;
          }

          final bool showRank = col == 0;
          final bool showFile = row == 7;

          final bool lightSquare = istWeiss(index);

          final Color coordinateColor =
          lightSquare ? Colors.black54 : Colors.white70;

          return Stack(
            children: [
              Positioned.fill(
                child: Feld(
                  istWeiss: lightSquare,
                  figur: gameState.brett[row][col],
                  ausgewaehlt: ausgewaehlt,
                  isValidMove: isValidMove,
                  canBeTakenOut: canBeTakenOut,
                  lastMoveFrom: lastMoveFrom,
                  lastMoveTo: lastMoveTo,
                  kingInCheck: kingInCheck,
                  isCheckmate: isCheckmate,
                  onTap: () {
                    onFieldTap(row, col);
                  },
                ),
              ),

              if (showRank)
                Positioned(
                  top: 3,
                  left: 4,
                  child: Text(
                    rankLabelForGuiRow(row),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: coordinateColor,
                    ),
                  ),
                ),

              if (showFile)
                Positioned(
                  right: 4,
                  bottom: 2,
                  child: Text(
                    fileLabelForGuiCol(col),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: coordinateColor,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}