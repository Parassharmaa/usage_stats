// On-device end-to-end tests for usage_stats.
//
// These run against a real Android device/emulator and assert that each API
// returns plausible, real data. The usage-access permission must be granted
// first, e.g.:
//
//   adb shell appops set io.github.parassharmaa.usage_stats_example \
//       GET_USAGE_STATS allow
//
// Run with:  flutter test integration_test

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usage_stats/usage_stats.dart';

const _ownPackage = 'io.github.parassharmaa.usage_stats_example';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final end = DateTime.now();
  final start = end.subtract(const Duration(days: 1));

  test('usage access permission is granted', () async {
    final granted = await UsageStats.checkUsagePermission();
    expect(
      granted,
      isTrue,
      reason: 'Grant it first: adb shell appops set $_ownPackage '
          'GET_USAGE_STATS allow',
    );
  });

  test('queryInstalledApps includes this app', () async {
    final apps = await UsageStats.queryInstalledApps();
    expect(apps, isNotEmpty);
    expect(apps.map((a) => a.packageName), contains(_ownPackage));
  });

  test('getAppInfo resolves this app label and version', () async {
    final info = await UsageStats.getAppInfo(_ownPackage);
    expect(info, isNotNull);
    expect(info!.packageName, _ownPackage);
    expect(info.appName, isNotNull);
    expect(info.versionCode, greaterThan(0));
    expect(info.isSystemApp, isFalse);
  });

  test('getAppIcon returns non-empty PNG bytes', () async {
    final icon = await UsageStats.getAppIcon(_ownPackage);
    expect(icon, isNotNull);
    expect(icon!, isNotEmpty);
    // PNG magic number.
    expect(icon.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
  });

  test('queryStorageStats reports a non-zero install size', () async {
    final storage = await UsageStats.queryStorageStats(_ownPackage);
    expect(storage, isNotNull);
    expect(storage!.packageName, _ownPackage);
    expect(storage.totalBytes, greaterThan(0));
  });

  test('getAppStandbyBucket returns a valid bucket', () async {
    final bucket = await UsageStats.getAppStandbyBucket();
    expect(bucket, isNotNull);
    expect(bucket, inInclusiveRange(5, 50));
  });

  test('isAppInactive returns a value for this app', () async {
    final idle = await UsageStats.isAppInactive(_ownPackage);
    expect(idle, isNotNull);
  });

  test('queryEvents returns real events with known types', () async {
    final events = await UsageStats.queryEvents(start, end);
    expect(events, isNotEmpty);
    for (final event in events.take(20)) {
      expect(event.eventTypeValue, isNotNull);
      expect(event.timeStampDate, isNotNull);
    }
  });

  test('queryUsageStats returns parsable entries', () async {
    final stats = await UsageStats.queryUsageStats(start, end);
    expect(stats, isA<List<UsageInfo>>());
    for (final s in stats.take(20)) {
      expect(s.packageName, isNotNull);
      expect(s.totalTimeInForegroundMs, isNotNull);
    }
  });

  test('queryEventStats works on API 28+', () async {
    final stats = await UsageStats.queryEventStats(start, end);
    expect(stats, isA<List<EventInfo>>());
  });

  test('queryEventsForSelf works without extra permission', () async {
    final events = await UsageStats.queryEventsForSelf(start, end);
    expect(events, isA<List<EventUsageInfo>>());
  });

  test('queryNetworkUsageStats returns a list', () async {
    final infos = await UsageStats.queryNetworkUsageStats(start, end);
    expect(infos, isA<List<NetworkInfo>>());
  });

  test('queryAndAggregateUsageStats returns a keyed map', () async {
    final map = await UsageStats.queryAndAggregateUsageStats(start, end);
    expect(map, isA<Map<String, UsageInfo>>());
  });
}
