class MyPedestrianStatus {
  const MyPedestrianStatus({
    required this.status,
    required this.timestamp,
  });

  final String status;
  final DateTime timestamp;

  static bool containsData(Map<String, dynamic> json) {
    return json.containsKey('status');
  }

  factory MyPedestrianStatus.fromJson(Map<String, dynamic> json) {
    return MyPedestrianStatus(
      status: json['status'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
