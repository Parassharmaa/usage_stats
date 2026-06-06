import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';

void main() => runApp(const UsageStatsDemoApp());

/// Root of the usage_stats showcase application.
class UsageStatsDemoApp extends StatelessWidget {
  const UsageStatsDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'usage_stats demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6750A4),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF6750A4),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

/// Hosts the permission banner and the tabbed showcase of every API.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool _hasPermission = false;
  int _reload = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check once the user returns from the Usage Access settings screen.
    if (state == AppLifecycleState.resumed) _refreshPermission();
  }

  Future<void> _refreshPermission() async {
    final granted = await UsageStats.checkUsagePermission() ?? false;
    if (!mounted) return;
    setState(() {
      // When access flips, bump the reload token so every tab re-queries.
      if (granted != _hasPermission) _reload++;
      _hasPermission = granted;
    });
  }

  Future<void> _openSettings() => UsageStats.openUsageAccessSettings();

  static const _tabs = <Tab>[
    Tab(icon: Icon(Icons.bar_chart), text: 'Usage'),
    Tab(icon: Icon(Icons.timeline), text: 'Events'),
    Tab(icon: Icon(Icons.wifi), text: 'Network'),
    Tab(icon: Icon(Icons.apps), text: 'Apps'),
    Tab(icon: Icon(Icons.info_outline), text: 'Self'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('usage_stats'),
          actions: [
            IconButton(
              tooltip: 'Open usage access settings',
              onPressed: _openSettings,
              icon: const Icon(Icons.settings),
            ),
          ],
          bottom: const TabBar(isScrollable: true, tabs: _tabs),
        ),
        body: Column(
          children: [
            if (!_hasPermission) _PermissionBanner(onGrant: _openSettings),
            Expanded(
              child: TabBarView(
                children: [
                  UsageTab(key: ValueKey('usage-$_reload')),
                  EventsTab(key: ValueKey('events-$_reload')),
                  NetworkTab(key: ValueKey('network-$_reload')),
                  AppsTab(key: ValueKey('apps-$_reload')),
                  SelfTab(key: ValueKey('self-$_reload')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({required this.onGrant});

  final VoidCallback onGrant;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          children: [
            Icon(Icons.lock_outline, color: scheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Usage access is not granted. Most data will be empty until '
                'you enable it.',
                style: TextStyle(color: scheme.onErrorContainer),
              ),
            ),
            TextButton(onPressed: onGrant, child: const Text('GRANT')),
          ],
        ),
      ),
    );
  }
}

/// A query window covering the last 24 hours.
({DateTime start, DateTime end}) _last24h() {
  final end = DateTime.now();
  return (start: end.subtract(const Duration(hours: 24)), end: end);
}

String _formatDuration(int? ms) {
  if (ms == null || ms <= 0) return '0s';
  final d = Duration(milliseconds: ms);
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  if (h > 0) return '${h}h ${m}m';
  if (m > 0) return '${m}m ${s}s';
  return '${s}s';
}

String _formatBytes(int? bytes) {
  final b = bytes ?? 0;
  if (b < 1024) return '$b B';
  const units = ['KB', 'MB', 'GB', 'TB'];
  var value = b / 1024;
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  return '${value.toStringAsFixed(value >= 100 ? 0 : 1)} ${units[unit]}';
}

String _shortTime(DateTime? time) {
  if (time == null) return '';
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(time.hour)}:${two(time.minute)}:${two(time.second)}';
}

/// A reusable scaffold for a tab: pull-to-refresh, loading and empty states.
class TabScaffold<T> extends StatefulWidget {
  const TabScaffold({
    super.key,
    required this.load,
    required this.builder,
    this.emptyMessage = 'No data for the selected range.',
  });

  final Future<T> Function() load;
  final Widget Function(BuildContext context, T data) builder;
  final String emptyMessage;

  @override
  State<TabScaffold<T>> createState() => _TabScaffoldState<T>();
}

