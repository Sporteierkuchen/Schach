import 'dart:math';

import 'package:flutter/material.dart';
import 'package:schach/components/Spielart.dart';
import 'package:schach/components/Toast.dart';
import 'package:schach/models/saved_position.dart';
import 'package:schach/pages/saved_positions_page.dart';
import 'package:schach/pages/spielbrett.dart';
import 'package:schach/pages/stellung_editor.dart';
import 'package:schach/values/colors.dart';

class SpielAuswahl extends StatefulWidget {
  const SpielAuswahl({super.key});

  @override
  State<SpielAuswahl> createState() => _SpielAuswahlState();
}

class _SpielAuswahlState extends State<SpielAuswahl> {
  final List<SpielArt> spielartenListe = <SpielArt>[
    SpielArt(path: "assets/images/figuren/koenig_gold.png", figurenfarbe: 1),
    SpielArt(path: "", figurenfarbe: -1),
    SpielArt(path: "assets/images/figuren/koenig_gold.png", figurenfarbe: 0),
  ];

  final List<int> spielModusListe = <int>[0, 1, -1];

  SpielArt? selectedSpielArt;
  int? selectedSpielModus;

  Future<void> _startNormalGame() async {
    if (selectedSpielArt == null && selectedSpielModus == null) {
      showInfo(
        context: context,
        text: "Wähle die Farbe deiner Figuren aus und den Spielmodus!",
      );
      return;
    }

    if (selectedSpielArt == null) {
      showInfo(
        context: context,
        text: "Wähle die Farbe deiner Figuren aus, mit denen du spielen willst!",
      );
      return;
    }

    if (selectedSpielModus == null) {
      showInfo(
        context: context,
        text: "Wähle einen Spielmodus aus!",
      );
      return;
    }

    int spielfarbe = selectedSpielArt!.figurenfarbe;

    if (spielfarbe == -1) {
      spielfarbe = Random().nextInt(2);
    }

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SpielBrett(
          figurenfarbe: spielfarbe == 1,
          spielModus: selectedSpielModus!,
        ),
      ),
    );
  }

  Future<void> _openEditor() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StellungEditor(),
      ),
    );
  }

  Future<void> _openSavedPositions() async {
    final SavedPosition? position = await Navigator.push<SavedPosition>(
      context,
      MaterialPageRoute(
        builder: (context) => const SavedPositionsPage(),
      ),
    );

    if (position == null) return;

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SpielBrett(
          figurenfarbe: position.playerColorWhite,
          spielModus: position.spielModus,
          customBrett: position.brett,
          customIsWhiteTurn: position.whiteToMove,
          customMoveInfos: position.moveInfos,
        ),
      ),
    );
  }

  String _farbeText(int value) {
    if (value == 1) return "Weiß";
    if (value == 0) return "Schwarz";
    return "Zufall";
  }

  String _modusText(int value) {
    if (value == 0) return "Gegen Computer";
    if (value == 1) return "Gegen Spieler";
    if (value == -1) return "Computer vs Computer";
    return "$value";
  }

  IconData _modusIcon(int value) {
    if (value == 0) return Icons.smart_toy;
    if (value == 1) return Icons.people;
    return Icons.auto_awesome;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColorSpielAuswahl,
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
          child: Column(
            children: [
              const Text(
                "Schach",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 44,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 12),

              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  "assets/images/figuren/schach.png",
                  width: 145,
                  height: 145,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 28),

              _buildPlainSection(
                title: "Ich spiele als",
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: spielartenListe.map((spielart) {
                    final bool selected = selectedSpielArt == spielart;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedSpielArt = spielart;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 92,
                          height: 92,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: spielart.figurenfarbe == 1
                                ? Colors.white
                                : spielart.figurenfarbe == 0
                                ? Colors.black
                                : Colors.grey[500],
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: selected ? Colors.green : Colors.black26,
                              width: selected ? 4 : 1,
                            ),
                            boxShadow: selected
                                ? [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: spielart.figurenfarbe != -1
                                    ? Image.asset(spielart.path)
                                    : const Icon(
                                  Icons.question_mark,
                                  color: Colors.amber,
                                  size: 42,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _farbeText(spielart.figurenfarbe),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: spielart.figurenfarbe == 0
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              _buildPlainSection(
                title: "Spielmodus",
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: spielModusListe.map((modus) {
                    final bool selected = selectedSpielModus == modus;

                    return ChoiceChip(
                        selected: selected,
                        avatar: Icon(
                          _modusIcon(modus),
                          size: 18,
                          color: selected ? Colors.white : Colors.green[800],
                        ),
                        label: Text(_modusText(modus)),
                        selectedColor: Colors.green,
                        backgroundColor: Colors.white.withOpacity(0.45),
                        side: BorderSide(
                          color: selected ? Colors.green : Colors.black26,
                          width: selected ? 2 : 1,
                        ),
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) {
                          setState(() {
                            selectedSpielModus = modus;
                          });
                        },
                      );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 22),

              _buildMainButton(
                text: "Spielen",
                icon: Icons.play_arrow,
                color: Colors.green,
                onPressed: _startNormalGame,
              ),

              const SizedBox(height: 12),

              _buildSecondaryButton(
                text: "Stellung aufbauen",
                icon: Icons.edit_note,
                onPressed: _openEditor,
              ),

              const SizedBox(height: 10),

              _buildSecondaryButton(
                text: "Gespeicherte Stellungen",
                icon: Icons.folder_open,
                onPressed: _openSavedPositions,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlainSection({
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildMainButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: color,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.green[800],
          side: BorderSide(
            color: Colors.green.shade700,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }
}