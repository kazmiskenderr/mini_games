import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'router/game_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Tam ekran modu
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MiniGamesApp());
}

class MiniGamesApp extends StatelessWidget {
  const MiniGamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiniGames',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0f0f23),
      ),
      initialRoute: GameRoutes.home,
      onGenerateRoute: GameRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
