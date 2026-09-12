import '../entities/shoe_item.dart';
import 'clothing_repository.dart' show ClothingSortOrder;

abstract class ShoeRepository {
  Stream<List<ShoeItem>> watchAll();

  Future<List<ShoeItem>> search({
    String? query,
    String? brand,
    String? category,
    bool? favoritesOnly,
    ClothingSortOrder sortOrder = ClothingSortOrder.newest,
  });

  Future<ShoeItem> add(ShoeItem item);

  Future<void> update(ShoeItem item);

  Future<void> delete(String id);

  Future<void> setFavorite(String id, bool favorite);

  Future<List<String>> knownBrands();

  Stream<FootProfile> watchFootProfile();

  Future<FootProfile> getFootProfile();

  Future<void> updateFootProfile(FootProfile profile);
}
