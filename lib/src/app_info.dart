import 'parse.dart';

/// Metadata about an installed application, resolved via `PackageManager`.
///
/// Returned by [UsageStats.getAppInfo] and [UsageStats.queryInstalledApps].
/// Use [UsageStats.getAppIcon] to fetch the launcher icon separately.
class AppInfo {
  /// Creates an [AppInfo]. Usually constructed via [AppInfo.fromMap].
  AppInfo({
    required this.packageName,
    this.appName,
    required this.isSystemApp,
    required this.enabled,
    this.versionName,
    required this.versionCode,
    this.firstInstallTime,
    this.lastUpdateTime,
  });

  /// Builds an [AppInfo] from a platform-channel map.
  factory AppInfo.fromMap(Map<dynamic, dynamic> map) => AppInfo(
        packageName: map['packageName'] as String? ?? '',
        appName: map['appName'] as String?,
        isSystemApp: '${map['isSystemApp']}' == 'true',
        enabled: '${map['enabled']}' == 'true',
        versionName: map['versionName'] as String?,
        versionCode: asInt(map['versionCode']) ?? 0,
        firstInstallTime: asDate(map['firstInstallTime']),
        lastUpdateTime: asDate(map['lastUpdateTime']),
      );

  /// The application's package name.
  final String packageName;

  /// The user-visible application label, if it could be resolved.
  final String? appName;

  /// Whether the app is part of the system image.
  final bool isSystemApp;

  /// Whether the app is currently enabled.
  final bool enabled;

  /// The app's `versionName`, if available.
  final String? versionName;

  /// The app's numeric version code.
  final int versionCode;

  /// When the app was first installed.
  final DateTime? firstInstallTime;

  /// When the app was last updated.
  final DateTime? lastUpdateTime;

  @override
  String toString() => 'AppInfo(packageName: $packageName, appName: $appName, '
      'isSystemApp: $isSystemApp)';
}
