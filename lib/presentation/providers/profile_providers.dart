import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/measurement_units.dart';
import '../../domain/entities/user_profile.dart';
import 'repository_providers.dart';

final profileStreamProvider = StreamProvider<UserProfile>((ref) {
  return ref.watch(profileRepositoryProvider).watchProfile();
});

/// Convenience accessor: the user's preferred unit system, defaulting to
/// metric while the profile is still loading.
final unitSystemProvider = Provider<UnitSystem>((ref) {
  return ref.watch(profileStreamProvider).value?.unitSystem ?? UnitSystem.metric;
});
