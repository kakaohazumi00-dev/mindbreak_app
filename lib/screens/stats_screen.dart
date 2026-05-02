import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../providers/shield_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final shield = context.watch<ShieldProvider>();
    final state = game.state;
    final rank = game.rankInfo;
    final progress = game.rankProgress;

    final streakColor = state.streak >= 7
        ? AppColors.success
        : state.streak >= 3
            ? AppColors.warning
            : AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
          children: [
            Text('Your Stats',
                style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 16),

            // Points & Rank Widget
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: rank.color.withAlpha(26),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: rank.color.withAlpha(102)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rank.title.toUpperCase(),
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w600,
                                    color: rank.color)),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${state.points}',
                                    style: GoogleFonts.inter(
                                        fontSize: 40,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary),
                                  ),
                                  TextSpan(
                                    text: ' pts',
                                    style: GoogleFonts.inter(
                                        fontSize: 18,
                                        color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: rank.color.withAlpha(51),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: rank.color.withAlpha(153)),
                        ),
                        child: const Icon(Icons.military_tech,
                            color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.muted,
                      valueColor: AlwaysStoppedAnimation(rank.color),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(rank.title,
                          style: GoogleFonts.inter(
                              fontSize: 11, color: rank.color)),
                      if (rank.title != 'Mind Master')
                        Text(
                            '${rank.nextMin - state.points} pts to ${rank.nextTitle}',
                            style: GoogleFonts.inter(
                                fontSize: 11, color: AppColors.textMuted))
                      else
                        Text('Max rank reached',
                            style: GoogleFonts.inter(
                                fontSize: 11, color: rank.color)),
                      Text(rank.nextTitle,
                          style: GoogleFonts.inter(
                              fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // All ranks ladder
                  ...kRanks.asMap().entries.map((entry) {
                    final r = entry.value;
                    final unlocked = state.points >= (r['min'] as int);
                    final isCurrent = r['title'] == rank.title;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? (r['color'] as Color).withAlpha(38)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: unlocked
                                  ? r['color'] as Color
                                  : AppColors.muted,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(r['title'] as String,
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: isCurrent
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: isCurrent
                                        ? r['color'] as Color
                                        : unlocked
                                            ? AppColors.textPrimary
                                            : AppColors.textMuted)),
                          ),
                          Text('${r['min']} pts',
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: AppColors.textMuted)),
                          if (isCurrent) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: r['color'] as Color,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('YOU',
                                  style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black)),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Streak Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: streakColor.withAlpha(26),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: streakColor.withAlpha(102)),
              ),
              child: Column(
                children: [
                  Text('${state.streak}',
                      style: GoogleFonts.inter(
                          fontSize: 64,
                          fontWeight: FontWeight.w700,
                          color: streakColor,
                          height: 1)),
                  Text('DAY STREAK',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                          color: streakColor)),
                  const SizedBox(height: 8),
                  Text(
                    state.streak == 0
                        ? 'Stay under today\'s limit to start'
                        : state.streak >= 7
                            ? 'You\'re legendary. Don\'t stop now.'
                            : state.streak >= 3
                                ? 'You\'re on fire. Keep going.'
                                : 'Good start. Build the habit.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.3,
              children: [
                _StatCell(
                    icon: Icons.emoji_events_outlined,
                    color: AppColors.warning,
                    value: '${state.longestStreak}',
                    unit: 'days',
                    label: 'Best Streak'),
                _StatCell(
                    icon: Icons.lock_outline,
                    color: AppColors.danger,
                    value: '${state.totalLockedDays}',
                    unit: 'days',
                    label: 'Times Locked'),
                _StatCell(
                    icon: Icons.check_circle_outline,
                    color: AppColors.success,
                    value: '${state.totalCleanDays}',
                    unit: 'days',
                    label: 'Clean Days'),
                _StatCell(
                    icon: Icons.access_time_outlined,
                    color: AppColors.primary,
                    value: '${shield.settings.dailyLimitMinutes}',
                    unit: 'min',
                    label: 'Daily Limit'),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String unit;
  final String label;

  const _StatCell(
      {required this.icon,
      required this.color,
      required this.value,
      required this.unit,
      required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.card, borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: value,
                  style: GoogleFonts.inter(
                      fontSize: 26, fontWeight: FontWeight.w700, color: color)),
              TextSpan(
                  text: ' $unit',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textMuted)),
            ]),
          ),
          Text(label,
              style:
                  GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
