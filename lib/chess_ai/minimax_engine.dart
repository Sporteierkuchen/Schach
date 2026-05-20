import 'dart:math';

import '../components/FigurenMovesArray.dart';
import 'ai_move.dart';
import 'board_evaluator.dart';
import 'board_helper.dart';
import 'move_generator.dart';
import 'move_ordering.dart';
import 'transposition_table.dart';

class MinimaxEngine {
  final MoveGenerator moveGenerator;
  final BoardEvaluator evaluator;
  final MoveOrdering moveOrdering;
  final TranspositionTable transpositionTable;

  MinimaxEngine({
    required this.moveGenerator,
    required this.evaluator,
    required this.moveOrdering,
    required this.transpositionTable,
  });

  AiMove? findBestMove({
    required List<int> board,
    required int depth,
    required bool isEnemyMove,
    required bool isWhiteTurn,
  }) {
    final int? whiteKingIndex = BoardHelper.getKingIndex(board, true);
    final int? blackKingIndex = BoardHelper.getKingIndex(board, false);

    if (whiteKingIndex == null || blackKingIndex == null) {
      return null;
    }

    final List<FigurenMovesArray> moves = moveGenerator.getAllLegalMoves(
      board: board,
      isEnemyMove: isEnemyMove,
      isWhiteTurn: isWhiteTurn,
      whiteKingIndex: whiteKingIndex,
      blackKingIndex: blackKingIndex,
    );

    if (moves.isEmpty) return null;

    final List<FigurenMovesArray> orderedMoves =
    moveOrdering.orderMoves(moves, board);

    int bestScore = isEnemyMove ? 999999999 : -999999999;
    final List<AiMove> bestMoves = [];

    for (final FigurenMovesArray move in orderedMoves) {
      for (final int target in move.targetIndices) {
        final bool promotion =
            move.piece.abs() == 1 &&
                (BoardHelper.getRow(target) == 0 ||
                    BoardHelper.getRow(target) == 7);

        final List<int> promotionPieces =
        promotion ? [5, 4, 3, 2] : [move.piece];

        for (final int promo in promotionPieces) {
          final List<int> copy = List<int>.from(board);

          final int? promotionPiece =
          promotion ? (move.piece > 0 ? promo : -promo) : null;

          BoardHelper.makeMove(
            copy,
            move.fromIndex,
            target,
            promotionPiece: promotionPiece,
          );

          final int score = minimax(
            board: copy,
            depth: depth - 1,
            isEnemyMove: !isEnemyMove,
            isWhiteTurn: !isWhiteTurn,
            alpha: -999999999,
            beta: 999999999,
          );

          final AiMove aiMove = AiMove(
            fromIndex: move.fromIndex,
            toIndex: target,
            piece: move.piece,
            promotionPiece: promotionPiece,
            score: score,
          );

          final bool better = isEnemyMove
              ? score < bestScore
              : score > bestScore;

          if (better) {
            bestScore = score;
            bestMoves
              ..clear()
              ..add(aiMove);
          } else if (score == bestScore) {
            bestMoves.add(aiMove);
          }
        }
      }
    }

    final Random random = Random();
    final AiMove selected = bestMoves[random.nextInt(bestMoves.length)];

    print(
      "⭐ Beste Bewertung Tiefe $depth: $bestScore | Kandidaten: ${bestMoves.length}",
    );

/*    print(
      "KI-Zug: ${BoardHelper.indexToCoord(selected.fromIndex)} → ${BoardHelper.indexToCoord(selected.toIndex)}",
    );*/

    return selected;
  }

