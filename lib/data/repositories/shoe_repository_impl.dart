import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/shoe_item.dart';
import '../../domain/repositories/clothing_repository.dart' show ClothingSortOrder;
import '../../domain/repositories/shoe_repository.dart';
import '../database/app_database.dart';
import '../database/daos/shoe_dao.dart';

class ShoeRepositoryImpl implements ShoeRepository {
  ShoeRepositoryImpl(this._dao);

  final ShoeDao _dao;
  static const _uuid = Uuid();

  ShoeItem _toDomain(ShoeItemRow row) {
    return ShoeItem(
      id: row.id,
      brand: row.brand,
      label: row.label,
      category: row.category,
      sizeSystem: ShoeSizeSystem.values.firstWhere((s) => s.name == row.sizeSystem),
      sizeValue: row.sizeValue,
      notes: row.notes,
      isFavorite: row.isFavorite,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  ShoeItemsCompanion _toCompanion(ShoeItem item) {
    return ShoeItemsCompanion(
      id: Value(item.id),
      brand: Value(item.brand),
      label: Value(item.label),
      category: Value(item.category),
      sizeSystem: Value(item.sizeSystem.name),
      sizeValue: Value(item.sizeValue),
      notes: Value(item.notes),
      isFavorite: Value(item.isFavorite),
      createdAt: Value(item.createdAt),
      updatedAt: Value(item.updatedAt),
    );
  }

  FootProfile _toDomainFootProfile(FootProfileRow row) {
    return FootProfile(
      leftFootLengthCm: row.leftFootLengthCm,
      rightFootLengthCm: row.rightFootLengthCm,
      leftFootWidthCm: row.leftFootWidthCm,
      rightFootWidthCm: row.rightFootWidthCm,
      archNotes: row.archNotes,
      preferredSizeSystem: row.preferredSizeSystem == null
          ? null
          : ShoeSizeSystem.values.firstWhere((s) => s.name == row.preferredSizeSystem),
      preferredSizeValue: row.preferredSizeValue,
      updatedAt: row.updatedAt,
    );
  }

  @override
  Stream<List<ShoeItem>> watchAll() => _dao.watchAll().map((rows) => rows.map(_toDomain).toList());

  @override
  Future<List<ShoeItem>> search({
    String? query,
    String? brand,
    String? category,
    bool? favoritesOnly,
    ClothingSortOrder sortOrder = ClothingSortOrder.newest,
  }) async {
    var items = (await _dao.getAll()).map(_toDomain).toList();

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      items = items.where((i) {
        return (i.brand?.toLowerCase().contains(q) ?? false) ||
            (i.label?.toLowerCase().contains(q) ?? false);
      }).toList();
    }
    if (brand != null && brand.isNotEmpty) {
      items = items.where((i) => i.brand == brand).toList();
    }
    if (category != null && category.isNotEmpty) {
      items = items.where((i) => i.category == category).toList();
    }
    if (favoritesOnly == true) {
      items = items.where((i) => i.isFavorite).toList();
    }

    switch (sortOrder) {
      case ClothingSortOrder.newest:
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case ClothingSortOrder.oldest:
        items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case ClothingSortOrder.brand:
        items.sort((a, b) => (a.brand ?? '').compareTo(b.brand ?? ''));
      case ClothingSortOrder.category:
        items.sort((a, b) => (a.category ?? '').compareTo(b.category ?? ''));
    }
    return items;
  }

  @override
  Future<ShoeItem> add(ShoeItem item) async {
    final now = DateTime.now();
    final withId = ShoeItem(
      id: _uuid.v4(),
      brand: item.brand,
      label: item.label,
      category: item.category,
      sizeSystem: item.sizeSystem,
      sizeValue: item.sizeValue,
      notes: item.notes,
      isFavorite: item.isFavorite,
      createdAt: now,
      updatedAt: now,
    );
    final row = await _dao.insertItem(_toCompanion(withId));
    return _toDomain(row);
  }

  @override
  Future<void> update(ShoeItem item) => _dao.updateItem(_toCompanion(item));

  @override
  Future<void> delete(String id) => _dao.deleteItem(id);

  @override
  Future<void> setFavorite(String id, bool favorite) => _dao.setFavorite(id, favorite);

  @override
  Future<List<String>> knownBrands() => _dao.knownBrands();

  @override
  Stream<FootProfile> watchFootProfile() => _dao.watchFootProfile().map(_toDomainFootProfile);

  @override
  Future<FootProfile> getFootProfile() async => _toDomainFootProfile(await _dao.getFootProfile());

  @override
  Future<void> updateFootProfile(FootProfile profile) {
    return _dao.upsertFootProfile(FootProfilesCompanion(
      id: const Value(0),
      leftFootLengthCm: Value(profile.leftFootLengthCm),
      rightFootLengthCm: Value(profile.rightFootLengthCm),
      leftFootWidthCm: Value(profile.leftFootWidthCm),
      rightFootWidthCm: Value(profile.rightFootWidthCm),
      archNotes: Value(profile.archNotes),
      preferredSizeSystem: Value(profile.preferredSizeSystem?.name),
      preferredSizeValue: Value(profile.preferredSizeValue),
      updatedAt: Value(profile.updatedAt),
    ));
  }
}
