import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'components/player.dart';
import 'components/platform.dart';
import 'components/obstacle.dart';
import 'components/background.dart';

class JumpGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  late Player player;
  late Background background;
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  
  int score = 0;
  double gameSpeed = 200.0;
  double obstacleSpawnTimer = 0;
  double obstacleSpawnInterval = 2.0;
  bool isGameOver = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Background
    background = Background();
    add(background);
    
    // Ground platform
    final ground = Platform(
      position: Vector2(0, size.y - 100),
      width: size.x,
    );
    add(ground);
    
    // Player
    player = Player(
      position: Vector2(100, size.y - 200),
    );
    add(player);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (isGameOver) return;
    
    // Update score
    score += (dt * 10).toInt();
    scoreNotifier.value = score;
    
    // Increase game speed gradually
    gameSpeed += dt * 2;
    
    // Spawn obstacles
    obstacleSpawnTimer += dt;
    if (obstacleSpawnTimer >= obstacleSpawnInterval) {
      obstacleSpawnTimer = 0;
      spawnObstacle();
      
      // Gradually decrease spawn interval
      if (obstacleSpawnInterval > 1.0) {
        obstacleSpawnInterval -= 0.01;
      }
    }
  }

  void spawnObstacle() {
    final obstacle = Obstacle(
      position: Vector2(size.x + 50, size.y - 150),
      speed: gameSpeed,
    );
    add(obstacle);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isGameOver) {
      player.jump();
    } else {
      restartGame();
    }
  }

  void gameOver() {
    isGameOver = true;
    overlays.add('GameOver');
  }

  void restartGame() {
    isGameOver = false;
    score = 0;
    scoreNotifier.value = 0;
    gameSpeed = 200.0;
    obstacleSpawnInterval = 2.0;
    obstacleSpawnTimer = 0;
    
    // Remove all obstacles
    children.whereType<Obstacle>().forEach((obstacle) {
      obstacle.removeFromParent();
    });
    
    // Reset player
    player.reset();
    
    overlays.remove('GameOver');
  }
}
