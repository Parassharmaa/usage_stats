package io.github.parassharmaa.usage_stats

import android.app.usage.UsageStatsManager
import android.content.Context
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/** UsageStatsPlugin */
class UsageStatsPlugin :
    FlutterPlugin,
    MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var context: Context? = null

    // Plugin-owned scope so background work is tied to the engine lifecycle
    // and cancelled on detach, instead of leaking through GlobalScope.
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "usage_stats")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
        scope.cancel()
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result,
    ) {
        val context = this.context
        if (context == null) {
            result.error("no_context", "usage_stats is not attached to a context", null)
            return
        }
        val handled =
            handlePermissionCalls(call, result, context) ||
                handleUsageCalls(call, result, context) ||
                handleNetworkCalls(call, result, context) ||
                handlePackageCalls(call, result, context)
        if (!handled) result.notImplemented()
    }

    private fun handlePermissionCalls(
        call: MethodCall,
        result: Result,
        context: Context,
    ): Boolean {
        when (call.method) {
            "isUsagePermission" -> {
                result.success(Utils.isUsagePermission(context))
            }

            "grantUsagePermission" -> {
                Utils.grantUsagePermission(context)
                result.success(null)
            }

            "openUsageAccessSettings" -> {
                Utils.openUsageAccessSettings(context)
                result.success(null)
            }

            "getAppStandbyBucket" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    result.success(UsageStats.getAppStandbyBucket(context))
                } else {
                    result.success(null)
                }
            }

            "isAppInactive" -> {
                result.success(UsageStats.isAppInactive(context, call.stringArg("packageName")))
            }

            else -> {
                return false
            }
        }
        return true
    }

    private fun handleUsageCalls(
        call: MethodCall,
        result: Result,
        context: Context,
    ): Boolean {
        when (call.method) {
            "queryEvents" -> {
                runAsync(result) {
                    UsageStats.queryEvents(context, call.longArg("start"), call.longArg("end"))
                }
            }

            "queryConfiguration" -> {
                runAsync(result) {
                    UsageStats.queryConfig(context, call.longArg("start"), call.longArg("end"))
                }
            }

            "queryUsageStats" -> {
                runAsync(result) {
                    UsageStats.queryUsageStats(
                        context,
                        call.longArg("start"),
                        call.longArg("end"),
                        call.intervalArg(),
                    )
                }
            }

            "queryAndAggregateUsageStats" -> {
                runAsync(result) {
                    UsageStats.queryAndAggregateUsageStats(
                        context,
                        call.longArg("start"),
                        call.longArg("end"),
                    )
                }
            }

            "queryEventStats" -> {
                handleEventStats(call, result, context)
            }

            "queryEventsForSelf" -> {
                handleEventsForSelf(call, result, context)
            }

            else -> {
                return false
            }
        }
        return true
    }

    private fun handleEventStats(
        call: MethodCall,
        result: Result,
        context: Context,
    ) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            runAsync(result) {
                UsageStats.queryEventStats(
                    context,
                    call.longArg("start"),
                    call.longArg("end"),
                    call.intervalArg(),
                )
            }
        } else {
            result.error(
                "API Error",
                "Requires API Level 28",
                "queryEventStats requires Android 9 (API 28) or higher",
            )
        }
    }

    private fun handleEventsForSelf(
        call: MethodCall,
        result: Result,
        context: Context,
    ) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            runAsync(result) {
                UsageStats.queryEventsForSelf(context, call.longArg("start"), call.longArg("end"))
            }
        } else {
            result.success(emptyList<Map<String, String?>>())
        }
    }

    private fun handleNetworkCalls(
        call: MethodCall,
        result: Result,
        context: Context,
    ): Boolean {
        when (call.method) {
            "queryNetworkUsageStats" -> {
                runAsync(result) {
                    NetworkStats.queryNetworkUsageStats(
                        context,
                        call.longArg("start"),
                        call.longArg("end"),
                        call.intArg("type"),
                    )
                }
            }

            "queryNetworkUsageStatsByPackage" -> {
                runAsync(result) {
                    NetworkStats.queryNetworkUsageStatsByPackage(
                        context,
                        call.longArg("start"),
                        call.longArg("end"),
                        call.intArg("type"),
                        call.stringArg("packageName"),
                    )
                }
            }

            else -> {
                return false
            }
        }
        return true
    }

    private fun handlePackageCalls(
        call: MethodCall,
        result: Result,
        context: Context,
    ): Boolean {
        when (call.method) {
            "queryStorageStats" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    runAsync(result, onError = { null }) {
                        StorageStats.queryStatsForPackage(context, call.stringArg("packageName"))
                    }
                } else {
                    result.success(null)
                }
            }

            "getAppInfo" -> {
                runAsync(result) {
                    AppInfo.getAppInfo(context, call.stringArg("packageName"))
                }
            }

            "queryInstalledApps" -> {
                runAsync(result) {
                    AppInfo.queryInstalledApps(
                        context,
                        call.argument<Boolean>("includeSystem") ?: true,
                    )
                }
            }

            "getAppIcon" -> {
                runAsync(result) {
                    AppInfo.getAppIcon(context, call.stringArg("packageName"))
                }
            }

            else -> {
                return false
            }
        }
        return true
    }

    /**
     * Run [block] on the IO dispatcher and deliver its value on the main thread.
     * On failure, [onError] produces the value to return (defaults to a channel error).
     */
    private fun runAsync(
        result: Result,
        onError: ((Throwable) -> Any?)? = null,
        block: suspend () -> Any?,
    ) {
        scope.launch {
            try {
                val value = withContext(Dispatchers.IO) { block() }
                result.success(value)
            } catch (e: Exception) {
                if (onError != null) {
                    result.success(onError(e))
                } else {
                    result.error("usage_stats_error", e.message, null)
                }
            }
        }
    }

    private fun MethodCall.longArg(key: String): Long =
        (argument<Number>(key) ?: error("Missing argument: $key")).toLong()

    private fun MethodCall.intArg(key: String): Int = (argument<Number>(key) ?: error("Missing argument: $key")).toInt()

    private fun MethodCall.stringArg(key: String): String = argument<String>(key) ?: error("Missing argument: $key")

    private fun MethodCall.intervalArg(): Int =
        argument<Number>("intervalType")?.toInt() ?: UsageStatsManager.INTERVAL_BEST
}
