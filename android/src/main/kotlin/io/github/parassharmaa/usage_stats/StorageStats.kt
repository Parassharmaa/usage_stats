package io.github.parassharmaa.usage_stats

import android.app.usage.StorageStatsManager
import android.content.Context
import android.os.Build
import android.os.Process
import androidx.annotation.RequiresApi

object StorageStats {
    /**
     * App/data/cache byte usage for [packageName] via [StorageStatsManager].
     *
     * Available from API 26. Querying this app's own package needs no permission;
     * querying other packages requires PACKAGE_USAGE_STATS. May throw, in which
     * case the plugin returns null to the caller.
     */
    @RequiresApi(Build.VERSION_CODES.O)
    fun queryStatsForPackage(
        context: Context,
        packageName: String,
    ): Map<String, String> {
        val ssm = context.getSystemService(Context.STORAGE_STATS_SERVICE) as StorageStatsManager
        val appInfo = context.packageManager.getApplicationInfo(packageName, 0)
        val stats =
            ssm.queryStatsForPackage(
                appInfo.storageUuid,
                packageName,
                Process.myUserHandle(),
            )

        val appBytes = stats.appBytes
        val dataBytes = stats.dataBytes
        val cacheBytes = stats.cacheBytes

        return mapOf(
            "packageName" to packageName,
            "appBytes" to appBytes.toString(),
            "dataBytes" to dataBytes.toString(),
            "cacheBytes" to cacheBytes.toString(),
            "totalBytes" to (appBytes + dataBytes).toString(),
        )
    }
}
