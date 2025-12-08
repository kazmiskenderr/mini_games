import 'package:flutter/material.dart';
import '../screens/menu/menu_screen.dart';
import '../screens/level_select/level_select_screen.dart';
import '../screens/game/game_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/pro_home_screen.dart';
import '../models/level_model.dart';
import 'game_router.dart';

class ColorRoutes {
  static const home = '/';
  static const colorTubeMenu = '/color-tube';
  static const levels = '/levels';
  static const game = '/game';
  static const settings = '/settings';
  
  // Eski oyun rotaları
  static const jumpGamePreview = GameRoutes.jumpGamePreview;
  static const dartGamePreview = GameRoutes.dartGamePreview;
  static const jumpGame = GameRoutes.jumpGame;
  static const dartGame = GameRoutes.dartGame;

  static Route<dynamic> onGenerate(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case colorTubeMenu:
        return MaterialPageRoute(builder: (_) => const MenuScreen());
      case levels:
        return MaterialPageRoute(builder: (_) => const LevelSelectScreen());
      case game:
        final level = routeSettings.arguments as LevelModel;
        return MaterialPageRoute(builder: (_) => GameScreen(level: level));
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      // Eski oyun rotalarını GameRoutes üzerinden handle et
      default:
        return GameRoutes.generateRoute(routeSettings);
    }
  }
}
