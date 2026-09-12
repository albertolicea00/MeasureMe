import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/clothing_item.dart';
import '../../domain/repositories/clothing_repository.dart';
import '../database/app_database.dart';
import '../database/daos/clothing_dao.dart';

class ClothingRepositoryImpl implements ClothingRepository {
  ClothingRepositoryImpl(this._dao);

  final ClothingDao _dao;
  static const _uuid = Uuid();

  ClothingItem _toDomain(ClothingItemRow row) {
    final measurements = row.measurementsJson == null
        ? <String, double>{}
        : (jsonDecode(row.measurementsJson!) as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, (value as num).toDouble()));
    return ClothingItem(
      id: row.id,
      category: ClothingCategory.values.firstWhere((c) => c.name == row.category),
      brand: row.brand,
      itemName: row.itemName,
      size: row.size,
      fit: row.fit == null
          ? null
          : ClothingFit.values.firstWhere((f) => f.name == row.fit),
      measurements: measurements,
      notes: row.notes,
      isFavorite: row.isFavorite,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  ClothingItemsCompanion _toCompanion(ClothingItem item) {
    return ClothingItemsCompanion(
      id: Value(item.id),
      category: Value(item.category.name),
      brand: Value(item.brand),
      itemName: Value(item.itemName),
      size: Value(item.size),
      fit: Value(item.fit?.name),
      measurementsJson: Value(item.measurements.isEmpty ? null : jsonEncode(item.measurements)),
      notes: Value(item.notes),
      isFavorite: Value(item.isFavorite),
      createdAt: Value(item.createdAt),
      updatedAt: Value(item.updatedAt),
    );
  }

  @override
  Stream<List<ClothingItem>> watchAll() {
    return _dao.watchAll().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<List<ClothingItem>> search({
    String? query,
    ClothingCategory? category,
    String? brand,
    bool? favoritesOnly,
    ClothingSortOrder sortOrder = ClothingSortOrder.newest,
  }) async {
    var items = (await _dao.getAll()).map(_toDomain).toList();

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      items = items.where((i) {
        return (i.brand?.toLowerCase().contains(q) ?? false) ||
            (i.itemName?.toLowerCase().contains(q) ?? false) ||
            i.size.toLowerCase().contains(q);
      }).toList();
    }
    if (category != null) {
      items = items.where((i) => i.category == category).toList();
    }
    if (brand != null && brand.isNotEmpty) {
      items = items.where((i) => i.brand == brand).toList();
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
        items.sort((a, b) => a.category.label.compareTo(b.category.label));
    }
    return items;
  }

  @override
  Future<ClothingItem> add(ClothingItem item) async {
    final now = DateTime.now();
    final withId = ClothingItem(
      id: _uuid.v4(),
      category: item.category,
      brand: item.brand,
      itemName: item.itemName,
      size: item.size,
      fit: item.fit,
      measurements: item.measurements,
      notes: item.notes,
      isFavorite: item.isFavorite,
      createdAt: now,
      updatedAt: now,
    );
    final row = await _dao.insertItem(_toCompanion(withId));
    return _toDomain(row);
  }

  @override
  Future<void> update(ClothingItem item) => _dao.updateItem(_toCompanion(item));

  @override
  Future<void> delete(String id) => _dao.deleteItem(id);

  @override
  Future<void> setFavorite(String id, bool favorite) => _dao.setFavorite(id, favorite);

  @override
  Future<List<String>> knownBrands() => _dao.knownBrands();
}
