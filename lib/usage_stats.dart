/// Query Android usage statistics — app usage, events, configuration changes,
/// app standby buckets, storage usage and per-app network data — by wrapping
/// Android's `UsageStatsManager`, `NetworkStatsManager`, `StorageStatsManager`
/// and `PackageManager` behind a single [UsageStats] facade.
///
/// This package is Android-only. Most queries require the special
/// `PACKAGE_USAGE_STATS` permission, which the user grants from system
/// settings via [UsageStats.grantUsagePermission].
library;

import 'dart:async';

import 'package:flutter/services.dart';

import 'src/app_info.dart';
import 'src/configuration_info.dart';
import 'src/event_info.dart';
import 'src/event_usage_info.dart';
import 'src/network_info.dart';
import 'src/storage_info.dart';
import 'src/usage_info.dart';

export 'src/app_info.dart';
export 'src/configuration_info.dart';
export 'src/event_info.dart';
export 'src/event_usage_info.dart';
export 'src/network_info.dart';
export 'src/storage_info.dart';
export 'src/usage_info.dart';

/// The interval granularity used by [UsageStats.queryUsageStats] and
/// [UsageStats.queryEventStats]. Mirrors `UsageStatsManager.INTERVAL_*`.
enum IntervalType {
  /// Daily buckets (`INTERVAL_DAILY`).
  daily,

  /// Weekly buckets (`INTERVAL_WEEKLY`).
  weekly,

  /// Monthly buckets (`INTERVAL_MONTHLY`).
  monthly,

  /// Yearly buckets (`INTERVAL_YEARLY`).
  yearly,

  /// Let the system pick the best-fitting interval (`INTERVAL_BEST`, default).
  best,
}

/// Maps [IntervalType] to the integer expected by the platform channel.
extension IntervalTypeValue on IntervalType {
  /// The `UsageStatsManager.INTERVAL_*` value for this interval.
  int get value => index;
}

/// Entry point for all usage-statistics queries. All methods are static.
class UsageStats {
  UsageStats._();

  static const MethodChannel _channel = MethodChannel('usage_stats');

  /// Whether the `PACKAGE_USAGE_STATS` permission has been granted to this app.
  static Future<bool?> checkUsagePermission() async {
    return _channel.invokeMethod<bool>('isUsagePermission');
  }

  /// Opens the system "Usage access" settings screen so the user can grant
  /// the `PACKAGE_USAGE_STATS` permission. Does nothing if already granted.
  ///
  /// Use [openUsageAccessSettings] to open the screen unconditionally.
  static Future<void> grantUsagePermission() async {
    await _channel.invokeMethod<void>('grantUsagePermission');
  }

  /// Opens the system "Usage access" settings screen unconditionally, even when
  /// the permission is already granted (handy for a "Manage access" button).
  static Future<void> openUsageAccessSettings() async {
    await _channel.invokeMethod<void>('openUsageAccessSettings');
  }

  /// Returns the raw usage events between [startDate] and [endDate].
  static Future<List<EventUsageInfo>> queryEvents(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final events = await _channel.invokeMethod('queryEvents', {
      'start': startDate.millisecondsSinceEpoch,
      'end': endDate.millisecondsSinceEpoch,
    });
    return (events as List)
        .map((item) => EventUsageInfo.fromMap(item))
        .toList();
  }

  /// Returns this app's own usage events between [startDate] and [endDate]
  /// **without** requiring `PACKAGE_USAGE_STATS`.
  ///
  /// Requires Android 9 (API 28); returns an empty list on older devices.
  static Future<List<EventUsageInfo>> queryEventsForSelf(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final events = await _channel.invokeMethod('queryEventsForSelf', {
      'start': startDate.millisecondsSinceEpoch,
      'end': endDate.millisecondsSinceEpoch,
    });
    return (events as List)
        .map((item) => EventUsageInfo.fromMap(item))
        .toList();
  }

  /// Returns the device [ConfigurationInfo] entries between [startDate] and
  /// [endDate].
  static Future<List<ConfigurationInfo>> queryConfiguration(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final configs = await _channel.invokeMethod('queryConfiguration', {
      'start': startDate.millisecondsSinceEpoch,
      'end': endDate.millisecondsSinceEpoch,
    });
    return (configs as List)
        .map((item) => ConfigurationInfo.fromMap(item))
        .toList();
  }

  /// Returns aggregated [EventInfo] statistics between [startDate] and
  /// [endDate].
  ///
  /// Requires Android 9 (API 28). [intervalType] controls the bucket
  /// granularity and defaults to [IntervalType.best].
  static Future<List<EventInfo>> queryEventStats(
    DateTime startDate,
    DateTime endDate, {
    IntervalType? intervalType,
  }) async {
    final eventsStats = await _channel.invokeMethod('queryEventStats', {
      'start': startDate.millisecondsSinceEpoch,
      'end': endDate.millisecondsSinceEpoch,
      if (intervalType != null) 'intervalType': intervalType.value,
    });
    return (eventsStats as List)
        .map((item) => EventInfo.fromMap(item))
        .toList();
  }

