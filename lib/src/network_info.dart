class NetworkInfo {
  NetworkInfo({
    this.packageName,
    this.rxTotalBytes,
    this.txTotalBytes,
  });

  /// Construct class from the json map
  factory NetworkInfo.fromMap(Map map) => NetworkInfo(
        packageName: map['packageName'],
        rxTotalBytes: map['rxTotalBytes'],
        txTotalBytes: map['txTotalBytes'],
      );

  final String? packageName;
  final String? rxTotalBytes;
  final String? txTotalBytes;
}
