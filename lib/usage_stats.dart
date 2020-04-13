import 'dart:async';
import 'dart:ffi';

import 'package:flutter/services.dart';

class UsageStats {
  static const MethodChannel _channel =
      const MethodChannel('usage_stats');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> checkUsagePermission() async {
    bool isPermission = await _channel.invokeMethod('isUsagePermission');
    return isPermission;
  }

  static Future<void> grantUsagePermission() async {
    await _channel.invokeMethod('grantUsagePermission');
  }


  static queryEvents(DateTime startDate, DateTime endDate) async {
    int end = endDate.millisecondsSinceEpoch;
    int start = startDate.millisecondsSinceEpoch;
    Map<String, int> interval = {'start': start, 'end': end};
    var events = await _channel.invokeMethod('queryEvents', interval);
    return events;
  }

  static queryConfiguration(DateTime startDate, DateTime endDate) async {
      int end = endDate.millisecondsSinceEpoch;
      int start = startDate.millisecondsSinceEpoch;
      Map<String, int> interval = {'start': start, 'end': end};
      var configs = await _channel.invokeMethod('queryConfiguration', interval);
      return configs;
    }
}
