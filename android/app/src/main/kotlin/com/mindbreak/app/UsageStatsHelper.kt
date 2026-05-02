package com.mindbreak.app

import android.app.usage.UsageStatsManager
import android.content.Context
import java.util.Calendar

object UsageStatsHelper {

    /**
     * Returns a map of packageName -> usedMinutesToday for all apps
     * that have been used today (since midnight).
     */
    fun getTopAppUsageToday(context: Context): Map<String, Int> {
        val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        // Start of today (midnight)
        val cal = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val startTime = cal.timeInMillis
        val endTime = System.currentTimeMillis()

        val stats = usm.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        ) ?: return emptyMap()

        val result = mutableMapOf<String, Int>()
        for (s in stats) {
            if (s.totalTimeInForeground > 0) {
                val minutes = (s.totalTimeInForeground / 1000 / 60).toInt()
                result[s.packageName] = minutes
            }
        }
        return result
    }

    /**
     * Returns the package name of the app with the most foreground time today.
     * Excludes system/launcher packages.
     */
    fun getTopPackageToday(context: Context): String? {
        val excludedPackages = setOf(
            "com.mindbreak.app",
            "com.android.launcher",
            "com.android.launcher3",
            "com.google.android.apps.nexuslauncher",
            "com.android.systemui",
            "com.sec.android.app.launcher",
        )

        return getTopAppUsageToday(context)
            .filter { (pkg, mins) -> pkg !in excludedPackages && mins > 0 }
            .maxByOrNull { it.value }
            ?.key
    }
}
