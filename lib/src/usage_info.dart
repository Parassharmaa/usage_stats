import 'parse.dart';

/// Aggregated foreground-usage statistics for a single app package.
///
/// Returned by [UsageStats.queryUsageStats] and
/// [UsageStats.queryAndAggregateUsageStats]. The raw fields are kept as
/// strings for backwards compatibility; prefer the typed getters
/// ([totalTimeInForegroundMs], [lastTimeUsedDate], …) for new code.
class UsageInfo {
  /// Creates a [UsageInfo]. Usually constructed via [UsageInfo.fromMap].
  UsageInfo({
    this.firstTimeStamp,
    this.lastTimeStamp,
    this.lastTimeUsed,
    this.packageName,
    this.totalTimeInForeground,
  });

  /// Builds a [UsageInfo] from a platform-channel map.
  factory UsageInfo.fromMap(Map<dynamic, dynamic> map) => UsageInfo(
        firstTimeStamp: map['firstTimeStamp'],
        lastTimeStamp: map['lastTimeStamp'],
        lastTimeUsed: map['lastTimeUsed'],
        totalTimeInForeground: map['totalTimeInForeground'],
        packageName: map['packageName'],
      );

  /// The package name of the app these statistics belong to.
  final String? packageName;

  /// Beginning of the queried interval, as epoch milliseconds (string).
  final String? firstTimeStamp;

  /// End of the queried interval, as epoch milliseconds (string).
  final String? lastTimeStamp;

  /// Last time the app was used, as epoch milliseconds (string).
  final String? lastTimeUsed;

  /// Total time the app spent in the foreground, in milliseconds (string).
  final String? totalTimeInForeground;

  /// [totalTimeInForeground] parsed to an [int] (milliseconds), or null.
  int? get totalTimeInForegroundMs => asInt(totalTimeInForeground);

  /// [firstTimeStamp] parsed to a [DateTime], or null.
  DateTime? get firstTimestampDate => asDate(firstTimeStamp);

  /// [lastTimeStamp] parsed to a [DateTime], or null.
  DateTime? get lastTimestampDate => asDate(lastTimeStamp);

  /// [lastTimeUsed] parsed to a [DateTime], or null.
  DateTime? get lastTimeUsedDate => asDate(lastTimeUsed);

  @override
  String toString() => 'UsageInfo(packageName: $packageName, '
      'totalTimeInForeground: $totalTimeInForeground)';
}
