import 'color_unit.dart';

class TubeModel {
  final int capacity;
  final List<ColorUnit> units;

  TubeModel({this.capacity = 4, List<ColorUnit>? units}) : units = units ?? [];

  bool get isEmpty => units.isEmpty;
  bool get isFull => units.length >= capacity;
  int get availableSpace => capacity - units.length;
  ColorUnit? get top => isEmpty ? null : units.last;

  bool get isUniform {
    if (isEmpty) return true;
    final first = units.first.color;
    return units.length == capacity && units.every((u) => u.color == first);
  }

  bool canPourInto(TubeModel target) {
    if (isEmpty || target.isFull) return false;
    if (target.isEmpty) return true;
    return target.top?.color == top?.color;
  }

  /// Moves contiguous top units into target; returns moved count.
  int pourInto(TubeModel target) {
    if (!canPourInto(target)) return 0;
    final sourceColor = top!.color;
    var moved = 0;
    while (!isEmpty && top!.color == sourceColor && !target.isFull) {
      target.units.add(units.removeLast());
      moved++;
    }
    return moved;
  }

  TubeModel copy() => TubeModel(
        capacity: capacity,
        units: units.map((e) => ColorUnit(e.color)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'capacity': capacity,
        'units': units.map((e) => e.toJson()).toList(),
      };

  factory TubeModel.fromJson(Map<String, dynamic> json) => TubeModel(
        capacity: json['capacity'] as int,
        units: (json['units'] as List<dynamic>)
            .map((e) => ColorUnit.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
