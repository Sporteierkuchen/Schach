import 'dart:math';

import 'package:schach/chess_ai/search_heuristics.dart';
import 'package:schach/chess_ai/static_exchange_evaluator.dart';
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
  static const int quiescenceDepth = 8;

  int searchedNodes = 0;

  final SearchHeuristics heuristics = SearchHeuristics();

  late final StaticExchangeEvaluator see = StaticExchangeEvaluator(evaluator);

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
      ply: 0,
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
    int alpha = -infinity,
    int beta = infinity,
  }) {
    if (depth == 1) {
      heuristics.clear();
    }

    searchedNodes = 0;

    final List<AiMove> legalMoves = _getOrderedMoves(
      state: state,
      hashEntry: null,
      ply: 0,
    );

    if (legalMoves.isEmpty) {
      return null;
    }

    int? bestScore;
    AiMove? bestMove;

    int localAlpha = alpha;
    int localBeta = beta;

    bool completedRootSearch = true;

    for (final AiMove move in legalMoves) {
      if (stopwatch.elapsedMilliseconds >= timeLimitMs) {
        completedRootSearch = false;
        break;
      }

      final AiGameState nextState = _makeNextState(
        state: state,
        move: move,
      );

      if (moveGenerator.isCheckmate(state: nextState)) {
        final int mateMoveScore =
        state.isWhiteTurn ? mateScore - 1 : -mateScore + 1;

        return AiMove(
          fromIndex: move.fromIndex,
          toIndex: move.toIndex,
          piece: move.piece,
          promotionPiece: move.promotionPiece,
          score: mateMoveScore,
        );
      }

      int score = minimaxTimed(
        state: nextState,
        depth: depth - 1,
        alpha: localAlpha,
        beta: localBeta,
        ply: 1,
        stopwatch: stopwatch,
        timeLimitMs: timeLimitMs,
      );

      final bool isMateScore = score.abs() > mateScore - 10000;

      if (!isMateScore) {
        score += _rootSeeAdjustment(
          state: state,
          move: move,
        );

        score += _rootHangingPiecesAdjustment(
          beforeState: state,
          afterState: nextState,
        );

        score += _rootOpponentThreatAdjustment(
          afterState: nextState,
          aiIsWhite: state.isWhiteTurn,
        );

        score += _rootAttackedPieceEscapeBonus(
          beforeState: state,
          afterState: nextState,
          move: move,
        );

        score += _rootOpponentMateThreatAdjustment(
          afterState: nextState,
          aiIsWhite: state.isWhiteTurn,
        );
      }

      if (stopwatch.elapsedMilliseconds >= timeLimitMs) {
        completedRootSearch = false;
        break;
      }

      final bool better =
          bestScore == null ||
              (state.isWhiteTurn ? score > bestScore : score < bestScore);

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
        localAlpha = max(localAlpha, bestScore);
      } else {
        localBeta = min(localBeta, bestScore);
      }

      if (localAlpha >= localBeta) {
        break;
      }
    }

    print(
      "🔎 Tiefe $depth | "
          "Score: ${bestScore ?? "TIMEOUT"} | "
          "Nodes: $searchedNodes | "
          "Zeit: ${stopwatch.elapsedMilliseconds} ms",
    );

    if (!completedRootSearch) {
      print("⏱️ Tiefe $depth unvollständig -> Ergebnis wird verworfen");
      return null;
    }

    if (bestMove != null) {
      final String pv = getPrincipalVariationFromMove(
        state,
        bestMove,
        depth,
      );

      print("📌 PV Tiefe $depth: $pv");
    }

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
      ply: ply,
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

    final int key = _buildTranspositionKey(state: state);

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

    final int? whiteKingIndex = BoardHelper.getKingIndex(state.board, true);
    final int? blackKingIndex = BoardHelper.getKingIndex(state.board, false);

    if (whiteKingIndex == null || blackKingIndex == null) {
      return evaluator.evaluate(state.board);
    }

    final bool inCheck = moveGenerator.isKingInCheck(
      state: state,
      isWhiteKing: state.isWhiteTurn,
      whiteKingIndex: whiteKingIndex,
      blackKingIndex: blackKingIndex,
    );

    if (moveGenerator.isCheckmate(state: state)) {
      return state.isWhiteTurn ? -mateScore + ply : mateScore - ply;
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

    // Null Move Pruning
    if (_canApplyNullMovePruning(
      state: state,
      depth: depth,
      inCheck: inCheck,
    )) {
      final AiGameState nullMoveState = state.copyWith(
        isWhiteTurn: !state.isWhiteTurn,
        isEnemyMove: !state.isEnemyMove,
        enPassantTargetIndex: null,
      );

      final int reduction = depth >= 7 ? 3 : 2;

      final int nullMoveScore = minimaxTimed(
        state: nullMoveState,
        depth: depth - 1 - reduction,
        alpha: localAlpha,
        beta: localBeta,
        ply: ply + 1,
        stopwatch: stopwatch,
        timeLimitMs: timeLimitMs,
      );

      if (state.isWhiteTurn) {
        if (nullMoveScore >= localBeta) {
          return localBeta;
        }
      } else {
        if (nullMoveScore <= localAlpha) {
          return localAlpha;
        }
      }
    }

    final List<AiMove> moves = _getOrderedMoves(
      state: state,
      hashEntry: entry,
      ply: ply,
    );

    if (moves.isEmpty) {
      return evaluator.evaluate(state.board);
    }

    AiMove? bestMove;

    if (state.isWhiteTurn) {
      int bestScore = -infinity;

      for (int moveIndex = 0; moveIndex < moves.length; moveIndex++) {
        final AiMove move = moves[moveIndex];

        if (stopwatch.elapsedMilliseconds >= timeLimitMs) {
          break;
        }

        final AiGameState nextState = _makeNextState(
          state: state,
          move: move,
        );

        int newDepth = depth - 1;

        final bool givesCheck = _moveGivesCheck(
          state: nextState,
        );

        final bool canReduce = _canApplyLmr(
          move: move,
          state: state,
          depth: depth,
          moveIndex: moveIndex,
          inCheck: inCheck,
          givesCheck: givesCheck,
        );

        if (canReduce && !givesCheck) {
          newDepth = depth - 2;
        }

        if (givesCheck) {
          newDepth += 1;
        }

        int score = minimaxTimed(
          state: nextState,
          depth: newDepth,
          alpha: localAlpha,
          beta: localBeta,
          ply: ply + 1,
          stopwatch: stopwatch,
          timeLimitMs: timeLimitMs,
        );

        if (canReduce && score > localAlpha) {
          score = minimaxTimed(
            state: nextState,
            depth: givesCheck ? newDepth : depth - 1,
            alpha: localAlpha,
            beta: localBeta,
            ply: ply + 1,
            stopwatch: stopwatch,
            timeLimitMs: timeLimitMs,
          );
        }

        if (score > bestScore) {
          bestScore = score;
          bestMove = move;
        }

        localAlpha = max(localAlpha, bestScore);

        if (localAlpha >= localBeta) {
          if (state.board[move.toIndex] == 0) {
            heuristics.addKillerMove(move, ply);
            heuristics.addHistoryScore(move, depth);
          }

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

      for (int moveIndex = 0; moveIndex < moves.length; moveIndex++) {
        final AiMove move = moves[moveIndex];

        if (stopwatch.elapsedMilliseconds >= timeLimitMs) {
          break;
        }

        final AiGameState nextState = _makeNextState(
          state: state,
          move: move,
        );

        int newDepth = depth - 1;

        final bool givesCheck = _moveGivesCheck(
          state: nextState,
        );

        final bool canReduce = _canApplyLmr(
          move: move,
          state: state,
          depth: depth,
          moveIndex: moveIndex,
          inCheck: inCheck,
          givesCheck: givesCheck,
        );

        if (canReduce && !givesCheck) {
          newDepth = depth - 2;
        }

        if (givesCheck) {
          newDepth += 1;
        }

        int score = minimaxTimed(
          state: nextState,
          depth: newDepth,
          alpha: localAlpha,
          beta: localBeta,
          ply: ply + 1,
          stopwatch: stopwatch,
          timeLimitMs: timeLimitMs,
        );

        if (canReduce && score < localBeta) {
          score = minimaxTimed(
            state: nextState,
            depth: givesCheck ? newDepth : depth - 1,
            alpha: localAlpha,
            beta: localBeta,
            ply: ply + 1,
            stopwatch: stopwatch,
            timeLimitMs: timeLimitMs,
          );
        }

        if (score < bestScore) {
          bestScore = score;
          bestMove = move;
        }

        localBeta = min(localBeta, bestScore);

        if (localAlpha >= localBeta) {
          if (state.board[move.toIndex] == 0) {
            heuristics.addKillerMove(move, ply);
            heuristics.addHistoryScore(move, depth);
          }

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

    final bool allowChecks = depth >= quiescenceDepth - 3;

    int localAlpha = alpha;
    int localBeta = beta;

    final int standPat = evaluator.evaluate(state.board);

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

    final List<_QuiescenceCandidate> candidates = [];

    final List<AiMove> orderedMoves = _getOrderedMoves(
      state: state,
      hashEntry: null,
      ply: 0,
    );

    for (final AiMove move in orderedMoves) {
      final bool isCapture = state.board[move.toIndex] != 0;
      final bool isPromotion = move.promotionPiece != null;

      AiGameState? nextState;

      bool givesCheck = false;

      if (!isCapture && !isPromotion) {
        if (!allowChecks) {
          continue;
        }

        nextState = _makeNextState(
          state: state,
          move: move,
        );

        givesCheck = _moveGivesCheck(
          state: nextState,
        );

        if (!givesCheck) {
          continue;
        }
      }

      if (isCapture) {
        final int seeScore = see.evaluateCapture(
          board: state.board,
          from: move.fromIndex,
          to: move.toIndex,
          movingPiece: move.piece,
        );

        if (seeScore < 0) {
          continue;
        }
      }

      nextState ??= _makeNextState(
        state: state,
        move: move,
      );

      candidates.add(
        _QuiescenceCandidate(
          move: move,
          nextState: nextState,
        ),
      );
    }

    for (final _QuiescenceCandidate candidate in candidates) {
      final int score = quiescence(
        state: candidate.nextState,
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

    return state.isWhiteTurn ? localAlpha : localBeta;
  }

  List<AiMove> _getOrderedMoves({
    required AiGameState state,
    required TranspositionEntry? hashEntry,
    int ply = 0,
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
      heuristics: heuristics,
      ply: ply,
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

  int _rootSeeAdjustment({
    required AiGameState state,
    required AiMove move,
  }) {
    final int captured = state.board[move.toIndex];

    // Nur echte Schlagzüge bewerten
    if (captured == 0) {
      return 0;
    }

    final int seeScore = see.evaluateCapture(
      board: state.board,
      from: move.fromIndex,
      to: move.toIndex,
      movingPiece: move.piece,
    );

    final bool badCapture = see.isBadCapture(
      board: state.board,
      from: move.fromIndex,
      to: move.toIndex,
      movingPiece: move.piece,
    );

    int adjustment = seeScore * 6;

    if (badCapture) {
      adjustment -= 3000;
    }

    return state.isWhiteTurn ? adjustment : -adjustment;
  }

  int _rootOpponentThreatAdjustment({
    required AiGameState afterState,
    required bool aiIsWhite,
  }) {
    final List<AiMove> opponentMoves = _getOrderedMoves(
      state: afterState,
      hashEntry: null,
      ply: 1,
    );

    int worstLoss = 0;

    for (final AiMove opponentMove in opponentMoves) {
      final int captured = afterState.board[opponentMove.toIndex];

      if (captured == 0) {
        continue;
      }

      if ((captured > 0) != aiIsWhite) {
        continue;
      }

      final int victimValue = evaluator.pieceValue(captured).abs();
      final int attackerValue = evaluator.pieceValue(opponentMove.piece).abs();

      final int seeScore = see.evaluateCapture(
        board: afterState.board,
        from: opponentMove.fromIndex,
        to: opponentMove.toIndex,
        movingPiece: opponentMove.piece,
      );

      int loss = victimValue;

      if (attackerValue < victimValue) {
        loss += victimValue - attackerValue;
      }

      if (seeScore > 0) {
        loss += seeScore;
      }

      if (loss > worstLoss) {
        worstLoss = loss;
      }
    }

    if (worstLoss == 0) {
      return 0;
    }

    final int penalty = worstLoss * 2;

    return aiIsWhite ? -penalty : penalty;
  }

  int _rootAttackedPieceEscapeBonus({
    required AiGameState beforeState,
    required AiGameState afterState,
    required AiMove move,
  }) {
    final bool aiIsWhite = beforeState.isWhiteTurn;

    final int movedPiece = move.piece.abs();

    if (movedPiece == 1 || movedPiece == 6) {
      return 0;
    }

    final bool wasAttacked = see.isSquareAttackedBySide(
      beforeState.board,
      move.fromIndex,
      byWhite: !aiIsWhite,
    );

    if (!wasAttacked) {
      return 0;
    }

    final bool stillExistsOnTarget =
        afterState.board[move.toIndex].abs() == movedPiece &&
            (afterState.board[move.toIndex] > 0) == aiIsWhite;

    if (!stillExistsOnTarget) {
      return 0;
    }

    final bool stillAttacked = see.isSquareAttackedBySide(
      afterState.board,
      move.toIndex,
      byWhite: !aiIsWhite,
    );

    final int value = evaluator.pieceValue(move.piece).abs();

    if (!stillAttacked) {
      return aiIsWhite ? value : -value;
    }

    return aiIsWhite ? -(value ~/ 2) : (value ~/ 2);
  }

  int _rootOpponentMateThreatAdjustment({
    required AiGameState afterState,
    required bool aiIsWhite,
  }) {
    final List<AiMove> opponentMoves = _getOrderedMoves(
      state: afterState,
      hashEntry: null,
      ply: 1,
    );

    for (final AiMove opponentMove in opponentMoves) {
      final AiGameState replyState = _makeNextState(
        state: afterState,
        move: opponentMove,
      );

      if (moveGenerator.isCheckmate(state: replyState)) {
        return aiIsWhite ? -mateScore ~/ 2 : mateScore ~/ 2;
      }
    }

    return 0;
  }


  int _rootHangingPiecesAdjustment({
    required AiGameState beforeState,
    required AiGameState afterState,
  }) {
    int penalty = 0;

    final bool aiIsWhite = beforeState.isWhiteTurn;

    for (int i = 0; i < 64; i++) {
      final int piece = afterState.board[i];

      if (piece == 0) continue;
      if ((piece > 0) != aiIsWhite) continue;
      if (piece.abs() == 1 || piece.abs() == 6) continue;

      final bool attacked = see.isSquareAttackedBySide(
        afterState.board,
        i,
        byWhite: !aiIsWhite,
      );

      if (!attacked) continue;

      final bool defended = see.isSquareAttackedBySide(
        afterState.board,
        i,
        byWhite: aiIsWhite,
      );

      final int value = evaluator.pieceValue(piece).abs();

      if (!defended) {
        penalty += value * 2;
      } else {
        penalty += value ~/ 2;
      }

    }

    if (penalty == 0) {
      return 0;
    }

    return aiIsWhite ? -penalty : penalty;
  }

  bool _canApplyLmr({
    required AiMove move,
    required AiGameState state,
    required int depth,
    required int moveIndex,
    required bool inCheck,
    required bool givesCheck,
  }) {
    if (depth < 4) {
      return false;
    }

    if (moveIndex < 6) {
      return false;
    }

    if (inCheck) {
      return false;
    }

    // Schachzüge niemals reduzieren
    if (givesCheck) {
      return false;
    }

    final bool isCapture = state.board[move.toIndex] != 0;

    if (isCapture) {
      return false;
    }

    if (move.promotionPiece != null) {
      return false;
    }

    if (move.piece.abs() == 6) {
      return false;
    }

    return true;
  }

  bool _canApplyNullMovePruning({
    required AiGameState state,
    required int depth,
    required bool inCheck,
  }) {
    if (depth < 4) {
      return false;
    }

    if (inCheck) {
      return false;
    }

    if (_isEndgameForNullMove(state.board)) {
      return false;
    }

    if (!_sideHasNonPawnMaterial(
      board: state.board,
      white: state.isWhiteTurn,
    )) {
      return false;
    }

    return true;
  }

  bool _isEndgameForNullMove(List<int> board) {
    int material = 0;

    for (final int piece in board) {
      switch (piece.abs()) {
        case 2:
          material += 320;
          break;
        case 3:
          material += 330;
          break;
        case 4:
          material += 500;
          break;
        case 5:
          material += 900;
          break;
      }
    }

    return material <= 1400;
  }

  bool _sideHasNonPawnMaterial({
    required List<int> board,
    required bool white,
  }) {
    for (final int piece in board) {
      if (piece == 0) continue;
      if ((piece > 0) != white) continue;

      final int absPiece = piece.abs();

      if (absPiece == 2 ||
          absPiece == 3 ||
          absPiece == 4 ||
          absPiece == 5) {
        return true;
      }
    }

    return false;
  }

  bool _moveGivesCheck({
    required AiGameState state,
  }) {
    final int? whiteKingIndex =
    BoardHelper.getKingIndex(state.board, true);

    final int? blackKingIndex =
    BoardHelper.getKingIndex(state.board, false);

    if (whiteKingIndex == null ||
        blackKingIndex == null) {
      return false;
    }

    return moveGenerator.isKingInCheck(
      state: state,
      isWhiteKing: state.isWhiteTurn,
      whiteKingIndex: whiteKingIndex,
      blackKingIndex: blackKingIndex,
    );
  }

  String getPrincipalVariationFromMove(
      AiGameState state,
      AiMove bestMove,
      int maxDepth,
      ) {
    final List<String> pv = [];

    AiGameState currentState = state;
    AiMove? currentMove = bestMove;

    for (int i = 0; i < maxDepth; i++) {
      if (currentMove == null) break;

      pv.add(
        "${BoardHelper.indexToCoord(currentMove.fromIndex)}"
            "${BoardHelper.indexToCoord(currentMove.toIndex)}",
      );

      currentState = _makeNextState(
        state: currentState,
        move: currentMove,
      );

      final int key = _buildTranspositionKey(
        state: currentState,
      );

      final TranspositionEntry? entry =
      transpositionTable.get(key);

      if (entry == null) break;
      if (entry.bestFrom == null || entry.bestTo == null) break;

      final int piece =
      currentState.board[entry.bestFrom!];

      if (piece == 0) break;

      currentMove = AiMove(
        fromIndex: entry.bestFrom!,
        toIndex: entry.bestTo!,
        piece: piece,
        promotionPiece: entry.bestPromotion,
        score: entry.score,
      );
    }

    return pv.join(" ");
  }

}


class _QuiescenceCandidate {
  final AiMove move;
  final AiGameState nextState;

  const _QuiescenceCandidate({
    required this.move,
    required this.nextState,
  });
}
