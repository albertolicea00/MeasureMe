import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../integrations/health/health_connect_service.dart';
import '../../../integrations/health/health_metric.dart';
import '../../../integrations/health/health_service.dart';
import '../../providers/health_providers.dart';
import '../../providers/profile_providers.dart';
import '../../providers/repository_providers.dart';

/// Health Integration screen (§15, §16): shows real platform capability
/// and lets the user opt in or out per data type. Never claims to sync
/// something the platform doesn't support (implementation rule 4).
class HealthIntegrationScreen extends ConsumerStatefulWidget {
  const HealthIntegrationScreen({super.key});

  @override
  ConsumerState<HealthIntegrationScreen> createState() => _HealthIntegrationScreenState();
}

class _HealthIntegrationScreenState extends ConsumerState<HealthIntegrationScreen> {
  bool? _available;
  Map<HealthMetric, bool> _permissions = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final service = ref.read(healthServiceProvider);
    try {
      final available = await service.isAvailable();
      final permissions = <HealthMetric, bool>{};
      if (available) {
        for (final metric in service.supportedMetrics) {
          permissions[metric] = await service.hasPermission(metric);
        }
      }
      if (!mounted) return;
      setState(() {
        _available = available;
        _permissions = permissions;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  Future<void> _connect() async {
    final service = ref.read(healthServiceProvider);
    final result = await service.requestAuthorization(service.supportedMetrics);
    if (result == HealthAuthorizationResult.denied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${service.platformName} permission was not granted. You can enable it later in Settings.',
          ),
        ),
      );
    }
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(healthServiceProvider);
    final profileAsync = ref.watch(profileStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(service.platformName)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Something went wrong: $_error'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_available == false) _UnavailableCard(service: service, onRetry: _refresh),
                    if (_available == true) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.favorite,
                                color: _permissions.values.any((v) => v)
                                    ? Colors.red
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _permissions.values.any((v) => v) ? 'Connected' : 'Not connected',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              FilledButton(onPressed: _connect, child: const Text('Connect')),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Column(
                          children: [
                            for (final metric in HealthMetric.values)
                              CheckboxListTile(
                                title: Text(metric.label),
                                value: service.supportedMetrics.contains(metric)
                                    ? (_permissions[metric] ?? false)
                                    : false,
                                enabled: false,
                                subtitle: service.supportedMetrics.contains(metric)
                                    ? null
                                    : Text('Not supported by ${service.platformName}'),
                                onChanged: (_) {},
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'Other body measurements (chest, waist, neck, arms, thighs, and similar) are not '
                          'part of Apple Health or Health Connect, so MeasureMe keeps those local-only.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(height: 16),
                      profileAsync.when(
                        data: (profile) => Card(
                          child: SwitchListTile(
                            title: const Text('Sync automatically'),
                            subtitle: Text('Write weight, height, and body fat to ${service.platformName} when recorded'),
                            value: service is HealthConnectService
                                ? profile.healthConnectSyncEnabled
                                : profile.appleHealthSyncEnabled,
                            onChanged: (value) {
                              final updated = service is HealthConnectService
                                  ? profile.copyWith(healthConnectSyncEnabled: value)
                                  : profile.copyWith(appleHealthSyncEnabled: value);
                              ref.read(profileRepositoryProvider).updateProfile(updated);
                            },
                          ),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (e, st) => const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
    );
  }
}

class _UnavailableCard extends StatelessWidget {
  const _UnavailableCard({required this.service, required this.onRetry});

  final dynamic service;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isHealthConnect = service is HealthConnectService;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isHealthConnect
                  ? 'Health Connect is not available on this device.'
                  : '${service.platformName} is not available on this device.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (isHealthConnect) ...[
              const SizedBox(height: 8),
              const Text('Install Health Connect from the Play Store to sync weight, height, and body fat.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  await (service as HealthConnectService).promptInstall();
                  onRetry();
                },
                child: const Text('Install Health Connect'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
