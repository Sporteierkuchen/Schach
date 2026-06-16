import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:schach/models/match_history_entry.dart';

class MatchHistoryStorageService {
  static const String _key = "match_history";

  static Future<List<MatchHistoryEntry>> loadMatches() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? jsonText = prefs.getString(_key);

    if (jsonText == null || jsonText.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(jsonText);

    return decoded
        .map((item) => MatchHistoryEntry.fromJson(item))
        .toList();
  }

  static Future<void> saveMatch(MatchHistoryEntry match) async {
    final List<MatchHistoryEntry> matches = await loadMatches();

    matches.add(match);

    matches.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _key,
      jsonEncode(matches.map((m) => m.toJson()).toList()),
    );
  }

  static Future<void> deleteMatch(String id) async {
    final List<MatchHistoryEntry> matches = await loadMatches();

    matches.removeWhere((match) => match.id == id);

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _key,
      jsonEncode(matches.map((m) => m.toJson()).toList()),
    );
  }

  static Future<void> clearHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}