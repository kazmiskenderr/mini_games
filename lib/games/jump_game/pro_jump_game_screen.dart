import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pro_jump_game.dart';
import 'services/game_settings.dart';

class ProJumpGameScreen extends StatefulWidget {
  final GameDifficulty difficulty;
  
  const ProJumpGameScreen({
    super.key, 
    this.difficulty = GameDifficulty.medium,
  });

  @override
  State<ProJumpGameScreen> createState() => _ProJumpGameScreenState();
}

class _ProJumpGameScreenState extends State<ProJumpGameScreen> with TickerProviderStateMixin {
  late final JumpGame game;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  
  @override
  void initState() {
    super.initState();
    game = JumpGame(difficulty: widget.difficulty);
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Oyun
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'GameOver': (context, game) => ProGameOverOverlay(
                game: game as JumpGame,
                onRestart: () => (game).restartGame(),
                onHome: () => Navigator.pop(context),
              ),
            },
          ),
          
          // Üst UI
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _slideController,
                  curve: Curves.easeOutBack,
                )),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Geri butonu
                      _buildGlassButton(
                        icon: Icons.arrow_back_ios_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      
                      // Skor
                      _buildScoreDisplay(),
                      
                      // Yüksek skor
                      _buildHighScoreDisplay(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Combo göstergesi
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: ValueListenableBuilder<int>(
                valueListenable: game.comboNotifier,
                builder: (context, combo, _) {
                  if (combo < 2) return const SizedBox.shrink();
                  
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.5, end: 1.0),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.shade400,
                                Colors.red.shade400,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withValues(alpha: 0.5),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Text(
                            '${combo}x COMBO!',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 16,
                              color: Colors.white,
                              shadows: [
                                const Shadow(
                                  color: Colors.black54,
                                  offset: Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          
          // Power-up mesajı
          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: Center(
              child: ValueListenableBuilder<String?>(
                valueListenable: game.powerUpMessageNotifier,
                builder: (context, message, _) {
                  if (message == null) return const SizedBox.shrink();
                  
                  return ValueListenableBuilder<Color>(
                    valueListenable: game.powerUpColorNotifier,
                    builder: (context, color, _) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Text(
                                message,
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
  
  Widget _buildScoreDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade700.withValues(alpha: 0.8),
            Colors.purple.shade700.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: Colors.amber,
            size: 24,
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<int>(
            valueListenable: game.scoreNotifier,
            builder: (context, score, _) {
              return Text(
                '$score',
                style: GoogleFonts.pressStart2p(
                  fontSize: 16,
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      color: Colors.black54,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildHighScoreDisplay() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.amber.withValues(alpha: 0.3 + _pulseController.value * 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events_rounded,
                color: Colors.amber.shade400,
                size: 20,
              ),
              const SizedBox(width: 6),
              ValueListenableBuilder<int>(
                valueListenable: game.highScoreNotifier,
                builder: (context, highScore, _) {
                  return Text(
                    '$highScore',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 12,
                      color: Colors.amber.shade300,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProGameOverOverlay extends StatefulWidget {
  final JumpGame game;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const ProGameOverOverlay({
    super.key,
    required this.game,
    required this.onRestart,
    required this.onHome,
  });

  @override
  State<ProGameOverOverlay> createState() => _ProGameOverOverlayState();
}

class _ProGameOverOverlayState extends State<ProGameOverOverlay> 
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _starController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  bool isNewHighScore = false;
  
  @override
  void initState() {
    super.initState();
    
    isNewHighScore = widget.game.score >= widget.game.highScoreNotifier.value &&
                     widget.game.score > 0;
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _starController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Container(
          color: Colors.black.withValues(alpha: _fadeAnimation.value * 0.8),
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                margin: const EdgeInsets.all(30),
                padding: const EdgeInsets.all(35),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.indigo.shade900,
                      Colors.purple.shade900,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isNewHighScore 
                        ? Colors.amber.withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.2),
                    width: isNewHighScore ? 3 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isNewHighScore 
                          ? Colors.amber.withValues(alpha: 0.4)
                          : Colors.purple.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Başlık
                    if (isNewHighScore) ...[
                      _buildNewHighScoreBadge(),
                      const SizedBox(height: 15),
                    ],
                    
                    Text(
                      'OYUN BİTTİ',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 24,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.purple.shade400,
                            offset: const Offset(3, 3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Skor kartı
                    _buildScoreCard(),
                    
                    const SizedBox(height: 25),
                    
                    // İstatistikler
                    _buildStats(),
                    
                    const SizedBox(height: 35),
                    
                    // Butonlar
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildButton(
                          icon: Icons.home_rounded,
                          label: 'ANA MENÜ',
                          color: Colors.grey.shade700,
                          onTap: widget.onHome,
                        ),
                        const SizedBox(width: 15),
                        _buildButton(
                          icon: Icons.refresh_rounded,
                          label: 'TEKRAR',
                          color: Colors.green.shade600,
                          onTap: widget.onRestart,
                          isPrimary: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildNewHighScoreBadge() {
    return AnimatedBuilder(
      animation: _starController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.shade400,
                Colors.orange.shade500,
                Colors.amber.shade400,
              ],
              stops: [
                0,
                0.5 + sin(_starController.value * pi * 2) * 0.3,
                1,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.6),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'YENİ REKOR!',
                style: GoogleFonts.pressStart2p(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildScoreCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.star_rounded,
            color: Colors.amber,
            size: 50,
          ),
          const SizedBox(height: 10),
          Text(
            '${widget.game.score}',
            style: GoogleFonts.pressStart2p(
              fontSize: 36,
              color: Colors.white,
              shadows: [
                const Shadow(
                  color: Colors.black38,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'PUAN',
            style: GoogleFonts.pressStart2p(
              fontSize: 10,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStats() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatItem(
          icon: Icons.emoji_events_rounded,
          value: '${widget.game.highScoreNotifier.value}',
          label: 'EN İYİ',
          color: Colors.amber,
        ),
        const SizedBox(width: 30),
        _buildStatItem(
          icon: Icons.timer_rounded,
          value: '${widget.game.gameTime.toInt()}s',
          label: 'SÜRE',
          color: Colors.cyan,
        ),
      ],
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 5),
        Text(
          value,
          style: GoogleFonts.pressStart2p(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: GoogleFonts.pressStart2p(
            fontSize: 8,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }
  
  Widget _buildButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          gradient: isPrimary 
              ? LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                )
              : null,
          color: isPrimary ? null : color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isPrimary 
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.pressStart2p(
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
