import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/measurement_type.dart';
import '../../providers/measurement_providers.dart';
import '../../providers/profile_providers.dart';
import '../../widgets/cards/measurement_value_card.dart';
import '../../widgets/section_header.dart';
import 'widgets/progress_summary_card.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/reminder_card.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key, required this.onGoToTab});

  final ValueChanged<int> onGoToTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typesAsync = ref.watch(measurementTypesProvider);
    final profileAsync = ref.watch(profileStreamProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                profileAsync.value?.nickname?.isNotEmpty == true
                    ? 'Welcome back, ${profileAsync.value!.nickname}'
                    : 'MeasureMe',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(child: const ReminderCard()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverToBoxAdapter(child: const ProgressSummaryCard()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverToBoxAdapter(
              child: SectionHeader('Quick actions'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverToBoxAdapter(
              child: QuickActionsGrid(onViewProgress: () => onGoToTab(2)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverToBoxAdapter(child: SectionHeader('Your measurements')),
          ),
          typesAsync.when(
            data: (types) {
              final favorites = types.where((t) => t.isFavorite).toList();
              final shown = favorites.isNotEmpty
                  ? favorites
                  : types
                      .where((t) => MeasurementTypeCatalog.dashboardDefaultIds.contains(t.id))
                      .toList();
              shown.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.15,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _DashboardCard(type: shown[index]),
                    childCount: shown.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, st) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends ConsumerWidget {
  const _DashboardCard({required this.type});

  final MeasurementType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = ref.watch(latestMeasurementProvider(type.id)).value;
    final unitSystem = ref.watch(unitSystemProvider);
    return MeasurementValueCard(
      type: type,
      latest: latest,
      unitSystem: unitSystem,
      onTap: () => context.push('/measurements/${type.id}/history'),
    );
  }
}
