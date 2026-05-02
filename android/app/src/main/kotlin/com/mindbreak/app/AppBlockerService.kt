package com.mindbreak.app

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.view.accessibility.AccessibilityEvent
import android.provider.Settings
import android.text.TextUtils

/**
 * AccessibilityService that monitors which app is in the foreground.
 * When the blocked app is opened and is over its time limit, it
 * launches MindBreak (bringing the ShieldScreen to the foreground).
 *
 * The Flutter side sets "blocked_packages" in SharedPreferences.
 * This service reads them to know which packages to intercept.
 */
class AppBlockerService : AccessibilityService() {

    private lateinit var prefs: SharedPreferences
    private var lastInterceptedPackage: String? = null

    override fun onCreate() {
        super.onCreate()
        prefs = getSharedPreferences("mindbreak_blocker", Context.MODE_PRIVATE)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val pkg = event.packageName?.toString() ?: return
        if (pkg == packageName) return  // Don't intercept MindBreak itself

        val blockedPackages = prefs.getStringSet("blocked_packages", emptySet()) ?: emptySet()
        if (pkg in blockedPackages && pkg != lastInterceptedPackage) {
            lastInterceptedPackage = pkg

            // Launch MindBreak to foreground — FlutterApp shows ShieldScreen
            val intent = Intent(applicationContext, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
                putExtra("shield_target", pkg)
            }
            startActivity(intent)
        }
    }

    override fun onInterrupt() {
        lastInterceptedPackage = null
    }

    override fun onServiceConnected() {
        val info = serviceInfo ?: AccessibilityServiceInfo()
        info.eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
        info.feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
        info.flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS
        info.notificationTimeout = 100
        serviceInfo = info
    }

    companion object {
        /** Check if this service is enabled in Accessibility Settings */
        fun isEnabled(context: Context): Boolean {
            val enabledServices = Settings.Secure.getString(
                context.contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
            ) ?: return false
            val packageName = context.packageName
            return enabledServices.split(':').any { it.contains(packageName) }
        }
    }
}
