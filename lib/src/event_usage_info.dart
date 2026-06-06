import 'parse.dart';

/// A single usage event emitted by the system, such as an activity moving to
/// the foreground or a notification being shown.
///
/// Returned by [UsageStats.queryEvents] and [UsageStats.queryEventsForSelf].
class EventUsageInfo {
  /// Creates an [EventUsageInfo]. Usually constructed via [EventUsageInfo.fromMap].
  EventUsageInfo({
    this.eventType,
    this.timeStamp,
    this.packageName,
    this.className,
    this.appStandbyBucket,
    this.shortcutId,
  });

  /// Builds an [EventUsageInfo] from a platform-channel map.
  factory EventUsageInfo.fromMap(Map<dynamic, dynamic> map) => EventUsageInfo(
        eventType: map['eventType'],
        timeStamp: map['timeStamp'],
        packageName: map['packageName'],
        className: map['className'],
        appStandbyBucket: map['appStandbyBucket'],
        shortcutId: map['shortcutId'],
      );

  /// The event type as an integer string (see [eventTypeName] for the label).
  final String? eventType;

  /// When the event occurred, as epoch milliseconds (string).
  final String? timeStamp;

  /// The package name associated with the event.
  final String? packageName;

  /// The class name associated with the event, if any.
  final String? className;

  /// App Standby bucket at the time of the event (API 28+), if available.
  final String? appStandbyBucket;

  /// The shortcut id for `SHORTCUT_INVOCATION` events (API 25+), if available.
  final String? shortcutId;

  /// [eventType] parsed to an [int], or null.
  int? get eventTypeValue => asInt(eventType);

  /// Human-readable name of [eventType], e.g. `ACTIVITY_RESUMED`.
  String? get eventTypeDescription => eventTypeName(eventTypeValue);

  /// [appStandbyBucket] parsed to an [int], or null.
  int? get appStandbyBucketValue => asInt(appStandbyBucket);

  /// [timeStamp] parsed to a [DateTime], or null.
  DateTime? get timeStampDate => asDate(timeStamp);

  @override
  String toString() => 'EventUsageInfo(packageName: $packageName, '
      'eventType: ${eventTypeDescription ?? eventType}, timeStamp: $timeStamp)';
}
