import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usage_stats/usage_stats.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('usage_stats');
  final log = <MethodCall>[];

  // Per-test responses, keyed by method name.
  late Map<String, dynamic Function(MethodCall call)> responders;

  setUp(() {
    log.clear();
    responders = {};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      log.add(call);
      return responders[call.method]?.call(call);
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Map<dynamic, dynamic> argsOf(String method) =>
      log.firstWhere((c) => c.method == method).arguments as Map;

  final start = DateTime(2024, 6, 10);
  final end = DateTime(2024, 6, 11);

  group('permission', () {
    test('checkUsagePermission returns the platform value', () async {
      responders['isUsagePermission'] = (_) => true;
      expect(await UsageStats.checkUsagePermission(), isTrue);
      expect(log.single.method, 'isUsagePermission');
    });

    test('grantUsagePermission invokes the channel', () async {
      await UsageStats.grantUsagePermission();
      expect(log.single.method, 'grantUsagePermission');
    });

    test('openUsageAccessSettings invokes the channel', () async {
      await UsageStats.openUsageAccessSettings();
      expect(log.single.method, 'openUsageAccessSettings');
    });
  });

  group('queryUsageStats', () {
    test('parses results and forwards the interval type', () async {
      responders['queryUsageStats'] = (_) => [
            {
              'packageName': 'com.a',
              'firstTimeStamp': '1700000000000',
              'lastTimeStamp': '1700000500000',
              'lastTimeUsed': '1700000400000',
              'totalTimeInForeground': '1500',
            },
          ];
      final result = await UsageStats.queryUsageStats(
        start,
        end,
        intervalType: IntervalType.monthly,
      );
      expect(argsOf('queryUsageStats')['intervalType'], 2);
      expect(argsOf('queryUsageStats')['start'], start.millisecondsSinceEpoch);
      final info = result.single;
      expect(info.packageName, 'com.a');
      expect(info.totalTimeInForegroundMs, 1500);
      expect(
        info.lastTimeUsedDate,
        DateTime.fromMillisecondsSinceEpoch(1700000400000),
      );
    });

    test('omits intervalType when not provided', () async {
      responders['queryUsageStats'] = (_) => [];
      await UsageStats.queryUsageStats(start, end);
      expect(argsOf('queryUsageStats').containsKey('intervalType'), isFalse);
    });
  });

  group('queryEvents', () {
    test('parses events including the new typed fields', () async {
      responders['queryEvents'] = (_) => [
            {
              'eventType': '1',
              'timeStamp': '1700000000000',
              'packageName': 'com.a',
              'className': null,
              'appStandbyBucket': '10',
              'shortcutId': null,
            },
          ];
      final events = await UsageStats.queryEvents(start, end);
      final event = events.single;
      expect(event.packageName, 'com.a');
      expect(event.eventTypeValue, 1);
      expect(event.eventTypeDescription, 'ACTIVITY_RESUMED');
      expect(event.appStandbyBucketValue, 10);
      expect(
        event.timeStampDate,
        DateTime.fromMillisecondsSinceEpoch(1700000000000),
      );
    });
  });

  group('queryEventsForSelf', () {
    test('invokes the self channel and parses events', () async {
      responders['queryEventsForSelf'] = (_) => [
            {'eventType': '2', 'timeStamp': '1', 'packageName': 'self'},
          ];
      final events = await UsageStats.queryEventsForSelf(start, end);
      expect(log.single.method, 'queryEventsForSelf');
      expect(events.single.eventTypeDescription, 'ACTIVITY_PAUSED');
    });
  });

  group('queryEventStats', () {
    test('parses aggregated event stats', () async {
      responders['queryEventStats'] = (_) => [
            {'eventType': '15', 'totalTime': '2000', 'count': '4'},
          ];
      final stats = await UsageStats.queryEventStats(
        start,
        end,
        intervalType: IntervalType.daily,
      );
      expect(argsOf('queryEventStats')['intervalType'], 0);
      final info = stats.single;
      expect(info.totalTimeMs, 2000);
      expect(info.countValue, 4);
      expect(info.eventTypeDescription, 'SCREEN_INTERACTIVE');
    });
  });

  group('queryConfiguration', () {
    test('parses configuration stats', () async {
      responders['queryConfiguration'] = (_) => [
            {
              'configuration': 'en_US',
              'activationCount': '3',
              'totalTimeActive': '500',
            },
          ];
      final configs = await UsageStats.queryConfiguration(start, end);
      expect(configs.single.configuration, 'en_US');
      expect(configs.single.activationCountValue, 3);
      expect(configs.single.totalTimeActiveMs, 500);
    });
  });

  group('queryAndAggregateUsageStats', () {
    test('parses a package-keyed map', () async {
      responders['queryAndAggregateUsageStats'] = (_) => {
            'com.a': {'packageName': 'com.a', 'totalTimeInForeground': '10'},
          };
      final result = await UsageStats.queryAndAggregateUsageStats(start, end);
      expect(result['com.a']?.totalTimeInForegroundMs, 10);
    });
  });

  group('network', () {
    test('queryNetworkUsageStats forwards the network type', () async {
      responders['queryNetworkUsageStats'] = (_) => [
            {
              'packageName': 'com.a',
              'rxTotalBytes': '100',
              'txTotalBytes': '50'
            },
          ];
      final result = await UsageStats.queryNetworkUsageStats(
        start,
        end,
        networkType: NetworkType.wifi,
      );
      expect(argsOf('queryNetworkUsageStats')['type'], 2);
      expect(result.single.rxTotalBytesValue, 100);
      expect(result.single.txTotalBytesValue, 50);
    });

    test('queryNetworkUsageStatsByPackage forwards the package name', () async {
      responders['queryNetworkUsageStatsByPackage'] = (_) =>
          {'packageName': 'com.a', 'rxTotalBytes': '1', 'txTotalBytes': '2'};
      final info = await UsageStats.queryNetworkUsageStatsByPackage(
        start,
        end,
        packageName: 'com.a',
      );
      expect(argsOf('queryNetworkUsageStatsByPackage')['packageName'], 'com.a');
      expect(info.packageName, 'com.a');
    });
  });

  group('app standby', () {
    test('getAppStandbyBucket returns the bucket', () async {
      responders['getAppStandbyBucket'] = (_) => 20;
      expect(await UsageStats.getAppStandbyBucket(), 20);
    });

    test('isAppInactive forwards the package name', () async {
      responders['isAppInactive'] = (_) => true;
      expect(await UsageStats.isAppInactive('com.a'), isTrue);
      expect(argsOf('isAppInactive')['packageName'], 'com.a');
    });
  });

  group('storage', () {
    test('queryStorageStats parses a StorageInfo', () async {
      responders['queryStorageStats'] = (_) => {
            'packageName': 'com.a',
            'appBytes': '100',
            'dataBytes': '200',
            'cacheBytes': '30',
            'totalBytes': '300',
          };
      final info = await UsageStats.queryStorageStats('com.a');
      expect(info?.appBytes, 100);
      expect(info?.dataBytes, 200);
      expect(info?.cacheBytes, 30);
      expect(info?.totalBytes, 300);
    });

    test('queryStorageStats returns null when unavailable', () async {
      responders['queryStorageStats'] = (_) => null;
      expect(await UsageStats.queryStorageStats('com.a'), isNull);
    });
  });

  group('package info', () {
    test('getAppInfo parses typed metadata', () async {
      responders['getAppInfo'] = (_) => {
            'packageName': 'com.a',
            'appName': 'App A',
            'isSystemApp': 'false',
            'enabled': 'true',
            'versionName': '1.2.3',
            'versionCode': '42',
            'firstInstallTime': '1700000000000',
            'lastUpdateTime': '1700000500000',
          };
      final info = await UsageStats.getAppInfo('com.a');
      expect(info?.appName, 'App A');
      expect(info?.isSystemApp, isFalse);
      expect(info?.enabled, isTrue);
      expect(info?.versionCode, 42);
      expect(
        info?.firstInstallTime,
        DateTime.fromMillisecondsSinceEpoch(1700000000000),
      );
    });

    test('getAppInfo returns null when not found', () async {
      responders['getAppInfo'] = (_) => null;
      expect(await UsageStats.getAppInfo('com.missing'), isNull);
    });

    test('queryInstalledApps forwards includeSystem', () async {
      responders['queryInstalledApps'] = (_) => [
            {
              'packageName': 'com.a',
              'isSystemApp': 'false',
              'enabled': 'true',
              'versionCode': '1',
            },
          ];
      final apps = await UsageStats.queryInstalledApps(includeSystem: false);
      expect(argsOf('queryInstalledApps')['includeSystem'], isFalse);
      expect(apps.single.packageName, 'com.a');
    });

    test('getAppIcon returns the raw bytes', () async {
      responders['getAppIcon'] = (_) => Uint8List.fromList([1, 2, 3]);
      final icon = await UsageStats.getAppIcon('com.a');
      expect(icon, Uint8List.fromList([1, 2, 3]));
    });
  });

  group('enum mappings', () {
    test('IntervalType.value matches UsageStatsManager.INTERVAL_*', () {
      expect(IntervalType.daily.value, 0);
      expect(IntervalType.weekly.value, 1);
      expect(IntervalType.monthly.value, 2);
      expect(IntervalType.yearly.value, 3);
      expect(IntervalType.best.value, 4);
    });

    test('NetworkType.value maps to the platform integers', () {
      expect(NetworkType.all.value, 1);
      expect(NetworkType.wifi.value, 2);
      expect(NetworkType.mobile.value, 3);
    });
  });
}
