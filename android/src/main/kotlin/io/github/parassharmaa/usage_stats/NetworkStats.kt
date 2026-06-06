package io.github.parassharmaa.usage_stats

import android.annotation.SuppressLint
import android.app.usage.NetworkStatsManager
import android.content.Context
import android.content.pm.ApplicationInfo
import android.net.NetworkCapabilities
import android.os.Build
import android.telephony.TelephonyManager
import androidx.annotation.RequiresApi
import android.app.usage.NetworkStats as AndroidNetworkStats

object NetworkStats {
    @RequiresApi(Build.VERSION_CODES.M)
    fun queryNetworkUsageStats(
        context: Context,
        startDate: Long,
        endDate: Long,
        type: Int,
    ): List<Map<String, String>> {
        val networkType = networkTypeFromInt(type)
        val networkStatsManager =
            context.getSystemService(Context.NETWORK_STATS_SERVICE) as NetworkStatsManager
        val subscriberId = getSubscriberId(context)

        @Suppress("DEPRECATION")
        val installedApplications: List<ApplicationInfo> =
            context.packageManager.getInstalledApplications(0)

        return installedApplications.map { appInfo ->
            val summary =
                appInfo.getNetworkSummary(
                    networkStatsManager = networkStatsManager,
                    startDate = startDate,
                    endDate = endDate,
                    networkType = networkType,
                    subscriberId = subscriberId,
                )
            mapOf(
                "packageName" to appInfo.packageName,
                "rxTotalBytes" to summary.rxTotalBytes.toString(),
                "txTotalBytes" to summary.txTotalBytes.toString(),
            )
        }
    }

    @RequiresApi(Build.VERSION_CODES.M)
    fun queryNetworkUsageStatsByPackage(
        context: Context,
        startDate: Long,
        endDate: Long,
        type: Int,
        packageName: String,
    ): Map<String, String> {
        val networkType = networkTypeFromInt(type)
        val networkStatsManager =
            context.getSystemService(Context.NETWORK_STATS_SERVICE) as NetworkStatsManager
        val subscriberId = getSubscriberId(context)
        val appInfo = context.packageManager.getApplicationInfo(packageName, 0)

        val summary =
            appInfo.getNetworkSummary(
                networkStatsManager = networkStatsManager,
                startDate = startDate,
                endDate = endDate,
                networkType = networkType,
                subscriberId = subscriberId,
            )

        return mapOf(
            "packageName" to appInfo.packageName,
            "rxTotalBytes" to summary.rxTotalBytes.toString(),
            "txTotalBytes" to summary.txTotalBytes.toString(),
        )
    }

    private fun networkTypeFromInt(type: Int): NetworkType =
        when (type) {
            2 -> NetworkType.WiFi
            3 -> NetworkType.Mobile
            else -> NetworkType.All
        }

    @RequiresApi(Build.VERSION_CODES.M)
    private fun ApplicationInfo.getNetworkSummary(
        networkStatsManager: NetworkStatsManager,
        startDate: Long,
        endDate: Long,
        networkType: NetworkType,
        subscriberId: String? = null,
    ): AppNetworkStats {
        val wifi =
            if (networkType != NetworkType.Mobile) {
                getNetworkSummary(
                    NetworkCapabilities.TRANSPORT_WIFI,
                    networkStatsManager,
                    startDate,
                    endDate,
                )
            } else {
                AppNetworkStats(0, 0)
            }
        val mobile =
            if (networkType != NetworkType.WiFi) {
                getNetworkSummary(
                    NetworkCapabilities.TRANSPORT_CELLULAR,
                    networkStatsManager,
                    startDate,
                    endDate,
                    subscriberId,
                )
            } else {
                AppNetworkStats(0, 0)
            }
        return AppNetworkStats(
            rxTotalBytes = wifi.rxTotalBytes + mobile.rxTotalBytes,
            txTotalBytes = wifi.txTotalBytes + mobile.txTotalBytes,
        )
    }

    @SuppressLint("MissingPermission")
    @RequiresApi(Build.VERSION_CODES.M)
    private fun ApplicationInfo.getNetworkSummary(
        transport: Int,
        networkStatsManager: NetworkStatsManager,
        startDate: Long,
        endDate: Long,
        subscriberId: String? = null,
    ): AppNetworkStats =
        try {
            val details: AndroidNetworkStats =
                networkStatsManager.queryDetailsForUid(
                    transport,
                    subscriberId,
                    startDate,
                    endDate,
                    uid,
                )
            val bucket = AndroidNetworkStats.Bucket()
            var rxTotal = 0L
            var txTotal = 0L
            while (details.hasNextBucket()) {
                details.getNextBucket(bucket)
                txTotal += bucket.txBytes
                rxTotal += bucket.rxBytes
            }
            AppNetworkStats(rxTotal, txTotal)
        } catch (e: Exception) {
            AppNetworkStats(0, 0)
        }

    @SuppressLint("MissingPermission", "HardwareIds")
    private fun getSubscriberId(context: Context): String? {
        // From Android 10 (API 29) reading the subscriber id is restricted and is
        // no longer required by queryDetailsForUid, so pass null.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) return null
        return try {
            val telephonyManager =
                context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager?
            @Suppress("DEPRECATION")
            telephonyManager?.subscriberId
        } catch (e: Exception) {
            null
        }
    }

    private data class AppNetworkStats(
        val rxTotalBytes: Long,
        val txTotalBytes: Long,
    )

    private enum class NetworkType { All, WiFi, Mobile }
}
