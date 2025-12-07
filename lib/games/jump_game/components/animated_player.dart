import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../pro_jump_game.dart';
import 'advanced_obstacle.dart';
import 'advanced_platform.dart';

enum PlayerState { idle, running, jumping, falling, dead }

class Player extends PositionComponent with HasGameReference<JumpGame>, CollisionCallbacks {
  final double gravity;
  final double jumpVelocity;
  final double doubleJumpVelocity;
  static const double playerWidth = 55.0;
  static const double playerHeight = 65.0;
  
  double velocityY = 0;
  bool isOnGround = false;
  bool canDoubleJump = false;
  bool hasDoubleJumped = false;
  bool hasShield = false;
  double shieldTimer = 0;
  
  Vector2 initialPosition = Vector2.zero();
  PlayerState state = PlayerState.running;
  
  // Animasyon değişkenleri
  double animationTime = 0;
  double runCycle = 0;
  double squashStretch = 1.0;
  double targetSquash = 1.0;
  double eyeBlinkTimer = 0;
  bool isBlinking = false;
  double jumpRotation = 0;
  
  // Partikül efektleri için
  final List<JumpParticle> particles = [];
  final List<TrailParticle> trail = [];

  Player({
    required Vector2 position,
    double? jumpForce,
    double? gravity,
  }) : jumpVelocity = -(jumpForce ?? 600.0),
       doubleJumpVelocity = -((jumpForce ?? 600.0) * 0.85),
       gravity = gravity ?? 1200.0,
       super(
         position: position, 
         size: Vector2(playerWidth, playerHeight),
         anchor: Anchor.bottomCenter,
       ) {
    initialPosition = position.clone();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(
      size: Vector2(playerWidth * 0.7, playerHeight * 0.9),
      position: Vector2(playerWidth * 0.15, playerHeight * 0.05),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    animationTime += dt;
    runCycle += dt * 12;
    
    // Göz kırpma
    eyeBlinkTimer += dt;
    if (eyeBlinkTimer > 3 + Random().nextDouble() * 2) {
      isBlinking = true;
      eyeBlinkTimer = 0;
    }
    if (isBlinking && eyeBlinkTimer > 0.15) {
      isBlinking = false;
    }
    
    // Squash & Stretch animasyonu
    squashStretch += (targetSquash - squashStretch) * dt * 15;
    targetSquash += (1.0 - targetSquash) * dt * 8;
    
    // Kalkan zamanlaması
    if (hasShield) {
      shieldTimer -= dt;
      if (shieldTimer <= 0) {
        hasShield = false;
      }
    }
    
    // Yerçekimi
    velocityY += gravity * dt;
    position.y += velocityY * dt;
    
    // Durum güncelleme
    if (state != PlayerState.dead) {
      if (velocityY < -50) {
        state = PlayerState.jumping;
        jumpRotation = min(jumpRotation + dt * 8, 0.3);
      } else if (velocityY > 50) {
        state = PlayerState.falling;
        jumpRotation = max(jumpRotation - dt * 5, -0.2);
      } else if (isOnGround) {
        state = PlayerState.running;
        jumpRotation *= 0.9;
      }
    }
    
    // Yer kontrolü
    if (position.y >= game.size.y - 100) {
      position.y = game.size.y - 100;
      if (velocityY > 100) {
        targetSquash = 0.7; // Yere iniş squash
        _spawnLandingParticles();
      }
      velocityY = 0;
      isOnGround = true;
      hasDoubleJumped = false;
    }
    
    // Trail efekti
    if (state == PlayerState.jumping || state == PlayerState.falling) {
      if (animationTime % 0.05 < dt) {
        trail.add(TrailParticle(
          position: position.clone() - Vector2(0, size.y / 2),
          alpha: 0.6,
        ));
      }
    }
    
    // Trail güncelleme
    trail.removeWhere((p) {
      p.alpha -= dt * 3;
      return p.alpha <= 0;
    });
    
    // Partikülleri güncelle
    particles.removeWhere((p) {
      p.update(dt);
      return p.isDead;
    });
  }

  void jump() {
    if (state == PlayerState.dead) return;
    
    if (isOnGround) {
      velocityY = jumpVelocity;
      isOnGround = false;
      targetSquash = 1.4; // Zıplama stretch
      _spawnJumpParticles();
      game.onPlayerJump();
    } else if (canDoubleJump && !hasDoubleJumped) {
      velocityY = doubleJumpVelocity;
      hasDoubleJumped = true;
      targetSquash = 1.3;
      _spawnDoubleJumpParticles();
      game.onPlayerJump();
    }
  }
  
  void _spawnJumpParticles() {
    for (int i = 0; i < 8; i++) {
      particles.add(JumpParticle(
        position: position.clone(),
        velocity: Vector2(
          (Random().nextDouble() - 0.5) * 150,
          -Random().nextDouble() * 100 - 50,
        ),
        color: Colors.white,
        size: 4 + Random().nextDouble() * 4,
      ));
    }
  }
  
  void _spawnLandingParticles() {
    for (int i = 0; i < 6; i++) {
      particles.add(JumpParticle(
        position: position.clone(),
        velocity: Vector2(
          (Random().nextDouble() - 0.5) * 200,
          -Random().nextDouble() * 50 - 20,
        ),
        color: Colors.brown.shade300,
        size: 3 + Random().nextDouble() * 3,
      ));
    }
  }
  
  void _spawnDoubleJumpParticles() {
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * pi * 2;
      particles.add(JumpParticle(
        position: position.clone() - Vector2(0, size.y / 2),
        velocity: Vector2(cos(angle) * 100, sin(angle) * 100),
        color: Colors.cyan.shade300,
        size: 5 + Random().nextDouble() * 3,
      ));
    }
  }
  
