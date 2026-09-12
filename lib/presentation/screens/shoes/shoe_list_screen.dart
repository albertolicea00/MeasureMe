import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/shoe_item.dart';
import '../../providers/repository_providers.dart';
import '../../providers/shoe_providers.dart';
import '../../widgets/empty_states/empty_state.dart';
import 'foot_profile_sheet.dart';

class ShoeListScreen extends ConsumerWidget {
  const ShoeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(shoeItemsProvider);
    final footProfileAsync = ref.watch(footProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Shoes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          footProfileAsync.when(
            data: (profile) => Card(
              child: ListTile(
                leading: const Icon(Icons.straighten_outlined),
                title: const Text('Foot measurements'),
                subtitle: Text(
                  profile.isEmpty
                      ? 'Add your foot length, width, and preferred size'
                      : [
                          if (profile.leftFootLengthCm != null || profile.rightFootLengthCm != null)
                            'Length: ${profile.leftFootLengthCm ?? '—'} / ${profile.rightFootLengthCm ?? '—'} cm',
                          if (profile.preferredSizeValue != null)
                            'Preferred: ${profile.preferredSizeValue} (${profile.preferredSizeSystem?.label})',
                        ].join(' · '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => FootProfileSheet.show(context, profile),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),
          Text('Sizes by brand', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          itemsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const EmptyState(
                  icon: Icons.snowshoeing_outlined,
                  message: 'Save a shoe size to remember what fits.',
                );
              }
              return Column(children: [for (final item in items) _ShoeTile(item: item)]);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('$e')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'shoeListFab',
        onPressed: () => context.push('/shoes/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ShoeTile extends ConsumerWidget {
  const _ShoeTile({required this.item});

  final ShoeItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitleParts = [
      if (item.category != null) item.category!,
      '${item.sizeValue} (${item.sizeSystem.label})',
    ];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
          child: Icon(Icons.snowshoeing_outlined, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(item.label ?? item.brand ?? 'Shoe'),
        subtitle: Text(subtitleParts.join(' · ')),
        trailing: IconButton(
          icon: Icon(item.isFavorite ? Icons.star : Icons.star_border, color: Colors.amber),
          onPressed: () => ref.read(shoeRepositoryProvider).setFavorite(item.id, !item.isFavorite),
        ),
        onTap: () => context.push('/shoes/${item.id}/edit'),
      ),
    );
  }
}
