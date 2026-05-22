import 'dart:math';

import 'ai_game_state.dart';
import 'ai_move.dart';
import 'board_evaluator.dart';
import 'board_helper.dart';
import 'move_generator.dart';
import 'move_ordering.dart';
import 'transposition_table.dart';
import 'zobrist_hasher.dart';

class MinimaxEngine {
  final MoveGenerator moveGenerator;
  final BoardEvaluator evaluator;
  final MoveOrdering moveOrdering;
  final TranspositionTable transpositionTable;

  static const int infinity = 1000000000;
  static const int mateScore = 900000;
  static const int quiescenceDepth = 4;

  int searchedNodes = 0;

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
    searchedNodes = 0;

    final List<AiMove> legalMoves = _getOrderedMoves(
      state: state,
      hashEntry: null,
    );

    if (legalMoves.isEmpty) {
      return null;
    }

    int bestScore = state.isWhiteTurn ? -infinity : infinity;
    final List<AiMove> bestMoves = [];

    int alpha = -infinity;
    int beta = infinity;

    for (final AiMove move in legalMoves) {
      final AiGameState nextState = _makeNextState(
        state: state,
        move: move,
      );

      final int score = minimax(
        state: nextState,
        depth: depth - 1,
        alpha: alpha,
        beta: beta,
        ply: 1,
      );

      final AiMove scoredMove = AiMove(
        fromIndex: move.fromIndex,
        toIndex: move.toIndex,
        piece: move.piece,
        promotionPiece: move.promotionPiece,
        score: score,
      );

      final bool better =
      state.isWhiteTurn
          ? score > bestScore
          : score < bestScore;

      if (better) {
        bestScore = score;

        bestMoves
          ..clear()
          ..add(scoredMove);

      } else if (score == bestScore) {
        bestMoves.add(scoredMove);
      }

      if (state.isWhiteTurn) {
        alpha = max(alpha, bestScore);
      } else {
        beta = min(beta, bestScore);
      }
    }

    final AiMove selected =
    bestMoves[
    Random().nextInt(bestMoves.length)
    ];

    print(
      "⭐ Beste Bewertung Tiefe $depth: "
          "$bestScore | "
          "Kandidaten: ${bestMoves.length} | "
          "Nodes: $searchedNodes | "
          "TT: ${transpositionTable.size}",
    );

