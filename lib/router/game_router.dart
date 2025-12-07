import 'package:flutter/material.dart';
import '../screens/pro_home_screen.dart';
import '../games/jump_game/pro_jump_game_screen.dart';
import '../games/jump_game/game_preview_screen.dart';
import '../games/jump_game/services/game_settings.dart';
import '../games/dart_game/dart_game_screen.dart';
import '../games/dart_game/dart_game_preview_screen.dart';

class GameRoutes {
  static const String home = '/';
  static const String jumpGame = '/jump-game';
  static const String jumpGamePreview = '/jump-game-preview';
  static const String snakeGame = '/snake-game';
  static const String dartGame = '/dart-game';
  static const String dartGamePreview = '/dart-game-preview';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case dartGamePreview:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
              const DartGamePreviewScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
      case dartGame:
        final mode = settings.arguments as DartGameMode? ?? DartGameMode.practice;
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
              DartGameScreen(mode: mode),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        );
      case jumpGamePreview:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
              const GamePreviewScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
      case jumpGame:
        final difficulty = settings.arguments as GameDifficulty? ?? GameDifficulty.medium;
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
              ProJumpGameScreen(difficulty: difficulty),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Sayfa bulunamadı: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
