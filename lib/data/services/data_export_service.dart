import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart' as csv_lib;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/measurement_units.dart';
import '../../domain/entities/clothing_item.dart';
import '../../domain/entities/measurement_entry.dart';
import '../../domain/entities/measurement_type.dart';
import '../../domain/entities/shoe_item.dart';
import '../../domain/repositories/clothing_repository.dart';
import '../../domain/repositories/measurement_repository.dart';
import '../../domain/repositories/shoe_repository.dart';

/// Exports (and re-imports) the user's own data as JSON, or measurements
/// alone as CSV (§36). The user owns and controls their data — this never
/// touches a network.
class DataExportService {
  DataExportService({
    required this.measurementRepository,
    required this.clothingRepository,
    required this.shoeRepository,
  });

  final MeasurementRepository measurementRepository;
  final ClothingRepository clothingRepository;
  final ShoeRepository shoeRepository;

  Future<File> exportJson() async {
    final types = await measurementRepository.getTypes();
    final measurements = <Map<String, dynamic>>[];
    for (final type in types) {
      final history = await measurementRepository.getHistory(type.id);
      for (final entry in history) {
        measurements.add(_measurementToJson(entry));
      }
    }
    final clothing = await clothingRepository.search();
    final shoes = await shoeRepository.search();

    final payload = {
      'exportedAt': DateTime.now().toIso8601String(),
      'formatVersion': 1,
      'measurementTypes': types.map(_typeToJson).toList(),
      'measurements': measurements,
      'clothingItems': clothing.map(_clothingToJson).toList(),
      'shoeItems': shoes.map(_shoeToJson).toList(),
    };

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/measureme_export_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
    return file;
  }

  Future<File> exportMeasurementsCsv() async {
    final types = await measurementRepository.getTypes();
    final rows = <List<dynamic>>[
      ['type', 'value', 'unit', 'date', 'notes'],
    ];
    for (final type in types) {
      final history = await measurementRepository.getHistory(type.id);
      for (final entry in history) {
        rows.add([
          type.displayName,
          entry.valueCanonical,
          entry.unit.name,
          entry.timestamp.toIso8601String(),
          entry.notes ?? '',
        ]);
      }
    }
    final csvString = csv_lib.csv.encode(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/measureme_measurements_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvString);
    return file;
  }

  /// Re-imports a JSON file previously produced by [exportJson]. Custom
  /// measurement types referenced in the file are created if missing;
  /// entries are added as new history rows, never overwriting existing
  /// ones.
  Future<void> importJson(File file) async {
    final decoded = jsonDecode(await file.readAsString()) as Map<String, dynamic>;

    final existingTypes = await measurementRepository.getTypes();
    final existingIds = existingTypes.map((t) => t.id).toSet();

    for (final raw in (decoded['measurementTypes'] as List? ?? [])) {
      final map = raw as Map<String, dynamic>;
      if (existingIds.contains(map['id'])) continue;
      await measurementRepository.addCustomType(MeasurementType(
        id: map['id'] as String,
        displayName: map['displayName'] as String,
        category: MeasurementCategory.values.firstWhere((c) => c.name == map['category']),
        canonicalUnit: CanonicalUnitJson.fromName(map['canonicalUnit'] as String),
        instructions: map['instructions'] as String?,
        isCustom: true,
      ));
    }

    for (final raw in (decoded['measurements'] as List? ?? [])) {
      final map = raw as Map<String, dynamic>;
      await measurementRepository.addEntry(
        typeId: map['typeId'] as String,
        valueCanonical: (map['value'] as num).toDouble(),
        timestamp: DateTime.parse(map['timestamp'] as String),
        notes: map['notes'] as String?,
        source: MeasurementSource.manual,
      );
    }

    for (final raw in (decoded['clothingItems'] as List? ?? [])) {
      final map = raw as Map<String, dynamic>;
      await clothingRepository.add(ClothingItem(
        id: '',
        category: ClothingCategory.values.firstWhere((c) => c.name == map['category']),
        brand: map['brand'] as String?,
        itemName: map['itemName'] as String?,
        size: map['size'] as String,
        fit: map['fit'] == null ? null : ClothingFit.values.firstWhere((f) => f.name == map['fit']),
        measurements: (map['measurements'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
        notes: map['notes'] as String?,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }

    for (final raw in (decoded['shoeItems'] as List? ?? [])) {
      final map = raw as Map<String, dynamic>;
      await shoeRepository.add(ShoeItem(
        id: '',
        brand: map['brand'] as String?,
        label: map['label'] as String?,
        category: map['category'] as String?,
        sizeSystem: ShoeSizeSystem.values.firstWhere((s) => s.name == map['sizeSystem']),
        sizeValue: map['sizeValue'] as String,
        notes: map['notes'] as String?,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
  }

  Map<String, dynamic> _typeToJson(MeasurementType type) => {
        'id': type.id,
        'displayName': type.displayName,
        'category': type.category.name,
        'canonicalUnit': type.canonicalUnit.name,
        'instructions': type.instructions,
      };

  Map<String, dynamic> _measurementToJson(MeasurementEntry entry) => {
        'typeId': entry.typeId,
        'value': entry.valueCanonical,
        'unit': entry.unit.name,
        'timestamp': entry.timestamp.toIso8601String(),
        'notes': entry.notes,
        'source': entry.source.name,
      };

  Map<String, dynamic> _clothingToJson(ClothingItem item) => {
        'category': item.category.name,
        'brand': item.brand,
        'itemName': item.itemName,
        'size': item.size,
        'fit': item.fit?.name,
        'measurements': item.measurements,
        'notes': item.notes,
      };

  Map<String, dynamic> _shoeToJson(ShoeItem item) => {
        'brand': item.brand,
        'label': item.label,
        'category': item.category,
        'sizeSystem': item.sizeSystem.name,
        'sizeValue': item.sizeValue,
        'notes': item.notes,
      };
}

extension CanonicalUnitJson on CanonicalUnit {
  static CanonicalUnit fromName(String name) => CanonicalUnit.values.firstWhere((u) => u.name == name);
}
