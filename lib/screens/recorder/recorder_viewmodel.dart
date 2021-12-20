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
  String storagePath = '';

  final List<AudioModel> audioFiles = [];

  AudioPlayer get player => _player;

  void initialize() {
    _loadAllAudios();
  }

  Future<void> _loadAllAudios() async {
    if (Platform.isAndroid) {
      final directory = (await getExternalStorageDirectory())!;
      storagePath = directory.path;

      if (directory.existsSync()) {
        final files = directory.listSync();
        int i = 0;
        for (FileSystemEntity it in files) {
          if (i++ > 5) break;
          final duration = await _player.setFilePath(it.uri.path);
          audioFiles.add(AudioModel(
            path: it.uri.path,
            isPlaying: false,
            duration: duration?.inSeconds ?? 0,
            durationString: Helper.getTimerString(duration?.inSeconds ?? 0),
          ));
        }

        _player.stop();
        notifyListeners();
      }
    }
  }

  Future<void> startRecording() async {
    _secondsRecorded = 0;
    final result = await _record.hasPermission();

    if (result) {
      if (Platform.isAndroid) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        await _record.start(path: '$storagePath/$timestamp.m4a');
      } else {
        await _record.start();
      }
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

  void seekPlayer(int sec) {
    final duration = Duration(seconds: sec);
    _player.seek(duration);
  }

  @override
  void dispose() {
    super.dispose();

    //release resources
    _record.dispose();
    _player.dispose();
  }
}