  void activateShield(double duration) {
    hasShield = true;
    shieldTimer = duration;
  }
  
  void activateDoubleJump() {
    canDoubleJump = true;
  }

  void reset() {
    position = initialPosition.clone();
    velocityY = 0;
    isOnGround = false;
    state = PlayerState.running;
    hasShield = false;
    shieldTimer = 0;
    hasDoubleJumped = false;
    jumpRotation = 0;
    particles.clear();
    trail.clear();
  }
  
  void die() {
    if (hasShield) {
      hasShield = false;
      shieldTimer = 0;
      // Kalkan kırılma efekti
      for (int i = 0; i < 20; i++) {
        final angle = (i / 20) * pi * 2;
        particles.add(JumpParticle(
          position: position.clone() - Vector2(0, size.y / 2),
          velocity: Vector2(cos(angle) * 150, sin(angle) * 150),
          color: Colors.cyan,
          size: 6,
        ));
      }
      return;
    }
    state = PlayerState.dead;
    game.gameOver();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    
    if (other is AdvancedObstacle && state != PlayerState.dead) {
      die();
    } else if (other is AdvancedPlatform) {
      if (velocityY > 0) {
        position.y = other.position.y;
        velocityY = 0;
        isOnGround = true;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Trail çiz
    for (var t in trail) {
      canvas.drawCircle(
        Offset(t.position.x - position.x + size.x / 2, 
               t.position.y - position.y + size.y),
        8,
        Paint()..color = Colors.cyan.withValues(alpha: t.alpha * 0.5),
      );
    }
    
    // Partikülleri çiz
    for (var p in particles) {
      canvas.drawCircle(
        Offset(p.position.x - position.x + size.x / 2, 
               p.position.y - position.y + size.y),
        p.size,
        Paint()..color = p.color.withValues(alpha: p.alpha),
      );
    }
    
    canvas.save();
    canvas.translate(size.x / 2, size.y);
    canvas.rotate(jumpRotation);
    canvas.scale(1 / squashStretch, squashStretch);
    canvas.translate(-size.x / 2, -size.y);
    
    _drawCharacter(canvas);
    
    canvas.restore();
    
    // Kalkan efekti
    if (hasShield) {
      _drawShield(canvas);
    }
  }
  
  void _drawCharacter(Canvas canvas) {
    final bodyColor = state == PlayerState.dead 
        ? Colors.grey 
        : const Color(0xFF5c6bc0);
    final bodyDarkColor = state == PlayerState.dead 
        ? Colors.grey.shade700 
        : const Color(0xFF3949ab);
    
    // Gölge
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y + 2),
        width: size.x * 0.8,
        height: 10,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.3),
    );
    
    // Bacaklar (koşma animasyonu)
    final legOffset = sin(runCycle) * 8;
    final legPaint = Paint()..color = bodyDarkColor;
    
