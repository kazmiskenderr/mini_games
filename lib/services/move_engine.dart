import '../models/game_state.dart';
import '../models/move_record.dart';
import '../models/tube_model.dart';

class MoveEngine {
  bool canMove(GameState state, int from, int to) {
    if (from == to) return false;
    if (from < 0 || to < 0 || from >= state.tubes.length || to >= state.tubes.length) {
      return false;
    }
    final source = state.tubes[from];
    final target = state.tubes[to];
    return source.canPourInto(target);
  }

  GameState applyMove(GameState state, int from, int to) {
    if (!canMove(state, from, to)) return state;
    final tubes = state.tubes.map((t) => t.copy()).toList();
    final moved = tubes[from].pourInto(tubes[to]);
    if (moved == 0) return state;

    final history = List<MoveRecord>.from(state.history)
      ..add(MoveRecord(fromIndex: from, toIndex: to, moved: moved));

    return state.copyWith(
      tubes: tubes,
      moves: state.moves + 1,
      history: history,
      isCompleted: tubes.every((t) => t.isEmpty || t.isUniform),
    );
  }

  GameState undo(GameState state) {
    if (state.history.isEmpty) return state;
    final tubes = state.tubes.map((t) => t.copy()).toList();
    final history = List<MoveRecord>.from(state.history);
    final last = history.removeLast();

    final target = tubes[last.toIndex];
    final source = tubes[last.fromIndex];
    for (var i = 0; i < last.moved; i++) {
      if (target.isEmpty) break;
      source.units.add(target.units.removeLast());
    }

    final moves = (state.moves - 1).clamp(0, 1 << 30);
    return state.copyWith(
      tubes: tubes,
      moves: moves,
      history: history,
      isCompleted: false,
    );
  }

  GameState restart(GameState state) {
    return restartWith(state, state.tubes);
  }

  GameState restartWith(GameState state, List<TubeModel> seedTubes) {
    final tubes = seedTubes.map((t) => t.copy()).toList();
    return GameState(
      levelId: state.levelId,
      tubes: tubes,
      moves: 0,
      history: const [],
      isCompleted: false,
      hintsUsed: 0,
      elapsed: Duration.zero,
    );
  }
}