class _TabScaffoldState<T> extends State<TabScaffold<T>>
    with AutomaticKeepAliveClientMixin {
  late Future<T> _future;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _future = widget.load();
  }

  Future<void> _reload() async {
    setState(() => _future = widget.load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: _reload,
      child: FutureBuilder<T>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _Message(
              icon: Icons.error_outline,
              text: '${snapshot.error}',
            );
          }
          final data = snapshot.data;
          final isEmpty = data is List && data.isEmpty;
          if (data == null || isEmpty) {
            return _Message(icon: Icons.inbox, text: widget.emptyMessage);
          }
          return widget.builder(context, data);
        },
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    // Wrapped in a scrollable so pull-to-refresh still works when empty.
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(icon, size: 48, color: Theme.of(context).disabledColor),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(text, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}

/// Per-app foreground usage over the last 24 hours.
class UsageTab extends StatelessWidget {
  const UsageTab({super.key});

  Future<List<UsageInfo>> _load() async {
    final w = _last24h();
    final stats = await UsageStats.queryUsageStats(w.start, w.end);
    final used = stats
        .where((s) => (s.totalTimeInForegroundMs ?? 0) > 0)
        .toList()
      ..sort((a, b) => (b.totalTimeInForegroundMs ?? 0)
          .compareTo(a.totalTimeInForegroundMs ?? 0));
    return used;
  }

