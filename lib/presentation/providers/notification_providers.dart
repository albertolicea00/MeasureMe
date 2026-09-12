import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../integrations/notifications/notification_service.dart';
import '../../integrations/notifications/notification_service_impl.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationServiceImpl();
});

/// Initializes the notification plugin exactly once. Widgets that need
/// scheduling to be ready should `await ref.watch(notificationInitProvider.future)`.
final notificationInitProvider = FutureProvider<void>((ref) async {
  await ref.watch(notificationServiceProvider).initialize();
});
