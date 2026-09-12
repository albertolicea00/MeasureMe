import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/data_export_service.dart';
import 'repository_providers.dart';

final dataExportServiceProvider = Provider<DataExportService>((ref) {
  return DataExportService(
    measurementRepository: ref.watch(measurementRepositoryProvider),
    clothingRepository: ref.watch(clothingRepositoryProvider),
    shoeRepository: ref.watch(shoeRepositoryProvider),
  );
});
