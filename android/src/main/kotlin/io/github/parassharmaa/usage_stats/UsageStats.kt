package io.github.parassharmaa.usage_stats

import android.app.usage.ConfigurationStats
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.os.Build
import androidx.annotation.RequiresApi

object UsageStats {
    private fun usageStatsManager(context: Context): UsageStatsManager =
        context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

    fun queryConfig(
        context: Context,
        startDate: Long,
        endDate: Long,
    ): ArrayList<Map<String, String>> {
        val usm = usageStatsManager(context)
        val configs: List<ConfigurationStats> =
            usm.queryConfigurations(UsageStatsManager.INTERVAL_BEST, startDate, endDate)

        val configList: ArrayList<Map<String, String>> = arrayListOf()

        for (config in configs) {
            val c: Map<String, String> =
                mapOf(
                    "activationCount" to config.activationCount.toString(),
                    "totalTimeActive" to config.totalTimeActive.toString(),
                    "configuration" to config.configuration.toString(),
                    "lastTimeActive" to config.lastTimeActive.toString(),
                    "firstTimeStamp" to config.firstTimeStamp.toString(),
                    "lastTimeStamp" to config.lastTimeStamp.toString(),
                )
            configList.add(c)
        }
        return configList
    }

    /** Build a serializable map from a [UsageEvents.Event], guarding API-gated fields. */
    private fun eventToMap(event: UsageEvents.Event): Map<String, String?> {
        val map =
            hashMapOf<String, String?>(
                "eventType" to event.eventType.toString(),
                "timeStamp" to event.timeStamp.toString(),
                "packageName" to event.packageName,
                // className may legitimately be null for some events.
                "className" to event.className,
            )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
            map["shortcutId"] = event.shortcutId
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            map["appStandbyBucket"] = event.appStandbyBucket.toString()
        }
        return map
    }

    fun queryEvents(
        context: Context,
        startDate: Long,
        endDate: Long,
    ): ArrayList<Map<String, String?>> {
        val usm = usageStatsManager(context)
        val events: UsageEvents = usm.queryEvents(startDate, endDate)
        val eventsList: ArrayList<Map<String, String?>> = arrayListOf()

        while (events.hasNextEvent()) {
            val event = UsageEvents.Event()
            events.getNextEvent(event)
            eventsList.add(eventToMap(event))
        }
        return eventsList
    }

    /**
     * Read this app's own usage events without requiring PACKAGE_USAGE_STATS.
     * Available from API 28; returns an empty list on older devices.
     */
    @RequiresApi(Build.VERSION_CODES.P)
    fun queryEventsForSelf(
        context: Context,
        startDate: Long,
        endDate: Long,
    ): ArrayList<Map<String, String?>> {
        val usm = usageStatsManager(context)
        val events: UsageEvents = usm.queryEventsForSelf(startDate, endDate)
        val eventsList: ArrayList<Map<String, String?>> = arrayListOf()

        while (events.hasNextEvent()) {
            val event = UsageEvents.Event()
            events.getNextEvent(event)
            eventsList.add(eventToMap(event))
        }
        return eventsList
    }

    @RequiresApi(Build.VERSION_CODES.P)
    fun queryEventStats(
        context: Context,
        startDate: Long,
        endDate: Long,
        intervalType: Int = UsageStatsManager.INTERVAL_BEST,
    ): ArrayList<Map<String, String>> {
        val usm = usageStatsManager(context)
        val eventStats = usm.queryEventStats(intervalType, startDate, endDate)

        val eventList: ArrayList<Map<String, String>> = arrayListOf()

        for (event in eventStats) {
            val u: Map<String, String> =
                mapOf(
                    "firstTimeStamp" to event.firstTimeStamp.toString(),
                    "lastTimeStamp" to event.lastTimeStamp.toString(),
                    "totalTime" to event.totalTime.toString(),
                    "lastEventTime" to event.lastEventTime.toString(),
                    "eventType" to event.eventType.toString(),
                    "count" to event.count.toString(),
                )
            eventList.add(u)
        }
        return eventList
    }

    fun queryUsageStats(
        context: Context,
        startDate: Long,
        endDate: Long,
        intervalType: Int = UsageStatsManager.INTERVAL_BEST,
    ): ArrayList<Map<String, String>> {
        val usm = usageStatsManager(context)
        val usageStats = usm.queryUsageStats(intervalType, startDate, endDate)

        val usageList: ArrayList<Map<String, String>> = arrayListOf()

        for (usage in usageStats) {
            val u: Map<String, String> =
                mapOf(
                    "firstTimeStamp" to usage.firstTimeStamp.toString(),
                    "lastTimeStamp" to usage.lastTimeStamp.toString(),
                    "lastTimeUsed" to usage.lastTimeUsed.toString(),
                    "packageName" to usage.packageName.toString(),
                    "totalTimeInForeground" to usage.totalTimeInForeground.toString(),
                )
            usageList.add(u)
        }
        return usageList
    }

    fun queryAndAggregateUsageStats(
        context: Context,
        startDate: Long,
        endDate: Long,
    ): Map<String, Map<String, String>> {
        val usm = usageStatsManager(context)
        val usageStats = usm.queryAndAggregateUsageStats(startDate, endDate)

        val usageList = mutableMapOf<String, Map<String, String>>()

        for (packageName in usageStats.keys) {
            val packageUsage = usageStats[packageName]
            usageList[packageName] =
                mapOf(
                    "firstTimeStamp" to packageUsage?.firstTimeStamp.toString(),
                    "lastTimeStamp" to packageUsage?.lastTimeStamp.toString(),
                    "lastTimeUsed" to packageUsage?.lastTimeUsed.toString(),
                    "packageName" to packageUsage?.packageName.toString(),
                    "totalTimeInForeground" to packageUsage?.totalTimeInForeground.toString(),
                )
        }
        return usageList
    }

    /**
     * This app's current App Standby bucket. Requires no permission.
     * Available from API 28; the plugin guards the call on older devices.
     */
    @RequiresApi(Build.VERSION_CODES.P)
    fun getAppStandbyBucket(context: Context): Int = usageStatsManager(context).appStandbyBucket

    /**
     * Whether [packageName] is considered inactive (idle). Available from API 23.
     * Querying packages other than the caller requires PACKAGE_USAGE_STATS.
     */
    fun isAppInactive(
        context: Context,
        packageName: String,
    ): Boolean = usageStatsManager(context).isAppInactive(packageName)
}
