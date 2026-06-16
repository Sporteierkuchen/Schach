import 'package:schach/chess_ai/board_helper.dart';
import 'package:schach/chess_ai/zobrist_hasher.dart';

class AiCastlingRights {
  final bool whiteKingSide;
  final bool whiteQueenSide;
  final bool blackKingSide;
  final bool blackQueenSide;

  const AiCastlingRights({
    required this.whiteKingSide,
    required this.whiteQueenSide,
    required this.blackKingSide,
    required this.blackQueenSide,
  });

  AiCastlingRights copyWith({
    bool? whiteKingSide,
    bool? whiteQueenSide,
    bool? blackKingSide,
    bool? blackQueenSide,
  }) {
    return AiCastlingRights(
      whiteKingSide: whiteKingSide ?? this.whiteKingSide,
      whiteQueenSide: whiteQueenSide ?? this.whiteQueenSide,
      blackKingSide: blackKingSide ?? this.blackKingSide,
      blackQueenSide: blackQueenSide ?? this.blackQueenSide,
    );
  }
}

class AiGameState {
  final List<int> board;

  bool isEnemyMove;
  bool isWhiteTurn;
  final bool playerIsWhite;

  int? enPassantTargetIndex;
  AiCastlingRights castlingRights;

  int zobristKey;

  int halfmoveClock;
  final List<int> positionHistory;

  AiGameState({
    required this.board,
    required this.isEnemyMove,
    required this.isWhiteTurn,
    required this.playerIsWhite,
    required this.enPassantTargetIndex,
    required this.castlingRights,
    int? zobristKey,
    this.halfmoveClock = 0,
    List<int>? positionHistory,
  })  : zobristKey = zobristKey ??
      ZobristHasher.hashFromValues(
        board: board,
        isWhiteTurn: isWhiteTurn,
        enPassantTargetIndex: enPassantTargetIndex,
        castlingRights: castlingRights,
      ),
        positionHistory = positionHistory ?? [];

  int? get whiteKingIndex {
    final int whiteKingCode = playerIsWhite ? 6 : -6;
    return board.indexWhere((p) => p == whiteKingCode);
  }

  int? get blackKingIndex {
    final int blackKingCode = playerIsWhite ? -6 : 6;
    return board.indexWhere((p) => p == blackKingCode);
  }

  String get debugString {
    return "AiGameState("
        "isWhiteTurn=$isWhiteTurn, "
        "isEnemyMove=$isEnemyMove, "
        "playerIsWhite=$playerIsWhite, "
        "enPassant=${enPassantTargetIndex == null ? "none" : BoardHelper.indexToCoord(enPassantTargetIndex!)}, "
        "castle WK=${castlingRights.whiteKingSide}, "
        "WQ=${castlingRights.whiteQueenSide}, "
        "BK=${castlingRights.blackKingSide}, "
        "BQ=${castlingRights.blackQueenSide}"
        ")";
  }
}