    // Sol bacak
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.x * 0.2, 
          size.y - 20 + (isOnGround ? legOffset : 0), 
          12, 
          20
        ),
        const Radius.circular(6),
      ),
      legPaint,
    );
    
    // Sağ bacak
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.x * 0.55, 
          size.y - 20 + (isOnGround ? -legOffset : 0), 
          12, 
          20
        ),
        const Radius.circular(6),
      ),
      legPaint,
    );
    
    // Gövde
    final bodyPath = Path();
    bodyPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(size.x * 0.1, size.y * 0.25, size.x * 0.8, size.y * 0.55),
      const Radius.circular(15),
    ));
    
    // Gövde gradient
    final bodyGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [bodyColor, bodyDarkColor],
    );
    
    canvas.drawPath(
      bodyPath,
      Paint()..shader = bodyGradient.createShader(
        Rect.fromLTWH(0, 0, size.x, size.y),
      ),
    );
    
    // Göğüs detayı
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.25, size.y * 0.4, size.x * 0.5, size.y * 0.25),
        const Radius.circular(10),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.2),
    );
    
    // Kafa
    final headRect = Rect.fromLTWH(size.x * 0.05, 0, size.x * 0.9, size.y * 0.45);
    canvas.drawRRect(
      RRect.fromRectAndRadius(headRect, const Radius.circular(20)),
      Paint()..shader = bodyGradient.createShader(headRect),
    );
    
    // Kulaklar
    canvas.drawCircle(
      Offset(size.x * 0.1, size.y * 0.12),
      8,
      Paint()..color = bodyColor,
    );
    canvas.drawCircle(
      Offset(size.x * 0.9, size.y * 0.12),
      8,
      Paint()..color = bodyColor,
    );
    canvas.drawCircle(
      Offset(size.x * 0.1, size.y * 0.12),
      4,
      Paint()..color = Colors.pink.shade200,
    );
    canvas.drawCircle(
      Offset(size.x * 0.9, size.y * 0.12),
      4,
      Paint()..color = Colors.pink.shade200,
    );
    
    // Gözler
    final eyeY = size.y * 0.18;
    final eyeHeight = isBlinking ? 2.0 : 14.0;
    
    // Sol göz beyazı
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x * 0.35, eyeY),
        width: 16,
        height: eyeHeight,
      ),
      Paint()..color = Colors.white,
    );
    
    // Sağ göz beyazı
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x * 0.65, eyeY),
        width: 16,
        height: eyeHeight,
      ),
      Paint()..color = Colors.white,
    );
    
    if (!isBlinking) {
      // Göz bebekleri
      final pupilOffset = state == PlayerState.jumping ? -2.0 : 2.0;
      canvas.drawCircle(
        Offset(size.x * 0.35 + 2, eyeY + pupilOffset),
        5,
        Paint()..color = Colors.black,
      );
      canvas.drawCircle(
        Offset(size.x * 0.65 + 2, eyeY + pupilOffset),
        5,
        Paint()..color = Colors.black,
      );
      
      // Göz parlaması
      canvas.drawCircle(
        Offset(size.x * 0.33, eyeY - 2),
        2,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(size.x * 0.63, eyeY - 2),
        2,
        Paint()..color = Colors.white,
      );
    }
    
    // Ağız
    if (state == PlayerState.dead) {
      // Üzgün ağız
      final mouthPath = Path();
      mouthPath.moveTo(size.x * 0.3, size.y * 0.38);
      mouthPath.quadraticBezierTo(
        size.x * 0.5, size.y * 0.32,
        size.x * 0.7, size.y * 0.38,
      );
      canvas.drawPath(
        mouthPath,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    } else if (state == PlayerState.jumping) {
      // Mutlu ağız
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(size.x * 0.5, size.y * 0.32),
          width: 20,
          height: 14,
        ),
        0,
        pi,
        false,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    } else {
      // Normal ağız
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(size.x * 0.5, size.y * 0.34),
          width: 16,
          height: 8,
        ),
        0,
        pi,
        false,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    
    // Yanaklar
    canvas.drawCircle(
      Offset(size.x * 0.2, size.y * 0.28),
      6,
      Paint()..color = Colors.pink.shade200.withValues(alpha: 0.6),
    );
    canvas.drawCircle(
      Offset(size.x * 0.8, size.y * 0.28),
      6,
      Paint()..color = Colors.pink.shade200.withValues(alpha: 0.6),
    );
  }
  
  void _drawShield(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final radius = max(size.x, size.y) * 0.8;
    
    // Kalkan parlaması
    for (int i = 3; i > 0; i--) {
      canvas.drawCircle(
        center,
        radius + i * 5,
        Paint()
          ..color = Colors.cyan.withValues(alpha: 0.1 * (shieldTimer % 1))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
    
    // Ana kalkan
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.cyan.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill,
    );
    
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.cyan
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }
}

class JumpParticle {
  Vector2 position;
  Vector2 velocity;
  Color color;
  double size;
  double alpha = 1.0;
  double gravity = 300;
  
  bool get isDead => alpha <= 0;
  
  JumpParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
  });
  
  void update(double dt) {
    position += velocity * dt;
    velocity.y += gravity * dt;
    alpha -= dt * 2;
    size *= 0.98;
  }
}

class TrailParticle {
  Vector2 position;
  double alpha;
  
  TrailParticle({required this.position, required this.alpha});
}
