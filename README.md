# usage_stats
Query Android Usage Statistics (Configuration, Events, App Usage)

## Install
Add ```usage_stats``` as a dependency in  `pubspec.yaml`.

## Android
*NB: Requires API level 22 as a minimum!*

Add the following permission to the manifest namespace in `AndroidManifest.xml`:
```xml
    <uses-permission
        android:name="android.permission.PACKAGE_USAGE_STATS"
        tools:ignore="ProtectedPermissions" />
```

## Usage
```dart
import 'package:usage_stats/usage_stats.dart';

getUsage() async {

    DateTime endDate = new DateTime.now();
    DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0);
    
    // grant usage permission - opens Usage Settings
    UsageStats.grantUsagePermission();
    
    // check if permission is granted
    bool isPermission = UsageStats.checkUsagePermission();
    
    // query events
    List<EventUsageInfo> events = await UsageStats.queryEvents(startDate, endDate);
    
    // query usage stats
    List<UsageInfo> usageStats = await UsageStats.queryUsageStats(startDate, endDate);
    
    // query eventStats API Level 28
    List<EventInfo> eventStats = await UsageStats.queryEventStats(startDate, endDate);
    
    // query configurations
    List<ConfigurationInfo> configurations = await UsageStats.queryConfiguration(startDate, endDate);
    
    // query aggregated Usage statistics
    Map<String, UsageInfo> queryAndAggregateUsageStats = await UsageStats.queryAndAggregateUsageStats(startDate, endDate);

}
```

## To DO
* Add option to pass Interval Type in queryUsageStats, queryEventStats method
