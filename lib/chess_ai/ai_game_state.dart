import 'package:schach/chess_ai/board_helper.dart';

const Object _unset = Object();

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

  final bool isEnemyMove;
  final bool isWhiteTurn;
  final bool playerIsWhite;

  final int? enPassantTargetIndex;
  final AiCastlingRights castlingRights;

  const AiGameState({
    required this.board,
    required this.isEnemyMove,
    required this.isWhiteTurn,
    required this.playerIsWhite,
    required this.enPassantTargetIndex,
    required this.castlingRights,
  });

  AiGameState copyWith({
    List<int>? board,
    bool? isEnemyMove,
    bool? isWhiteTurn,
    bool? playerIsWhite,
    Object? enPassantTargetIndex = _unset,
    AiCastlingRights? castlingRights,
  }) {
    return AiGameState(
      board: board ?? List<int>.from(this.board),
      isEnemyMove: isEnemyMove ?? this.isEnemyMove,
      isWhiteTurn: isWhiteTurn ?? this.isWhiteTurn,
      playerIsWhite: playerIsWhite ?? this.playerIsWhite,
      enPassantTargetIndex: enPassantTargetIndex == _unset
          ? this.enPassantTargetIndex
          : enPassantTargetIndex as int?,
      castlingRights: castlingRights ?? this.castlingRights,
    );
  }

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