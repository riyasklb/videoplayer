import 'package:chat_application/firebase_options.dart';
import 'package:chat_application/service/alert_service.dart';
import 'package:chat_application/service/auth_service.dart';
import 'package:chat_application/service/database_service.dart';
import 'package:chat_application/service/media_service%20.dart';
import 'package:chat_application/service/navigation_service.dart';
import 'package:chat_application/service/storge_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

Future<void> setupfirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // await FirebaseAppCheck.instance.activate(
  //   androidProvider: AppCheckProvider.debug,
  //   webRecaptchaSiteKey: 'your-web-recaptcha-site-key',
  // );
}

Future<void> registerservice() async {
  final GetIt getIt = GetIt.instance;
  getIt.registerSingleton<AuthService>(
    AuthService(),
  );

  getIt.registerSingleton<NavigationService>(
    NavigationService(),
  );

  getIt.registerSingleton<AlertService>(
    AlertService(),
  );

  getIt.registerSingleton<MediaService>(
    MediaService(),
  );

  getIt.registerSingleton<StorgeService>(
    StorgeService(),
  );

  getIt.registerSingleton<DatabaseService>(
    DatabaseService(),
  );
}
