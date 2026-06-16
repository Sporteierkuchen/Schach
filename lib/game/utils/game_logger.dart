import 'package:flutter/foundation.dart';

class GameLogger {

  static bool enableGameLogs = true;
  static bool enableAiLogs = true;
  static bool enableSimulationLogs = false;

  static void spiel(String text) {

    if (!enableGameLogs) {
      return;
    }

    debugPrint(
      "[Spiel ${DateTime.now().toIso8601String()}] $text",
    );
  }

  static void ki(String text) {

    if (!enableAiLogs) {
      return;
    }

    debugPrint(
      "[KI ${DateTime.now().toIso8601String()}] $text",
    );
  }

  static void simulation(String text) {

    if (!enableSimulationLogs) {
      return;
    }

    debugPrint(
      "[Simulation ${DateTime.now().toIso8601String()}] $text",
    );
  }
}