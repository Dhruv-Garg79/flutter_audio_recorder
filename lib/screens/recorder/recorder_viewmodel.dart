import 'dart:io';

import 'package:audio_recorder/models/audio_model.dart';
import 'package:audio_recorder/utils/app_logger.dart';
import 'package:audio_recorder/utils/helper.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:stacked/stacked.dart';

class RecorderViewModel extends BaseViewModel {
  final _record = Record();
  final _player = AudioPlayer();
  int _lastPlayedIndex = -1;
  int _secondsRecorded = 0;

  final List<AudioModel> audioFiles = [];

  AudioPlayer get player => _player;

  void initialize() {}

  Future<void> startRecording() async {
    _secondsRecorded = 0;
    final result = await _record.hasPermission();
    if (result) {
      await _record.start();
    }
  }

  Future<void> stopRecording(bool save) async {
    if (await _record.isRecording()) {
      final output = await _record.stop();

      if (output == null) {
        return;
      }

      AppLogger.print(output);

      if (save) {
        audioFiles.add(AudioModel(
          path: output,
          isPlaying: false,
          duration: _secondsRecorded,
          durationString: Helper.getTimerString(_secondsRecorded),
        ));

        notifyListeners();
      }
    }
  }

  void incrementTimeRecorder() {
    _secondsRecorded++;
  }

  int get secondsRecorded => _secondsRecorded;

  Future<Duration?> startPlaying(int index) async {
    // set last playing track as stopped
    if (_lastPlayedIndex != -1) {
      audioFiles[_lastPlayedIndex].isPlaying = false;
    }

    // play current track
    final audio = audioFiles[index];
    _lastPlayedIndex = index;
    audio.isPlaying = true;

    final duration = await _player.setFilePath(audio.path);
    _player.play();
    notifyListeners();
    return duration;
  }

  Future<Duration?> playPause(int index) async {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  @override
  void dispose() {
    super.dispose();

    //release resources
    _record.dispose();
    _player.dispose();
  }
}
