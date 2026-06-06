import 'parse.dart';

/// Aggregated statistics for a single event type over an interval.
///
/// Returned by [UsageStats.queryEventStats] (requires Android 9 / API 28+).
class EventInfo {
  /// Creates an [EventInfo]. Usually constructed via [EventInfo.fromMap].
  EventInfo({
    this.firstTimeStamp,
    this.lastTimeStamp,
    this.totalTime,
    this.lastEventTime,
    this.eventType,
    this.count,
  });

  /// Builds an [EventInfo] from a platform-channel map.
  factory EventInfo.fromMap(Map<dynamic, dynamic> map) => EventInfo(
        firstTimeStamp: map['firstTimeStamp'],
        lastTimeStamp: map['lastTimeStamp'],
        totalTime: map['totalTime'],
        lastEventTime: map['lastEventTime'],
        eventType: map['eventType'],
        count: map['count'],
      );

  /// Beginning of the queried interval, as epoch milliseconds (string).
  final String? firstTimeStamp;

  /// End of the queried interval, as epoch milliseconds (string).
  final String? lastTimeStamp;

  /// Total time this event type was active, in milliseconds (string).
  final String? totalTime;

  /// Last time this event type occurred, as epoch milliseconds (string).
  final String? lastEventTime;

  /// The event type as an integer string (see [eventTypeDescription]).
  final String? eventType;

  /// Number of times this event type occurred in the interval (string).
  final String? count;

  /// [totalTime] parsed to an [int] (milliseconds), or null.
  int? get totalTimeMs => asInt(totalTime);

  /// [count] parsed to an [int], or null.
  int? get countValue => asInt(count);

  /// [eventType] parsed to an [int], or null.
  int? get eventTypeValue => asInt(eventType);

  /// Human-readable name of [eventType], e.g. `SCREEN_INTERACTIVE`.
  String? get eventTypeDescription => eventTypeName(eventTypeValue);

  /// [firstTimeStamp] parsed to a [DateTime], or null.
  DateTime? get firstTimestampDate => asDate(firstTimeStamp);

  /// [lastTimeStamp] parsed to a [DateTime], or null.
  DateTime? get lastTimestampDate => asDate(lastTimeStamp);

  /// [lastEventTime] parsed to a [DateTime], or null.
  DateTime? get lastEventTimeDate => asDate(lastEventTime);

  @override
  String toString() =>
      'EventInfo(eventType: ${eventTypeDescription ?? eventType}, count: $count)';
}
