import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../models/record_file_info.dart';

class RecordFilePlayer extends StatefulWidget {
  const RecordFilePlayer({super.key, required this.fileInfo});

  final RecordFileInfo fileInfo;

  @override
  State<StatefulWidget> createState() => _RecordFilePlayerState();
}

class _RecordFilePlayerState extends State<RecordFilePlayer> {
  final AudioPlayer _player = AudioPlayer();

  final ValueNotifier<Duration> _durationListenable =
      ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> _positionListenable =
      ValueNotifier(Duration.zero);

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

  void _subscribeStreams() {
    _durationSubscription = _player.onDurationChanged.listen((duration) {
      _durationListenable.value = duration;
    });
    _positionSubscription = _player.onPositionChanged.listen((position) {
      _positionListenable.value = position;
    });
  }

  void _playRecordFile() {
    final Source source = DeviceFileSource(widget.fileInfo.path);
    _player.play(source);
  }

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _subscribeStreams();
    _playRecordFile();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
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
      valueListenable: _durationListenable,
      builder: (context, duration, _) {
        return ValueListenableBuilder(
          valueListenable: _positionListenable,
          builder: (context, position, _) {
            final int positionMillis = _positionListenable.value.inMilliseconds;
            final int durationMillis = _durationListenable.value.inMilliseconds;
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
    _durationListenable.dispose();
    _positionListenable.dispose();
    _player.dispose();
    super.dispose();
  }
}
