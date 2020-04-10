package io.github.parassharmaa.usage_stats

import android.app.usage.ConfigurationStats
import android.content.Context
import android.app.usage.UsageStatsManager
import android.app.usage.UsageEvents
import android.util.Log

object UsageStats {


    fun queryConfig(context: Context, startDate: Long, endDate: Long): List<ConfigurationStats> {
        var usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        var configs: List<ConfigurationStats> = usm.queryConfigurations(1, startDate, endDate)
        
        return configs
    }

    fun queryEvents(context: Context, startDate: Long, endDate: Long): ArrayList<Map<String, String>> {
        var usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        var events: UsageEvents = usm.queryEvents(startDate, endDate)
        var eventsList: ArrayList<Map<String, String>> = arrayListOf()

        while (events.hasNextEvent()) {
            var event: UsageEvents.Event = UsageEvents.Event()
            events.getNextEvent(event)
            var e: Map<String, String> = mapOf(
                    "eventType" to event.eventType.toString(),
                    "timeStamp" to event.timeStamp.toString(),
                    "packageName" to event.packageName.toString(),
                    "className" to event.className
            )

            eventsList.add(e)

        }
        return eventsList
    }
}