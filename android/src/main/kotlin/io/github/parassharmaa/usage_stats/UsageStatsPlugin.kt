package io.github.parassharmaa.usage_stats

import android.content.Context
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext


/** UsageStatsPlugin */
public class UsageStatsPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel

    private var mContext: Context? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "usage_stats")
        channel.setMethodCallHandler(this);
        setContext(flutterPluginBinding.applicationContext)
    }

    private fun setContext(context: Context) {
        this.mContext = context
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "usage_stats")
            var plugin = UsageStatsPlugin()
            plugin.setContext(registrar.context())
            channel.setMethodCallHandler(plugin)
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "queryEvents" -> {
                var start: Long = call.argument<Long>("start") as Long
                var end: Long = call.argument<Long>("end") as Long
                result.success(UsageStats.queryEvents(mContext!!, start, end))
            }
            "isUsagePermission" -> {
                result.success(Utils.isUsagePermission(mContext!!))
            }
            "grantUsagePermission" -> {
                Utils.grantUsagePermission(mContext!!)
            }
            "queryConfiguration" -> {
                var start: Long = call.argument<Long>("start") as Long
                var end: Long = call.argument<Long>("end") as Long
                result.success(UsageStats.queryConfig(mContext!!, start, end))
            }
            "queryEventStats" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    var start: Long = call.argument<Long>("start") as Long
                    var end: Long = call.argument<Long>("end") as Long
                    result.success(UsageStats.queryEventStats(mContext!!, start, end))
                } else {
                    result.error("API Error",
                        "Requires API Level 28",
                        "Target should be set to 28 to use this API"
                    )
                }
            }
            "queryAndAggregateUsageStats" -> {
                var start: Long = call.argument<Long>("start") as Long
                var end: Long = call.argument<Long>("end") as Long
                result.success(UsageStats.queryAndAggregateUsageStats(mContext!!, start, end))
            }
            "queryUsageStats" -> {
                var start: Long = call.argument<Long>("start") as Long
                var end: Long = call.argument<Long>("end") as Long
                result.success(UsageStats.queryUsageStats(mContext!!, start, end))
            }
            "queryNetworkUsageStats" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    var start: Long = call.argument<Long>("start") as Long
                    var end: Long = call.argument<Long>("end") as Long
                    GlobalScope.launch(Dispatchers.Main) {
                        val netResult = withContext(Dispatchers.IO) {
                            NetworkStats.queryNetworkUsageStats(
                                context = mContext!!,
                                startDate = start,
                                endDate = end
                            )
                        }
                        result.success(netResult)
                    }
                } else {
                    result.error(
                        "API Error",
                        "Requires API Level 23",
                        "Target should be set to 23 to use this API"
                    )
                }

            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

