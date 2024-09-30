class ReadingSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;

  ReadingSession({
    required this.id,
    required this.startTime,
    this.endTime,
  });

  Duration get duration {
    return (endTime ?? DateTime.now()).difference(startTime);
  }

  ReadingSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return ReadingSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}