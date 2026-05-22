import 'dart:math';

import '../chess_ai/ai_game_state.dart';
import '../chess_ai/ai_move.dart';
import '../chess_ai/board_helper.dart';
import '../chess_ai/move_generator.dart';
import '../chess_ai/move_ordering.dart';
import 'opening_book.dart';

class OpeningBookService {

  final Random random = Random();

  AiMove? findBookMove({

    required AiGameState state,

    required List<String> moveHistory,

    required MoveGenerator moveGenerator,

    required MoveOrdering moveOrdering,

    required int aiLevel,

    required OpeningStyle style,
  }) {

    final List<_BookCandidate> candidates = [];

    for(final opening in OpeningBook.lines){

      if(aiLevel < opening.minLevel){
        continue;
      }

      if(aiLevel > opening.maxLevel){
        continue;
      }

      if(
      opening.style != style &&
          style != OpeningStyle.balanced
      ){
        continue;
      }

      if(moveHistory.length >= opening.line.length){
        continue;
      }

      bool fits = true;

      for(
      int i=0;
      i<moveHistory.length;
      i++
      ){

        if(
        opening.line[i] !=
            moveHistory[i]
        ){

          fits=false;

          break;
        }
      }

      if(!fits){
        continue;
      }

      candidates.add(

        _BookCandidate(

          move:

          opening.line[
          moveHistory.length
          ],

          weight:

          opening.weight,

          name:

          opening.name,
        ),
      );
    }

    if(candidates.isEmpty){

      return null;
    }

    final candidate =
    _weightedChoice(
        candidates
    );

    final grouped =
    moveGenerator
        .getAllLegalMoves(
      state: state,
    );

    final legal =
    moveOrdering
        .flattenAndOrderMoves(
      grouped,
      state.board,
    );

    for(final move in legal){

      if(

      _toUci(move)==
          candidate.move

      ){

        print(

            "📖 "
                "${candidate.name}"
                " -> "
                "${candidate.move}"

        );

        return move;
      }
    }

    return null;
  }

  _BookCandidate
  _weightedChoice(

      List<_BookCandidate>
      candidates

      ){

    int total=0;

    for(
    final c
    in candidates
    ){

      total+=c.weight;
    }

    int value=
    random.nextInt(total);

    int current=0;

    for(
    final c
    in candidates
    ){

      current+=c.weight;

      if(
      value<current
      ){

        return c;
      }
    }

    return candidates.first;
  }

  String _toUci(
      AiMove move
      ){

    return

      BoardHelper.indexToCoord(
          move.fromIndex
      )+

          BoardHelper.indexToCoord(
              move.toIndex
          );
  }
}

class _BookCandidate{

  final String move;

  final int weight;

  final String name;

  _BookCandidate({

    required this.move,

    required this.weight,

    required this.name,
  });
}