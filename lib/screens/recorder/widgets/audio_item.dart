import 'package:audio_recorder/models/audio_model.dart';
import 'package:audio_recorder/screens/recorder/recorder_viewmodel.dart';
import 'package:audio_recorder/theme/app_colors.dart';
import 'package:audio_recorder/theme/dimensions.dart';
import 'package:audio_recorder/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioItem extends StatefulWidget {
  final RecorderViewModel model;
  final int itemIndex;

  const AudioItem({Key? key, required this.model, required this.itemIndex})
      : super(key: key);

  @override
  _AudioItemState createState() => _AudioItemState();
}

class _AudioItemState extends State<AudioItem> {
  void _startPlaying() async {
    await widget.model.startPlaying(widget.itemIndex);
  }

  void _playPause() async {
    await widget.model.playPause(widget.itemIndex);
  }

  @override
  Widget build(BuildContext context) {
    final audio = widget.model.audioFiles[widget.itemIndex];
    final width = MediaQuery.of(context).size.width * 0.6;

    // we are using two different players so that streamlistener widget is only created for currently playing file
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: Dimensions.mediumMargin),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(Dimensions.smallPadding),
              bottomRight: Radius.circular(Dimensions.smallPadding),
              topLeft: Radius.circular(Dimensions.smallPadding),
            ),
          ),
          color: AppColors.primaryColor,
          child: Container(
              width: width,
              padding: const EdgeInsets.all(Dimensions.smallPadding),
              child: !audio.isPlaying
                  ? _staticPlayer(audio)
                  : _dynamicPlayer(audio)),
        ),
      ],
    );
  }

  Widget _staticPlayer(AudioModel audio) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _iconButton(Icons.play_arrow_rounded, _startPlaying),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _progressBar(1),
              const SizedBox(
                height: Dimensions.mediumMargin,
              ),
              _duration(audio),
            ],
          ),
        )
      ],
    );
  }

  Widget _dynamicPlayer(AudioModel audio) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        StreamBuilder<PlayerState>(
          stream: widget.model.player.playerStateStream,
          builder: (context, snapshot) {
            final processingState = snapshot.data?.processingState;
            final playing = snapshot.data?.playing == true;

            if (processingState == ProcessingState.buffering ||
                processingState == ProcessingState.loading ||
                processingState == ProcessingState.ready) {
              return _iconButton(
                  playing ? Icons.pause : Icons.play_arrow_rounded, _playPause);
            }

            return _iconButton(Icons.play_arrow_rounded, _startPlaying);
          },
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder<Duration>(
                stream: widget.model.player.positionStream,
                builder: (context, snapshot) {
                  final value = (snapshot.data?.inSeconds ?? audio.duration) /
                      audio.duration;
                  return _progressBar(value);
                },
              ),
              const SizedBox(
                height: Dimensions.mediumMargin,
              ),
              _duration(audio),
            ],
          ),
        ),
      ],
    );
  }

  Widget _progressBar(double value) {
    return LinearProgressIndicator(
      value: value,
      color: AppColors.primaryColor.withOpacity(0.6),
      backgroundColor: Colors.white,
      minHeight: 3,
    );
  }

  Widget _duration(AudioModel audio) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          audio.durationString,
          style: const TextStyle(
            color: AppColors.lightGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _iconButton(IconData icon, Function() function) {
    return InkWell(
      onTap: function,
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.smallMargin),
        child: Icon(
          icon,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }
}
