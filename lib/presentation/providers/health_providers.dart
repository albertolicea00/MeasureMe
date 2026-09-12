import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../integrations/health/apple_health_service.dart';
import '../../integrations/health/health_connect_service.dart';
import '../../integrations/health/health_service.dart';
import '../../integrations/health/unsupported_health_service.dart';

/// Selects the platform-appropriate [HealthService] implementation. The
/// rest of the app depends only on the [HealthService] interface (§17).
final healthServiceProvider = Provider<HealthService>((ref) {
  if (Platform.isIOS) return AppleHealthService();
  if (Platform.isAndroid) return HealthConnectService();
  return UnsupportedHealthService();
});
