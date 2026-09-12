import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/shoe_item.dart';
import 'repository_providers.dart';

final shoeItemsProvider = StreamProvider<List<ShoeItem>>((ref) {
  return ref.watch(shoeRepositoryProvider).watchAll();
});

final shoeBrandsProvider = FutureProvider<List<String>>((ref) {
  ref.watch(shoeItemsProvider);
  return ref.watch(shoeRepositoryProvider).knownBrands();
});

final footProfileProvider = StreamProvider<FootProfile>((ref) {
  return ref.watch(shoeRepositoryProvider).watchFootProfile();
});
