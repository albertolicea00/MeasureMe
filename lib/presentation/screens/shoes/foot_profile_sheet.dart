import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/shoe_item.dart';
import '../../providers/repository_providers.dart';

/// Edits the user's own foot measurements, independent of any brand (§12).
class FootProfileSheet extends ConsumerStatefulWidget {
  const FootProfileSheet({super.key, required this.profile});

  final FootProfile profile;

  static Future<void> show(BuildContext context, FootProfile profile) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => FootProfileSheet(profile: profile),
    );
  }

  @override
  ConsumerState<FootProfileSheet> createState() => _FootProfileSheetState();
}

class _FootProfileSheetState extends ConsumerState<FootProfileSheet> {
  late final _leftLength = TextEditingController(text: widget.profile.leftFootLengthCm?.toString() ?? '');
  late final _rightLength = TextEditingController(text: widget.profile.rightFootLengthCm?.toString() ?? '');
  late final _leftWidth = TextEditingController(text: widget.profile.leftFootWidthCm?.toString() ?? '');
  late final _rightWidth = TextEditingController(text: widget.profile.rightFootWidthCm?.toString() ?? '');
  late final _archNotes = TextEditingController(text: widget.profile.archNotes ?? '');
  late final _preferredSize = TextEditingController(text: widget.profile.preferredSizeValue ?? '');
  late ShoeSizeSystem _preferredSystem = widget.profile.preferredSizeSystem ?? ShoeSizeSystem.usMens;

  @override
  void dispose() {
    for (final c in [_leftLength, _rightLength, _leftWidth, _rightWidth, _archNotes, _preferredSize]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    double? parse(TextEditingController c) => c.text.trim().isEmpty ? null : double.tryParse(c.text.trim());
    await ref.read(shoeRepositoryProvider).updateFootProfile(FootProfile(
          leftFootLengthCm: parse(_leftLength),
          rightFootLengthCm: parse(_rightLength),
          leftFootWidthCm: parse(_leftWidth),
          rightFootWidthCm: parse(_rightWidth),
          archNotes: _archNotes.text.trim().isEmpty ? null : _archNotes.text.trim(),
          preferredSizeSystem: _preferredSize.text.trim().isEmpty ? null : _preferredSystem,
          preferredSizeValue: _preferredSize.text.trim().isEmpty ? null : _preferredSize.text.trim(),
          updatedAt: DateTime.now(),
        ));
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Foot measurements', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _leftLength,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Left foot length', suffixText: 'cm'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _rightLength,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Right foot length', suffixText: 'cm'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _leftWidth,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Left foot width', suffixText: 'cm'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _rightWidth,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Right foot width', suffixText: 'cm'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _preferredSize,
                  decoration: const InputDecoration(labelText: 'Preferred size'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<ShoeSizeSystem>(
                  initialValue: _preferredSystem,
                  decoration: const InputDecoration(labelText: 'System'),
                  items: [
                    for (final s in ShoeSizeSystem.values) DropdownMenuItem(value: s, child: Text(s.label)),
                  ],
                  onChanged: (v) => setState(() => _preferredSystem = v ?? _preferredSystem),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _archNotes,
            decoration: const InputDecoration(labelText: 'Arch notes (optional)'),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
