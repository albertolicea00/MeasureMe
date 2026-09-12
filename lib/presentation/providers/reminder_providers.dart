import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reminder.dart';
import 'repository_providers.dart';

final remindersProvider = StreamProvider<List<Reminder>>((ref) {
  return ref.watch(reminderRepositoryProvider).watchAll();
});
