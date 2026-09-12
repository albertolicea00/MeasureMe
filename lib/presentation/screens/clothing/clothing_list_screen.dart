import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/clothing_item.dart';
import '../../../domain/repositories/clothing_repository.dart';
import '../../providers/clothing_providers.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/empty_states/empty_state.dart';

class ClothingListScreen extends ConsumerStatefulWidget {
  const ClothingListScreen({super.key});

  @override
  ConsumerState<ClothingListScreen> createState() => _ClothingListScreenState();
}

class _ClothingListScreenState extends ConsumerState<ClothingListScreen> {
  String _query = '';
  ClothingCategory? _category;
  bool _favoritesOnly = false;
  ClothingSortOrder _sort = ClothingSortOrder.newest;

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(clothingItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clothing & Suits'),
        actions: [
          PopupMenuButton<ClothingSortOrder>(
            icon: const Icon(Icons.sort),
            initialValue: _sort,
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (context) => const [
              PopupMenuItem(value: ClothingSortOrder.newest, child: Text('Newest first')),
              PopupMenuItem(value: ClothingSortOrder.oldest, child: Text('Oldest first')),
              PopupMenuItem(value: ClothingSortOrder.brand, child: Text('Brand')),
              PopupMenuItem(value: ClothingSortOrder.category, child: Text('Category')),
            ],
          ),
        ],
      ),
      body: itemsAsync.when(
        data: (allItems) {
          if (allItems.isEmpty) {
            return EmptyState(
              icon: Icons.checkroom_outlined,
              message: 'Save your first clothing size.',
              actionLabel: 'Add clothing size',
              onAction: () => context.push('/clothing/new'),
            );
          }

          var items = allItems.where((i) {
            if (_category != null && i.category != _category) return false;
            if (_favoritesOnly && !i.isFavorite) return false;
            if (_query.isNotEmpty) {
              final q = _query.toLowerCase();
              final matches = (i.brand?.toLowerCase().contains(q) ?? false) ||
                  (i.itemName?.toLowerCase().contains(q) ?? false) ||
                  i.size.toLowerCase().contains(q);
              if (!matches) return false;
            }
            return true;
          }).toList();

          switch (_sort) {
            case ClothingSortOrder.newest:
              items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            case ClothingSortOrder.oldest:
              items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            case ClothingSortOrder.brand:
              items.sort((a, b) => (a.brand ?? '').compareTo(b.brand ?? ''));
            case ClothingSortOrder.category:
              items.sort((a, b) => a.category.label.compareTo(b.category.label));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search brand, item, or size',
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    FilterChip(
                      label: const Text('Favorites'),
                      selected: _favoritesOnly,
                      onSelected: (v) => setState(() => _favoritesOnly = v),
                    ),
                    const SizedBox(width: 8),
                    for (final category in ClothingCategory.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category.label),
                          selected: _category == category,
                          onSelected: (v) => setState(() => _category = v ? category : null),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: items.isEmpty
                    ? const EmptyState(icon: Icons.search_off, message: 'No items match your filters.')
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: items.length,
                        itemBuilder: (context, index) => _ClothingTile(item: items[index]),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('$e')),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'clothingListFab',
        onPressed: () => context.push('/clothing/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ClothingTile extends ConsumerWidget {
  const _ClothingTile({required this.item});

  final ClothingItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = item.itemName ?? item.category.label;
    final subtitleParts = [
      if (item.brand != null) item.brand!,
      'Size ${item.size}',
      if (item.fit != null) item.fit!.label,
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitleParts.join(' · ')),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
          child: Icon(Icons.checkroom_outlined, color: Theme.of(context).colorScheme.primary),
        ),
        trailing: IconButton(
          icon: Icon(item.isFavorite ? Icons.star : Icons.star_border, color: Colors.amber),
          onPressed: () => ref.read(clothingRepositoryProvider).setFavorite(item.id, !item.isFavorite),
        ),
        onTap: () => context.push('/clothing/${item.id}/edit'),
      ),
    );
  }
}
