import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/measurement_units.dart';
import '../../../domain/entities/measurement_type.dart';
import '../../providers/measurement_providers.dart';
import '../../providers/profile_providers.dart';
import '../../widgets/cards/measurement_value_card.dart';
import '../../widgets/empty_states/empty_state.dart';
import '../../widgets/section_header.dart';
import 'customize_measurements_sheet.dart';

class MeasurementsHubScreen extends ConsumerWidget {
  const MeasurementsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typesAsync = ref.watch(measurementTypesProvider);
    final unitSystem = ref.watch(unitSystemProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Measurements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Customize tracked measurements',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const CustomizeMeasurementsSheet(),
            ),
          ),
        ],
      ),
      body: typesAsync.when(
        data: (types) {
          final tracked = types.where((t) => t.isTracked).toList();
          if (tracked.isEmpty) {
            return EmptyState(
              icon: Icons.straighten_outlined,
              message: 'Your measurements will appear here.',
              actionLabel: 'Add your first measurement',
              onAction: () => context.push('/session'),
            );
          }

          final byCategory = <MeasurementCategory, List<MeasurementType>>{};
          for (final type in tracked) {
            byCategory.putIfAbsent(type.category, () => []).add(type);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SizingSection(
                icon: Icons.checkroom_outlined,
                title: 'Clothing & Suits',
                subtitle: 'Sizes by brand, shirts, suits, and more',
                onTap: () => context.push('/clothing'),
              ),
              const SizedBox(height: 12),
              _SizingSection(
                icon: Icons.snowshoeing_outlined,
                title: 'Shoes',
                subtitle: 'Foot measurements and sizes by brand',
                onTap: () => context.push('/shoes'),
              ),
              const SizedBox(height: 24),
              for (final category in MeasurementCategory.values)
                if (byCategory[category]?.isNotEmpty ?? false) ...[
                  SectionHeader(category.label),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.15,
                    children: [
                      for (final type in byCategory[category]!)
                        _TypeCard(type: type, unitSystem: unitSystem),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Could not load measurements: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'measurementsHubFab',
        onPressed: () => context.push('/session'),
        icon: const Icon(Icons.add),
        label: const Text('Update measurements'),
      ),
    );
  }
}

class _TypeCard extends ConsumerWidget {
  const _TypeCard({required this.type, required this.unitSystem});

  final MeasurementType type;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = ref.watch(latestMeasurementProvider(type.id)).value;
    return MeasurementValueCard(
      type: type,
      latest: latest,
      unitSystem: unitSystem,
      onTap: () => context.push('/measurements/${type.id}/history'),
    );
  }
}

class _SizingSection extends StatelessWidget {
  const _SizingSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                child: Icon(icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
