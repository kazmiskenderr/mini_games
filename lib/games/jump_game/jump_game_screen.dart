import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'jump_game.dart';

class JumpGameScreen extends StatefulWidget {
  const JumpGameScreen({super.key});

  @override
  State<JumpGameScreen> createState() => _JumpGameScreenState();
}

class _JumpGameScreenState extends State<JumpGameScreen> {
  late final JumpGame game;

  @override
  void initState() {
    super.initState();
    game = JumpGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'GameOver': (context, game) => GameOverOverlay(
                    game: game as JumpGame,
                    onRestart: () {
                      game.restartGame();
                    },
                  ),
            },
          ),
          Positioned(
            top: 50,
            left: 20,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ValueListenableBuilder<int>(
                  valueListenable: game.scoreNotifier,
                  builder: (context, score, _) {
                    return Text(
                      'Skor: $score',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  final JumpGame game;
  final VoidCallback onRestart;

  const GameOverOverlay({
    super.key,
    required this.game,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.sentiment_dissatisfied,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 20),
              const Text(
                'Oyun Bitti!',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Skorun: ${game.score}',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: onRestart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Tekrar Oyna',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Ana Menüye Dön',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
