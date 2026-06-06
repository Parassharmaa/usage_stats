import 'parse.dart';

/// On-device storage usage for a single app package.
///
/// Returned by [UsageStats.queryStorageStats] (requires Android 8 / API 26+).
/// Byte values default to `0` when the platform reports nothing.
class StorageInfo {
  /// Creates a [StorageInfo]. Usually constructed via [StorageInfo.fromMap].
  StorageInfo({
    required this.packageName,
    required this.appBytes,
    required this.dataBytes,
    required this.cacheBytes,
    required this.totalBytes,
  });

  /// Builds a [StorageInfo] from a platform-channel map.
  factory StorageInfo.fromMap(Map<dynamic, dynamic> map) => StorageInfo(
        packageName: map['packageName'] as String? ?? '',
        appBytes: asInt(map['appBytes']) ?? 0,
        dataBytes: asInt(map['dataBytes']) ?? 0,
        cacheBytes: asInt(map['cacheBytes']) ?? 0,
        totalBytes: asInt(map['totalBytes']) ?? 0,
      );

  /// The package name these statistics belong to.
  final String packageName;

  /// Size of the app's APK and related code, in bytes.
  final int appBytes;

  /// Size of the app's data directory (includes [cacheBytes]), in bytes.
  final int dataBytes;

  /// Size of the app's cache, in bytes.
  final int cacheBytes;

  /// Convenience total of [appBytes] + [dataBytes], in bytes.
  final int totalBytes;

  @override
  String toString() =>
      'StorageInfo(packageName: $packageName, totalBytes: $totalBytes)';
}
