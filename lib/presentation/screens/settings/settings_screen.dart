import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/measurement_units.dart';
import '../../../domain/entities/user_profile.dart';
import '../../providers/profile_providers.dart';
import '../../providers/repository_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: profileAsync.when(
        data: (profile) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionCard(
              title: 'Units',
              children: [
                RadioGroup<UnitSystem>(
                  groupValue: profile.unitSystem,
                  onChanged: (v) => _updateUnitSystem(ref, profile, v),
                  child: const Column(
                    children: [
                      RadioListTile<UnitSystem>(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Metric (cm, kg)'),
                        value: UnitSystem.metric,
                      ),
                      RadioListTile<UnitSystem>(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Imperial (in, lb)'),
                        value: UnitSystem.imperial,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Appearance',
              children: [
                RadioGroup<AppThemeMode>(
                  groupValue: profile.themeMode,
                  onChanged: (v) {
                    if (v == null) return;
                    ref.read(profileRepositoryProvider).updateProfile(profile.copyWith(themeMode: v));
                  },
                  child: Column(
                    children: [
                      for (final mode in AppThemeMode.values)
                        RadioListTile<AppThemeMode>(
                          contentPadding: EdgeInsets.zero,
                          title: Text(switch (mode) {
                            AppThemeMode.light => 'Light',
                            AppThemeMode.dark => 'Dark',
                            AppThemeMode.system => 'System',
                          }),
                          value: mode,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Health & Data',
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.favorite_border),
                  title: const Text('Apple Health / Health Connect'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/health'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy & data'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/data-privacy'),
                ),
              ],
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('$e')),
      ),
    );
  }

  void _updateUnitSystem(WidgetRef ref, UserProfile profile, UnitSystem? value) {
    if (value == null) return;
    ref.read(profileRepositoryProvider).updateProfile(profile.copyWith(unitSystem: value));
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            ...children,
          ],
        ),
      ),
    );
  }
}
