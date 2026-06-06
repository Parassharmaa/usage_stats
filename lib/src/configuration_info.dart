import 'parse.dart';

/// Statistics about how long a given device [configuration] was active.
///
/// Returned by [UsageStats.queryConfiguration].
class ConfigurationInfo {
  /// Creates a [ConfigurationInfo]. Usually constructed via [ConfigurationInfo.fromMap].
  ConfigurationInfo({
    this.activationCount,
    this.totalTimeActive,
    this.configuration,
    this.lastTimeActive,
    this.firstTimeStamp,
    this.lastTimeStamp,
  });

  /// Builds a [ConfigurationInfo] from a platform-channel map.
  factory ConfigurationInfo.fromMap(Map<dynamic, dynamic> map) =>
      ConfigurationInfo(
        activationCount: map['activationCount'],
        totalTimeActive: map['totalTimeActive'],
        configuration: map['configuration'],
        lastTimeActive: map['lastTimeActive'],
        firstTimeStamp: map['firstTimeStamp'],
        lastTimeStamp: map['lastTimeStamp'],
      );

  /// Number of times this configuration became active (string).
  final String? activationCount;

  /// Total time this configuration was active, in milliseconds (string).
  final String? totalTimeActive;

  /// String representation of the Android `Configuration`.
  final String? configuration;

  /// Last time this configuration was active, as epoch milliseconds (string).
  final String? lastTimeActive;

  /// Beginning of the queried interval, as epoch milliseconds (string).
  final String? firstTimeStamp;

  /// End of the queried interval, as epoch milliseconds (string).
  final String? lastTimeStamp;

  /// [activationCount] parsed to an [int], or null.
  int? get activationCountValue => asInt(activationCount);

  /// [totalTimeActive] parsed to an [int] (milliseconds), or null.
  int? get totalTimeActiveMs => asInt(totalTimeActive);

  /// [lastTimeActive] parsed to a [DateTime], or null.
  DateTime? get lastTimeActiveDate => asDate(lastTimeActive);

  /// [firstTimeStamp] parsed to a [DateTime], or null.
  DateTime? get firstTimestampDate => asDate(firstTimeStamp);

  /// [lastTimeStamp] parsed to a [DateTime], or null.
  DateTime? get lastTimestampDate => asDate(lastTimeStamp);

  @override
  String toString() => 'ConfigurationInfo(configuration: $configuration, '
      'totalTimeActive: $totalTimeActive)';
}
