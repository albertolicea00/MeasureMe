import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/shoe_item.dart';
import '../../providers/repository_providers.dart';
import '../../providers/shoe_providers.dart';

class ShoeItemEditScreen extends ConsumerStatefulWidget {
  const ShoeItemEditScreen({super.key, this.itemId});

  final String? itemId;

  @override
  ConsumerState<ShoeItemEditScreen> createState() => _ShoeItemEditScreenState();
}

class _ShoeItemEditScreenState extends ConsumerState<ShoeItemEditScreen> {
  bool _initialized = false;
  ShoeItem? _existing;
  ShoeSizeSystem _sizeSystem = ShoeSizeSystem.usMens;

  final _brandController = TextEditingController();
  final _labelController = TextEditingController();
  final _categoryController = TextEditingController();
  final _sizeController = TextEditingController();
  final _notesController = TextEditingController();

  void _initFrom(ShoeItem item) {
    _existing = item;
    _sizeSystem = item.sizeSystem;
    _brandController.text = item.brand ?? '';
    _labelController.text = item.label ?? '';
    _categoryController.text = item.category ?? '';
    _sizeController.text = item.sizeValue;
    _notesController.text = item.notes ?? '';
  }

  @override
  void dispose() {
    for (final c in [_brandController, _labelController, _categoryController, _sizeController, _notesController]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_sizeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a size.')));
      return;
    }
    final repo = ref.read(shoeRepositoryProvider);
    if (_existing == null) {
      await repo.add(ShoeItem(
        id: '',
        brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        label: _labelController.text.trim().isEmpty ? null : _labelController.text.trim(),
        category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
        sizeSystem: _sizeSystem,
        sizeValue: _sizeController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    } else {
      await repo.update(_existing!.copyWith(
        brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        label: _labelController.text.trim().isEmpty ? null : _labelController.text.trim(),
        category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
        sizeSystem: _sizeSystem,
        sizeValue: _sizeController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      ));
    }
    if (!mounted) return;
    context.pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this shoe size?'),
        content: const Text('This can\'t be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && _existing != null) {
      await ref.read(shoeRepositoryProvider).delete(_existing!.id);
      if (!mounted) return;
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemId != null && !_initialized) {
      final items = ref.watch(shoeItemsProvider).value;
      final match = items?.where((i) => i.id == widget.itemId).toList();
      if (match != null && match.isNotEmpty) {
        _initFrom(match.first);
        _initialized = true;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_existing == null ? 'Add shoe size' : 'Edit shoe size'),
        actions: [
          if (_existing != null)
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _brandController,
            decoration: const InputDecoration(labelText: 'Brand', hintText: 'e.g. Nike'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _labelController,
            decoration: const InputDecoration(
              labelText: 'Label (optional)',
              hintText: 'e.g. Black running shoes',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: 'Category (optional)', hintText: 'e.g. Running, Boots'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _sizeController,
                  decoration: const InputDecoration(labelText: 'Size'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<ShoeSizeSystem>(
                  initialValue: _sizeSystem,
                  decoration: const InputDecoration(labelText: 'System'),
                  items: [
                    for (final s in ShoeSizeSystem.values) DropdownMenuItem(value: s, child: Text(s.label)),
                  ],
                  onChanged: (v) => setState(() => _sizeSystem = v ?? _sizeSystem),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Notes (optional)', hintText: 'e.g. Fits slightly narrow'),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
