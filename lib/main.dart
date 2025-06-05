import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'utils/permissions_helper.dart';
import 'screens/main_navigator.dart';
import 'state/app_state.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestAllAppPermissions();


  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const AuraApp(),
    ),
  );
}

class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura',
      debugShowCheckedModeBanner: false,
      locale: const Locale('sr', 'RS'),
      supportedLocales: const [
        Locale('sr', 'RS'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardColor: Colors.grey[100],
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      fontFamily: 'Roboto',
    ),

      home: const MainNavigator(),
    );
  }
}
