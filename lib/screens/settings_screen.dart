import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/game_provider.dart';
import '../providers/shield_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _deviceId = 'local-demo';

  @override
  void initState() {
    super.initState();
  }

  static const _limitPresets = [
    {
      'label': 'Strict',
      'minutes': 15,
      'desc': '15 minutes · maximum discipline',
      'icon': Icons.bolt,
      'color': AppColors.danger
    },
    {
      'label': 'Moderate',
      'minutes': 30,
      'desc': '30 minutes · balanced control',
      'icon': Icons.track_changes,
      'color': AppColors.warning
    },
    {
      'label': 'Relaxed',
      'minutes': 60,
      'desc': '60 minutes · light awareness',
      'icon': Icons.air,
      'color': AppColors.primary
    },
  ];

  static const _safetyApps = [
    'Phone',
    'Emergency SOS',
    'Maps',
    'Messages',
    'MindBreak'
  ];

  @override
  Widget build(BuildContext context) {
    final shield = context.watch<ShieldProvider>();
    final game = context.watch<GameProvider>();
    final settings = shield.settings;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
          children: [
            Text('Settings',
                style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 16),

            // Daily Limit
            _SectionTitle('Daily Time Limit'),
            ..._limitPresets.map((preset) {
              final active =
                  settings.dailyLimitMinutes == (preset['minutes'] as int);
              final color = preset['color'] as Color;
              return GestureDetector(
                onTap: () => shield.updateSettings(settings.copyWith(
                    dailyLimitMinutes: preset['minutes'] as int)),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: active ? color.withAlpha(31) : AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: active ? color : AppColors.border,
                        width: active ? 1.5 : 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: active ? color.withAlpha(51) : AppColors.muted,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(preset['icon'] as IconData,
                            color: active ? color : AppColors.textMuted,
                            size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(preset['label'] as String,
                                style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: active
                                        ? color
                                        : AppColors.textPrimary)),
                            Text(preset['desc'] as String,
                                style: GoogleFonts.inter(
                                    fontSize: 13, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      if (active)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(6)),
                          child: Text('ACTIVE',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black)),
                        ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),
            _SectionTitle('Behavior'),
            Container(
              decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18)),
              child: Column(
                children: [
                  _ToggleRow(
                    icon: Icons.bolt,
                    label: 'Strict Mode',
                    sublabel: 'Hides dismiss on lock screen — truly no way out',
                    value: settings.strictMode,
                    onChanged: (v) =>
                        shield.updateSettings(settings.copyWith(strictMode: v)),
                  ),
                  _ToggleRow(
                    icon: Icons.notifications_outlined,
                    label: 'Focus Notifications',
                    sublabel: 'Daily reminders before your limit is reached',
                    value: settings.notificationsEnabled,
                    onChanged: (v) => shield.updateSettings(
                        settings.copyWith(notificationsEnabled: v)),
                  ),
                  _ToggleRow(
                    icon: Icons.vibration,
                    label: 'Haptic Feedback',
                    sublabel: 'Vibrations on key interactions',
                    value: settings.hapticsEnabled,
                    onChanged: (v) => shield
                        .updateSettings(settings.copyWith(hapticsEnabled: v)),
                    showDivider: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            _SectionTitle('Always Unlocked'),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hardcoded. These apps can never be blocked.',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textMuted)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _safetyApps
                        .map((name) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.success.withAlpha(31),
                                border: Border.all(
                                    color: AppColors.success.withAlpha(77)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check,
                                        size: 10, color: AppColors.success),
                                    const SizedBox(width: 4),
                                    Text(name,
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppColors.success,
                                            fontWeight: FontWeight.w500)),
                                  ]),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            _SectionTitle('Account'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                            color: AppColors.secondary.withAlpha(51),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.smartphone,
                            color: AppColors.secondary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('One Device · One Account',
                                style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text('No sign-in. No cloud sync. No cheating.',
                                style: GoogleFonts.inter(
                                    fontSize: 13, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppColors.muted,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DEVICE ID',
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                letterSpacing: 1.5,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text(_deviceId,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _AccountStat(
                          value: '${game.state.streak}', label: 'streak'),
                      Container(width: 1, height: 32, color: AppColors.border),
                      _AccountStat(
                          value: '${game.state.points}', label: 'points'),
                      Container(width: 1, height: 32, color: AppColors.border),
                      _AccountStat(value: game.rankInfo.title, label: 'rank'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text('MindBreak · v1.0.0 · No mercy, no excuses',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      );
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: AppColors.muted,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    Text(sublabel,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
        if (showDivider)
          Divider(
              height: 1, color: AppColors.border, indent: 14, endIndent: 14),
      ],
    );
  }
}

class _AccountStat extends StatelessWidget {
  final String value;
  final String label;
  const _AccountStat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary),
                overflow: TextOverflow.ellipsis),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      );
}
