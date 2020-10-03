package io.github.parassharmaa.usage_stats

import android.app.usage.NetworkStats
import android.app.usage.NetworkStatsManager
import android.content.Context
import android.content.pm.ApplicationInfo
import android.net.ConnectivityManager
import android.os.Build
import androidx.annotation.RequiresApi

object NetworkStats {

    @RequiresApi(Build.VERSION_CODES.M)
    fun queryNetworkUsageStats(
        context: Context,
        startDate: Long,
        endDate: Long
    ): List<Map<String, String>> {
        val networkStatsManager =
            context.getSystemService(Context.NETWORK_STATS_SERVICE) as NetworkStatsManager

        val installedApplications: MutableList<ApplicationInfo> =
            context.packageManager.getInstalledApplications(0)

        return installedApplications.map { appInfo: ApplicationInfo ->

            val totalAppSummary = appInfo.getNetworkSummary(
                networkStatsManager = networkStatsManager,
                startDate = startDate,
                endDate = endDate
            )

            mapOf<String, String>(
                "packageName" to appInfo.packageName,
                "rxTotalBytes" to totalAppSummary.rxTotalBytes.toString(),
                "txTotalBytes" to totalAppSummary.txTotalBytes.toString()
            )
        }
    }

    @RequiresApi(Build.VERSION_CODES.M)
    private fun ApplicationInfo.getNetworkSummary(
        networkStatsManager: NetworkStatsManager,
        startDate: Long,
        endDate: Long
    ): AppNetworkStats {
        val wifiStats = this.getNetworkSummary(
            networkType = ConnectivityManager.TYPE_WIFI,
            networkStatsManager = networkStatsManager,
            startDate = startDate,
            endDate = endDate
        )

        val mobileStats = this.getNetworkSummary(
            networkType = ConnectivityManager.TYPE_MOBILE,
            networkStatsManager = networkStatsManager,
            startDate = startDate,
            endDate = endDate
        )

        return AppNetworkStats(
            rxTotalBytes = wifiStats.rxTotalBytes + mobileStats.rxTotalBytes,
            txTotalBytes = wifiStats.txTotalBytes + mobileStats.txTotalBytes
        )
    }

    @RequiresApi(Build.VERSION_CODES.M)
    private fun ApplicationInfo.getNetworkSummary(
        networkType: Int,
        networkStatsManager: NetworkStatsManager,
        startDate: Long,
        endDate: Long
    ): AppNetworkStats {
        try {
            val queryDetailsForUid: NetworkStats = networkStatsManager.queryDetailsForUid(
                networkType, "", startDate, endDate, uid
            )

            val tmpBucket = NetworkStats.Bucket()
            var rxTotal = 0L
            var txTotal = 0L
            while (queryDetailsForUid.hasNextBucket()) {
                queryDetailsForUid.getNextBucket(tmpBucket)
                txTotal += tmpBucket.txBytes
                rxTotal += tmpBucket.rxBytes
            }
            return AppNetworkStats(rxTotal, txTotal)
        } catch (err: Exception) {

            return AppNetworkStats(0, 0)
        }

    }

    private data class AppNetworkStats(
        val rxTotalBytes: Long,
        val txTotalBytes: Long
    )
}