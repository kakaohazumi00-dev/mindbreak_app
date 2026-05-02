import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_state.dart';
import '../theme/app_theme.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<DayUsage> weeklyUsage;
  final int dailyLimitMinutes;

  const WeeklyBarChart({
    super.key,
    required this.weeklyUsage,
    required this.dailyLimitMinutes,
  });

  @override
  Widget build(BuildContext context) {
    if (weeklyUsage.isEmpty) return const SizedBox.shrink();

    final maxMins = weeklyUsage
        .map((d) => d.minutes)
        .fold(dailyLimitMinutes, (a, b) => a > b ? a : b)
        .toDouble();

    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    const barMaxHeight = 72.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Usage',
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text('Top app · limit ${dailyLimitMinutes}m',
              style:
                  GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 14),
          SizedBox(
            height: barMaxHeight + 36,
            child: Stack(
              children: [
                // Dashed limit line
                Positioned(
                  top: barMaxHeight -
                      (dailyLimitMinutes / maxMins) * barMaxHeight,
                  left: 0,
                  right: 0,
                  child: _DashedLine(),
                ),

                // Bars row
                Positioned(
                  bottom: 28,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: barMaxHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: weeklyUsage.map((day) {
                        final isToday = day.date == todayStr;
                        final isOver = day.minutes >= dailyLimitMinutes;
                        final barH = maxMins > 0
                            ? (day.minutes / maxMins) * barMaxHeight
                            : 0.0;
                        final color = isOver
                            ? AppColors.danger
                            : isToday
                                ? AppColors.primary
                                : AppColors.textMuted.withAlpha(77);

                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (day.minutes > 0)
                                Text(
                                  '${day.minutes}m',
                                  style: GoogleFonts.inter(
                                    fontSize: 8,
                                    color: isOver
                                        ? AppColors.danger
                                        : AppColors.textMuted,
                                  ),
                                ),
                              const SizedBox(height: 2),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                height: barH.clamp(3, barMaxHeight),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Day labels
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: weeklyUsage.map((day) {
                      final isToday = day.date == todayStr;
                      final dayObj = DateTime.tryParse(
                          day.date.replaceAll('-', '/') + ' 00:00:00');
                      final label = dayObj != null
                          ? [
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Sun'
                            ][dayObj.weekday - 1]
                          : '?';
                      return Expanded(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight:
                                isToday ? FontWeight.w700 : FontWeight.w400,
                            color: isToday
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _DashedLinePainter(),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.danger.withAlpha(102)
      ..strokeWidth = 1;
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
