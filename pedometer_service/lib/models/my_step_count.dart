class MyStepCount {
  const MyStepCount({
    required this.steps,
    required this.timestamp,
  });

  final int steps;
  final DateTime timestamp;

  static bool containsData(Map<String, dynamic> json) {
    return json.containsKey('steps');
  }

  factory MyStepCount.fromJson(Map<String, dynamic> json) {
    return MyStepCount(
      steps: json['steps'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'steps': steps,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
