import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/clothing_repository_impl.dart';
import '../../data/repositories/goal_repository_impl.dart';
import '../../data/repositories/measurement_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../data/repositories/shoe_repository_impl.dart';
import '../../domain/repositories/clothing_repository.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../domain/repositories/measurement_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/repositories/shoe_repository.dart';
import 'database_provider.dart';

final measurementRepositoryProvider = Provider<MeasurementRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return MeasurementRepositoryImpl(db.measurementDao);
});

final clothingRepositoryProvider = Provider<ClothingRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ClothingRepositoryImpl(db.clothingDao);
});

final shoeRepositoryProvider = Provider<ShoeRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ShoeRepositoryImpl(db.shoeDao);
});

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ReminderRepositoryImpl(db.reminderDao);
});

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return GoalRepositoryImpl(db.goalDao);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ProfileRepositoryImpl(db, db.profileDao);
});
