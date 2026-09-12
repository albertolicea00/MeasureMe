import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/clothing_item.dart';
import '../../providers/clothing_providers.dart';
import '../../providers/repository_providers.dart';

/// Add or edit a clothing size record (§10, §11). The same form serves a
/// brand size profile and an owned-item record — they're the same shape.
class ClothingItemEditScreen extends ConsumerStatefulWidget {
  const ClothingItemEditScreen({super.key, this.itemId});

  final String? itemId;

  @override
  ConsumerState<ClothingItemEditScreen> createState() => _ClothingItemEditScreenState();
}

class _ClothingItemEditScreenState extends ConsumerState<ClothingItemEditScreen> {
  ClothingCategory _category = ClothingCategory.shirt;
  ClothingFit? _fit;
  bool _initialized = false;

  final _brandController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _sizeController = TextEditingController();
  final _notesController = TextEditingController();
  final Map<String, TextEditingController> _measurementControllers = {};

  ClothingItem? _existing;

  TextEditingController _measurementController(String key) {
    return _measurementControllers.putIfAbsent(key, () => TextEditingController());
  }

  void _initFrom(ClothingItem item) {
    _existing = item;
    _category = item.category;
    _fit = item.fit;
    _brandController.text = item.brand ?? '';
    _itemNameController.text = item.itemName ?? '';
    _sizeController.text = item.size;
    _notesController.text = item.notes ?? '';
    for (final entry in item.measurements.entries) {
      _measurementController(entry.key).text = entry.value.toString();
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _itemNameController.dispose();
    _sizeController.dispose();
    _notesController.dispose();
    for (final c in _measurementControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_sizeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a size.')),
      );
      return;
    }
    final measurements = <String, double>{};
    for (final entry in _category.measurementFields.entries) {
      final text = _measurementControllers[entry.key]?.text.trim();
      final parsed = text == null || text.isEmpty ? null : double.tryParse(text);
      if (parsed != null) measurements[entry.key] = parsed;
    }

    final repo = ref.read(clothingRepositoryProvider);
    if (_existing == null) {
      await repo.add(ClothingItem(
        id: '',
        category: _category,
        brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        itemName: _itemNameController.text.trim().isEmpty ? null : _itemNameController.text.trim(),
        size: _sizeController.text.trim(),
        fit: _fit,
        measurements: measurements,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    } else {
      await repo.update(_existing!.copyWith(
        category: _category,
        brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        itemName: _itemNameController.text.trim().isEmpty ? null : _itemNameController.text.trim(),
        size: _sizeController.text.trim(),
        fit: _fit,
        measurements: measurements,
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
        title: const Text('Delete this item?'),
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
      await ref.read(clothingRepositoryProvider).delete(_existing!.id);
      if (!mounted) return;
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemId != null && !_initialized) {
      final items = ref.watch(clothingItemsProvider).value;
      final match = items?.where((i) => i.id == widget.itemId).toList();
      if (match != null && match.isNotEmpty) {
        _initFrom(match.first);
        _initialized = true;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_existing == null ? 'Add clothing size' : 'Edit clothing size'),
        actions: [
          if (_existing != null)
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<ClothingCategory>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [
              for (final c in ClothingCategory.values)
                DropdownMenuItem(value: c, child: Text(c.label)),
            ],
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _brandController,
            decoration: const InputDecoration(labelText: 'Brand (optional)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _itemNameController,
            decoration: const InputDecoration(labelText: 'Item name (optional)', hintText: 'e.g. Navy suit'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _sizeController,
            decoration: const InputDecoration(labelText: 'Size', hintText: 'e.g. 42R, L, 34x32'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ClothingFit?>(
            initialValue: _fit,
            decoration: const InputDecoration(labelText: 'Fit (optional)'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Not specified')),
              for (final f in ClothingFit.values) DropdownMenuItem(value: f, child: Text(f.label)),
            ],
            onChanged: (v) => setState(() => _fit = v),
          ),
          if (_category.measurementFields.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Measurements (optional)', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final entry in _category.measurementFields.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: _measurementController(entry.key),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: entry.value, suffixText: 'cm'),
                ),
              ),
          ],
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
