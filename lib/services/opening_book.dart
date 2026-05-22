enum OpeningStyle {
  aggressive,
  solid,
  balanced,
}

class OpeningBookMove {

  final List<String> line;

  final String name;

  final int weight;

  final int minLevel;

  final int maxLevel;

  final OpeningStyle style;

  const OpeningBookMove({

    required this.line,

    required this.name,

    required this.weight,

    required this.minLevel,

    required this.maxLevel,

    required this.style,
  });
}

class OpeningBook {

  static const List<OpeningBookMove> lines = [

    // Italienisch

    OpeningBookMove(

      name: "Italian Game",

      style: OpeningStyle.balanced,

      weight: 100,

      minLevel: 1,

      maxLevel: 10,

      line: [

        "e2e4",
        "e7e5",

        "g1f3",
        "b8c6",

        "f1c4",
        "f8c5",

        "c2c3",
        "g8f6",
      ],
    ),

    // Spanisch

    OpeningBookMove(

      name: "Ruy Lopez",

      style: OpeningStyle.solid,

      weight: 100,

      minLevel: 3,

      maxLevel: 10,

      line: [

        "e2e4",
        "e7e5",

        "g1f3",
        "b8c6",

        "f1b5",
        "a7a6",

        "b5a4",
        "g8f6",
      ],
    ),

    // Sizilianisch Najdorf

    OpeningBookMove(

      name: "Sicilian Najdorf",

      style: OpeningStyle.aggressive,

      weight: 95,

      minLevel: 5,

      maxLevel: 10,

      line: [

        "e2e4",
        "c7c5",

        "g1f3",
        "d7d6",

        "d2d4",
        "c5d4",

        "f3d4",
        "g8f6",

        "b1c3",
        "a7a6",
      ],
    ),

    // Caro Kann

    OpeningBookMove(

      name: "Caro Kann",

      style: OpeningStyle.solid,

      weight: 90,

      minLevel: 1,

      maxLevel: 10,

      line: [

        "e2e4",

        "c7c6",

        "d2d4",

        "d7d5",
      ],
    ),

    // Französisch

    OpeningBookMove(

      name: "French Defense",

      style: OpeningStyle.solid,

      weight: 80,

      minLevel: 2,

      maxLevel: 10,

      line: [

        "e2e4",

        "e7e6",

        "d2d4",

        "d7d5",
      ],
    ),

    // Damengambit

    OpeningBookMove(

      name: "Queens Gambit",

      style: OpeningStyle.balanced,

      weight: 100,

      minLevel: 1,

      maxLevel: 10,

      line: [

        "d2d4",

        "d7d5",

        "c2c4",
      ],
    ),

    // London

    OpeningBookMove(

      name: "London",

      style: OpeningStyle.solid,

      weight: 70,

      minLevel: 1,

      maxLevel: 10,

      line: [

        "d2d4",

        "d7d5",

        "c1f4",
      ],
    ),

    // Königsindisch

    OpeningBookMove(

      name: "Kings Indian",

      style: OpeningStyle.aggressive,

      weight: 80,

      minLevel: 4,

      maxLevel: 10,

      line: [

        "d2d4",

        "g8f6",

        "c2c4",

        "g7g6",

        "b1c3",

        "f8g7",
      ],
    ),

    // Englisch

    OpeningBookMove(

      name: "English",

      style: OpeningStyle.balanced,

      weight: 60,

      minLevel: 2,

      maxLevel: 10,

      line: [

        "c2c4",

        "e7e5",
      ],
    ),











    // Weitere Italienisch-Varianten
    OpeningBookMove(
      name: "Italian Game - Giuoco Piano",
      style: OpeningStyle.balanced,
      weight: 95,
      minLevel: 1,
      maxLevel: 10,
      line: ["e2e4", "e7e5", "g1f3", "b8c6", "f1c4", "f8c5", "c2c3", "g8f6", "d2d4"],
    ),

    OpeningBookMove(
      name: "Italian Game - Two Knights",
      style: OpeningStyle.aggressive,
      weight: 85,
      minLevel: 3,
      maxLevel: 10,
      line: ["e2e4", "e7e5", "g1f3", "b8c6", "f1c4", "g8f6", "f3g5"],
    ),

    OpeningBookMove(
      name: "Italian Game - Quiet Line",
      style: OpeningStyle.solid,
      weight: 80,
      minLevel: 1,
      maxLevel: 10,
      line: ["e2e4", "e7e5", "g1f3", "b8c6", "f1c4", "f8c5", "d2d3", "g8f6"],
    ),

    // Spanisch / Ruy Lopez
    OpeningBookMove(
      name: "Ruy Lopez - Closed",
      style: OpeningStyle.solid,
      weight: 100,
      minLevel: 5,
      maxLevel: 10,
      line: ["e2e4", "e7e5", "g1f3", "b8c6", "f1b5", "a7a6", "b5a4", "g8f6", "e1g1", "f8e7"],
    ),

    OpeningBookMove(
      name: "Ruy Lopez - Berlin",
      style: OpeningStyle.solid,
      weight: 90,
      minLevel: 5,
      maxLevel: 10,
      line: ["e2e4", "e7e5", "g1f3", "b8c6", "f1b5", "g8f6", "e1g1", "f6e4"],
    ),

    OpeningBookMove(
      name: "Ruy Lopez - Exchange",
      style: OpeningStyle.solid,
      weight: 70,
      minLevel: 2,
      maxLevel: 10,
      line: ["e2e4", "e7e5", "g1f3", "b8c6", "f1b5", "a7a6", "b5c6", "d7c6"],
    ),

    // Schottisch
    OpeningBookMove(
      name: "Scotch Game",
      style: OpeningStyle.aggressive,
      weight: 80,
      minLevel: 2,
      maxLevel: 10,
      line: ["e2e4", "e7e5", "g1f3", "b8c6", "d2d4", "e5d4", "f3d4"],
    ),

    OpeningBookMove(
      name: "Scotch Four Knights",
      style: OpeningStyle.balanced,
      weight: 70,
      minLevel: 2,
      maxLevel: 10,
      line: ["e2e4", "e7e5", "g1f3", "b8c6", "b1c3", "g8f6", "d2d4"],
    ),

    // Sizilianisch
    OpeningBookMove(
      name: "Sicilian Dragon",
      style: OpeningStyle.aggressive,
      weight: 90,
      minLevel: 5,
      maxLevel: 10,
      line: ["e2e4", "c7c5", "g1f3", "d7d6", "d2d4", "c5d4", "f3d4", "g8f6", "b1c3", "g7g6"],
    ),

    OpeningBookMove(
      name: "Sicilian Classical",
      style: OpeningStyle.balanced,
      weight: 80,
      minLevel: 4,
      maxLevel: 10,
      line: ["e2e4", "c7c5", "g1f3", "d7d6", "d2d4", "c5d4", "f3d4", "g8f6", "b1c3", "b8c6"],
    ),

    OpeningBookMove(
      name: "Sicilian Alapin",
      style: OpeningStyle.solid,
      weight: 75,
      minLevel: 1,
      maxLevel: 10,
      line: ["e2e4", "c7c5", "c2c3", "d7d5", "e4d5", "d8d5"],
    ),

    OpeningBookMove(
      name: "Sicilian Accelerated Dragon",
      style: OpeningStyle.aggressive,
      weight: 75,
      minLevel: 4,
      maxLevel: 10,
      line: ["e2e4", "c7c5", "g1f3", "b8c6", "d2d4", "c5d4", "f3d4", "g7g6"],
    ),

    // Französisch
    OpeningBookMove(
      name: "French Advance",
      style: OpeningStyle.solid,
      weight: 80,
      minLevel: 2,
      maxLevel: 10,
      line: ["e2e4", "e7e6", "d2d4", "d7d5", "e4e5", "c7c5"],
    ),

    OpeningBookMove(
      name: "French Classical",
      style: OpeningStyle.balanced,
      weight: 75,
      minLevel: 3,
      maxLevel: 10,
      line: ["e2e4", "e7e6", "d2d4", "d7d5", "b1c3", "g8f6"],
    ),

    OpeningBookMove(
      name: "French Tarrasch",
      style: OpeningStyle.solid,
      weight: 70,
      minLevel: 2,
      maxLevel: 10,
      line: ["e2e4", "e7e6", "d2d4", "d7d5", "b1d2", "g8f6"],
    ),

    // Caro-Kann
    OpeningBookMove(
      name: "Caro Kann Advance",
      style: OpeningStyle.solid,
      weight: 80,
      minLevel: 2,
      maxLevel: 10,
      line: ["e2e4", "c7c6", "d2d4", "d7d5", "e4e5", "c8f5"],
    ),

    OpeningBookMove(
      name: "Caro Kann Classical",
      style: OpeningStyle.solid,
      weight: 85,
      minLevel: 3,
      maxLevel: 10,
      line: ["e2e4", "c7c6", "d2d4", "d7d5", "b1c3", "d5e4", "c3e4"],
    ),

    OpeningBookMove(
      name: "Caro Kann Exchange",
      style: OpeningStyle.solid,
      weight: 65,
      minLevel: 1,
      maxLevel: 10,
      line: ["e2e4", "c7c6", "d2d4", "d7d5", "e4d5", "c6d5"],
    ),

    // Pirc / Modern
    OpeningBookMove(
      name: "Pirc Defense",
      style: OpeningStyle.aggressive,
      weight: 75,
      minLevel: 3,
      maxLevel: 10,
      line: ["e2e4", "d7d6", "d2d4", "g8f6", "b1c3", "g7g6"],
    ),

    OpeningBookMove(
      name: "Modern Defense",
      style: OpeningStyle.aggressive,
      weight: 70,
      minLevel: 2,
      maxLevel: 10,
      line: ["e2e4", "g7g6", "d2d4", "f8g7", "b1c3", "d7d6"],
    ),

    // Skandinavisch / Alekhine
    OpeningBookMove(
      name: "Scandinavian Main Line",
      style: OpeningStyle.balanced,
      weight: 65,
      minLevel: 1,
      maxLevel: 8,
      line: ["e2e4", "d7d5", "e4d5", "d8d5", "b1c3", "d5a5"],
    ),

    OpeningBookMove(
      name: "Alekhine Defense",
      style: OpeningStyle.aggressive,
      weight: 55,
      minLevel: 2,
      maxLevel: 8,
      line: ["e2e4", "g8f6", "e4e5", "f6d5", "d2d4", "d7d6"],
    ),

    // Damengambit
    OpeningBookMove(
      name: "Queens Gambit Declined",
      style: OpeningStyle.solid,
      weight: 100,
      minLevel: 2,
      maxLevel: 10,
      line: ["d2d4", "d7d5", "c2c4", "e7e6", "b1c3", "g8f6"],
    ),

    OpeningBookMove(
      name: "Queens Gambit Accepted",
      style: OpeningStyle.balanced,
      weight: 75,
      minLevel: 2,
      maxLevel: 10,
      line: ["d2d4", "d7d5", "c2c4", "d5c4", "g1f3", "g8f6"],
    ),

    OpeningBookMove(
      name: "Slav Defense",
      style: OpeningStyle.solid,
      weight: 90,
      minLevel: 3,
      maxLevel: 10,
      line: ["d2d4", "d7d5", "c2c4", "c7c6", "g1f3", "g8f6"],
    ),

    OpeningBookMove(
      name: "Semi-Slav Defense",
      style: OpeningStyle.solid,
      weight: 80,
      minLevel: 5,
      maxLevel: 10,
      line: ["d2d4", "d7d5", "c2c4", "c7c6", "g1f3", "g8f6", "b1c3", "e7e6"],
    ),

    // London / Colle / Torre
    OpeningBookMove(
      name: "London System",
      style: OpeningStyle.solid,
      weight: 85,
      minLevel: 1,
      maxLevel: 10,
      line: ["d2d4", "d7d5", "c1f4", "g8f6", "e2e3", "e7e6"],
    ),

    OpeningBookMove(
      name: "London vs Nf6",
      style: OpeningStyle.solid,
      weight: 80,
      minLevel: 1,
      maxLevel: 10,
      line: ["d2d4", "g8f6", "c1f4", "e7e6", "e2e3"],
    ),

    OpeningBookMove(
      name: "Colle System",
      style: OpeningStyle.solid,
      weight: 60,
      minLevel: 1,
      maxLevel: 8,
      line: ["d2d4", "d7d5", "g1f3", "g8f6", "e2e3", "e7e6"],
    ),

    OpeningBookMove(
      name: "Torre Attack",
      style: OpeningStyle.balanced,
      weight: 60,
      minLevel: 2,
      maxLevel: 9,
      line: ["d2d4", "g8f6", "g1f3", "e7e6", "c1g5"],
    ),

    // Indische Systeme
    OpeningBookMove(
      name: "Kings Indian Defense",
      style: OpeningStyle.aggressive,
      weight: 95,
      minLevel: 4,
      maxLevel: 10,
      line: ["d2d4", "g8f6", "c2c4", "g7g6", "b1c3", "f8g7", "e2e4", "d7d6"],
    ),

    OpeningBookMove(
      name: "Nimzo Indian",
      style: OpeningStyle.solid,
      weight: 95,
      minLevel: 5,
      maxLevel: 10,
      line: ["d2d4", "g8f6", "c2c4", "e7e6", "b1c3", "f8b4"],
    ),

    OpeningBookMove(
      name: "Queens Indian",
      style: OpeningStyle.solid,
      weight: 80,
      minLevel: 5,
      maxLevel: 10,
      line: ["d2d4", "g8f6", "c2c4", "e7e6", "g1f3", "b7b6"],
    ),

    OpeningBookMove(
      name: "Grunfeld Defense",
      style: OpeningStyle.aggressive,
      weight: 80,
      minLevel: 6,
      maxLevel: 10,
      line: ["d2d4", "g8f6", "c2c4", "g7g6", "b1c3", "d7d5"],
    ),

    OpeningBookMove(
      name: "Benoni Defense",
      style: OpeningStyle.aggressive,
      weight: 65,
      minLevel: 4,
      maxLevel: 10,
      line: ["d2d4", "g8f6", "c2c4", "c7c5", "d4d5", "e7e6"],
    ),

    // Holländisch
    OpeningBookMove(
      name: "Dutch Defense",
      style: OpeningStyle.aggressive,
      weight: 65,
      minLevel: 2,
      maxLevel: 9,
      line: ["d2d4", "f7f5", "g2g3", "g8f6"],
    ),

    OpeningBookMove(
      name: "Stonewall Dutch",
      style: OpeningStyle.solid,
      weight: 55,
      minLevel: 3,
      maxLevel: 9,
      line: ["d2d4", "f7f5", "g2g3", "g8f6", "f1g2", "e7e6"],
    ),

    // Englisch
    OpeningBookMove(
      name: "English Opening",
      style: OpeningStyle.balanced,
      weight: 80,
      minLevel: 2,
      maxLevel: 10,
      line: ["c2c4", "e7e5", "b1c3", "g8f6"],
    ),

    OpeningBookMove(
      name: "English Symmetrical",
      style: OpeningStyle.solid,
      weight: 70,
      minLevel: 2,
      maxLevel: 10,
      line: ["c2c4", "c7c5", "g1f3", "g8f6"],
    ),

    OpeningBookMove(
      name: "English Four Knights",
      style: OpeningStyle.balanced,
      weight: 70,
      minLevel: 3,
      maxLevel: 10,
      line: ["c2c4", "e7e5", "b1c3", "g8f6", "g1f3", "b8c6"],
    ),

    // Reti / Flanken
    OpeningBookMove(
      name: "Reti Opening",
      style: OpeningStyle.solid,
      weight: 75,
      minLevel: 2,
      maxLevel: 10,
      line: ["g1f3", "d7d5", "c2c4"],
    ),

    OpeningBookMove(
      name: "Kings Indian Attack",
      style: OpeningStyle.balanced,
      weight: 65,
      minLevel: 2,
      maxLevel: 10,
      line: ["g1f3", "d7d5", "g2g3", "g8f6", "f1g2"],
    ),

    OpeningBookMove(
      name: "Larsen Opening",
      style: OpeningStyle.balanced,
      weight: 45,
      minLevel: 1,
      maxLevel: 7,
      line: ["b2b3", "e7e5", "c1b2"],
    ),

    OpeningBookMove(
      name: "Bird Opening",
      style: OpeningStyle.aggressive,
      weight: 45,
      minLevel: 1,
      maxLevel: 7,
      line: ["f2f4", "d7d5", "g1f3"],
    ),











    // Vienna Game
    OpeningBookMove(
      name: "Vienna Game",
      style: OpeningStyle.aggressive,
      weight: 70,
      minLevel: 1,
      maxLevel: 8,
      line: [
        "e2e4","e7e5",
        "b1c3","g8f6",
        "f2f4"
      ],
    ),

    OpeningBookMove(
      name: "Vienna Gambit",
      style: OpeningStyle.aggressive,
      weight: 60,
      minLevel: 2,
      maxLevel: 8,
      line: [
        "e2e4","e7e5",
        "b1c3","g8f6",
        "f2f4","d7d5"
      ],
    ),

// Evans Gambit
    OpeningBookMove(
      name: "Evans Gambit",
      style: OpeningStyle.aggressive,
      weight: 70,
      minLevel: 3,
      maxLevel: 9,
      line: [
        "e2e4","e7e5",
        "g1f3","b8c6",
        "f1c4","f8c5",
        "b2b4"
      ],
    ),

// Danish Gambit
    OpeningBookMove(
      name: "Danish Gambit",
      style: OpeningStyle.aggressive,
      weight: 50,
      minLevel: 2,
      maxLevel: 7,
      line: [
        "e2e4","e7e5",
        "d2d4","e5d4",
        "c2c3"
      ],
    ),

// Scotch Gambit
    OpeningBookMove(
      name: "Scotch Gambit",
      style: OpeningStyle.aggressive,
      weight: 65,
      minLevel: 2,
      maxLevel: 9,
      line: [
        "e2e4","e7e5",
        "g1f3","b8c6",
        "d2d4","e5d4",
        "f1c4"
      ],
    ),

// Sicilian Najdorf English Attack
    OpeningBookMove(
      name: "Najdorf English Attack",
      style: OpeningStyle.aggressive,
      weight: 90,
      minLevel: 6,
      maxLevel: 10,
      line: [
        "e2e4","c7c5",
        "g1f3","d7d6",
        "d2d4","c5d4",
        "f3d4","g8f6",
        "b1c3","a7a6",
        "c1e3"
      ],
    ),

// Sicilian Rossolimo
    OpeningBookMove(
      name: "Rossolimo Sicilian",
      style: OpeningStyle.solid,
      weight: 70,
      minLevel: 4,
      maxLevel: 10,
      line: [
        "e2e4","c7c5",
        "g1f3","b8c6",
        "f1b5"
      ],
    ),

// French Winawer
    OpeningBookMove(
      name: "French Winawer",
      style: OpeningStyle.aggressive,
      weight: 75,
      minLevel: 5,
      maxLevel: 10,
      line: [
        "e2e4","e7e6",
        "d2d4","d7d5",
        "b1c3","f8b4"
      ],
    ),

// French Rubinstein
    OpeningBookMove(
      name: "French Rubinstein",
      style: OpeningStyle.solid,
      weight: 65,
      minLevel: 4,
      maxLevel: 10,
      line: [
        "e2e4","e7e6",
        "d2d4","d7d5",
        "b1c3","d5e4"
      ],
    ),

// Caro-Kann Tartakower
    OpeningBookMove(
      name: "Caro Tartakower",
      style: OpeningStyle.solid,
      weight: 65,
      minLevel: 5,
      maxLevel: 10,
      line: [
        "e2e4","c7c6",
        "d2d4","d7d5",
        "b1d2"
      ],
    ),

// Kings Indian Saemisch
    OpeningBookMove(
      name: "Kings Indian Saemisch",
      style: OpeningStyle.aggressive,
      weight: 75,
      minLevel: 6,
      maxLevel: 10,
      line: [
        "d2d4","g8f6",
        "c2c4","g7g6",
        "b1c3","f8g7",
        "e2e4","d7d6",
        "f2f3"
      ],
    ),

// Grunfeld Main
    OpeningBookMove(
      name: "Grunfeld Main",
      style: OpeningStyle.aggressive,
      weight: 85,
      minLevel: 6,
      maxLevel: 10,
      line: [
        "d2d4","g8f6",
        "c2c4","g7g6",
        "b1c3","d7d5",
        "c4d5","f6d5"
      ],
    ),

// Catalan
    OpeningBookMove(
      name: "Catalan Opening",
      style: OpeningStyle.solid,
      weight: 80,
      minLevel: 5,
      maxLevel: 10,
      line: [
        "d2d4","g8f6",
        "c2c4","e7e6",
        "g2g3"
      ],
    ),

// Benko Gambit
    OpeningBookMove(
      name: "Benko Gambit",
      style: OpeningStyle.aggressive,
      weight: 55,
      minLevel: 6,
      maxLevel: 10,
      line: [
        "d2d4","g8f6",
        "c2c4","c7c5",
        "d4d5","b7b5"
      ],
    ),

// Accelerated London
    OpeningBookMove(
      name: "Accelerated London",
      style: OpeningStyle.solid,
      weight: 60,
      minLevel: 2,
      maxLevel: 9,
      line: [
        "d2d4","g8f6",
        "c1f4","d7d5",
        "e2e3"
      ],
    ),

// English Botvinnik
    OpeningBookMove(
      name: "English Botvinnik",
      style: OpeningStyle.solid,
      weight: 65,
      minLevel: 5,
      maxLevel: 10,
      line: [
        "c2c4","g8f6",
        "b1c3","e7e5",
        "g2g3"
      ],
    ),

// Trompowsky
    OpeningBookMove(
      name: "Trompowsky",
      style: OpeningStyle.aggressive,
      weight: 45,
      minLevel: 2,
      maxLevel: 8,
      line: [
        "d2d4","g8f6",
        "c1g5"
      ],
    ),

// Orangutan
    OpeningBookMove(
      name: "Orangutan",
      style: OpeningStyle.balanced,
      weight: 15,
      minLevel: 1,
      maxLevel: 3,
      line: [
        "b2b4"
      ],
    ),

// Grob
    OpeningBookMove(
      name: "Grob Attack",
      style: OpeningStyle.aggressive,
      weight: 10,
      minLevel: 1,
      maxLevel: 2,
      line: [
        "g2g4"
      ],
    ),











    // Petrov Main Line
    OpeningBookMove(
      name: "Petrov Main Line",
      style: OpeningStyle.solid,
      weight: 70,
      minLevel: 4,
      maxLevel: 10,
      line: ["e2e4", "e7e5", "g1f3", "g8f6", "f3e5", "d7d6", "e5f3", "f6e4"],
    ),

// Four Knights Spanish
    OpeningBookMove(
      name: "Four Knights Spanish",
      style: OpeningStyle.solid,
      weight: 65,
      minLevel: 2,
      maxLevel: 9,
      line: ["e2e4", "e7e5", "g1f3", "b8c6", "b1c3", "g8f6", "f1b5"],
    ),

// Philidor Defense
    OpeningBookMove(
      name: "Philidor Defense",
      style: OpeningStyle.solid,
      weight: 45,
      minLevel: 1,
      maxLevel: 7,
      line: ["e2e4", "e7e5", "g1f3", "d7d6"],
    ),

// Modern Italian
    OpeningBookMove(
      name: "Modern Italian",
      style: OpeningStyle.solid,
      weight: 85,
      minLevel: 3,
      maxLevel: 10,
      line: ["e2e4", "e7e5", "g1f3", "b8c6", "f1c4", "f8c5", "d2d3", "g8f6", "c2c3"],
    ),

// Ruy Lopez Marshall Setup
    OpeningBookMove(
      name: "Ruy Lopez Marshall Setup",
      style: OpeningStyle.aggressive,
      weight: 75,
      minLevel: 6,
      maxLevel: 10,
      line: ["e2e4", "e7e5", "g1f3", "b8c6", "f1b5", "a7a6", "b5a4", "g8f6", "e1g1", "f8e7", "f1e1", "b7b5"],
    ),

// Sicilian Scheveningen
    OpeningBookMove(
      name: "Sicilian Scheveningen",
      style: OpeningStyle.aggressive,
      weight: 80,
      minLevel: 5,
      maxLevel: 10,
      line: ["e2e4", "c7c5", "g1f3", "d7d6", "d2d4", "c5d4", "f3d4", "g8f6", "b1c3", "e7e6"],
    ),

// Sicilian Kan
    OpeningBookMove(
      name: "Sicilian Kan",
      style: OpeningStyle.solid,
      weight: 70,
      minLevel: 4,
      maxLevel: 10,
      line: ["e2e4", "c7c5", "g1f3", "e7e6", "d2d4", "c5d4", "f3d4", "a7a6"],
    ),

// Sicilian Sveshnikov
    OpeningBookMove(
      name: "Sicilian Sveshnikov",
      style: OpeningStyle.aggressive,
      weight: 80,
      minLevel: 6,
      maxLevel: 10,
      line: ["e2e4", "c7c5", "g1f3", "b8c6", "d2d4", "c5d4", "f3d4", "g8f6", "b1c3", "e7e5"],
    ),

// Sicilian Taimanov
    OpeningBookMove(
      name: "Sicilian Taimanov",
      style: OpeningStyle.balanced,
      weight: 75,
      minLevel: 5,
      maxLevel: 10,
      line: ["e2e4", "c7c5", "g1f3", "e7e6", "d2d4", "c5d4", "f3d4", "b8c6"],
    ),

// French Winawer Main
    OpeningBookMove(
      name: "French Winawer Main",
      style: OpeningStyle.aggressive,
      weight: 80,
      minLevel: 5,
      maxLevel: 10,
      line: ["e2e4", "e7e6", "d2d4", "d7d5", "b1c3", "f8b4", "e4e5", "c7c5"],
    ),

// French Burn
    OpeningBookMove(
      name: "French Burn",
      style: OpeningStyle.solid,
      weight: 65,
      minLevel: 5,
      maxLevel: 10,
      line: ["e2e4", "e7e6", "d2d4", "d7d5", "b1c3", "g8f6", "c1g5", "d5e4"],
    ),

// Caro-Kann Panov
    OpeningBookMove(
      name: "Caro-Kann Panov",
      style: OpeningStyle.balanced,
      weight: 70,
      minLevel: 3,
      maxLevel: 10,
      line: ["e2e4", "c7c6", "d2d4", "d7d5", "e4d5", "c6d5", "c2c4"],
    ),

// Caro-Kann Fantasy
    OpeningBookMove(
      name: "Caro-Kann Fantasy",
      style: OpeningStyle.aggressive,
      weight: 55,
      minLevel: 2,
      maxLevel: 8,
      line: ["e2e4", "c7c6", "d2d4", "d7d5", "f2f3"],
    ),

// Blackmar-Diemer Gambit
    OpeningBookMove(
      name: "Blackmar-Diemer Gambit",
      style: OpeningStyle.aggressive,
      weight: 35,
      minLevel: 1,
      maxLevel: 5,
      line: ["d2d4", "d7d5", "e2e4", "d5e4", "b1c3"],
    ),

// Veresov Attack
    OpeningBookMove(
      name: "Veresov Attack",
      style: OpeningStyle.aggressive,
      weight: 50,
      minLevel: 2,
      maxLevel: 8,
      line: ["d2d4", "d7d5", "b1c3", "g8f6", "c1g5"],
    ),

// Trompowsky Main
    OpeningBookMove(
      name: "Trompowsky Main",
      style: OpeningStyle.balanced,
      weight: 55,
      minLevel: 2,
      maxLevel: 8,
      line: ["d2d4", "g8f6", "c1g5", "e7e6"],
    ),

// Jobava London
    OpeningBookMove(
      name: "Jobava London",
      style: OpeningStyle.aggressive,
      weight: 55,
      minLevel: 3,
      maxLevel: 9,
      line: ["d2d4", "d7d5", "b1c3", "g8f6", "c1f4"],
    ),

// Catalan Closed
    OpeningBookMove(
      name: "Closed Catalan",
      style: OpeningStyle.solid,
      weight: 85,
      minLevel: 6,
      maxLevel: 10,
      line: ["d2d4", "g8f6", "c2c4", "e7e6", "g2g3", "d7d5"],
    ),

// Catalan Open
    OpeningBookMove(
      name: "Open Catalan",
      style: OpeningStyle.solid,
      weight: 75,
      minLevel: 6,
      maxLevel: 10,
      line: ["d2d4", "g8f6", "c2c4", "e7e6", "g2g3", "d7d5", "f1g2", "d5c4"],
    ),

// Queen's Indian Main
    OpeningBookMove(
      name: "Queen's Indian Main",
      style: OpeningStyle.solid,
      weight: 80,
      minLevel: 5,
      maxLevel: 10,
      line: ["d2d4", "g8f6", "c2c4", "e7e6", "g1f3", "b7b6", "g2g3", "c8b7"],
    ),

// Bogo Indian
    OpeningBookMove(
      name: "Bogo Indian",
      style: OpeningStyle.solid,
      weight: 60,
      minLevel: 5,
      maxLevel: 10,
      line: ["d2d4", "g8f6", "c2c4", "e7e6", "g1f3", "f8b4"],
    ),

// Semi-Tarrasch
    OpeningBookMove(
      name: "Semi-Tarrasch",
      style: OpeningStyle.balanced,
      weight: 65,
      minLevel: 5,
      maxLevel: 10,
      line: ["d2d4", "d7d5", "c2c4", "e7e6", "g1f3", "g8f6", "b1c3", "c7c5"],
    ),

// Tarrasch Defense
    OpeningBookMove(
      name: "Tarrasch Defense",
      style: OpeningStyle.balanced,
      weight: 65,
      minLevel: 4,
      maxLevel: 10,
      line: ["d2d4", "d7d5", "c2c4", "e7e6", "b1c3", "c7c5"],
    ),

// Chigorin Defense
    OpeningBookMove(
      name: "Chigorin Defense",
      style: OpeningStyle.aggressive,
      weight: 40,
      minLevel: 2,
      maxLevel: 7,
      line: ["d2d4", "d7d5", "c2c4", "b8c6"],
    ),

// Albin Countergambit
    OpeningBookMove(
      name: "Albin Countergambit",
      style: OpeningStyle.aggressive,
      weight: 35,
      minLevel: 1,
      maxLevel: 6,
      line: ["d2d4", "d7d5", "c2c4", "e7e5"],
    ),

// King's Indian Classical
    OpeningBookMove(
      name: "King's Indian Classical",
      style: OpeningStyle.aggressive,
      weight: 90,
      minLevel: 6,
      maxLevel: 10,
      line: ["d2d4", "g8f6", "c2c4", "g7g6", "b1c3", "f8g7", "e2e4", "d7d6", "g1f3", "e8g8"],
    ),

// King's Indian Fianchetto
    OpeningBookMove(
      name: "King's Indian Fianchetto",
      style: OpeningStyle.solid,
      weight: 70,
      minLevel: 5,
      maxLevel: 10,
      line: ["d2d4", "g8f6", "c2c4", "g7g6", "g2g3", "f8g7"],
    ),

// English Reversed Sicilian
    OpeningBookMove(
      name: "English Reversed Sicilian",
      style: OpeningStyle.balanced,
      weight: 75,
      minLevel: 3,
      maxLevel: 10,
      line: ["c2c4", "e7e5", "b1c3", "g8f6", "g2g3", "d7d5"],
    ),

// English Hedgehog
    OpeningBookMove(
      name: "English Hedgehog",
      style: OpeningStyle.solid,
      weight: 60,
      minLevel: 5,
      maxLevel: 10,
      line: ["c2c4", "c7c5", "g1f3", "g8f6", "g2g3", "b7b6"],
    ),

// King's Indian Attack
    OpeningBookMove(
      name: "King's Indian Attack vs French setup",
      style: OpeningStyle.balanced,
      weight: 60,
      minLevel: 2,
      maxLevel: 9,
      line: ["g1f3", "d7d5", "g2g3", "g8f6", "f1g2", "e7e6", "e1g1"],
    ),


// Ruy Lopez Anti-Marshall
    OpeningBookMove(
      name: "Ruy Lopez Anti-Marshall",
      style: OpeningStyle.solid,
      weight: 75,
      minLevel: 6,
      maxLevel: 10,
      line: ["e2e4", "e7e5", "g1f3", "b8c6", "f1b5", "a7a6", "b5a4", "g8f6", "e1g1", "f8e7", "h2h3"],
    ),

// Ruy Lopez Arkhangelsk
    OpeningBookMove(
      name: "Ruy Lopez Arkhangelsk",
      style: OpeningStyle.aggressive,
      weight: 65,
      minLevel: 6,
      maxLevel: 10,
      line: ["e2e4", "e7e5", "g1f3", "b8c6", "f1b5", "a7a6", "b5a4", "g8f6", "e1g1", "b7b5", "b5b3", "f8b7"],
    ),

// Italian Evans Declined
    OpeningBookMove(
      name: "Evans Gambit Declined",
      style: OpeningStyle.aggressive,
      weight: 45,
      minLevel: 2,
      maxLevel: 7,
      line: ["e2e4", "e7e5", "g1f3", "b8c6", "f1c4", "f8c5", "b2b4", "c5b6"],
    ),

// Center Game
    OpeningBookMove(
      name: "Center Game",
      style: OpeningStyle.balanced,
      weight: 35,
      minLevel: 1,
      maxLevel: 5,
      line: ["e2e4", "e7e5", "d2d4", "e5d4", "d1d4"],
    ),

// Bishop's Opening
    OpeningBookMove(
      name: "Bishop's Opening",
      style: OpeningStyle.balanced,
      weight: 45,
      minLevel: 1,
      maxLevel: 7,
      line: ["e2e4", "e7e5", "f1c4", "g8f6"],
    ),

// King's Gambit Declined
    OpeningBookMove(
      name: "King's Gambit Declined",
      style: OpeningStyle.solid,
      weight: 40,
      minLevel: 2,
      maxLevel: 7,
      line: ["e2e4", "e7e5", "f2f4", "f8c5"],
    ),

// Sicilian Dragon Yugoslav Attack
    OpeningBookMove(
      name: "Dragon Yugoslav Attack",
      style: OpeningStyle.aggressive,
      weight: 85,
      minLevel: 6,
      maxLevel: 10,
      line: ["e2e4", "c7c5", "g1f3", "d7d6", "d2d4", "c5d4", "f3d4", "g8f6", "b1c3", "g7g6", "c1e3", "f8g7"],
    ),

// Sicilian Najdorf Classical
    OpeningBookMove(
      name: "Najdorf Classical",
      style: OpeningStyle.balanced,
      weight: 75,
      minLevel: 6,
      maxLevel: 10,
      line: ["e2e4", "c7c5", "g1f3", "d7d6", "d2d4", "c5d4", "f3d4", "g8f6", "b1c3", "a7a6", "f1e2"],
    ),

// Sicilian Closed
    OpeningBookMove(
      name: "Closed Sicilian",
      style: OpeningStyle.balanced,
      weight: 55,
      minLevel: 2,
      maxLevel: 8,
      line: ["e2e4", "c7c5", "b1c3", "b8c6", "g2g3", "g7g6"],
    ),

// Smith-Morra Gambit
    OpeningBookMove(
      name: "Smith-Morra Gambit",
      style: OpeningStyle.aggressive,
      weight: 40,
      minLevel: 1,
      maxLevel: 6,
      line: ["e2e4", "c7c5", "d2d4", "c5d4", "c2c3"],
    ),

// French Exchange
    OpeningBookMove(
      name: "French Exchange",
      style: OpeningStyle.solid,
      weight: 45,
      minLevel: 1,
      maxLevel: 7,
      line: ["e2e4", "e7e6", "d2d4", "d7d5", "e4d5", "e6d5"],
    ),

// French Advance Main
    OpeningBookMove(
      name: "French Advance Main",
      style: OpeningStyle.solid,
      weight: 70,
      minLevel: 3,
      maxLevel: 10,
      line: ["e2e4", "e7e6", "d2d4", "d7d5", "e4e5", "c7c5", "c2c3", "b8c6"],
    ),

// Caro-Kann Bronstein-Larsen
    OpeningBookMove(
      name: "Caro-Kann Bronstein-Larsen",
      style: OpeningStyle.solid,
      weight: 55,
      minLevel: 4,
      maxLevel: 9,
      line: ["e2e4", "c7c6", "d2d4", "d7d5", "b1c3", "d5e4", "c3e4", "g8f6"],
    ),

// Pirc Austrian Attack
    OpeningBookMove(
      name: "Pirc Austrian Attack",
      style: OpeningStyle.aggressive,
      weight: 65,
      minLevel: 4,
      maxLevel: 10,
      line: ["e2e4", "d7d6", "d2d4", "g8f6", "b1c3", "g7g6", "f2f4"],
    ),

// Modern Averbakh
    OpeningBookMove(
      name: "Modern Averbakh",
      style: OpeningStyle.balanced,
      weight: 55,
      minLevel: 3,
      maxLevel: 9,
      line: ["e2e4", "g7g6", "d2d4", "f8g7", "c2c4", "d7d6"],
    ),

// Queen's Gambit Orthodox
    OpeningBookMove(
      name: "QGD Orthodox",
      style: OpeningStyle.solid,
      weight: 85,
      minLevel: 5,
      maxLevel: 10,
      line: ["d2d4", "d7d5", "c2c4", "e7e6", "b1c3", "g8f6", "c1g5", "f8e7"],
    ),

// Queen's Gambit Cambridge Springs
    OpeningBookMove(
      name: "Cambridge Springs",
      style: OpeningStyle.solid,
      weight: 65,
      minLevel: 4,
      maxLevel: 9,
      line: ["d2d4", "d7d5", "c2c4", "e7e6", "b1c3", "g8f6", "c1g5", "b8d7"],
    ),

// Slav Main Line
    OpeningBookMove(
      name: "Slav Main Line",
      style: OpeningStyle.solid,
      weight: 80,
      minLevel: 4,
      maxLevel: 10,
      line: ["d2d4", "d7d5", "c2c4", "c7c6", "g1f3", "g8f6", "b1c3", "d5c4"],
    ),

// Meran Semi-Slav
    OpeningBookMove(
      name: "Meran Semi-Slav",
      style: OpeningStyle.balanced,
      weight: 75,
      minLevel: 6,
      maxLevel: 10,
      line: ["d2d4", "d7d5", "c2c4", "c7c6", "g1f3", "g8f6", "b1c3", "e7e6", "e2e3"],
    ),

// Nimzo Rubinstein
    OpeningBookMove(
      name: "Nimzo Rubinstein",
      style: OpeningStyle.solid,
      weight: 85,
      minLevel: 6,
      maxLevel: 10,
      line: ["d2d4", "g8f6", "c2c4", "e7e6", "b1c3", "f8b4", "e2e3", "e8g8"],
    ),

// Nimzo Classical
    OpeningBookMove(
      name: "Nimzo Classical",
      style: OpeningStyle.balanced,
      weight: 70,
      minLevel: 6,
      maxLevel: 10,
      line: ["d2d4", "g8f6", "c2c4", "e7e6", "b1c3", "f8b4", "d1c2"],
    ),

// Grunfeld Exchange
    OpeningBookMove(
      name: "Grunfeld Exchange",
      style: OpeningStyle.aggressive,
      weight: 80,
      minLevel: 6,
      maxLevel: 10,
      line: ["d2d4", "g8f6", "c2c4", "g7g6", "b1c3", "d7d5", "c4d5", "f6d5", "e2e4"],
    ),

// Benoni Modern
    OpeningBookMove(
      name: "Modern Benoni",
      style: OpeningStyle.aggressive,
      weight: 65,
      minLevel: 5,
      maxLevel: 10,
      line: ["d2d4", "g8f6", "c2c4", "c7c5", "d4d5", "e7e6", "b1c3"],
    ),

// Dutch Leningrad
    OpeningBookMove(
      name: "Leningrad Dutch",
      style: OpeningStyle.aggressive,
      weight: 60,
      minLevel: 5,
      maxLevel: 9,
      line: ["d2d4", "f7f5", "g2g3", "g8f6", "f1g2", "g7g6"],
    ),

// English Bremen
    OpeningBookMove(
      name: "English Bremen",
      style: OpeningStyle.balanced,
      weight: 60,
      minLevel: 4,
      maxLevel: 10,
      line: ["c2c4", "e7e5", "b1c3", "g8f6", "g2g3", "f8b4"],
    ),

// English Symmetrical Hedgehog
    OpeningBookMove(
      name: "Symmetrical English Hedgehog",
      style: OpeningStyle.solid,
      weight: 55,
      minLevel: 5,
      maxLevel: 10,
      line: ["c2c4", "c7c5", "g1f3", "g8f6", "b1c3", "e7e6", "g2g3", "b7b6"],
    ),

// Reti King's Indian setup
    OpeningBookMove(
      name: "Reti King's Indian Setup",
      style: OpeningStyle.solid,
      weight: 60,
      minLevel: 3,
      maxLevel: 10,
      line: ["g1f3", "g8f6", "g2g3", "g7g6", "f1g2", "f8g7"],
    ),

// Polish Opening
    OpeningBookMove(
      name: "Polish Opening",
      style: OpeningStyle.balanced,
      weight: 20,
      minLevel: 1,
      maxLevel: 4,
      line: ["b2b4", "e7e5", "c1b2"],
    ),




  ];
}