import '../core/storage/progress_storage.dart';
import '../models/player_progress.dart';

class ProgressRepository {
  final ProgressStorage storage;

  ProgressRepository({required this.storage});

  Future<PlayerProgress> load() async {
    final raw = await storage.load();
    return PlayerProgress.fromStorage(raw);
  }

  Future<void> save(PlayerProgress progress) async {
    await storage.save(progress.toStorage());
  }

  Future<PlayerProgress> markCompleted({
    required PlayerProgress current,
    required String levelId,
    required int moves,
  }) async {
    final updated = current.copyWith(
      completedLevels: {...current.completedLevels, levelId},
      highestUnlocked: current.highestUnlocked + 1,
      bestMoves: {
        ...current.bestMoves,
        levelId: current.bestMoves.containsKey(levelId)
            ? (moves < (current.bestMoves[levelId] ?? moves) ? moves : current.bestMoves[levelId]!)
            : moves,
      },
    );
    await save(updated);
    return updated;
  }

  Future<PlayerProgress> addHintUsage(PlayerProgress current) async {
    final updated = current.copyWith(totalHints: current.totalHints + 1);
    await save(updated);
    return updated;
  }

  Future<void> reset() async {
    await storage.clear();
  }
}
