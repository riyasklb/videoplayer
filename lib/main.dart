import 'package:chat_application/service/auth_service.dart';
import 'package:chat_application/service/navigation_service.dart';
import 'package:chat_application/utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:screen_protector/screen_protector.dart';

void main() async {
  await setup();
  runApp(MyApp());
}

Future<void> setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupfirebase();
  await registerservice();
  await ScreenProtector.protectDataLeakageOn();
  await ScreenProtector.preventScreenshotOn();


  await ScreenProtector.protectDataLeakageWithColor(Colors.black);
}

class MyApp extends StatelessWidget {
  final GetIt getIt = GetIt.instance;

  late NavigationService _navigationService;
  late AuthService _authService;
  MyApp({super.key}) {
    _navigationService = getIt.get<NavigationService>();
    _authService = getIt.get<AuthService>();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigationService.navigatorkey,
      title: 'videoplayer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: _authService.user != null ? "/playscreen" : "/login",
      routes: _navigationService.routes,
    );
  }
}
