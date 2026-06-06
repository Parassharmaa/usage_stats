import 'parse.dart';

/// Per-app network usage (bytes received and transmitted).
///
/// Returned by [UsageStats.queryNetworkUsageStats] and
/// [UsageStats.queryNetworkUsageStatsByPackage].
class NetworkInfo {
  /// Creates a [NetworkInfo]. Usually constructed via [NetworkInfo.fromMap].
  NetworkInfo({
    this.packageName,
    this.rxTotalBytes,
    this.txTotalBytes,
  });

  /// Builds a [NetworkInfo] from a platform-channel map.
  factory NetworkInfo.fromMap(Map<dynamic, dynamic> map) => NetworkInfo(
        packageName: map['packageName'],
        rxTotalBytes: map['rxTotalBytes'],
        txTotalBytes: map['txTotalBytes'],
      );

  /// The package name of the app these statistics belong to.
  final String? packageName;

  /// Total bytes received by the app, in the queried interval (string).
  final String? rxTotalBytes;

  /// Total bytes transmitted by the app, in the queried interval (string).
  final String? txTotalBytes;

  /// [rxTotalBytes] parsed to an [int], or null.
  int? get rxTotalBytesValue => asInt(rxTotalBytes);

  /// [txTotalBytes] parsed to an [int], or null.
  int? get txTotalBytesValue => asInt(txTotalBytes);

  @override
  String toString() => 'NetworkInfo(packageName: $packageName, '
      'rxTotalBytes: $rxTotalBytes, txTotalBytes: $txTotalBytes)';
}

/// The transport to aggregate when querying network usage.
enum NetworkType {
  /// Wi-Fi plus mobile/cellular combined.
  all,

  /// Wi-Fi only.
  wifi,

  /// Mobile/cellular only.
  mobile,
}

/// Maps [NetworkType] to the integer expected by the platform channel.
extension NetworkTypeExt on NetworkType {
  /// The platform-channel value for this [NetworkType].
  int get value {
    switch (this) {
      case NetworkType.all:
        return 1;
      case NetworkType.wifi:
        return 2;
      case NetworkType.mobile:
        return 3;
    }
  }
}