  int minimax({
    required List<int> board,
    required int depth,
    required bool isEnemyMove,
    required bool isWhiteTurn,
    required int alpha,
    required int beta,
  }) {
    final String key = BoardHelper.boardKey(board, isEnemyMove, isWhiteTurn);
    final TranspositionEntry? cached =
    transpositionTable.get(key, depth);

    if (cached != null) {
      return cached.score;
    }

    final int? whiteKingIndex = BoardHelper.getKingIndex(board, true);
    final int? blackKingIndex = BoardHelper.getKingIndex(board, false);

    if (whiteKingIndex == null || blackKingIndex == null) {
      return evaluator.evaluate(board);
    }

    if (moveGenerator.isCheckmate(
      board: board,
      isEnemyMove: isEnemyMove,
      isWhiteTurn: isWhiteTurn,
      whiteKingIndex: whiteKingIndex,
      blackKingIndex: blackKingIndex,
    )) {
      final int score = isEnemyMove ? 999999 - depth : -999999 + depth;
      transpositionTable.put(key, depth, score);
      return score;
    }

    if (moveGenerator.isStalemate(
      board: board,
      isEnemyMove: isEnemyMove,
      isWhiteTurn: isWhiteTurn,
      whiteKingIndex: whiteKingIndex,
      blackKingIndex: blackKingIndex,
    )) {
      transpositionTable.put(key, depth, 0);
      return 0;
    }

    if (moveGenerator.isInsufficientMaterial(board)) {
      transpositionTable.put(key, depth, 0);
      return 0;
    }

    if (depth == 0) {
      final int score = evaluator.evaluate(board);
      transpositionTable.put(key, depth, score);
      return score;
    }

    final List<FigurenMovesArray> moves = moveGenerator.getAllLegalMoves(
      board: board,
      isEnemyMove: isEnemyMove,
      isWhiteTurn: isWhiteTurn,
      whiteKingIndex: whiteKingIndex,
      blackKingIndex: blackKingIndex,
    );

    if (moves.isEmpty) {
      final int score = evaluator.evaluate(board);
      transpositionTable.put(key, depth, score);
      return score;
    }

    final List<FigurenMovesArray> orderedMoves =
    moveOrdering.orderMoves(moves, board);

    int localAlpha = alpha;
    int localBeta = beta;

    if (isEnemyMove) {
      int best = 999999999;

      for (final FigurenMovesArray move in orderedMoves) {
        for (final int target in move.targetIndices) {
          final bool promotion =
              move.piece.abs() == 1 &&
                  (BoardHelper.getRow(target) == 0 ||
                      BoardHelper.getRow(target) == 7);

          final List<int> promotionPieces =
          promotion ? [5, 4, 3, 2] : [move.piece];

          for (final int promo in promotionPieces) {
            final List<int> copy = List<int>.from(board);

            final int? promotionPiece =
            promotion ? (move.piece > 0 ? promo : -promo) : null;

            BoardHelper.makeMove(
              copy,
              move.fromIndex,
              target,
              promotionPiece: promotionPiece,
            );

            final int score = minimax(
              board: copy,
              depth: depth - 1,
              isEnemyMove: false,
              isWhiteTurn: !isWhiteTurn,
              alpha: localAlpha,
              beta: localBeta,
            );

            best = min(best, score);
            localBeta = min(localBeta, score);

            if (localBeta <= localAlpha) {
              transpositionTable.put(key, depth, best);
              return best;
            }
          }
        }
      }

      transpositionTable.put(key, depth, best);
      return best;
    } else {
      int best = -999999999;

      for (final FigurenMovesArray move in orderedMoves) {
        for (final int target in move.targetIndices) {
          final bool promotion =
              move.piece.abs() == 1 &&
                  (BoardHelper.getRow(target) == 0 ||
                      BoardHelper.getRow(target) == 7);

          final List<int> promotionPieces =
          promotion ? [5, 4, 3, 2] : [move.piece];

          for (final int promo in promotionPieces) {
            final List<int> copy = List<int>.from(board);

            final int? promotionPiece =
            promotion ? (move.piece > 0 ? promo : -promo) : null;

            BoardHelper.makeMove(
              copy,
              move.fromIndex,
              target,
              promotionPiece: promotionPiece,
            );

            final int score = minimax(
              board: copy,
              depth: depth - 1,
              isEnemyMove: true,
              isWhiteTurn: !isWhiteTurn,
              alpha: localAlpha,
              beta: localBeta,
            );

            best = max(best, score);
            localAlpha = max(localAlpha, score);

            if (localAlpha >= localBeta) {
              transpositionTable.put(key, depth, best);
              return best;
            }
          }
        }
      }

      transpositionTable.put(key, depth, best);
      return best;
    }
  }
}