  /// Returns per-app [UsageInfo] statistics between [startDate] and [endDate].
  ///
  /// [intervalType] controls the bucket granularity and defaults to
  /// [IntervalType.best].
  static Future<List<UsageInfo>> queryUsageStats(
    DateTime startDate,
    DateTime endDate, {
    IntervalType? intervalType,
  }) async {
    final usageStats = await _channel.invokeMethod('queryUsageStats', {
      'start': startDate.millisecondsSinceEpoch,
      'end': endDate.millisecondsSinceEpoch,
      if (intervalType != null) 'intervalType': intervalType.value,
    });
    return (usageStats as List).map((item) => UsageInfo.fromMap(item)).toList();
  }

  /// Returns per-app [UsageInfo] aggregated by package between [startDate] and
  /// [endDate], keyed by package name.
  static Future<Map<String, UsageInfo>> queryAndAggregateUsageStats(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final usageAggStats =
        await _channel.invokeMethod('queryAndAggregateUsageStats', {
      'start': startDate.millisecondsSinceEpoch,
      'end': endDate.millisecondsSinceEpoch,
    });
    return (usageAggStats as Map).map(
      (key, value) => MapEntry(key as String, UsageInfo.fromMap(value)),
    );
  }

  /// Returns per-app [NetworkInfo] for all installed apps between [startDate]
  /// and [endDate], for the given [networkType].
  static Future<List<NetworkInfo>> queryNetworkUsageStats(
    DateTime startDate,
    DateTime endDate, {
    NetworkType networkType = NetworkType.all,
  }) async {
    final events = await _channel.invokeMethod('queryNetworkUsageStats', {
      'start': startDate.millisecondsSinceEpoch,
      'end': endDate.millisecondsSinceEpoch,
      'type': networkType.value,
    });
    return (events as List).map((item) => NetworkInfo.fromMap(item)).toList();
  }

  /// Returns [NetworkInfo] for a single [packageName] between [startDate] and
  /// [endDate], for the given [networkType].
  static Future<NetworkInfo> queryNetworkUsageStatsByPackage(
    DateTime startDate,
    DateTime endDate, {
    required String packageName,
    NetworkType networkType = NetworkType.all,
  }) async {
    final response =
        await _channel.invokeMethod('queryNetworkUsageStatsByPackage', {
      'start': startDate.millisecondsSinceEpoch,
      'end': endDate.millisecondsSinceEpoch,
      'type': networkType.value,
      'packageName': packageName,
    });
    return NetworkInfo.fromMap(response as Map);
  }

  /// This app's current [App Standby bucket](https://developer.android.com/topic/performance/appstandby)
  /// (e.g. `10` active, `20` working set, `30` frequent, `40` rare). Requires
  /// no permission.
  ///
  /// Requires Android 9 (API 28); returns null on older devices.
  static Future<int?> getAppStandbyBucket() async {
    return _channel.invokeMethod<int>('getAppStandbyBucket');
  }

  /// Whether [packageName] is currently considered inactive (idle).
  ///
  /// Querying packages other than the caller requires `PACKAGE_USAGE_STATS`.
  static Future<bool?> isAppInactive(String packageName) async {
    return _channel.invokeMethod<bool>('isAppInactive', {
      'packageName': packageName,
    });
  }

  /// Returns app/data/cache [StorageInfo] for [packageName].
  ///
  /// Requires Android 8 (API 26); returns null on older devices or on failure.
  /// Querying this app's own package needs no permission; querying other
  /// packages requires `PACKAGE_USAGE_STATS`.
  static Future<StorageInfo?> queryStorageStats(String packageName) async {
    final response = await _channel.invokeMethod('queryStorageStats', {
      'packageName': packageName,
    });
    if (response == null) return null;
    return StorageInfo.fromMap(response as Map);
  }

  /// Returns [AppInfo] metadata (label, system flag, version, install times)
  /// for [packageName], or null if the package cannot be resolved.
  static Future<AppInfo?> getAppInfo(String packageName) async {
    final response = await _channel.invokeMethod('getAppInfo', {
      'packageName': packageName,
    });
    if (response == null) return null;
    return AppInfo.fromMap(response as Map);
  }

  /// Returns [AppInfo] for every installed app the caller is allowed to see.
  ///
  /// Set [includeSystem] to false to exclude system apps. On Android 11+
  /// (API 30) package-visibility rules may limit the result unless the host
  /// app declares the appropriate `<queries>` entry.
  static Future<List<AppInfo>> queryInstalledApps({
    bool includeSystem = true,
  }) async {
    final response = await _channel.invokeMethod('queryInstalledApps', {
      'includeSystem': includeSystem,
    });
    return (response as List).map((item) => AppInfo.fromMap(item)).toList();
  }

  /// Returns the PNG-encoded launcher icon for [packageName], or null if it
  /// cannot be resolved.
  static Future<Uint8List?> getAppIcon(String packageName) async {
    return _channel.invokeMethod<Uint8List>('getAppIcon', {
      'packageName': packageName,
    });
  }
}
