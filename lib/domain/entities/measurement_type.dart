import '../../core/constants/measurement_units.dart';

/// Body area grouping used to organize the Body Measurements screen.
enum MeasurementCategory {
  general,
  upperBody,
  waistTorso,
  lowerBody,
  custom,
}

/// Describes a *kind* of measurement (e.g. "chest", "weight") independently
/// from any recorded value. New types can be added by appending to the
/// built-in catalog or by letting a user create a custom type — the
/// database schema never needs to change to support a new type.
class MeasurementType {
  final String id;
  final String displayName;
  final MeasurementCategory category;
  final CanonicalUnit canonicalUnit;
  final String? instructions;
  final bool isCustom;
  final int sortOrder;

  const MeasurementType({
    required this.id,
    required this.displayName,
    required this.category,
    required this.canonicalUnit,
    this.instructions,
    this.isCustom = false,
    this.sortOrder = 0,
  });

  MeasurementType copyWith({
    String? displayName,
    MeasurementCategory? category,
    CanonicalUnit? canonicalUnit,
    String? instructions,
    bool? isCustom,
    int? sortOrder,
  }) {
    return MeasurementType(
      id: id,
      displayName: displayName ?? this.displayName,
      category: category ?? this.category,
      canonicalUnit: canonicalUnit ?? this.canonicalUnit,
      instructions: instructions ?? this.instructions,
      isCustom: isCustom ?? this.isCustom,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

/// Built-in measurement type catalog (§5, §35 of the product spec).
///
/// This is a *data-driven* registry, not a hard-coded schema: adding a new
/// measurement type in the future means adding one entry here (or letting a
/// user create a custom type at runtime) — no database migration required
/// for the concept of "a new kind of measurement".
class MeasurementTypeCatalog {
  MeasurementTypeCatalog._();

  static const weight = MeasurementType(
    id: 'weight',
    displayName: 'Weight',
    category: MeasurementCategory.general,
    canonicalUnit: CanonicalUnit.kilograms,
    instructions: 'Weigh yourself at a consistent time of day, ideally in the morning before eating.',
    sortOrder: 0,
  );

  static const height = MeasurementType(
    id: 'height',
    displayName: 'Height',
    category: MeasurementCategory.general,
    canonicalUnit: CanonicalUnit.centimeters,
    instructions: 'Stand fully upright against a wall without shoes.',
    sortOrder: 1,
  );

  static const bodyFatPercentage = MeasurementType(
    id: 'body_fat_percentage',
    displayName: 'Body Fat %',
    category: MeasurementCategory.general,
    canonicalUnit: CanonicalUnit.percent,
    instructions: 'Enter a value from a caliper, scale, or scan measurement.',
    sortOrder: 2,
  );

  static const neck = MeasurementType(
    id: 'neck',
    displayName: 'Neck',
    category: MeasurementCategory.upperBody,
    canonicalUnit: CanonicalUnit.centimeters,
    instructions: 'Measure around the base of your neck.',
    sortOrder: 10,
  );

  static const shoulders = MeasurementType(
    id: 'shoulders',
    displayName: 'Shoulders',
    category: MeasurementCategory.upperBody,
    canonicalUnit: CanonicalUnit.centimeters,
    instructions: 'Measure across the back from shoulder point to shoulder point.',
    sortOrder: 11,
  );

  static const chest = MeasurementType(
    id: 'chest',
    displayName: 'Chest',
    category: MeasurementCategory.upperBody,
    canonicalUnit: CanonicalUnit.centimeters,
    instructions: 'Measure around the fullest part of your chest while standing naturally.',
    sortOrder: 12,
  );

  static const upperArmLeft = MeasurementType(
    id: 'upper_arm_left',
    displayName: 'Upper Arm (Left)',
    category: MeasurementCategory.upperBody,
    canonicalUnit: CanonicalUnit.centimeters,
    instructions: 'Measure around the fullest part of your left upper arm, unflexed.',
    sortOrder: 13,
  );

  static const upperArmRight = MeasurementType(
    id: 'upper_arm_right',
    displayName: 'Upper Arm (Right)',
    category: MeasurementCategory.upperBody,
    canonicalUnit: CanonicalUnit.centimeters,
    instructions: 'Measure around the fullest part of your right upper arm, unflexed.',
    sortOrder: 14,
  );

  static const forearmLeft = MeasurementType(
    id: 'forearm_left',
    displayName: 'Forearm (Left)',
    category: MeasurementCategory.upperBody,
    canonicalUnit: CanonicalUnit.centimeters,
    instructions: 'Measure around the fullest part of your left forearm.',
    sortOrder: 15,
  );

  static const forearmRight = MeasurementType(
    id: 'forearm_right',
    displayName: 'Forearm (Right)',
    category: MeasurementCategory.upperBody,
    canonicalUnit: CanonicalUnit.centimeters,
    instructions: 'Measure around the fullest part of your right forearm.',
    sortOrder: 16,
  );

  static const waist = MeasurementType(
    id: 'waist',
    displayName: 'Waist',
    category: MeasurementCategory.waistTorso,
    canonicalUnit: CanonicalUnit.centimeters,
    instructions: 'Measure around your natural waist without pulling the tape tightly.',
    sortOrder: 20,
  );

  static const abdomen = MeasurementType(
    id: 'abdomen',
    displayName: 'Abdomen',
    category: MeasurementCategory.waistTorso,
    canonicalUnit: CanonicalUnit.centimeters,
    instructions: 'Measure around the widest part of your abdomen, at navel level.',
    sortOrder: 21,
  );

  static const hips = MeasurementType(
    id: 'hips',
    displayName: 'Hips',
    category: MeasurementCategory.waistTorso,
    canonicalUnit: CanonicalUnit.centimeters,
    instructions: 'Measure around the fullest part of your hips.',
    sortOrder: 22,
  );

  static const thighLeft = MeasurementType(
    id: 'thigh_left',
    displayName: 'Thigh (Left)',
    category: MeasurementCategory.lowerBody,
    canonicalUnit: CanonicalUnit.centimeters,
    instructions: 'Measure around the fullest part of your left thigh.',
    sortOrder: 30,
  );

  static const thighRight = MeasurementType(
    id: 'thigh_right',
    displayName: 'Thigh (Right)',
    category: MeasurementCategory.lowerBody,
    canonicalUnit: CanonicalUnit.centimeters,
    instructions: 'Measure around the fullest part of your right thigh.',
    sortOrder: 31,
  );

  static const calfLeft = MeasurementType(
    id: 'calf_left',
    displayName: 'Calf (Left)',
    category: MeasurementCategory.lowerBody,
    canonicalUnit: CanonicalUnit.centimeters,
    instructions: 'Measure around the fullest part of your left calf.',
    sortOrder: 32,
  );

  static const calfRight = MeasurementType(
    id: 'calf_right',
    displayName: 'Calf (Right)',
    category: MeasurementCategory.lowerBody,
    canonicalUnit: CanonicalUnit.centimeters,
    instructions: 'Measure around the fullest part of your right calf.',
    sortOrder: 33,
  );

  static const List<MeasurementType> builtIns = [
    weight,
    height,
    bodyFatPercentage,
    neck,
    shoulders,
    chest,
    upperArmLeft,
    upperArmRight,
    forearmLeft,
    forearmRight,
    waist,
    abdomen,
    hips,
    thighLeft,
    thighRight,
    calfLeft,
    calfRight,
  ];

  /// Measurement types shown as cards on the Home dashboard by default.
  /// "Arms" and "Thighs" are represented by the right side by convention;
  /// the full left/right breakdown lives in the Body Measurements screen.
  static const List<String> dashboardDefaultIds = [
    'weight',
    'height',
    'chest',
    'waist',
    'hips',
    'neck',
    'upper_arm_right',
    'thigh_right',
  ];

  static MeasurementType? byId(String id) {
    for (final type in builtIns) {
      if (type.id == id) return type;
    }
    return null;
  }
}
