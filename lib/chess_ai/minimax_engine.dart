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

    final bool aiIsWhite = state.isWhiteTurn;

    for (final AiMove move in legalMoves) {
      if (stopwatch.elapsedMilliseconds >= timeLimitMs) {
        completedRootSearch = false;
        break;
      }

      final List<int> beforeBoard = List<int>.from(state.board);

      final MoveUndo undo = _makeMoveInPlace(
        state: state,
        move: move,
      );

      if (moveGenerator.isCheckmate(state: state)) {
        _undoMoveInPlace(
          state: state,
          undo: undo,
        );

        final int mateMoveScore =
        aiIsWhite ? mateScore - 1 : -mateScore + 1;

        return AiMove(
          fromIndex: move.fromIndex,
          toIndex: move.toIndex,
          piece: move.piece,
          promotionPiece: move.promotionPiece,
          score: mateMoveScore,
        );
      }

      int score = minimaxTimed(
        state: state,
        depth: depth - 1,
        alpha: localAlpha,
        beta: localBeta,
        ply: 1,
        stopwatch: stopwatch,
        timeLimitMs: timeLimitMs,
      );

      bool isMateScore = score.abs() > mateScore - 10000;

      if (!isMateScore) {

        score += _rootSeeAdjustment(
          beforeBoard: beforeBoard,
          move: move,
          aiIsWhite: aiIsWhite,
        );

        score += _rootHangingPiecesAdjustment(
          afterState: state,
          aiIsWhite: aiIsWhite,
        );

        score += _rootOpponentThreatAdjustment(
          afterState: state,
          aiIsWhite: aiIsWhite,
        );

        score += _rootAttackedPieceEscapeBonus(
          beforeBoard: beforeBoard,
          afterBoard: state.board,
          move: move,
          aiIsWhite: aiIsWhite,
        );

        score += _rootOpponentMateThreatAdjustment(
          afterState: state,
          aiIsWhite: aiIsWhite,
        );

      }

      _undoMoveInPlace(
        state: state,
        undo: undo,
      );

      if (stopwatch.elapsedMilliseconds >= timeLimitMs) {
        completedRootSearch = false;
        break;
      }

      final bool better =
          bestScore == null ||
              (aiIsWhite ? score > bestScore : score < bestScore);

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

      if (aiIsWhite) {
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

    final int? drawScore = _drawScoreIfDraw(state);

    if (drawScore != null) {
      return drawScore;
    }

    final int key = _buildTranspositionKey(state: state);

    final int originalAlpha = alpha;
    final int originalBeta = beta;

    int localAlpha = alpha;
    int localBeta = beta;

    final TranspositionEntry? entry = transpositionTable.get(key);

    final bool canUseEntry =
        entry != null &&
            entry.depth >= depth &&
            entry.score.abs() <= mateScore - 10000;

    if (canUseEntry) {
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

    if (_canApplyNullMovePruning(
      state: state,
      depth: depth,
      inCheck: inCheck,
    )) {
      final bool oldIsWhiteTurn = state.isWhiteTurn;
      final bool oldIsEnemyMove = state.isEnemyMove;
      final int? oldEnPassant = state.enPassantTargetIndex;

      state.isWhiteTurn = !state.isWhiteTurn;
      state.isEnemyMove = !state.isEnemyMove;
      state.enPassantTargetIndex = null;

      final int reduction = depth >= 7 ? 3 : 2;

      final int nullMoveScore = minimaxTimed(
        state: state,
        depth: depth - 1 - reduction,
        alpha: localAlpha,
        beta: localBeta,
        ply: ply + 1,
        stopwatch: stopwatch,
        timeLimitMs: timeLimitMs,
      );

      state.isWhiteTurn = oldIsWhiteTurn;
      state.isEnemyMove = oldIsEnemyMove;
      state.enPassantTargetIndex = oldEnPassant;

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
      hashEntry: canUseEntry ? entry : null,
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

        final bool wasCapture = state.board[move.toIndex] != 0;

        final MoveUndo undo = _makeMoveInPlace(
          state: state,
          move: move,
        );

        int newDepth = depth - 1;

        final bool givesCheck = _moveGivesCheck(
          state: state,
        );

/*        final bool canFutilityPrune = _canApplyFutilityPruning(
          state: state,
          move: move,
          depth: depth,
          alpha: localAlpha,
          beta: localBeta,
          inCheck: inCheck,
          wasCapture: wasCapture,
          givesCheck: givesCheck,
        );

        if (canFutilityPrune) {
          _undoMoveInPlace(
            state: state,
            undo: undo,
          );

          continue;
        }*/

        final bool canReduce = _canApplyLmr(
          move: move,
          state: state,
          depth: depth,
          moveIndex: moveIndex,
          inCheck: inCheck,
          givesCheck: givesCheck,
          wasCapture: wasCapture,
        );

        if (canReduce && !givesCheck) {
          final int reduction = _lmrReduction(
            depth: depth,
            moveIndex: moveIndex,
          );

          newDepth = depth - 1 - reduction;

          if (newDepth < 1) {
            newDepth = 1;
          }
        }

        if (givesCheck) {
          newDepth += 1;
        }

        int score = minimaxTimed(
          state: state,
          depth: newDepth,
          alpha: localAlpha,
          beta: localBeta,
          ply: ply + 1,
          stopwatch: stopwatch,
          timeLimitMs: timeLimitMs,
        );

        if (canReduce && score > localAlpha) {
          score = minimaxTimed(
            state: state,
            depth: givesCheck ? newDepth : depth - 1,
            alpha: localAlpha,
            beta: localBeta,
            ply: ply + 1,
            stopwatch: stopwatch,
            timeLimitMs: timeLimitMs,
          );
        }

        _undoMoveInPlace(
          state: state,
          undo: undo,
        );

        if (score > bestScore) {
          bestScore = score;
          bestMove = move;
        }

        localAlpha = max(localAlpha, bestScore);

        if (localAlpha >= localBeta) {
          if (!wasCapture) {
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

        final bool wasCapture = state.board[move.toIndex] != 0;

        final MoveUndo undo = _makeMoveInPlace(
          state: state,
          move: move,
        );

        int newDepth = depth - 1;

        final bool givesCheck = _moveGivesCheck(
          state: state,
        );

/*        final bool canFutilityPrune = _canApplyFutilityPruning(
          state: state,
          move: move,
          depth: depth,
          alpha: localAlpha,
          beta: localBeta,
          inCheck: inCheck,
          wasCapture: wasCapture,
          givesCheck: givesCheck,
        );

        if (canFutilityPrune) {
          _undoMoveInPlace(
            state: state,
            undo: undo,
          );

          continue;
        }*/

        final bool canReduce = _canApplyLmr(
          move: move,
          state: state,
          depth: depth,
          moveIndex: moveIndex,
          inCheck: inCheck,
          givesCheck: givesCheck,
          wasCapture: wasCapture,
        );

        if (canReduce && !givesCheck) {
          final int reduction = _lmrReduction(
            depth: depth,
            moveIndex: moveIndex,
          );

          newDepth = depth - 1 - reduction;

          if (newDepth < 1) {
            newDepth = 1;
          }
        }

        if (givesCheck) {
          newDepth += 1;
        }

        int score = minimaxTimed(
          state: state,
          depth: newDepth,
          alpha: localAlpha,
          beta: localBeta,
          ply: ply + 1,
          stopwatch: stopwatch,
          timeLimitMs: timeLimitMs,
        );

        if (canReduce && score < localBeta) {
          score = minimaxTimed(
            state: state,
            depth: givesCheck ? newDepth : depth - 1,
            alpha: localAlpha,
            beta: localBeta,
            ply: ply + 1,
            stopwatch: stopwatch,
            timeLimitMs: timeLimitMs,
          );
        }

        _undoMoveInPlace(
          state: state,
          undo: undo,
        );

        if (score < bestScore) {
          bestScore = score;
          bestMove = move;
        }

        localBeta = min(localBeta, bestScore);

        if (localAlpha >= localBeta) {
          if (!wasCapture) {
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

    final int? drawScore = _drawScoreIfDraw(state);

    if (drawScore != null) {
      return drawScore;
    }

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

    final List<AiMove> orderedMoves = _getOrderedMoves(
      state: state,
      hashEntry: null,
      ply: 0,
    );

    for (final AiMove move in orderedMoves) {
      final bool isCapture = state.board[move.toIndex] != 0;
      final bool isPromotion = move.promotionPiece != null;

      if (!isCapture && !isPromotion && !allowChecks) {
        continue;
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

      final MoveUndo undo = _makeMoveInPlace(
        state: state,
        move: move,
      );

      if (!isCapture && !isPromotion) {
        final bool givesCheck = _moveGivesCheck(
          state: state,
        );

        if (!givesCheck) {
          _undoMoveInPlace(
            state: state,
            undo: undo,
          );

          continue;
        }
      }

      final int score = quiescence(
        state: state,
        alpha: localAlpha,
        beta: localBeta,
        depth: depth - 1,
      );

      _undoMoveInPlace(
        state: state,
        undo: undo,
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

    final List<AiMove> moves = moveGenerator.getAllLegalAiMoves(
      state: state,
    );

    return moveOrdering.orderAiMoves(
      moves,
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
    return state.zobristKey;
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
    required List<int> beforeBoard,
    required AiMove move,
    required bool aiIsWhite,
  }) {
    final int captured = beforeBoard[move.toIndex];

    if (captured == 0) {
      return 0;
    }

    final int seeScore = see.evaluateCapture(
      board: beforeBoard,
      from: move.fromIndex,
      to: move.toIndex,
      movingPiece: move.piece,
    );

    final bool badCapture = see.isBadCapture(
      board: beforeBoard,
      from: move.fromIndex,
      to: move.toIndex,
      movingPiece: move.piece,
    );

    int adjustment = seeScore * 6;

    if (badCapture) {
      adjustment -= 3000;
    }

    return aiIsWhite ? adjustment : -adjustment;
  }

  int _rootHangingPiecesAdjustment({
    required AiGameState afterState,
    required bool aiIsWhite,
  }) {
    int penalty = 0;

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

  int _rootAttackedPieceEscapeBonus({
    required List<int> beforeBoard,
    required List<int> afterBoard,
    required AiMove move,
    required bool aiIsWhite,
  }) {
    final int movedPiece = move.piece.abs();

    if (movedPiece == 1 || movedPiece == 6) {
      return 0;
    }

    final bool wasAttacked = see.isSquareAttackedBySide(
      beforeBoard,
      move.fromIndex,
      byWhite: !aiIsWhite,
    );

    if (!wasAttacked) {
      return 0;
    }

    final bool stillExistsOnTarget =
        afterBoard[move.toIndex].abs() == movedPiece &&
            (afterBoard[move.toIndex] > 0) == aiIsWhite;

    if (!stillExistsOnTarget) {
      return 0;
    }

    final bool stillAttacked = see.isSquareAttackedBySide(
      afterBoard,
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
      final MoveUndo undo = _makeMoveInPlace(
        state: afterState,
        move: opponentMove,
      );

      final bool mate = moveGenerator.isCheckmate(
        state: afterState,
      );

      _undoMoveInPlace(
        state: afterState,
        undo: undo,
      );

      if (mate) {
        return aiIsWhite ? -mateScore ~/ 2 : mateScore ~/ 2;
      }
    }

    return 0;
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

  bool _canApplyLmr({
    required AiMove move,
    required AiGameState state,
    required int depth,
    required int moveIndex,
    required bool inCheck,
    required bool givesCheck,
    required bool wasCapture,
  }) {
    if (depth < 4) return false;
    if (moveIndex < 6) return false;

    if (inCheck) return false;
    if (givesCheck) return false;
    if (wasCapture) return false;
    if (move.promotionPiece != null) return false;

    // Königszüge lieber nicht reduzieren:
    // In Mattnetzen und Endspielen sind Königszüge oft erzwungen/taktisch.
    if (move.piece.abs() == 6) return false;

    return true;
  }

  int _lmrReduction({
    required int depth,
    required int moveIndex,
  }) {
    if (depth >= 8 && moveIndex >= 8) {
      return 3;
    }

    if (depth >= 6 && moveIndex >= 5) {
      return 2;
    }

    return 1;
  }

  bool _canApplyNullMovePruning({
    required AiGameState state,
    required int depth,
    required bool inCheck,
  }) {
    if (depth < 4) return false;
    if (inCheck) return false;

    final int pieces = state.board.where((p) => p != 0).length;

    // Im Endspiel vorsichtig wegen Zugzwang.
    if (pieces <= 10) return false;

    // Wenn nur Könige + wenig Material vorhanden sind, kein Null Move.
    if (moveGenerator.isInsufficientMaterial(state.board)) {
      return false;
    }

    // Bei Bauernendspielen ebenfalls kein Null Move.
    if (_isPawnEndgame(state.board)) {
      return false;
    }

    return true;
  }

  bool _isPawnEndgame(List<int> board) {
    for (final int piece in board) {
      if (piece == 0) continue;

      final int absPiece = piece.abs();

      // König und Bauer sind okay.
      if (absPiece == 6 || absPiece == 1) {
        continue;
      }

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
    final List<MoveUndo> undoStack = [];

    AiMove? currentMove = bestMove;

    for (int i = 0; i < maxDepth; i++) {
      if (currentMove == null) break;

      pv.add(
        "${BoardHelper.indexToCoord(currentMove.fromIndex)}"
            "${BoardHelper.indexToCoord(currentMove.toIndex)}",
      );

      final MoveUndo undo = _makeMoveInPlace(
        state: state,
        move: currentMove,
      );

      undoStack.add(undo);

      final int key = _buildTranspositionKey(
        state: state,
      );

      final TranspositionEntry? entry = transpositionTable.get(key);

      if (entry == null) break;
      if (entry.bestFrom == null || entry.bestTo == null) break;

      final int piece = state.board[entry.bestFrom!];

      if (piece == 0) break;

      currentMove = AiMove(
        fromIndex: entry.bestFrom!,
        toIndex: entry.bestTo!,
        piece: piece,
        promotionPiece: entry.bestPromotion,
        score: entry.score,
      );
    }

    for (int i = undoStack.length - 1; i >= 0; i--) {
      _undoMoveInPlace(
        state: state,
        undo: undoStack[i],
      );
    }

    return pv.join(" ");
  }

  bool _isFiftyMoveRule(AiGameState state) {
    return state.halfmoveClock >= 100;
  }

  bool _isThreefoldRepetition(AiGameState state) {
    int count = 1;

    for (final int key in state.positionHistory) {
      if (key == state.zobristKey) {
        count++;
      }
    }

    return count >= 3;
  }

  int? _drawScoreIfDraw(AiGameState state) {
    if (_isFiftyMoveRule(state)) {
      return 0;
    }

    if (moveGenerator.isInsufficientMaterial(state.board)) {
      return 0;
    }

    if (_isThreefoldRepetition(state)) {
      return _repetitionScore(state);
    }

    return null;
  }

  int _repetitionScore(AiGameState state) {
    final int eval = evaluator.evaluate(state.board);

    // Weiß steht klar besser und ist am Zug:
    // Wiederholung ist aus weißer Sicht schlecht.
    if (eval > 250) {
      return state.isWhiteTurn ? -50 : 50;
    }

    // Schwarz steht klar besser:
    // Wiederholung ist aus schwarzer Sicht schlecht.
    if (eval < -250) {
      return state.isWhiteTurn ? -50 : 50;
    }

    return 0;
  }

  bool _canApplyFutilityPruning({
    required AiGameState state,
    required AiMove move,
    required int depth,
    required int alpha,
    required int beta,
    required bool inCheck,
    required bool wasCapture,
    required bool givesCheck,
  }) {
    if (depth > 1) return false;
    if (inCheck) return false;
    if (givesCheck) return false;
    if (wasCapture) return false;
    if (move.promotionPiece != null) return false;

    final int staticEval = evaluator.evaluate(state.board);

    final int margin = depth == 1 ? 150 : 300;

    if (state.isWhiteTurn) {
      return staticEval + margin <= alpha;
    } else {
      return staticEval - margin >= beta;
    }
  }

  int perft({
    required AiGameState state,
    required int depth,
  }) {
    return perftMakeUndo(
      state: state,
      depth: depth,
    );
  }


  Map<String, int> dividePerft({
    required AiGameState state,
    required int depth,
  }) {
    final Map<String, int> result = {};

    final List<AiMove> moves = _getOrderedMoves(
      state: state,
      hashEntry: null,
      ply: 0,
    );

    for (final AiMove move in moves) {
      final MoveUndo undo = _makeMoveInPlace(
        state: state,
        move: move,
      );

      final String moveName =
          "${BoardHelper.indexToCoord(move.fromIndex)}"
          "${BoardHelper.indexToCoord(move.toIndex)}";

      result[moveName] = perftMakeUndo(
        state: state,
        depth: depth - 1,
      );

      _undoMoveInPlace(
        state: state,
        undo: undo,
      );
    }

    return result;
  }

  MoveUndo _makeMoveInPlace({
    required AiGameState state,
    required AiMove move,
  }) {
    final List<int> board = state.board;

    final int oldZobristKey = state.zobristKey;
    final int oldHalfmoveClock = state.halfmoveClock;
    final int oldHistoryLength = state.positionHistory.length;

    final int movedPiece = board[move.fromIndex];
    final int capturedPiece = board[move.toIndex];

    final bool oldIsWhiteTurn = state.isWhiteTurn;
    final bool oldIsEnemyMove = state.isEnemyMove;
    final int? oldEnPassantTargetIndex = state.enPassantTargetIndex;
    final AiCastlingRights oldCastlingRights = state.castlingRights;

    int newHash = state.zobristKey;

    newHash ^= ZobristHasher.enPassantHash(oldEnPassantTargetIndex);
    newHash ^= ZobristHasher.castlingHash(oldCastlingRights);

    final AiCastlingRights newCastlingRights = _updateCastlingRights(
      state: state,
      move: move,
    );

    final bool isEnPassantMove =
        movedPiece.abs() == 1 &&
            state.enPassantTargetIndex != null &&
            move.toIndex == state.enPassantTargetIndex &&
            board[move.toIndex] == 0 &&
            BoardHelper.getCol(move.fromIndex) != BoardHelper.getCol(move.toIndex);

    int? enPassantCapturedIndex;
    int? enPassantCapturedPiece;

    if (isEnPassantMove) {
      enPassantCapturedIndex =
      movedPiece > 0 ? move.toIndex + 8 : move.toIndex - 8;

      enPassantCapturedPiece = board[enPassantCapturedIndex];

      if (enPassantCapturedPiece != 0) {
        newHash ^= ZobristHasher.pieceSquareKey(
          enPassantCapturedPiece,
          enPassantCapturedIndex,
        );
      }

      board[enPassantCapturedIndex] = 0;
    }

    final bool isCastleMove =
        movedPiece.abs() == 6 &&
            (BoardHelper.getCol(move.fromIndex) -
                BoardHelper.getCol(move.toIndex))
                .abs() ==
                2;

    int? rookFrom;
    int? rookTo;
    int? rookPiece;

    newHash ^= ZobristHasher.pieceSquareKey(movedPiece, move.fromIndex);

    if (capturedPiece != 0) {
      newHash ^= ZobristHasher.pieceSquareKey(capturedPiece, move.toIndex);
    }

    final int placedPiece = move.promotionPiece ?? movedPiece;

    newHash ^= ZobristHasher.pieceSquareKey(placedPiece, move.toIndex);

    board[move.fromIndex] = 0;
    board[move.toIndex] = placedPiece;

    if (isCastleMove) {
      final int row = BoardHelper.getRow(move.fromIndex);
      final int fromCol = BoardHelper.getCol(move.fromIndex);
      final int toCol = BoardHelper.getCol(move.toIndex);

      if (toCol > fromCol) {
        rookFrom = BoardHelper.getIndex(row, 7);
        rookTo = BoardHelper.getIndex(row, toCol - 1);
      } else {
        rookFrom = BoardHelper.getIndex(row, 0);
        rookTo = BoardHelper.getIndex(row, toCol + 1);
      }

      rookPiece = board[rookFrom];

      if (rookPiece != 0) {
        newHash ^= ZobristHasher.pieceSquareKey(rookPiece, rookFrom);
        newHash ^= ZobristHasher.pieceSquareKey(rookPiece, rookTo);
      }

      board[rookTo] = rookPiece;
      board[rookFrom] = 0;
    }

    final int? newEnPassantTargetIndex = _calculateNextEnPassantTarget(
      move: move,
    );

    newHash ^= ZobristHasher.enPassantHash(newEnPassantTargetIndex);
    newHash ^= ZobristHasher.castlingHash(newCastlingRights);
    newHash ^= ZobristHasher.whiteTurnKey;

    state.enPassantTargetIndex = newEnPassantTargetIndex;
    state.castlingRights = newCastlingRights;
    state.isWhiteTurn = !state.isWhiteTurn;
    state.isEnemyMove = !state.isEnemyMove;
    state.zobristKey = newHash;

    final bool isPawnMove = movedPiece.abs() == 1;
    final bool isCapture = capturedPiece != 0 || isEnPassantMove;

    if (isPawnMove || isCapture) {
      state.halfmoveClock = 0;
    } else {
      state.halfmoveClock++;
    }

    state.positionHistory.add(state.zobristKey);

    return MoveUndo(
      fromIndex: move.fromIndex,
      toIndex: move.toIndex,
      movedPiece: movedPiece,
      capturedPiece: capturedPiece,
      oldIsWhiteTurn: oldIsWhiteTurn,
      oldIsEnemyMove: oldIsEnemyMove,
      oldEnPassantTargetIndex: oldEnPassantTargetIndex,
      oldCastlingRights: oldCastlingRights,
      oldZobristKey: oldZobristKey,
      oldHalfmoveClock: oldHalfmoveClock,
      oldHistoryLength: oldHistoryLength,
      wasEnPassant: isEnPassantMove,
      enPassantCapturedIndex: enPassantCapturedIndex,
      enPassantCapturedPiece: enPassantCapturedPiece,
      wasCastle: isCastleMove,
      rookFrom: rookFrom,
      rookTo: rookTo,
      rookPiece: rookPiece,
    );
  }

  void _undoMoveInPlace({
    required AiGameState state,
    required MoveUndo undo,
  }) {
    final List<int> board = state.board;

    state.isWhiteTurn = undo.oldIsWhiteTurn;
    state.isEnemyMove = undo.oldIsEnemyMove;
    state.enPassantTargetIndex = undo.oldEnPassantTargetIndex;
    state.castlingRights = undo.oldCastlingRights;
    state.zobristKey = undo.oldZobristKey;
    state.halfmoveClock = undo.oldHalfmoveClock;

    while (state.positionHistory.length > undo.oldHistoryLength) {
      state.positionHistory.removeLast();
    }

    if (undo.wasCastle) {
      board[undo.rookFrom!] = undo.rookPiece!;
      board[undo.rookTo!] = 0;
    }

    board[undo.fromIndex] = undo.movedPiece;
    board[undo.toIndex] = undo.capturedPiece;

    if (undo.wasEnPassant) {
      board[undo.enPassantCapturedIndex!] =
      undo.enPassantCapturedPiece!;
    }
  }


  int perftMakeUndo({
    required AiGameState state,
    required int depth,
  }) {
    if (depth == 0) {
      return 1;
    }

    final List<AiMove> moves = _getOrderedMoves(
      state: state,
      hashEntry: null,
      ply: 0,
    );

    if (depth == 1) {
      return moves.length;
    }

    int nodes = 0;

    for (final AiMove move in moves) {
      final MoveUndo undo = _makeMoveInPlace(
        state: state,
        move: move,
      );

      nodes += perftMakeUndo(
        state: state,
        depth: depth - 1,
      );

      _undoMoveInPlace(
        state: state,
        undo: undo,
      );
    }

    return nodes;
  }

  MoveUndo makeMoveInPlaceForTest({
    required AiGameState state,
    required AiMove move,
  }) {
    return _makeMoveInPlace(
      state: state,
      move: move,
    );
  }

  void undoMoveInPlaceForTest({
    required AiGameState state,
    required MoveUndo undo,
  }) {
    _undoMoveInPlace(
      state: state,
      undo: undo,
    );
  }


}


class MoveUndo {
  final int fromIndex;
  final int toIndex;
  final int movedPiece;
  final int capturedPiece;

  final bool oldIsWhiteTurn;
  final bool oldIsEnemyMove;
  final int? oldEnPassantTargetIndex;
  final AiCastlingRights oldCastlingRights;
  final int oldZobristKey;
  final int oldHalfmoveClock;
  final int oldHistoryLength;

  final bool wasEnPassant;
  final int? enPassantCapturedIndex;
  final int? enPassantCapturedPiece;

  final bool wasCastle;
  final int? rookFrom;
  final int? rookTo;
  final int? rookPiece;

  const MoveUndo({
    required this.fromIndex,
    required this.toIndex,
    required this.movedPiece,
    required this.capturedPiece,
    required this.oldIsWhiteTurn,
    required this.oldIsEnemyMove,
    required this.oldEnPassantTargetIndex,
    required this.oldCastlingRights,
    required this.oldZobristKey,
    required this.oldHalfmoveClock,
    required this.oldHistoryLength,
    required this.wasEnPassant,
    this.enPassantCapturedIndex,
    this.enPassantCapturedPiece,
    required this.wasCastle,
    this.rookFrom,
    this.rookTo,
    this.rookPiece,
  });
}
