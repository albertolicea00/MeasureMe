import '../entities/clothing_item.dart';

enum ClothingSortOrder { newest, oldest, brand, category }

abstract class ClothingRepository {
  Stream<List<ClothingItem>> watchAll();

  Future<List<ClothingItem>> search({
    String? query,
    ClothingCategory? category,
    String? brand,
    bool? favoritesOnly,
    ClothingSortOrder sortOrder = ClothingSortOrder.newest,
  });

  Future<ClothingItem> add(ClothingItem item);

  Future<void> update(ClothingItem item);

  Future<void> delete(String id);

  Future<void> setFavorite(String id, bool favorite);

  /// Distinct brand names already used, for autocomplete.
  Future<List<String>> knownBrands();
}
