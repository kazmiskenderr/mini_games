import '../models/game_state.dart';
import '../models/move_record.dart';
import 'move_engine.dart';

class HintService {
  final MoveEngine _engine;
  HintService(this._engine);

  MoveRecord? firstHint(GameState state) {
    for (var from = 0; from < state.tubes.length; from++) {
      for (var to = 0; to < state.tubes.length; to++) {
        if (_engine.canMove(state, from, to)) {
          return MoveRecord(fromIndex: from, toIndex: to);
        }
      }
    }
    return null;
  }
}
