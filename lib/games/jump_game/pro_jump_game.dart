import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'components/animated_player.dart';
import 'components/advanced_platform.dart';
import 'components/advanced_obstacle.dart';
import 'components/parallax_background.dart';
import 'components/power_up.dart';
import 'components/falling_obstacle.dart';
import 'services/score_service.dart';
import 'services/game_settings.dart';
import 'services/sound_service.dart';

class JumpGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  late Player player;
  late ParallaxBackground background;
  late ScoreService scoreService;
  late GameSoundService soundService;
  
  // Zorluk seviyesi
  final GameDifficulty difficulty;
  late DifficultyParams difficultyParams;
  
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> highScoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<String?> powerUpMessageNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<Color> powerUpColorNotifier = ValueNotifier<Color>(Colors.white);
  final ValueNotifier<int> comboNotifier = ValueNotifier<int>(0);
  
  int score = 0;
  int combo = 0;
  double comboTimer = 0;
  double gameSpeed = 250.0;
  double baseGameSpeed = 250.0;
  double obstacleSpawnTimer = 0;
  double obstacleSpawnInterval = 2.2;
  double powerUpSpawnTimer = 0;
  double powerUpSpawnInterval = 8.0;
  double fallingSpawnTimer = 0;
  double fallingSpawnInterval = 4.0;
  bool isGameOver = false;
  bool isSlowMotion = false;
  double slowMotionTimer = 0;
  double gameTime = 0;
  int jumpsWithoutLanding = 0;
  
  bool isInitialized = false;
  
  // Partikül mesajları
  final List<FloatingText> floatingTexts = [];
  
  JumpGame({this.difficulty = GameDifficulty.medium});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Zorluk parametrelerini ayarla
    difficultyParams = DifficultyParams.fromDifficulty(difficulty);
    
    // Oyun değerlerini zorluk seviyesine göre ayarla
    baseGameSpeed = difficultyParams.initialSpeed;
    gameSpeed = baseGameSpeed;
    obstacleSpawnInterval = difficultyParams.obstacleSpawnInterval;
    powerUpSpawnInterval = difficultyParams.powerUpSpawnInterval;
    
    scoreService = await ScoreService.getInstance();
    soundService = GameSoundService.instance;
    highScoreNotifier.value = scoreService.highScore;
    
    // Arka plan
    background = ParallaxBackground();
    add(background);
    
    // Zemin
    final ground = AdvancedPlatform(
      position: Vector2(0, size.y - 100),
      width: size.x,
    );
    add(ground);
    
    // Oyuncu
    player = Player(
      position: Vector2(120, size.y - 100),
      jumpForce: difficultyParams.playerJumpForce,
      gravity: difficultyParams.gravity,
    );
    add(player);
    
    isInitialized = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (!isInitialized || isGameOver) return;
    
    gameTime += dt;
    
    // Slow motion efekti
    double effectiveDt = dt;
    if (isSlowMotion) {
      effectiveDt *= 0.4;
      slowMotionTimer -= dt;
      if (slowMotionTimer <= 0) {
        isSlowMotion = false;
      }
    }
    
    // Skor güncelleme
    final scoreIncrease = (effectiveDt * 15 * (1 + combo * 0.1)).toInt();
    score += scoreIncrease;
    scoreNotifier.value = score;
    
    // Combo timer
    if (combo > 0) {
      comboTimer -= dt;
      if (comboTimer <= 0) {
        combo = 0;
        comboNotifier.value = combo;
      }
    }
    
    // Oyun hızını kademeli artır (zorluk seviyesine göre)
    if (gameTime > 5) {
      baseGameSpeed = difficultyParams.initialSpeed + (gameTime - 5) * difficultyParams.speedIncrease;
      baseGameSpeed = baseGameSpeed.clamp(difficultyParams.initialSpeed, difficultyParams.maxSpeed);
    }
    gameSpeed = isSlowMotion ? baseGameSpeed * 0.4 : baseGameSpeed;
    
    // Engel spawn
    obstacleSpawnTimer += effectiveDt;
    final adjustedInterval = obstacleSpawnInterval * (isSlowMotion ? 1.5 : 1);
    if (obstacleSpawnTimer >= adjustedInterval) {
      obstacleSpawnTimer = 0;
      _spawnObstacle();
      
      // Spawn aralığını azalt (zorluk seviyesine göre)
      if (obstacleSpawnInterval > difficultyParams.minObstacleSpawnInterval) {
        obstacleSpawnInterval -= 0.015;
      }
    }
    
    // Power-up spawn
    powerUpSpawnTimer += dt;
    if (powerUpSpawnTimer >= powerUpSpawnInterval) {
      powerUpSpawnTimer = 0;
      _spawnPowerUp();
    }
    
    // Düşen engel spawn (eğer zorluk izin veriyorsa)
    if (difficultyParams.hasFallingObstacles && gameTime > 15) {
      fallingSpawnTimer += dt;
      if (fallingSpawnTimer >= fallingSpawnInterval) {
        fallingSpawnTimer = 0;
        if (Random().nextDouble() < difficultyParams.fallingObstacleChance) {
          _spawnFallingObstacle();
        }
      }
    }
    
    // Floating text güncelleme
    floatingTexts.removeWhere((ft) {
      ft.update(dt);
      return ft.isDead;
    });
    
    // Engelleri güncelle (hız değişikliği için)
    for (var child in children) {
      if (child is AdvancedObstacle) {
        child.speed = gameSpeed;
      }
    }
  }
  
  void _spawnFallingObstacle() {
    final random = Random();
    final types = FallingType.values;
    final type = types[random.nextInt(types.length)];
    
    // Oyuncunun yakınında veya önünde spawn yap
    final targetX = player.position.x + 50 + random.nextDouble() * 200;
    
    final falling = FallingObstacle(
      position: Vector2(targetX, -50),
      type: type,
      fallSpeed: 350 + gameSpeed * 0.3,
    );
    add(falling);
  }

  void _spawnObstacle() {
    final random = Random();
    
    // Zorluk seviyesine göre mevcut engel tiplerini al
    final availableTypes = difficultyParams.getAvailableObstacles(gameTime);
    final type = availableTypes[random.nextInt(availableTypes.length)];
    
    double yPosition = size.y - 100;
    
    switch (type) {
      case ObstacleType.spike:
        yPosition -= 50;
        break;
      case ObstacleType.rock:
        yPosition -= 45;
        break;
      case ObstacleType.bird:
        yPosition = size.y - 200 - random.nextDouble() * 120;
        break;
      case ObstacleType.movingSpike:
        yPosition -= 55;
        break;
      case ObstacleType.laser:
        yPosition = size.y - 180;
        break;
    }
    
    final obstacle = AdvancedObstacle(
      position: Vector2(size.x + 60, yPosition),
      type: type,
      speed: gameSpeed,
    );
    add(obstacle);
  }

  void _spawnPowerUp() {
    final random = Random();
    final types = PowerUpType.values;
    final type = types[random.nextInt(types.length)];
    
    final powerUp = PowerUp(
      position: Vector2(
        size.x + 50,
        size.y - 180 - random.nextDouble() * 100,
      ),
      type: type,
      speed: gameSpeed * 0.8,
    );
    add(powerUp);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isInitialized) return;
    
    if (isGameOver) {
      // Restart handled by overlay
    } else {
      player.jump();
      soundService.playJump();
    }
  }
  
  void onPlayerJump() {
    jumpsWithoutLanding++;
    
    // Combo sistemi
    if (jumpsWithoutLanding > 1) {
      combo++;
      comboTimer = 2.0;
      comboNotifier.value = combo;
      
      if (combo >= 3) {
        addFloatingText('+${combo}x Combo!', player.position - Vector2(0, 50), Colors.orange);
        soundService.playCombo(combo);
      }
    }
  }
  
  void onPlayerLand() {
    jumpsWithoutLanding = 0;
  }
  
  void activateSlowMotion(double duration) {
    isSlowMotion = true;
    slowMotionTimer = duration;
  }
  
  void addBonusScore(int bonus) {
    score += bonus;
    scoreNotifier.value = score;
    addFloatingText('+$bonus', player.position - Vector2(0, 30), Colors.green);
  }
  
  void showPowerUpMessage(String message, Color color) {
    powerUpMessageNotifier.value = message;
    powerUpColorNotifier.value = color;
    soundService.playPowerUp();
    
    Future.delayed(const Duration(seconds: 2), () {
      if (powerUpMessageNotifier.value == message) {
        powerUpMessageNotifier.value = null;
      }
    });
  }
  
  void addFloatingText(String text, Vector2 position, Color color) {
    floatingTexts.add(FloatingText(
      text: text,
      position: position.clone(),
      color: color,
    ));
  }

  void gameOver() {
    if (isGameOver) return;
    
    isGameOver = true;
    soundService.playDeath();
    
    // Yüksek skor kontrolü
    scoreService.submitScore(score).then((isNewHighScore) {
      if (isNewHighScore) {
        highScoreNotifier.value = score;
      }
    });
    
    overlays.add('GameOver');
  }

  void restartGame() {
    isGameOver = false;
    score = 0;
    combo = 0;
    comboTimer = 0;
    scoreNotifier.value = 0;
    comboNotifier.value = 0;
    
    // Zorluk seviyesine göre sıfırla
    baseGameSpeed = difficultyParams.initialSpeed;
    gameSpeed = baseGameSpeed;
    obstacleSpawnInterval = difficultyParams.obstacleSpawnInterval;
    powerUpSpawnInterval = difficultyParams.powerUpSpawnInterval;
    obstacleSpawnTimer = 0;
    powerUpSpawnTimer = 0;
    fallingSpawnTimer = 0;
    gameTime = 0;
    isSlowMotion = false;
    slowMotionTimer = 0;
    jumpsWithoutLanding = 0;
    floatingTexts.clear();
    
    // Tüm engelleri kaldır
    children.whereType<AdvancedObstacle>().forEach((obstacle) {
      obstacle.removeFromParent();
    });
    
    // Tüm düşen engelleri kaldır
    children.whereType<FallingObstacle>().forEach((obstacle) {
      obstacle.removeFromParent();
    });
    
    // Tüm power-up'ları kaldır
    children.whereType<PowerUp>().forEach((powerUp) {
      powerUp.removeFromParent();
    });
    
    // Oyuncuyu sıfırla
    player.reset();
    
    overlays.remove('GameOver');
  }
}

class FloatingText {
  String text;
  Vector2 position;
  Color color;
  double alpha = 1.0;
  double scale = 0.5;
  
  bool get isDead => alpha <= 0;
  
  FloatingText({
    required this.text,
    required this.position,
    required this.color,
  });
  
  void update(double dt) {
    position.y -= 50 * dt;
    alpha -= dt * 0.8;
    scale = (scale + dt * 2).clamp(0.5, 1.2);
  }
}
