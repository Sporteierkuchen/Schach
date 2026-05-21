import 'dart:math';

import '../components/FigurenMovesArray.dart';
import 'ai_game_state.dart';
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
    required AiGameState state,
    required int depth,
  }) {
    final List<int> board = state.board;

    final int? whiteKingIndex = BoardHelper.getKingIndex(board, true);
    final int? blackKingIndex = BoardHelper.getKingIndex(board, false);

    if (whiteKingIndex == null || blackKingIndex == null) {
      return null;
    }

    final List<FigurenMovesArray> moves = moveGenerator.getAllLegalMoves(
      state: state,
    );

    if (moves.isEmpty) {
      return null;
    }

    final List<FigurenMovesArray> orderedMoves =
    moveOrdering.orderMoves(moves, board);

    int bestScore = state.isWhiteTurn ? -999999999 : 999999999;
    final List<AiMove> bestMoves = [];

    for (final FigurenMovesArray move in orderedMoves) {
      for (final int target in move.targetIndices) {
        final bool promotion = _isPromotion(move.piece, target);
        final List<int> promotionPieces =
        promotion ? [5, 4, 3, 2] : [move.piece];

        for (final int promo in promotionPieces) {
          final int? promotionPiece =
          promotion ? (move.piece > 0 ? promo : -promo) : null;

          final AiGameState nextState = _makeNextState(
            state: state,
            move: move,
            target: target,
            promotionPiece: promotionPiece,
          );

          final int score = minimax(
            state: nextState,
            depth: depth - 1,
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

          final bool better =
          state.isWhiteTurn ? score > bestScore : score < bestScore;

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

    final AiMove selected = bestMoves[Random().nextInt(bestMoves.length)];

    print(
      "⭐ Beste Bewertung Tiefe $depth: $bestScore | Kandidaten: ${bestMoves.length}",
    );

    return selected;
  }

  int minimax({
    required AiGameState state,
    required int depth,
    required int alpha,
    required int beta,
  }) {
    final List<int> board = state.board;
    final bool isWhiteTurn = state.isWhiteTurn;

    final String key = _buildTranspositionKey(
      state: state,
    );

    final TranspositionEntry? cached = transpositionTable.get(
      key,
      depth,
    );

    if (cached != null) {
      return cached.score;
    }

    final int? whiteKingIndex = BoardHelper.getKingIndex(
      board,
      true,
    );

    final int? blackKingIndex = BoardHelper.getKingIndex(
      board,
      false,
    );

    if (whiteKingIndex == null || blackKingIndex == null) {
      return evaluator.evaluate(board);
    }

    if (moveGenerator.isCheckmate(
      state: state,
    )) {
      final int score = isWhiteTurn
          ? -999999 + depth
          : 999999 - depth;

      transpositionTable.put(
        key,
        depth,
        score,
      );

      return score;
    }

    if (moveGenerator.isStalemate(
      state: state,
    )) {
      transpositionTable.put(
        key,
        depth,
        0,
      );

      return 0;
    }

    if (moveGenerator.isInsufficientMaterial(board)) {
      transpositionTable.put(
        key,
        depth,
        0,
      );

      return 0;
    }

    if (depth == 0) {
      final int score = evaluator.evaluate(board);

      transpositionTable.put(
        key,
        depth,
        score,
      );

      return score;
    }

    final List<FigurenMovesArray> moves = moveGenerator.getAllLegalMoves(
      state: state,
    );

    if (moves.isEmpty) {
      final int score = evaluator.evaluate(board);

      transpositionTable.put(
        key,
        depth,
        score,
      );

      return score;
    }

    final List<FigurenMovesArray> orderedMoves =
    moveOrdering.orderMoves(moves, board);

    int localAlpha = alpha;
    int localBeta = beta;

    if (!isWhiteTurn) {
      int best = 999999999;

      for (final FigurenMovesArray move in orderedMoves) {
        for (final int target in move.targetIndices) {
          final bool promotion = _isPromotion(move.piece, target);
          final List<int> promotionPieces =
          promotion ? [5, 4, 3, 2] : [move.piece];

          for (final int promo in promotionPieces) {
            final int? promotionPiece =
            promotion ? (move.piece > 0 ? promo : -promo) : null;

            final AiGameState nextState = _makeNextState(
              state: state,
              move: move,
              target: target,
              promotionPiece: promotionPiece,
            );

            final int score = minimax(
              state: nextState,
              depth: depth - 1,
              alpha: localAlpha,
              beta: localBeta,
            );

            best = min(best, score);
            localBeta = min(localBeta, score);

            if (localBeta <= localAlpha) {
              transpositionTable.put(
                key,
                depth,
                best,
              );

              return best;
            }
          }
        }
      }

      transpositionTable.put(
        key,
        depth,
        best,
      );

      return best;
    } else {
      int best = -999999999;

      for (final FigurenMovesArray move in orderedMoves) {
        for (final int target in move.targetIndices) {
          final bool promotion = _isPromotion(move.piece, target);
          final List<int> promotionPieces =
          promotion ? [5, 4, 3, 2] : [move.piece];

          for (final int promo in promotionPieces) {
            final int? promotionPiece =
            promotion ? (move.piece > 0 ? promo : -promo) : null;

            final AiGameState nextState = _makeNextState(
              state: state,
              move: move,
              target: target,
              promotionPiece: promotionPiece,
            );

            final int score = minimax(
              state: nextState,
              depth: depth - 1,
              alpha: localAlpha,
              beta: localBeta,
            );

            best = max(best, score);
            localAlpha = max(localAlpha, score);

            if (localAlpha >= localBeta) {
              transpositionTable.put(
                key,
                depth,
                best,
              );

              return best;
            }
          }
        }
      }

      transpositionTable.put(
        key,
        depth,
        best,
      );

      return best;
    }
  }

  bool _isPromotion(
      int piece,
      int targetIndex,
      ) {
    return piece.abs() == 1 &&
        (BoardHelper.getRow(targetIndex) == 0 ||
            BoardHelper.getRow(targetIndex) == 7);
  }

  AiGameState _makeNextState({
    required AiGameState state,
    required FigurenMovesArray move,
    required int target,
    required int? promotionPiece,
  }) {
    final List<int> newBoard = List<int>.from(state.board);

    final bool isEnPassantMove =
        move.piece.abs() == 1 &&
            state.enPassantTargetIndex != null &&
            target == state.enPassantTargetIndex &&
            state.board[target] == 0 &&
            BoardHelper.getCol(move.fromIndex) != BoardHelper.getCol(target);

    if (isEnPassantMove) {
      final int capturedPawnIndex =
      move.piece > 0 ? target + 8 : target - 8;

      if (capturedPawnIndex >= 0 && capturedPawnIndex < 64) {
        newBoard[capturedPawnIndex] = 0;
      }
    }

    final bool isCastleMove =
        move.piece.abs() == 6 &&
            (BoardHelper.getCol(move.fromIndex) -
                BoardHelper.getCol(target))
                .abs() ==
                2;

    BoardHelper.makeMove(
      newBoard,
      move.fromIndex,
      target,
      promotionPiece: promotionPiece,
    );

    if (isCastleMove) {
      _applyCastleRookMove(
        board: newBoard,
        fromIndex: move.fromIndex,
        toIndex: target,
      );
    }

    return state.copyWith(
      board: newBoard,
      isEnemyMove: !state.isEnemyMove,
      isWhiteTurn: !state.isWhiteTurn,
      enPassantTargetIndex: _calculateNextEnPassantTarget(
        move: move,
        target: target,
      ),
      castlingRights: _updateCastlingRights(
        state: state,
        move: move,
        target: target,
      ),
    );
  }

  void _applyCastleRookMove({
    required List<int> board,
    required int fromIndex,
    required int toIndex,
  }) {
    final int row = BoardHelper.getRow(fromIndex);
    final int fromCol = BoardHelper.getCol(fromIndex);
    final int toCol = BoardHelper.getCol(toIndex);

    if (toCol > fromCol) {
      final int rookFrom = BoardHelper.getIndex(row, 7);
      final int rookTo = BoardHelper.getIndex(row, toCol - 1);

      board[rookTo] = board[rookFrom];
      board[rookFrom] = 0;
    } else {
      final int rookFrom = BoardHelper.getIndex(row, 0);
      final int rookTo = BoardHelper.getIndex(row, toCol + 1);

      board[rookTo] = board[rookFrom];
      board[rookFrom] = 0;
    }
  }

  int? _calculateNextEnPassantTarget({
    required FigurenMovesArray move,
    required int target,
  }) {
    if (move.piece.abs() != 1) {
      return null;
    }

    final int fromRow = BoardHelper.getRow(move.fromIndex);
    final int toRow = BoardHelper.getRow(target);

    if ((fromRow - toRow).abs() != 2) {
      return null;
    }

    final int targetRow = (fromRow + toRow) ~/ 2;
    final int targetCol = BoardHelper.getCol(move.fromIndex);

    return BoardHelper.getIndex(
      targetRow,
      targetCol,
    );
  }

  AiCastlingRights _updateCastlingRights({
    required AiGameState state,
    required FigurenMovesArray move,
    required int target,
  }) {
    AiCastlingRights rights = state.castlingRights;

    final int piece = move.piece;
    final int from = move.fromIndex;

    if (piece == 6) {
      rights = rights.copyWith(
        whiteKingSide: false,
        whiteQueenSide: false,
      );
    }

    if (piece == -6) {
      rights = rights.copyWith(
        blackKingSide: false,
        blackQueenSide: false,
      );
    }

    if (piece == 4) {
      if (from == 63) {
        rights = rights.copyWith(
          whiteKingSide: false,
        );
      }

      if (from == 56) {
        rights = rights.copyWith(
          whiteQueenSide: false,
        );
      }
    }

    if (piece == -4) {
      if (from == 7) {
        rights = rights.copyWith(
          blackKingSide: false,
        );
      }

      if (from == 0) {
        rights = rights.copyWith(
          blackQueenSide: false,
        );
      }
    }

    final int capturedPiece = state.board[target];

    if (capturedPiece == 4) {
      if (target == 63) {
        rights = rights.copyWith(
          whiteKingSide: false,
        );
      }

      if (target == 56) {
        rights = rights.copyWith(
          whiteQueenSide: false,
        );
      }
    }

    if (capturedPiece == -4) {
      if (target == 7) {
        rights = rights.copyWith(
          blackKingSide: false,
        );
      }

      if (target == 0) {
        rights = rights.copyWith(
          blackQueenSide: false,
        );
      }
    }

    return rights;
  }

  String _buildTranspositionKey({
    required AiGameState state,
  }) {
    final AiCastlingRights rights = state.castlingRights;

    return "${state.board.join(",")}"
        "|turn=${state.isWhiteTurn}"
        "|enemy=${state.isEnemyMove}"
        "|ep=${state.enPassantTargetIndex ?? "-"}"
        "|wk=${rights.whiteKingSide}"
        "|wq=${rights.whiteQueenSide}"
        "|bk=${rights.blackKingSide}"
        "|bq=${rights.blackQueenSide}";
  }
}