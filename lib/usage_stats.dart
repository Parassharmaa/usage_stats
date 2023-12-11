import 'dart:async';

import 'src/usage_info.dart';
import 'src/event_info.dart';
import 'src/configuration_info.dart';
import 'src/event_usage_info.dart';
import 'package:flutter/services.dart';

import 'src/network_info.dart';
export 'src/usage_info.dart';
export 'src/event_info.dart';
export 'src/network_info.dart';
export 'src/configuration_info.dart';
export 'src/event_usage_info.dart';

// dd
class UsageStats {
  static const MethodChannel _channel = const MethodChannel('usage_stats');

  static Future<bool?> checkUsagePermission() async {
    bool? isPermission = await _channel.invokeMethod('isUsagePermission');
    return isPermission;
  }

  static Future<void> grantUsagePermission() async {
    await _channel.invokeMethod('grantUsagePermission');
  }

  static Future<List<EventUsageInfo>> queryEvents(
      DateTime startDate, DateTime endDate) async {
    int end = endDate.millisecondsSinceEpoch;
    int start = startDate.millisecondsSinceEpoch;
    Map<String, int> interval = {'start': start, 'end': end};
    List<dynamic> events = await _channel.invokeMethod('queryEvents', interval);
    List<EventUsageInfo> result =
        events.map((item) => EventUsageInfo.fromMap(item)).toList();
    return result;
  }

  static Future<List<ConfigurationInfo>> queryConfiguration(
      DateTime startDate, DateTime endDate) async {
    int end = endDate.millisecondsSinceEpoch;
    int start = startDate.millisecondsSinceEpoch;
    Map<String, int> interval = {'start': start, 'end': end};
    List<dynamic> configs =
        await _channel.invokeMethod('queryConfiguration', interval);
    List<ConfigurationInfo> result =
        configs.map((item) => ConfigurationInfo.fromMap(item)).toList();
    return result;
  }

  static Future<List<EventInfo>> queryEventStats(
      DateTime startDate, DateTime endDate) async {
    int end = endDate.millisecondsSinceEpoch;
    int start = startDate.millisecondsSinceEpoch;
    Map<String, int> interval = {'start': start, 'end': end};
    List<dynamic> eventsStats =
        await _channel.invokeMethod('queryEventStats', interval);

    List<EventInfo> result =
        eventsStats.map((item) => EventInfo.fromMap(item)).toList();
    return result;
  }

  static Future<List<UsageInfo>> queryUsageStats(
      DateTime startDate, DateTime endDate) async {
    int end = endDate.millisecondsSinceEpoch;
    int start = startDate.millisecondsSinceEpoch;
    Map<String, int> interval = {'start': start, 'end': end};
    List<dynamic> usageStats = [];
    List<UsageInfo> result = [];
    try {
      usageStats = await _channel.invokeMethod('queryUsageStats', interval);
      result = usageStats.map((item) => UsageInfo.fromMap(item)).toList();
    } catch (e) {
    } finally {
      _channel.setMethodCallHandler(null);
    }
    return result;
  }

  static Future<Map<String, UsageInfo>> queryAndAggregateUsageStats(
      DateTime startDate, DateTime endDate) async {
    int end = endDate.millisecondsSinceEpoch;
    int start = startDate.millisecondsSinceEpoch;
    Map<String, int> interval = {'start': start, 'end': end};
    Map<dynamic, dynamic> usageAggStats = {};
    Map<String, UsageInfo> result = {};
    try {
      usageAggStats =
          await _channel.invokeMethod('queryAndAggregateUsageStats', interval);
      usageAggStats.forEach((key, value) {
        if (key is String && value is Map<String, dynamic>) {
          result[key] = UsageInfo.fromMap(value);
        }
      });
    } catch (e) {
    } finally {
      _channel.setMethodCallHandler(null);
    }

    return result;
  }

  static Future<List<NetworkInfo>> queryNetworkUsageStats(
    DateTime startDate,
    DateTime endDate, {
    NetworkType networkType = NetworkType.all,
  }) async {
    int end = endDate.millisecondsSinceEpoch;
    int start = startDate.millisecondsSinceEpoch;
    Map<String, int> interval = {
      'start': start,
      'end': end,
      'type': networkType.value,
    };
    List<dynamic> events = [];
    List<NetworkInfo> result = [];
    try {
      events = await _channel.invokeMethod('queryNetworkUsageStats', interval);
      result = events.map((item) => NetworkInfo.fromMap(item)).toList();
    } catch (e) {
    } finally {
      _channel.setMethodCallHandler(null);
    }

    return result;
  }

  static Future<NetworkInfo> queryNetworkUsageStatsByPackage(
    DateTime startDate,
    DateTime endDate, {
    required String packageName,
    NetworkType networkType = NetworkType.all,
  }) async {
    int end = endDate.millisecondsSinceEpoch;
    int start = startDate.millisecondsSinceEpoch;
    Map<String, dynamic> interval = {
      'start': start,
      'end': end,
      'type': networkType.value,
      'packageName': packageName,
    };
    Map response = {};
    try {
      response = await _channel.invokeMethod(
          'queryNetworkUsageStatsByPackage', interval);
    } catch (e) {
    } finally {
      _channel.setMethodCallHandler(null);
    }
    return NetworkInfo.fromMap(response);
  }
}
