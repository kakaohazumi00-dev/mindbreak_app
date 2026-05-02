class AppSettings {
  final int dailyLimitMinutes;
  final bool hapticsEnabled;
  final bool strictMode;
  final bool notificationsEnabled;

  const AppSettings({
    this.dailyLimitMinutes = 30,
    this.hapticsEnabled = true,
    this.strictMode = false,
    this.notificationsEnabled = true,
  });

  AppSettings copyWith({
    int? dailyLimitMinutes,
    bool? hapticsEnabled,
    bool? strictMode,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      strictMode: strictMode ?? this.strictMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  Map<String, dynamic> toMap() => {
        'dailyLimitMinutes': dailyLimitMinutes,
        'hapticsEnabled': hapticsEnabled,
        'strictMode': strictMode,
        'notificationsEnabled': notificationsEnabled,
      };

  factory AppSettings.fromMap(Map<String, dynamic> m) => AppSettings(
        dailyLimitMinutes: (m['dailyLimitMinutes'] as int?) ?? 30,
        hapticsEnabled: (m['hapticsEnabled'] as bool?) ?? true,
        strictMode: (m['strictMode'] as bool?) ?? false,
        notificationsEnabled: (m['notificationsEnabled'] as bool?) ?? true,
      );
}
