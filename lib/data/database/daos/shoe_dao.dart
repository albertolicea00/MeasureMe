import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/shoe_tables.dart';

part 'shoe_dao.g.dart';

@DriftAccessor(tables: [ShoeItems, FootProfiles])
class ShoeDao extends DatabaseAccessor<AppDatabase> with _$ShoeDaoMixin {
  ShoeDao(super.db);

  Stream<List<ShoeItemRow>> watchAll() {
    return (select(shoeItems)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  Future<List<ShoeItemRow>> getAll() {
    return (select(shoeItems)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }

  Future<ShoeItemRow> insertItem(ShoeItemsCompanion item) {
    return into(shoeItems).insertReturning(item);
  }

  Future<void> updateItem(ShoeItemsCompanion item) {
    return update(shoeItems).replace(item);
  }

  Future<void> deleteItem(String id) {
    return (delete(shoeItems)..where((t) => t.id.equals(id))).go();
  }

  Future<void> setFavorite(String id, bool favorite) {
    return (update(shoeItems)..where((t) => t.id.equals(id)))
        .write(ShoeItemsCompanion(isFavorite: Value(favorite)));
  }

  Future<List<String>> knownBrands() async {
    final query = selectOnly(shoeItems, distinct: true)
      ..addColumns([shoeItems.brand])
      ..where(shoeItems.brand.isNotNull());
    final rows = await query.get();
    return rows.map((r) => r.read(shoeItems.brand)!).toList();
  }

  Stream<FootProfileRow> watchFootProfile() {
    return (select(footProfiles)..where((t) => t.id.equals(0))).watchSingleOrNull().map(
          (row) => row ?? _defaultFootProfileRow(),
        );
  }

  Future<FootProfileRow> getFootProfile() async {
    final row = await (select(footProfiles)..where((t) => t.id.equals(0))).getSingleOrNull();
    return row ?? _defaultFootProfileRow();
  }

  FootProfileRow _defaultFootProfileRow() => FootProfileRow(id: 0, updatedAt: DateTime.now());

  Future<void> upsertFootProfile(FootProfilesCompanion profile) {
    return into(footProfiles).insertOnConflictUpdate(profile);
  }
}
