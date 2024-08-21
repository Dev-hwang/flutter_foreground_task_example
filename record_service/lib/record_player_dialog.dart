import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'record_info.dart';

class RecordPlayerDialog extends StatefulWidget {
  const RecordPlayerDialog({super.key, required this.recordInfo});

  final RecordInfo recordInfo;

  @override
  State<StatefulWidget> createState() => _RecordPlayerDialogState();
}

class _RecordPlayerDialogState extends State<RecordPlayerDialog> {
  final AudioPlayer _player = AudioPlayer();

  final ValueNotifier<Duration> _duration = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> _position = ValueNotifier(Duration.zero);

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;

  void _initAudioPlayer() {
    final AudioContext audioContext = AudioContextConfig(
      route: AudioContextConfigRoute.speaker,
      focus: AudioContextConfigFocus.gain,
      respectSilence: false,
      stayAwake: true,
    ).build();
    AudioPlayer.global.setAudioContext(audioContext);
  }

  void _initStreams() {
    _durationSubscription = _player.onDurationChanged.listen((duration) {
      _duration.value = duration;
    });
    _positionSubscription = _player.onPositionChanged.listen((position) {
      _position.value = position;
    });
  }

  void _play() {
    final Source source = DeviceFileSource(widget.recordInfo.path);
    _player.play(source);
  }

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _initStreams();
    _play();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: _buildContentView(),
    );
  }

  Widget _buildContentView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildSeekBar(),
        ),
      ],
    );
  }

  Widget _buildSeekBar() {
    return ValueListenableBuilder(
      valueListenable: _duration,
      builder: (context, duration, _) {
        return ValueListenableBuilder(
          valueListenable: _position,
          builder: (context, position, _) {
            final int positionMillis = _position.value.inMilliseconds;
            final int durationMillis = _duration.value.inMilliseconds;
            final double value;
            if (positionMillis > 0 && positionMillis < durationMillis) {
              value = positionMillis / durationMillis;
            } else {
              value = 0.0;
            }

            return Slider(
              value: value,
              onChanged: (_) {
                // not implemented
              },
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _duration.dispose();
    _position.dispose();
    _player.dispose();
    super.dispose();
  }
}
