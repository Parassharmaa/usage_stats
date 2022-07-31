package io.github.parassharmaa.usage_stats

import android.app.usage.NetworkStats
import android.app.usage.NetworkStatsManager
import android.content.Context
import android.content.pm.ApplicationInfo
import android.net.NetworkCapabilities
import android.os.Build
import androidx.annotation.RequiresApi

object NetworkStats {

    @RequiresApi(Build.VERSION_CODES.M)
    fun queryNetworkUsageStats(
        context: Context,
        startDate: Long,
        endDate: Long,
        type: Int
    ): List<Map<String, String>> {
        val networkType: NetworkType = when (type) {
            1 -> NetworkType.All
            2 -> NetworkType.WiFi
            3 -> NetworkType.Mobile
            else -> NetworkType.All
        }

        val networkStatsManager =
            context.getSystemService(Context.NETWORK_STATS_SERVICE) as NetworkStatsManager

        val installedApplications: MutableList<ApplicationInfo> =
            context.packageManager.getInstalledApplications(0)

        return installedApplications.map { appInfo: ApplicationInfo ->

            val totalAppSummary = appInfo.getNetworkSummary(
                networkStatsManager = networkStatsManager,
                startDate = startDate,
                endDate = endDate,
                networkType = networkType
            )

            mapOf(
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
        endDate: Long,
        networkType: NetworkType,
    ): AppNetworkStats {
        val rxTotalBytes: Long
        val txTotalBytes: Long

        when (networkType) {
            NetworkType.Mobile -> {
                val mobileStats = this.getNetworkSummary(
                    networkType = NetworkCapabilities.TRANSPORT_CELLULAR,
                    networkStatsManager = networkStatsManager,
                    startDate = startDate,
                    endDate = endDate
                )

                rxTotalBytes = mobileStats.rxTotalBytes
                txTotalBytes = mobileStats.txTotalBytes
            }

            NetworkType.WiFi -> {
                val wifiStats = this.getNetworkSummary(
                    networkType = NetworkCapabilities.TRANSPORT_WIFI,
                    networkStatsManager = networkStatsManager,
                    startDate = startDate,
                    endDate = endDate
                )

                rxTotalBytes = wifiStats.rxTotalBytes
                txTotalBytes = wifiStats.txTotalBytes
            }

            NetworkType.All -> {
                val wifiStats = this.getNetworkSummary(
                    networkType = NetworkCapabilities.TRANSPORT_WIFI,
                    networkStatsManager = networkStatsManager,
                    startDate = startDate,
                    endDate = endDate
                )

                val mobileStats = this.getNetworkSummary(
                    networkType = NetworkCapabilities.TRANSPORT_CELLULAR,
                    networkStatsManager = networkStatsManager,
                    startDate = startDate,
                    endDate = endDate
                )

                rxTotalBytes = wifiStats.rxTotalBytes + mobileStats.rxTotalBytes
                txTotalBytes = wifiStats.txTotalBytes + mobileStats.txTotalBytes
            }
        }

        return AppNetworkStats(
            rxTotalBytes = rxTotalBytes,
            txTotalBytes = txTotalBytes
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

    private enum class NetworkType {
        All,
        WiFi,
        Mobile,
    }
}
