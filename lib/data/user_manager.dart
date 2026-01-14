import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryItem {
  final String action;
  final String location;
  final int points;
  final DateTime date;

  HistoryItem(this.action, this.location, this.points, this.date);

  Map<String, dynamic> toJson() => {
        'action': action,
        'location': location,
        'points': points,
        'date': date.toIso8601String(),
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        json['action'],
        json['location'],
        json['points'],
        DateTime.parse(json['date']),
      );
}

class RewardItem {
  final String id;
  final String title;
  final String description;
  final int cost;
  bool isUnlocked;

  RewardItem({
    required this.id,
    required this.title,
    this.description = "",
    required this.cost,
    this.isUnlocked = false,
  });
}

class UserManager {
  static final UserManager _instance = UserManager._internal();
  factory UserManager() => _instance;
  UserManager._internal();

  String username = "ParkQuest User";
  bool isLoggedIn = false;
  int points = 0;
  List<HistoryItem> history = [];

  final List<RewardItem> rewards = [
    RewardItem(id: "coffee", title: "Free Coffee", description: "Enjoy a hot coffee", cost: 5),
    RewardItem(id: "amazon", title: "Amazon Card", description: "Gift Card", cost: 15),
    RewardItem(id: "parking", title: "Free Hour", description: "Free parking", cost: 20),
  ];

  Future<void> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? "ParkQuest User";
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    points = prefs.getInt('points') ?? 0;
    List<String>? historyJson = prefs.getStringList('history');
    if (historyJson != null) {
      history = historyJson.map((str) => HistoryItem.fromJson(jsonDecode(str))).toList();
    }
    for (var r in rewards) r.isUnlocked = prefs.getBool('reward_${r.id}') ?? false;
  }

  Future<void> login([String name = "ParkQuest User"]) async {
    username = name;
    isLoggedIn = true;
    if (points == 0) points = 5;
    await _saveData();
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 
    username = "ParkQuest User";
    isLoggedIn = false;
    points = 0;
    history.clear();
    for (var r in rewards) r.isUnlocked = false;
  }

  Future<void> addPoints(int amount, String description, String location) async {
    points += amount;
    history.insert(0, HistoryItem(description, location, amount, DateTime.now()));
    await _saveData();
  }

  Future<bool> unlockReward(String id) async {
    final index = rewards.indexWhere((r) => r.id == id);
    if (index != -1 && points >= rewards[index].cost && !rewards[index].isUnlocked) {
      points -= rewards[index].cost;
      rewards[index].isUnlocked = true;
      await _saveData();
      return true;
    }
    return false;
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setBool('isLoggedIn', isLoggedIn);
    await prefs.setInt('points', points);
    List<String> historyJson = history.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('history', historyJson);
    for (var r in rewards) await prefs.setBool('reward_${r.id}', r.isUnlocked);
  }
}