    return selected;
  }

  AiMove? findBestMoveTimed({
    required AiGameState state,
    required int depth,
    required Stopwatch stopwatch,
    required int timeLimitMs,
  }) {

    searchedNodes = 0;

    final List<AiMove> legalMoves =
    _getOrderedMoves(
      state: state,
      hashEntry: null,
    );

    if (legalMoves.isEmpty) {
      return null;
    }

    int? bestScore;
    AiMove? bestMove;

    int alpha = -infinity;
    int beta = infinity;

    for (final AiMove move in legalMoves) {

      if (stopwatch.elapsedMilliseconds >= timeLimitMs) {
        break;
      }

      final AiGameState nextState =
      _makeNextState(
        state: state,
        move: move,
      );

      final int score =
      minimaxTimed(
        state: nextState,
        depth: depth - 1,
        alpha: alpha,
        beta: beta,
        ply: 1,
        stopwatch: stopwatch,
        timeLimitMs: timeLimitMs,
      );

      if (stopwatch.elapsedMilliseconds >= timeLimitMs) {
        break;
      }

      final bool better =
          bestScore == null ||
              (
                  state.isWhiteTurn
                      ? score > bestScore
                      : score < bestScore
              );

      if (better || bestMove == null) {

        bestScore = score;

        bestMove = AiMove(
          fromIndex: move.fromIndex,
          toIndex: move.toIndex,
          piece: move.piece,
          promotionPiece: move.promotionPiece,
          score: score,
        );
      }

      if (state.isWhiteTurn) {

        alpha =
            max(
              alpha,
              bestScore,
            );

      } else {

        beta =
            min(
              beta,
              bestScore,
            );
      }

      if (alpha >= beta) {
        break;
      }
    }

    print(
      "🔎 Tiefe $depth | "
          "Score: ${bestScore ?? "TIMEOUT"} | "
          "Nodes: $searchedNodes | "
          "Zeit: ${stopwatch.elapsedMilliseconds} ms",
    );

    return bestMove;
  }

  int minimax({
    required AiGameState state,
    required int depth,
    required int alpha,
    required int beta,
    required int ply,
  }) {

    searchedNodes++;

    final int key =
    _buildTranspositionKey(
      state: state,
    );

    final int originalAlpha = alpha;
    final int originalBeta = beta;

    int localAlpha = alpha;
    int localBeta = beta;

    final TranspositionEntry? entry =
    transpositionTable.get(key);

    if (entry != null &&
        entry.depth >= depth) {

      if (entry.flag ==
          TranspositionFlag.exact) {

        return entry.score;
      }

      if (entry.flag ==
          TranspositionFlag.lowerBound) {

        localAlpha =
            max(localAlpha, entry.score);

      } else if (entry.flag ==
          TranspositionFlag.upperBound) {

        localBeta =
            min(localBeta, entry.score);
      }

      if (localAlpha >= localBeta) {
        return entry.score;
      }
    }

    final int? whiteKingIndex =
    BoardHelper.getKingIndex(
      state.board,
      true,
    );

    final int? blackKingIndex =
    BoardHelper.getKingIndex(
      state.board,
      false,
    );

    if (whiteKingIndex == null ||
        blackKingIndex == null) {

      return evaluator.evaluate(
        state.board,
      );
    }

    if (moveGenerator.isCheckmate(
      state: state,
    )) {

      if (state.isWhiteTurn) {
        return -mateScore + ply;
      }

      return mateScore - ply;
    }

    if (moveGenerator.isStalemate(
      state: state,
    )) {
      return 0;
    }

    if (moveGenerator.isInsufficientMaterial(
      state.board,
    )) {
      return 0;
    }

    if (depth <= 0) {

      return quiescence(
        state: state,
        alpha: localAlpha,
        beta: localBeta,
        depth: quiescenceDepth,
      );
    }

    final List<AiMove> moves =
    _getOrderedMoves(
      state: state,
      hashEntry: entry,
    );

    if (moves.isEmpty) {

      return evaluator.evaluate(
        state.board,
      );
    }

    AiMove? bestMove;

    if (state.isWhiteTurn) {

      int bestScore = -infinity;

      for (final AiMove move in moves) {

        final AiGameState nextState =
        _makeNextState(
          state: state,
          move: move,
        );

        final int score = minimax(
          state: nextState,
          depth: depth - 1,
          alpha: localAlpha,
          beta: localBeta,
          ply: ply + 1,
        );

        if (score > bestScore) {
          bestScore = score;
          bestMove = move;
        }

        localAlpha =
            max(localAlpha, bestScore);

        if (localAlpha >= localBeta) {
          break;
        }
      }

      _storeTransposition(
        key: key,
        depth: depth,
        score: bestScore,
        originalAlpha: originalAlpha,
        originalBeta: originalBeta,
        bestMove: bestMove,
      );

      return bestScore;

    } else {

      int bestScore = infinity;

      for (final AiMove move in moves) {

        final AiGameState nextState =
        _makeNextState(
          state: state,
          move: move,
        );

        final int score = minimax(
          state: nextState,
          depth: depth - 1,
          alpha: localAlpha,
          beta: localBeta,
          ply: ply + 1,
        );

        if (score < bestScore) {
          bestScore = score;
          bestMove = move;
        }

        localBeta =
            min(localBeta, bestScore);

        if (localAlpha >= localBeta) {
          break;
        }
      }

      _storeTransposition(
        key: key,
        depth: depth,
        score: bestScore,
        originalAlpha: originalAlpha,
        originalBeta: originalBeta,
        bestMove: bestMove,
      );

      return bestScore;
    }
  }

  int minimaxTimed({
    required AiGameState state,
    required int depth,
    required int alpha,
    required int beta,
    required int ply,
    required Stopwatch stopwatch,
    required int timeLimitMs,
  }) {
    if (stopwatch.elapsedMilliseconds >= timeLimitMs) {
      return evaluator.evaluate(state.board);
    }

    searchedNodes++;

    final int key = _buildTranspositionKey(
      state: state,
    );

    final int originalAlpha = alpha;
    final int originalBeta = beta;

    int localAlpha = alpha;
    int localBeta = beta;

    final TranspositionEntry? entry = transpositionTable.get(key);

    if (entry != null && entry.depth >= depth) {
      if (entry.flag == TranspositionFlag.exact) {
        return entry.score;
      }

      if (entry.flag == TranspositionFlag.lowerBound) {
        localAlpha = max(localAlpha, entry.score);
      } else if (entry.flag == TranspositionFlag.upperBound) {
        localBeta = min(localBeta, entry.score);
      }

      if (localAlpha >= localBeta) {
        return entry.score;
      }
    }

    final int? whiteKingIndex = BoardHelper.getKingIndex(
      state.board,
      true,
    );

    final int? blackKingIndex = BoardHelper.getKingIndex(
      state.board,
      false,
    );

    if (whiteKingIndex == null || blackKingIndex == null) {
      return evaluator.evaluate(state.board);
    }

    if (moveGenerator.isCheckmate(state: state)) {
      if (state.isWhiteTurn) {
        return -mateScore + ply;
      }

      return mateScore - ply;
    }

    if (moveGenerator.isStalemate(state: state)) {
      return 0;
    }

    if (moveGenerator.isInsufficientMaterial(state.board)) {
      return 0;
    }

    if (depth <= 0) {
      return quiescence(
        state: state,
        alpha: localAlpha,
        beta: localBeta,
        depth: quiescenceDepth,
      );
    }

    final List<AiMove> moves = _getOrderedMoves(
      state: state,
      hashEntry: entry,
    );

    if (moves.isEmpty) {
      return evaluator.evaluate(state.board);
    }

    AiMove? bestMove;

    if (state.isWhiteTurn) {
      int bestScore = -infinity;

      for (final AiMove move in moves) {
        if (stopwatch.elapsedMilliseconds >= timeLimitMs) {
          break;
        }

        final AiGameState nextState = _makeNextState(
          state: state,
          move: move,
        );

        final int score = minimaxTimed(
          state: nextState,
          depth: depth - 1,
          alpha: localAlpha,
          beta: localBeta,
          ply: ply + 1,
          stopwatch: stopwatch,
          timeLimitMs: timeLimitMs,
        );

        if (score > bestScore) {
          bestScore = score;
          bestMove = move;
        }

        localAlpha = max(localAlpha, bestScore);

        if (localAlpha >= localBeta) {
          break;
        }
      }

      _storeTransposition(
        key: key,
        depth: depth,
        score: bestScore,
        originalAlpha: originalAlpha,
        originalBeta: originalBeta,
        bestMove: bestMove,
      );

      return bestScore;
    } else {
      int bestScore = infinity;

      for (final AiMove move in moves) {
        if (stopwatch.elapsedMilliseconds >= timeLimitMs) {
          break;
        }

        final AiGameState nextState = _makeNextState(
          state: state,
          move: move,
        );

        final int score = minimaxTimed(
          state: nextState,
          depth: depth - 1,
          alpha: localAlpha,
          beta: localBeta,
          ply: ply + 1,
          stopwatch: stopwatch,
          timeLimitMs: timeLimitMs,
        );

        if (score < bestScore) {
          bestScore = score;
          bestMove = move;
        }

        localBeta = min(localBeta, bestScore);

        if (localAlpha >= localBeta) {
          break;
        }
      }

      _storeTransposition(
        key: key,
        depth: depth,
        score: bestScore,
        originalAlpha: originalAlpha,
        originalBeta: originalBeta,
        bestMove: bestMove,
      );

      return bestScore;
    }
  }


  int quiescence({
    required AiGameState state,
    required int alpha,
    required int beta,
    required int depth,
  }) {

    searchedNodes++;

    int localAlpha = alpha;
    int localBeta = beta;

    final int standPat =
    evaluator.evaluate(state.board);

    if (state.isWhiteTurn) {

      if (standPat >= localBeta) {
        return localBeta;
      }

      if (standPat > localAlpha) {
        localAlpha = standPat;
      }

    } else {

      if (standPat <= localAlpha) {
        return localAlpha;
      }

      if (standPat < localBeta) {
        localBeta = standPat;
      }
    }

    if (depth <= 0) {
      return standPat;
    }

    final List<AiMove> captures =
    _getOrderedMoves(
      state: state,
      hashEntry: null,
    ).where((AiMove move) {

      return state.board[
      move.toIndex
      ] != 0 ||
          move.promotionPiece != null;

    }).toList();

    for (final AiMove move in captures) {

      final AiGameState nextState =
      _makeNextState(
        state: state,
        move: move,
      );

      final int score = quiescence(
        state: nextState,
        alpha: localAlpha,
        beta: localBeta,
        depth: depth - 1,
      );

      if (state.isWhiteTurn) {

        if (score > localAlpha) {
          localAlpha = score;
        }

        if (localAlpha >= localBeta) {
          return localBeta;
        }

      } else {

        if (score < localBeta) {
          localBeta = score;
        }

        if (localAlpha >= localBeta) {
          return localAlpha;
        }
      }
    }

    return state.isWhiteTurn
        ? localAlpha
        : localBeta;
  }

  List<AiMove> _getOrderedMoves({
    required AiGameState state,
    required TranspositionEntry? hashEntry,
  }) {

    final groupedMoves =
    moveGenerator.getAllLegalMoves(
      state: state,
    );

    return moveOrdering.flattenAndOrderMoves(
      groupedMoves,
      state.board,
      hashFrom: hashEntry?.bestFrom,
      hashTo: hashEntry?.bestTo,
      hashPromotion: hashEntry?.bestPromotion,
    );
  }

  int _buildTranspositionKey({
    required AiGameState state,
  }) {
    return ZobristHasher.hash(state);
  }

