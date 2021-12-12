import 'dart:convert';

import 'package:audio_recorder/utils/helper.dart';

class AudioModel {
  final String path;
  final int duration;
  final String durationString;
  bool isPlaying = false;

  AudioModel({
    required this.path,
    required this.duration,
    required this.durationString,
    required this.isPlaying,
  });

  AudioModel copyWith({
    String? path,
    int? duration,
    String? durationString,
    bool? isPlaying,
  }) {
    return AudioModel(
      path: path ?? this.path,
      duration: duration ?? this.duration,
      durationString: durationString ?? this.durationString,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'duration': duration,
      'durationString': durationString,
      'isPlaying': isPlaying,
    };
  }

  factory AudioModel.fromMap(Map<String, dynamic> map) {
    return AudioModel(
      path: map['path'] ?? '',
      duration: map['duration']?.toInt() ?? 0,
      durationString: map['durationString'] ?? '',
      isPlaying: map['isPlaying'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory AudioModel.fromJson(String source) =>
      AudioModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AudioModel(path: $path, duration: $duration, durationString: $durationString, isPlaying: $isPlaying)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AudioModel &&
        other.path == path &&
        other.duration == duration &&
        other.durationString == durationString &&
        other.isPlaying == isPlaying;
  }

  @override
  int get hashCode {
    return path.hashCode ^
        duration.hashCode ^
        durationString.hashCode ^
        isPlaying.hashCode;
  }
}
