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

class UsageStats {
  static const MethodChannel _channel = const MethodChannel('usage_stats');

  static Future<bool?> checkUsagePermission() async {
    bool? isPermission;
    try {
      isPermission = await _channel.invokeMethod('isUsagePermission');
      return isPermission;
    } catch (e) {
      print(e);
    } finally {
      // 关闭通道
      _channel.setMethodCallHandler(null);
    }
    return isPermission;
  }

  static Future<void> grantUsagePermission() async {
    try {
      await _channel.invokeMethod('grantUsagePermission');
    } catch (e) {
      print(e);
    } finally {
      _channel.setMethodCallHandler(null);
    }
  }

  static Future<List<EventUsageInfo>> queryEvents(
      DateTime startDate, DateTime endDate) async {
    int end = endDate.millisecondsSinceEpoch;
    int start = startDate.millisecondsSinceEpoch;
    Map<String, int> interval = {'start': start, 'end': end};
    List<EventUsageInfo> result = [];
    try {
      var events = await _channel.invokeMethod('queryEvents', interval);
      result = events.map((item) => EventUsageInfo.fromMap(item)).toList();
    } catch (e) {
      print(e);
    } finally {
      _channel.setMethodCallHandler(null);
    }
    return result;
  }

  static Future<List<ConfigurationInfo>> queryConfiguration(
      DateTime startDate, DateTime endDate) async {
    int end = endDate.millisecondsSinceEpoch;
    int start = startDate.millisecondsSinceEpoch;
    Map<String, int> interval = {'start': start, 'end': end};
    List<ConfigurationInfo> result = [];
    try {
      var configs = await _channel.invokeMethod('queryConfiguration', interval);
      result = configs.map((item) => ConfigurationInfo.fromMap(item)).toList();
    } catch (e) {
      print(e);
    } finally {
      _channel.setMethodCallHandler(null);
    }

    return result;
  }

  static Future<List<EventInfo>> queryEventStats(
      DateTime startDate, DateTime endDate) async {
    int end = endDate.millisecondsSinceEpoch;
    int start = startDate.millisecondsSinceEpoch;
    Map<String, int> interval = {'start': start, 'end': end};
    List<EventInfo> result = [];
    try {
      var eventsStats =
          await _channel.invokeMethod('queryEventStats', interval);

      result = eventsStats.map((item) => EventInfo.fromMap(item)).toList();
    } catch (e) {
      print(e);
    } finally {
      _channel.setMethodCallHandler(null);
    }

    return result;
  }

  static Future<List<UsageInfo>> queryUsageStats(
      DateTime startDate, DateTime endDate) async {
    int end = endDate.millisecondsSinceEpoch;
    int start = startDate.millisecondsSinceEpoch;
    Map<String, int> interval = {'start': start, 'end': end};
    List<UsageInfo> result = [];
    try {
      var usageStats = await _channel.invokeMethod('queryUsageStats', interval);

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
    Map<String, UsageInfo> result = {};
    try {
      var usageAggStats =
          await _channel.invokeMethod('queryAndAggregateUsageStats', interval);
      result = usageAggStats.map(
          (key, value) => MapEntry(key as String, UsageInfo.fromMap(value)));
    } catch (e) {
      print(e);
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
    List<NetworkInfo> result = [];
    try {
      var events =
          await _channel.invokeMethod('queryNetworkUsageStats', interval);
      result = events.map((item) => NetworkInfo.fromMap(item)).toList();
    } catch (e) {
      print(e);
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
      print(e);
    } finally {
      _channel.setMethodCallHandler(null);
    }
    return NetworkInfo.fromMap(response);
  }
}
