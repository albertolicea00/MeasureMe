/// Shoe sizing systems (§12). Conversions between these are approximate —
/// brands vary, so the app never claims exact equivalence (see
/// [core/utils/shoe_size_converter.dart]).
enum ShoeSizeSystem { usMens, usWomens, eu, uk }

extension ShoeSizeSystemLabel on ShoeSizeSystem {
  String get label {
    switch (this) {
      case ShoeSizeSystem.usMens:
        return "US Men's";
      case ShoeSizeSystem.usWomens:
        return "US Women's";
      case ShoeSizeSystem.eu:
        return 'EU';
      case ShoeSizeSystem.uk:
        return 'UK';
    }
  }
}

/// A brand-specific shoe size record the user has confirmed fits them
/// (§12, §13) — e.g. "Nike, US 10, Running".
class ShoeItem {
  final String id;
  final String? brand;
  final String? label;
  final String? category;
  final ShoeSizeSystem sizeSystem;
  final String sizeValue;
  final String? notes;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ShoeItem({
    required this.id,
    this.brand,
    this.label,
    this.category,
    required this.sizeSystem,
    required this.sizeValue,
    this.notes,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  ShoeItem copyWith({
    String? brand,
    String? label,
    String? category,
    ShoeSizeSystem? sizeSystem,
    String? sizeValue,
    String? notes,
    bool? isFavorite,
    DateTime? updatedAt,
  }) {
    return ShoeItem(
      id: id,
      brand: brand ?? this.brand,
      label: label ?? this.label,
      category: category ?? this.category,
      sizeSystem: sizeSystem ?? this.sizeSystem,
      sizeValue: sizeValue ?? this.sizeValue,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

/// Singleton record of the user's foot measurements, independent of any
/// one brand (§12). Lengths/widths are stored in centimeters.
class FootProfile {
  final double? leftFootLengthCm;
  final double? rightFootLengthCm;
  final double? leftFootWidthCm;
  final double? rightFootWidthCm;
  final String? archNotes;
  final ShoeSizeSystem? preferredSizeSystem;
  final String? preferredSizeValue;
  final DateTime updatedAt;

  const FootProfile({
    this.leftFootLengthCm,
    this.rightFootLengthCm,
    this.leftFootWidthCm,
    this.rightFootWidthCm,
    this.archNotes,
    this.preferredSizeSystem,
    this.preferredSizeValue,
    required this.updatedAt,
  });

  bool get isEmpty =>
      leftFootLengthCm == null &&
      rightFootLengthCm == null &&
      leftFootWidthCm == null &&
      rightFootWidthCm == null &&
      preferredSizeValue == null;

  FootProfile copyWith({
    double? leftFootLengthCm,
    double? rightFootLengthCm,
    double? leftFootWidthCm,
    double? rightFootWidthCm,
    String? archNotes,
    ShoeSizeSystem? preferredSizeSystem,
    String? preferredSizeValue,
  }) {
    return FootProfile(
      leftFootLengthCm: leftFootLengthCm ?? this.leftFootLengthCm,
      rightFootLengthCm: rightFootLengthCm ?? this.rightFootLengthCm,
      leftFootWidthCm: leftFootWidthCm ?? this.leftFootWidthCm,
      rightFootWidthCm: rightFootWidthCm ?? this.rightFootWidthCm,
      archNotes: archNotes ?? this.archNotes,
      preferredSizeSystem: preferredSizeSystem ?? this.preferredSizeSystem,
      preferredSizeValue: preferredSizeValue ?? this.preferredSizeValue,
      updatedAt: DateTime.now(),
    );
  }
}
