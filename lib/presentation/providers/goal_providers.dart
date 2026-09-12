import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/goal.dart';
import 'repository_providers.dart';

final goalsProvider = StreamProvider<List<Goal>>((ref) {
  return ref.watch(goalRepositoryProvider).watchAll();
});

final goalForTypeProvider = Provider.family<Goal?, String>((ref, typeId) {
  final goals = ref.watch(goalsProvider).value ?? const [];
  for (final goal in goals) {
    if (goal.measurementTypeId == typeId) return goal;
  }
  return null;
});
