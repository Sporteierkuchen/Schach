import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:schach/models/saved_position.dart';

class PositionStorageService {
  static const String _key = "saved_chess_positions";

  static Future<List<SavedPosition>> loadPositions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    return raw
        .map((e) => SavedPosition.fromJson(jsonDecode(e)))
        .toList();
  }

  static Future<void> savePosition(SavedPosition position) async {
    final prefs = await SharedPreferences.getInstance();
    final positions = await loadPositions();

    final bool nameExists = positions.any(
          (p) =>
      p.id != position.id &&
          p.name.trim().toLowerCase() == position.name.trim().toLowerCase(),
    );

    if (nameExists) {
      throw Exception("Eine Stellung mit diesem Namen existiert bereits.");
    }

    positions.removeWhere((p) => p.id == position.id);
    positions.add(position);

    await prefs.setStringList(
      _key,
      positions.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }

  static Future<void> deletePosition(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final positions = await loadPositions();

    positions.removeWhere((p) => p.id == id);

    await prefs.setStringList(
      _key,
      positions.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }
}