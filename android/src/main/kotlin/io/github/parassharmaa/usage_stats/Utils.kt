package io.github.parassharmaa.usage_stats

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Process
import android.provider.Settings

object Utils {
    fun isUsagePermission(context: Context): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode =
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName,
            )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    fun grantUsagePermission(context: Context) {
        if (isUsagePermission(context)) return
        openUsageAccessSettings(context)
    }

    /**
     * Always opens the system "Usage access" settings screen, regardless of the
     * current permission state. Tries to deep-link to this app's entry and falls
     * back to the general list if the OEM rejects the package URI.
     */
    fun openUsageAccessSettings(context: Context) {
        try {
            val intent =
                Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    data = Uri.parse("package:${context.packageName}")
                }
            context.startActivity(intent)
        } catch (e: Exception) {
            val intent =
                Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
            context.startActivity(intent)
        }
    }
}