// REST BLEIBT UNVERÄNDERT

  AiGameState _makeNextState({
    required AiGameState state,
    required AiMove move,
  }) {
    final List<int> newBoard = List<int>.from(state.board);

    final bool isEnPassantMove =
        move.piece.abs() == 1 &&
            state.enPassantTargetIndex != null &&
            move.toIndex == state.enPassantTargetIndex &&
            state.board[move.toIndex] == 0 &&
            BoardHelper.getCol(move.fromIndex) != BoardHelper.getCol(move.toIndex);

    if (isEnPassantMove) {
      final int capturedPawnIndex =
      move.piece > 0 ? move.toIndex + 8 : move.toIndex - 8;

      if (capturedPawnIndex >= 0 && capturedPawnIndex < 64) {
        newBoard[capturedPawnIndex] = 0;
      }
    }

    final bool isCastleMove =
        move.piece.abs() == 6 &&
            (BoardHelper.getCol(move.fromIndex) -
                BoardHelper.getCol(move.toIndex))
                .abs() ==
                2;

    BoardHelper.makeMove(
      newBoard,
      move.fromIndex,
      move.toIndex,
      promotionPiece: move.promotionPiece,
    );

    if (isCastleMove) {
      _applyCastleRookMove(
        board: newBoard,
        fromIndex: move.fromIndex,
        toIndex: move.toIndex,
      );
    }

    return state.copyWith(
      board: newBoard,
      isEnemyMove: !state.isEnemyMove,
      isWhiteTurn: !state.isWhiteTurn,
      enPassantTargetIndex: _calculateNextEnPassantTarget(
        move: move,
      ),
      castlingRights: _updateCastlingRights(
        state: state,
        move: move,
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
    required AiMove move,
  }) {
    if (move.piece.abs() != 1) {
      return null;
    }

    final int fromRow = BoardHelper.getRow(move.fromIndex);
    final int toRow = BoardHelper.getRow(move.toIndex);

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
    required AiMove move,
  }) {
    AiCastlingRights rights = state.castlingRights;

    final int piece = move.piece;
    final int from = move.fromIndex;
    final int target = move.toIndex;

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

  void _storeTransposition({
    required int key,
    required int depth,
    required int score,
    required int originalAlpha,
    required int originalBeta,
    required AiMove? bestMove,
  }) {
    TranspositionFlag flag = TranspositionFlag.exact;

    if (score <= originalAlpha) {
      flag = TranspositionFlag.upperBound;
    } else if (score >= originalBeta) {
      flag = TranspositionFlag.lowerBound;
    }

    transpositionTable.put(
      key: key,
      depth: depth,
      score: score,
      flag: flag,
      bestFrom: bestMove?.fromIndex,
      bestTo: bestMove?.toIndex,
      bestPromotion: bestMove?.promotionPiece,
    );
  }

}
