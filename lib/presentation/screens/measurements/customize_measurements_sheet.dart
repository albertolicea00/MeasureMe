import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/measurement_providers.dart';
import '../../providers/repository_providers.dart';

/// Lets the user choose which measurement types show up in the Body
/// Measurements screen (§5 — never force every field on everyone).
class CustomizeMeasurementsSheet extends ConsumerWidget {
  const CustomizeMeasurementsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typesAsync = ref.watch(measurementTypesProvider);
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return typesAsync.when(
          data: (types) => ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              Text('Customize tracked measurements', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Turn off anything you don\'t want to track, or star your most-checked '
                'measurements to prioritize them on the dashboard.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              for (final type in types)
                SwitchListTile(
                  title: Text(type.displayName),
                  value: type.isTracked,
                  secondary: IconButton(
                    icon: Icon(
                      type.isFavorite ? Icons.star : Icons.star_border,
                      color: type.isFavorite ? Colors.amber : null,
                    ),
                    onPressed: () {
                      ref.read(measurementRepositoryProvider).setTypeFavorite(type.id, !type.isFavorite);
                    },
                  ),
                  onChanged: (value) {
                    ref.read(measurementRepositoryProvider).setTypeTracked(type.id, value);
                  },
                ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('$e')),
        );
      },
    );
  }
}
