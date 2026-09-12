import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/clothing_item.dart';
import 'repository_providers.dart';

final clothingItemsProvider = StreamProvider<List<ClothingItem>>((ref) {
  return ref.watch(clothingRepositoryProvider).watchAll();
});

final clothingBrandsProvider = FutureProvider<List<String>>((ref) {
  ref.watch(clothingItemsProvider);
  return ref.watch(clothingRepositoryProvider).knownBrands();
});
