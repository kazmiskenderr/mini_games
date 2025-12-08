class MoveRecord {
  final int fromIndex;
  final int toIndex;
  final int moved;
  final DateTime timestamp;

  MoveRecord({required this.fromIndex, required this.toIndex, this.moved = 1, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'from': fromIndex,
        'to': toIndex,
        'moved': moved,
        'ts': timestamp.millisecondsSinceEpoch,
      };

  factory MoveRecord.fromJson(Map<String, dynamic> json) => MoveRecord(
        fromIndex: json['from'] as int,
        toIndex: json['to'] as int,
        moved: (json['moved'] as num?)?.toInt() ?? 1,
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['ts'] as int? ?? 0),
      );
}
