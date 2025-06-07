import 'package:core/secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:settings/settings.dart';
import 'services/ocr_service.dart';
import 'services/database_service.dart';
import 'services/contact_service.dart';
import 'services/export_service.dart';

final getIt = GetIt.instance;

void setup() {
  _setupExternalServices();
  _setupServices();
  _setupSettings();
}

void _setupServices() {
  // Register and initialize OCR service
  getIt.registerLazySingleton(() {
    final ocrService = OCRService();
    ocrService.initialize();
    return ocrService;
  });

  // Register database service
  getIt.registerLazySingleton(() => DatabaseService());

  // Register contact service
  getIt.registerLazySingleton(() => ContactService());

  // Register export service
  getIt.registerLazySingleton(() => ExportService());
}

void _setupSettings() {
  // Use cases
  getIt.registerLazySingleton(() => GetLocale(getIt()));

  getIt.registerLazySingleton(() => SaveLocale(getIt()));

  // Repositories
  getIt.registerLazySingleton<ILocaleRepository>(
      () => LocaleRepository(localDataSource: getIt()));

  // Data sources
  getIt.registerLazySingleton<ISettingsLocalDataSource>(
      () => SettingsLocalDataSource(storage: getIt()));
}

void _setupExternalServices() {
  getIt.registerLazySingleton(() => const FlutterSecureStorage());
}
