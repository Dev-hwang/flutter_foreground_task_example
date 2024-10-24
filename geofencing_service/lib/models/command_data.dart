class CommandData {
  const CommandData({
    required this.command,
    this.data = const {},
  });

  final Command command;
  final Object? data;

  factory CommandData.fromJson(Map<String, dynamic> json) {
    return CommandData(
      command: Command.fromRawValue(json['command']),
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'command': command.rawValue,
      'data': data,
    };
  }

  static bool containsCommand(Object data) {
    if (data is! Map<String, dynamic>) {
      return false;
    }
    return data.containsKey('command');
  }
}

enum Command {
  addRegion(1),
  removeRegionById(2),
  clearRegions(3);

  final int rawValue;

  const Command(this.rawValue);

  factory Command.fromRawValue(int rawValue) =>
      Command.values.firstWhere((e) => e.rawValue == rawValue);
}
