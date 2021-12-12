import 'dart:convert';

class AudioModel {
  final String path;
  final int duration;
  bool isPlaying = false;

  AudioModel({
    required this.path,
    required this.duration,
    required this.isPlaying,
  });

  AudioModel copyWith({
    String? path,
    int? duration,
    bool? isPlaying,
  }) {
    return AudioModel(
      path: path ?? this.path,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'duration': duration,
      'isPlaying': isPlaying,
    };
  }

  factory AudioModel.fromMap(Map<String, dynamic> map) {
    return AudioModel(
      path: map['path'] ?? '',
      duration: map['duration']?.toInt() ?? 0,
      isPlaying: map['isPlaying'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory AudioModel.fromJson(String source) =>
      AudioModel.fromMap(json.decode(source));

  @override
  String toString() => 'AudioModel(path: $path, duration: $duration, isPlaying: $isPlaying)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is AudioModel &&
      other.path == path &&
      other.duration == duration &&
      other.isPlaying == isPlaying;
  }

  @override
  int get hashCode => path.hashCode ^ duration.hashCode ^ isPlaying.hashCode;
}