  @override
  Widget build(BuildContext context) {
    return TabScaffold<List<UsageInfo>>(
      load: _load,
      emptyMessage: 'No foreground usage in the last 24h.',
      builder: (context, stats) => ListView.separated(
        itemCount: stats.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final s = stats[i];
          return ListTile(
            leading: CircleAvatar(child: Text('${i + 1}')),
            title: Text(s.packageName ?? '?',
                maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('Last used ${_shortTime(s.lastTimeUsedDate)}'),
            trailing: Text(
              _formatDuration(s.totalTimeInForegroundMs),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        },
      ),
    );
  }
}

/// Raw usage events over the last 24 hours, most recent first.
class EventsTab extends StatelessWidget {
  const EventsTab({super.key});

  Future<List<EventUsageInfo>> _load() async {
    final w = _last24h();
    final events = await UsageStats.queryEvents(w.start, w.end);
    return events.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return TabScaffold<List<EventUsageInfo>>(
      load: _load,
      builder: (context, events) => ListView.separated(
        itemCount: events.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final e = events[i];
          return ListTile(
            dense: true,
            leading: const Icon(Icons.touch_app_outlined),
            title: Text(e.packageName ?? '?',
                maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(e.eventTypeDescription ?? 'type ${e.eventType}'),
            trailing: Text(_shortTime(e.timeStampDate)),
          );
        },
      ),
    );
  }
}

/// Per-app network usage over the last 24 hours.
class NetworkTab extends StatelessWidget {
  const NetworkTab({super.key});

  Future<List<NetworkInfo>> _load() async {
    final w = _last24h();
    final infos = await UsageStats.queryNetworkUsageStats(
      w.start,
      w.end,
      networkType: NetworkType.all,
    );
    final used = infos
        .where(
            (n) => (n.rxTotalBytesValue ?? 0) + (n.txTotalBytesValue ?? 0) > 0)
        .toList()
      ..sort((a, b) => ((b.rxTotalBytesValue ?? 0) + (b.txTotalBytesValue ?? 0))
          .compareTo((a.rxTotalBytesValue ?? 0) + (a.txTotalBytesValue ?? 0)));
    return used;
  }

  @override
  Widget build(BuildContext context) {
    return TabScaffold<List<NetworkInfo>>(
      load: _load,
      emptyMessage: 'No network usage recorded in the last 24h.',
      builder: (context, infos) => ListView.separated(
        itemCount: infos.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final n = infos[i];
          return ListTile(
            leading: const Icon(Icons.swap_vert),
            title: Text(n.packageName ?? '?',
                maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('↓ ${_formatBytes(n.rxTotalBytesValue)}    '
                '↑ ${_formatBytes(n.txTotalBytesValue)}'),
          );
        },
      ),
    );
  }
}

/// Installed apps with icons; tap a row for storage and idle status.
class AppsTab extends StatelessWidget {
  const AppsTab({super.key});

  Future<List<AppInfo>> _load() async {
    final apps = await UsageStats.queryInstalledApps(includeSystem: false);
    apps.sort((a, b) => (a.appName ?? a.packageName)
        .toLowerCase()
        .compareTo((b.appName ?? b.packageName).toLowerCase()));
    return apps;
  }

  @override
  Widget build(BuildContext context) {
    return TabScaffold<List<AppInfo>>(
      load: _load,
      emptyMessage: 'No user apps visible (check package visibility).',
      builder: (context, apps) => ListView.separated(
        itemCount: apps.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final app = apps[i];
          return ListTile(
            leading: _AppIcon(packageName: app.packageName),
            title: Text(app.appName ?? app.packageName,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(app.packageName,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Text('v${app.versionName ?? app.versionCode}'),
            onTap: () => _showDetails(context, app),
          );
        },
      ),
    );
  }

  Future<void> _showDetails(BuildContext context, AppInfo app) async {
    final storage = await UsageStats.queryStorageStats(app.packageName);
    final idle = await UsageStats.isAppInactive(app.packageName);
    if (!context.mounted) return;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _AppIcon(packageName: app.packageName, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(app.appName ?? app.packageName,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow('Package', app.packageName),
            _DetailRow('Version', '${app.versionName} (${app.versionCode})'),
            _DetailRow('System app', app.isSystemApp ? 'yes' : 'no'),
            _DetailRow('Currently idle', idle == true ? 'yes' : 'no'),
            _DetailRow('App size', _formatBytes(storage?.appBytes)),
            _DetailRow('Data', _formatBytes(storage?.dataBytes)),
            _DetailRow('Cache', _formatBytes(storage?.cacheBytes)),
            if (app.firstInstallTime != null)
              _DetailRow('Installed', '${app.firstInstallTime}'),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(color: Theme.of(context).hintColor)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

/// Loads and caches an app's launcher icon via [UsageStats.getAppIcon].
class _AppIcon extends StatelessWidget {
  const _AppIcon({required this.packageName, this.size = 40});

  final String packageName;
  final double size;

  static final _cache = <String, Future<Uint8List?>>{};

  @override
  Widget build(BuildContext context) {
    final future = _cache[packageName] ??= UsageStats.getAppIcon(packageName);
    return SizedBox(
      width: size,
      height: size,
      child: FutureBuilder<Uint8List?>(
        future: future,
        builder: (context, snapshot) {
          final bytes = snapshot.data;
          if (bytes == null) {
            return Icon(Icons.android, size: size);
          }
          return Image.memory(bytes, width: size, height: size);
        },
      ),
    );
  }
}

/// Diagnostics for this app itself: permission, standby bucket, self events.
class SelfTab extends StatelessWidget {
  const SelfTab({super.key});

  Future<_SelfInfo> _load() async {
    final w = _last24h();
    final granted = await UsageStats.checkUsagePermission() ?? false;
    final bucket = await UsageStats.getAppStandbyBucket();
    final selfEvents = await UsageStats.queryEventsForSelf(w.start, w.end);
    return _SelfInfo(
      granted: granted,
      bucket: bucket,
      selfEventCount: selfEvents.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TabScaffold<_SelfInfo>(
      load: _load,
      builder: (context, info) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                      info.granted ? Icons.check_circle : Icons.cancel,
                      color: info.granted ? Colors.green : Colors.red),
                  title: const Text('Usage access permission'),
                  subtitle: Text(info.granted ? 'Granted' : 'Not granted'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.battery_saver),
                  title: const Text('App standby bucket'),
                  subtitle: Text(_bucketName(info.bucket)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Own events (no permission needed)'),
                  subtitle: Text('${info.selfEventCount} events in last 24h'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'queryEventsForSelf and getAppStandbyBucket require no special '
            'permission and read only this app\'s data.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _bucketName(int? bucket) {
    switch (bucket) {
      case 10:
        return 'Active (10)';
      case 20:
        return 'Working set (20)';
      case 30:
        return 'Frequent (30)';
      case 40:
        return 'Rare (40)';
      case 45:
        return 'Restricted (45)';
      case null:
        return 'Unavailable (needs Android 9+)';
      default:
        return 'Bucket $bucket';
    }
  }
}

class _SelfInfo {
  const _SelfInfo({
    required this.granted,
    required this.bucket,
    required this.selfEventCount,
  });

  final bool granted;
  final int? bucket;
  final int selfEventCount;
}
