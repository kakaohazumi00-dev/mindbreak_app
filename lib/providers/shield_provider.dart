import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tracked_app.dart';
import '../models/app_settings.dart';

/// MethodChannel for native UsageStats access (Android only)
const _usageChannel = MethodChannel('com.mindbreak.app/usage_stats');

class ShieldProvider extends ChangeNotifier {
  AppSettings _settings = const AppSettings();
  List<TrackedApp> _trackedApps = TrackedApp.defaults;
  bool _isLocked = false;
  String? _shieldTarget;

  AppSettings get settings => _settings;
  List<TrackedApp> get trackedApps => _trackedApps;
  bool get isLocked => _isLocked;
  String? get shieldTarget => _shieldTarget;

  // Sorted descending by usage
  List<TrackedApp> get sortedApps => [..._trackedApps]
    ..sort((a, b) => b.usedMinutesToday.compareTo(a.usedMinutesToday));

  TrackedApp? get topAppSorted =>
      sortedApps.isNotEmpty ? sortedApps.first : null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final settingsRaw = prefs.getString('app_settings');
    if (settingsRaw != null) {
      try {
        _settings = AppSettings.fromMap(
            jsonDecode(settingsRaw) as Map<String, dynamic>);
      } catch (_) {}
    }

    final appsRaw = prefs.getString('tracked_apps');
    if (appsRaw != null) {
      try {
        final list = jsonDecode(appsRaw) as List;
        _trackedApps = list
            .map((e) => TrackedApp.fromMap(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    // Try real UsageStats from native (Android only)
    await _fetchRealUsage();

    notifyListeners();
  }

  /// Calls native Kotlin to fetch real app usage via UsageStatsManager
  Future<void> _fetchRealUsage() async {
    try {
      final result = await _usageChannel.invokeMethod<Map>('getUsageStats');
      if (result != null) {
        _trackedApps = _trackedApps.map((app) {
          final mins = result[app.packageId];
          if (mins != null) {
            return app.copyWith(usedMinutesToday: (mins as int));
          }
          return app;
        }).toList();
      }
    } on PlatformException {
      // UsageStats permission not granted — keep simulated values
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_settings', jsonEncode(_settings.toMap()));
    await prefs.setString(
      'tracked_apps',
      jsonEncode(_trackedApps.map((a) => a.toMap()).toList()),
    );
  }

  Future<void> updateSettings(AppSettings updated) async {
    _settings = updated;
    notifyListeners();
    await _persist();
  }

  void triggerLock(String appName) {
    _isLocked = true;
    _shieldTarget = appName;
    notifyListeners();
  }

  void dismissShield() {
    _isLocked = false;
    _shieldTarget = null;
    notifyListeners();
  }

  void simulateUsage(String id, int minutes) {
    _trackedApps = _trackedApps.map((a) {
      if (a.id == id)
        return a.copyWith(usedMinutesToday: a.usedMinutesToday + minutes);
      return a;
    }).toList();
    notifyListeners();
    _persist();
  }

  void resetDailyUsage() {
    _trackedApps =
        _trackedApps.map((a) => a.copyWith(usedMinutesToday: 0)).toList();
    _isLocked = false;
    _shieldTarget = null;
    notifyListeners();
    _persist();
  }
}
