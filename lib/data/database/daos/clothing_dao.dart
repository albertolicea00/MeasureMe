import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/clothing_tables.dart';

part 'clothing_dao.g.dart';

@DriftAccessor(tables: [ClothingItems])
class ClothingDao extends DatabaseAccessor<AppDatabase> with _$ClothingDaoMixin {
  ClothingDao(super.db);

  Stream<List<ClothingItemRow>> watchAll() {
    return (select(clothingItems)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  Future<List<ClothingItemRow>> getAll() {
    return (select(clothingItems)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }

  Future<ClothingItemRow> insertItem(ClothingItemsCompanion item) {
    return into(clothingItems).insertReturning(item);
  }

  Future<void> updateItem(ClothingItemsCompanion item) {
    return update(clothingItems).replace(item);
  }

  Future<void> deleteItem(String id) {
    return (delete(clothingItems)..where((t) => t.id.equals(id))).go();
  }

  Future<void> setFavorite(String id, bool favorite) {
    return (update(clothingItems)..where((t) => t.id.equals(id)))
        .write(ClothingItemsCompanion(isFavorite: Value(favorite)));
  }

  Future<List<String>> knownBrands() async {
    final query = selectOnly(clothingItems, distinct: true)
      ..addColumns([clothingItems.brand])
      ..where(clothingItems.brand.isNotNull());
    final rows = await query.get();
    return rows.map((r) => r.read(clothingItems.brand)!).toList();
  }
}
