/// Health-store-agnostic metrics MeasureMe knows how to sync. Not every
/// metric is supported by every platform/OS version — see
/// [HealthService.supportedMetrics] (§15, §16, implementation rule 4).
enum HealthMetric { weight, height, bodyFatPercentage }

extension HealthMetricMeasurementType on HealthMetric {
  /// The corresponding [MeasurementType] id in this app's own catalog.
  String get measurementTypeId {
    switch (this) {
      case HealthMetric.weight:
        return 'weight';
      case HealthMetric.height:
        return 'height';
      case HealthMetric.bodyFatPercentage:
        return 'body_fat_percentage';
    }
  }

  String get label {
    switch (this) {
      case HealthMetric.weight:
        return 'Weight';
      case HealthMetric.height:
        return 'Height';
      case HealthMetric.bodyFatPercentage:
        return 'Body Fat %';
    }
  }
}
