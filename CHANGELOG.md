## 2.0.1

* Use absolute screenshot URLs in the README so they render on pub.dev
  (pub.dev does not resolve relative image paths).

## 2.0.0

The Dart API is fully backwards compatible (every change below is additive), but
this release raises the minimum platform requirements, which is a breaking change
for some consumers: `minSdk` is now 23 (was 22) and the Android build requires
Flutter 3.44+, AGP 9, Gradle 9 and JDK 17.

**New APIs**

* `queryUsageStats` / `queryEventStats` now accept an optional `intervalType`
  (`IntervalType.daily` / `weekly` / `monthly` / `yearly` / `best`).
* `getAppStandbyBucket()` — this app's standby bucket (no permission, API 28+).
* `isAppInactive(packageName)` — whether an app is idle (API 23+).
* `queryEventsForSelf(start, end)` — this app's own events with no permission
  prompt (API 28+).
* `queryStorageStats(packageName)` — app/data/cache byte usage (API 26+).
* `getAppInfo(packageName)` / `queryInstalledApps()` — app label, system flag,
  version and install times via `PackageManager`.
* `getAppIcon(packageName)` — PNG launcher icon bytes.
* `openUsageAccessSettings()` — opens the Usage Access screen unconditionally.
* Typed getters on every model (`...Ms`, `...Date`, `eventTypeDescription`,
  `rxTotalBytesValue`, …) plus new `appStandbyBucket` / `shortcutId` event fields.

**Improvements**

* Modernized the Android toolchain: AGP 9.1.1, Gradle 9.3.1, Kotlin 2.3.20,
  coroutines 1.11.0, `compileSdk` 36, `minSdk` 23, `mavenCentral()` (jcenter
  removed).
* Replaced `GlobalScope` with an engine-lifecycle `CoroutineScope` cancelled on
  detach; heavy queries now run off the main thread.
* Fixed `grantUsagePermission` never completing its platform result, and a
  potential null `className` crash in `queryEvents`.
* Added Kotlin static analysis (detekt + ktlint), `flutter_lints`, and dartdoc
  across the whole public API.
* Removed the unused iOS stub (the plugin is Android-only) and added
  `repository` / `issue_tracker` / `topics` metadata.

## 1.3.1

* Fix build errors with flutter 3.29.0

## 1.3.0

* Make compatibale with latest versions of android

## 1.2.1

* add namespace to android gradle

## 1.2.0

* Add Connection Type to query network
* Query network usage based on package id

## 1.1.0

* While granting Usage Access Permission directly opens up App Screen

## 1.0.1

* Update Readme

## 1.0.0

* Null Safety Support

## 0.1.0

* Add return type
* Add classes for UsageInfo, EventInfo, ConfigurationInfo, EventUsageInfo
* Update example and ReadMe

## 0.0.2

* Fix pubspec.yaml bug

## 0.0.1

* Add Query UsageStats API
* Add Grant Usage Permission and Check Permission API
* Add Query Event and EventStats API
* Add Query Configuration API
