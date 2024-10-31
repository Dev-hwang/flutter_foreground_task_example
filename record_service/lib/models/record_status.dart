enum RecordStatus {
  starting(1),
  started(2),
  stopping(3),
  stopped(4);

  final int rawValue;

  const RecordStatus(this.rawValue);

  factory RecordStatus.fromRawValue(int rawValue) =>
      RecordStatus.values.firstWhere((e) => e.rawValue == rawValue);
}
