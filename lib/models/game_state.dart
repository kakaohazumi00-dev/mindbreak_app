import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RankInfo {
  final String title;
  final int minPoints;
  final String nextTitle;
  final int nextMin;
  final Color color;

  const RankInfo({
    required this.title,
    required this.minPoints,
    required this.nextTitle,
    required this.nextMin,
    required this.color,
  });
}

const List<Map<String, dynamic>> kRanks = [
  {'title': 'Wanderer', 'min': 0, 'color': AppRankColors.wanderer},
  {'title': 'Seeker', 'min': 50, 'color': AppRankColors.seeker},
  {'title': 'Apprentice', 'min': 150, 'color': AppRankColors.apprentice},
  {'title': 'Guardian', 'min': 350, 'color': AppRankColors.guardian},
  {'title': 'Sage', 'min': 700, 'color': AppRankColors.sage},
  {'title': 'Mind Master', 'min': 1200, 'color': AppRankColors.mindMaster},
];

RankInfo getRankInfo(int points) {
  Map<String, dynamic> current = kRanks.first;
  Map<String, dynamic> next = kRanks[1];
  for (int i = 0; i < kRanks.length; i++) {
    if (points >= (kRanks[i]['min'] as int)) {
      current = kRanks[i];
      next = kRanks[i < kRanks.length - 1 ? i + 1 : i];
    }
  }
  return RankInfo(
    title: current['title'] as String,
    minPoints: current['min'] as int,
    nextTitle: next['title'] as String,
    nextMin: next['min'] as int,
    color: current['color'] as Color,
  );
}

double getRankProgress(int points, RankInfo rank) {
  if (rank.title == 'Mind Master') return 1.0;
  final inRank = points - rank.minPoints;
  final range = rank.nextMin - rank.minPoints;
  return (inRank / range).clamp(0.0, 1.0);
}

class GameState {
  final int streak;
  final String? lastCleanDate;
  final int longestStreak;
  final int totalLockedDays;
  final int totalCleanDays;
  final bool lockedToday;
  final int points;

  const GameState({
    this.streak = 0,
    this.lastCleanDate,
    this.longestStreak = 0,
    this.totalLockedDays = 0,
    this.totalCleanDays = 0,
    this.lockedToday = false,
    this.points = 0,
  });

  GameState copyWith({
    int? streak,
    String? lastCleanDate,
    int? longestStreak,
    int? totalLockedDays,
    int? totalCleanDays,
    bool? lockedToday,
    int? points,
  }) {
    return GameState(
      streak: streak ?? this.streak,
      lastCleanDate: lastCleanDate ?? this.lastCleanDate,
      longestStreak: longestStreak ?? this.longestStreak,
      totalLockedDays: totalLockedDays ?? this.totalLockedDays,
      totalCleanDays: totalCleanDays ?? this.totalCleanDays,
      lockedToday: lockedToday ?? this.lockedToday,
      points: points ?? this.points,
    );
  }

  Map<String, dynamic> toMap() => {
        'streak': streak,
        'lastCleanDate': lastCleanDate,
        'longestStreak': longestStreak,
        'totalLockedDays': totalLockedDays,
        'totalCleanDays': totalCleanDays,
        'lockedToday': lockedToday,
        'points': points,
      };

  factory GameState.fromMap(Map<String, dynamic> m) => GameState(
        streak: (m['streak'] as int?) ?? 0,
        lastCleanDate: m['lastCleanDate'] as String?,
        longestStreak: (m['longestStreak'] as int?) ?? 0,
        totalLockedDays: (m['totalLockedDays'] as int?) ?? 0,
        totalCleanDays: (m['totalCleanDays'] as int?) ?? 0,
        lockedToday: (m['lockedToday'] as bool?) ?? false,
        points: (m['points'] as int?) ?? 0,
      );
}

class DayUsage {
  final String date;
  final int minutes;
  final bool locked;

  const DayUsage({required this.date, required this.minutes, this.locked = false});

  Map<String, dynamic> toMap() => {'date': date, 'minutes': minutes, 'locked': locked};
  factory DayUsage.fromMap(Map<String, dynamic> m) => DayUsage(
        date: m['date'] as String,
        minutes: (m['minutes'] as int?) ?? 0,
        locked: (m['locked'] as bool?) ?? false,
      );
}
