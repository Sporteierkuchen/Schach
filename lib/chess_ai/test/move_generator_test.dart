import 'package:flutter_test/flutter_test.dart';
import 'package:schach/chess_ai/move_generator.dart';
import 'package:schach/chess_ai/board_helper.dart';

import 'package:schach/chess_ai/ai_game_state.dart';
import 'package:schach/chess_ai/test/test_positions.dart';

void main() {
  test('Weiße kurze Rochade ist legal, wenn Weg frei und sicher ist', () {
    final generator = MoveGenerator();
    final state = TestPositions.whiteCanCastleKingSide();

    final moves = generator.getLegalMovesForPiece(
      state: state,
      index: BoardHelper.getIndex(7, 4),
      piece: 6,
    );

    expect(moves, contains(BoardHelper.getIndex(7, 6))); // g1
  });

  test('Mattstellung erkennt Schachmatt nach B8 -> B1', () {
    final generator = MoveGenerator();
    final state = TestPositions.mateInOneBlack();

    final moves = generator.getLegalMovesForPiece(
      state: state,
      index: BoardHelper.getIndex(0, 1),
      piece: -4,
    );

    expect(moves, contains(BoardHelper.getIndex(7, 1)));
  });

  test(
    "König darf nicht auf ein angegriffenes Feld ziehen",
        () {

      final generator = MoveGenerator();

      final board = List<int>.filled(64, 0);

      // Weißer König e1
      board[60] = 6;

      // Schwarzer König e8
      board[4] = -6;

      // Schwarzer Turm e5 kontrolliert e-Reihe
      board[28] = -4;


      final state = AiGameState(
        board: board,
        isEnemyMove: false,
        isWhiteTurn: true,
        playerIsWhite: true,
        enPassantTargetIndex: null,
        castlingRights: TestPositions.noCastling(),
      );


      final moves =
      generator.getLegalMovesForPiece(
        state: state,
        index: 60,
        piece: 6,
      );


      // König darf nicht nach e2
      expect(
        moves.contains(52),
        false,
      );
    },
  );

  test(
    "Rochade durch Schachfeld verboten",
        () {

      final generator = MoveGenerator();

      final board = List<int>.filled(64,0);


      board[60] = 6; // Weißer König e1
      board[63] = 4; // Turm h1

      board[4] = -6; // Schwarzer König e8


      // Turm greift f1 an
      board[5] = -4;


      final state = AiGameState(
        board: board,
        isEnemyMove:false,
        isWhiteTurn:true,
        playerIsWhite:true,
        enPassantTargetIndex:null,

        castlingRights:
        const AiCastlingRights(
          whiteKingSide:true,
          whiteQueenSide:false,
          blackKingSide:false,
          blackQueenSide:false,
        ),
      );


      final moves =
      generator.getLegalMovesForPiece(
        state: state,
        index: 60,
        piece: 6,
      );


      expect(
        moves.contains(62),
        false,
      );
    },
  );

}