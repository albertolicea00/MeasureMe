/// Clothing category, each with its own conventional measurement fields
/// (§10). The [measurements] map on [ClothingItem] uses the keys returned
/// by [ClothingCategory.measurementFields] for that category.
enum ClothingCategory {
  shirt,
  tshirt,
  pants,
  suit,
  underwear,
  other,
}

extension ClothingCategoryLabel on ClothingCategory {
  String get label {
    switch (this) {
      case ClothingCategory.shirt:
        return 'Shirt';
      case ClothingCategory.tshirt:
        return 'T-Shirt';
      case ClothingCategory.pants:
        return 'Pants';
      case ClothingCategory.suit:
        return 'Suit / Jacket';
      case ClothingCategory.underwear:
        return 'Underwear';
      case ClothingCategory.other:
        return 'Other';
    }
  }

  /// Field key -> human label, in display order. Values are stored in
  /// centimeters in [ClothingItem.measurements]; all fields are optional.
  Map<String, String> get measurementFields {
    switch (this) {
      case ClothingCategory.shirt:
        return const {
          'neck': 'Neck',
          'chest': 'Chest',
          'sleeve': 'Sleeve',
          'shoulder': 'Shoulder',
          'length': 'Shirt length',
        };
      case ClothingCategory.tshirt:
        return const {
          'chest': 'Chest',
          'shoulder': 'Shoulder',
          'length': 'Length',
        };
      case ClothingCategory.pants:
        return const {
          'waist': 'Waist',
          'hips': 'Hips',
          'inseam': 'Inseam',
          'outseam': 'Outseam',
          'thigh': 'Thigh',
        };
      case ClothingCategory.suit:
        return const {
          'chest': 'Chest',
          'waist': 'Waist',
          'shoulder': 'Shoulder',
          'sleeve': 'Sleeve',
          'jacketLength': 'Jacket length',
          'neck': 'Neck',
        };
      case ClothingCategory.underwear:
        return const {
          'waist': 'Waist',
          'hips': 'Hips',
        };
      case ClothingCategory.other:
        return const {};
    }
  }
}

enum ClothingFit { slim, regular, relaxed, athletic }

extension ClothingFitLabel on ClothingFit {
  String get label {
    switch (this) {
      case ClothingFit.slim:
        return 'Slim';
      case ClothingFit.regular:
        return 'Regular';
      case ClothingFit.relaxed:
        return 'Relaxed';
      case ClothingFit.athletic:
        return 'Athletic';
    }
  }
}

/// A stored clothing size/sizing record. The same record shape serves both
/// "preferred size for a brand" (§11) and "an item I own" (§13) — a suit
/// from SuitSupply that fits well is both at once.
class ClothingItem {
  final String id;
  final ClothingCategory category;
  final String? brand;
  final String? itemName;
  final String size;
  final ClothingFit? fit;
  final Map<String, double> measurements;
  final String? notes;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClothingItem({
    required this.id,
    required this.category,
    this.brand,
    this.itemName,
    required this.size,
    this.fit,
    this.measurements = const {},
    this.notes,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  ClothingItem copyWith({
    ClothingCategory? category,
    String? brand,
    String? itemName,
    String? size,
    ClothingFit? fit,
    Map<String, double>? measurements,
    String? notes,
    bool? isFavorite,
    DateTime? updatedAt,
  }) {
    return ClothingItem(
      id: id,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      itemName: itemName ?? this.itemName,
      size: size ?? this.size,
      fit: fit ?? this.fit,
      measurements: measurements ?? this.measurements,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
