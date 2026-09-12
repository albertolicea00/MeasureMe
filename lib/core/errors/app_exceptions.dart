/// Thrown when a health platform (HealthKit / Health Connect) permission
/// is missing or was denied.
class HealthPermissionDeniedException implements Exception {
  final String message;
  const HealthPermissionDeniedException(this.message);
  @override
  String toString() => message;
}

/// Thrown when the requested health platform isn't available on this
/// device/OS version at all (e.g. Health Connect not installed).
class HealthUnavailableException implements Exception {
  final String message;
  const HealthUnavailableException(this.message);
  @override
  String toString() => message;
}

/// Thrown when a specific measurement type has no corresponding data type
/// on the target health platform — this is an expected, handled case, not
/// a bug (§15, §16, implementation rule 4).
class HealthTypeUnsupportedException implements Exception {
  final String message;
  const HealthTypeUnsupportedException(this.message);
  @override
  String toString() => message;
}

/// Thrown when a local notification could not be scheduled (§32).
class NotificationSchedulingException implements Exception {
  final String message;
  const NotificationSchedulingException(this.message);
  @override
  String toString() => message;
}
