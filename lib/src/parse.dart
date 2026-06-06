/// Internal parsing helpers shared by the model classes.
///
/// Values arrive from the Android platform channel as strings, so these helpers
/// turn them into the typed values exposed by the model getters. This file is
/// intentionally not exported from the package.
library;

/// Parses [value] into an [int], or returns null when it is null or malformed.
int? asInt(Object? value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

/// Interprets [value] as epoch milliseconds and returns the matching
/// [DateTime], or null when it is null or malformed.
DateTime? asDate(Object? value) {
  final ms = asInt(value);
  return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
}

/// Maps an Android `UsageEvents.Event` event-type integer to its constant name,
/// e.g. `1` -> `ACTIVITY_RESUMED`. Returns null for unknown values.
String? eventTypeName(int? type) {
  switch (type) {
    case 1:
      return 'ACTIVITY_RESUMED';
    case 2:
      return 'ACTIVITY_PAUSED';
    case 3:
      return 'END_OF_DAY';
    case 4:
      return 'CONTINUE_PREVIOUS_DAY';
    case 5:
      return 'CONFIGURATION_CHANGE';
    case 6:
      return 'SYSTEM_INTERACTION';
    case 7:
      return 'USER_INTERACTION';
    case 8:
      return 'SHORTCUT_INVOCATION';
    case 9:
      return 'CHOOSER_ACTION';
    case 10:
      return 'NOTIFICATION_SEEN';
    case 11:
      return 'STANDBY_BUCKET_CHANGED';
    case 12:
      return 'NOTIFICATION_INTERRUPTION';
    case 13:
      return 'SLICE_PINNED_PRIV';
    case 14:
      return 'SLICE_PINNED';
    case 15:
      return 'SCREEN_INTERACTIVE';
    case 16:
      return 'SCREEN_NON_INTERACTIVE';
    case 17:
      return 'KEYGUARD_SHOWN';
    case 18:
      return 'KEYGUARD_HIDDEN';
    case 19:
      return 'FOREGROUND_SERVICE_START';
    case 20:
      return 'FOREGROUND_SERVICE_STOP';
    case 21:
      return 'CONTINUING_FOREGROUND_SERVICE';
    case 22:
      return 'ROLLOVER_FOREGROUND_SERVICE';
    case 23:
      return 'ACTIVITY_STOPPED';
    case 26:
      return 'DEVICE_SHUTDOWN';
    case 27:
      return 'DEVICE_STARTUP';
    case 28:
      return 'USER_UNLOCKED';
    case 29:
      return 'USER_STOPPED';
    case 30:
      return 'LOCUS_ID_SET';
    case 31:
      return 'APP_COMPONENT_USED';
    default:
      return null;
  }
}
