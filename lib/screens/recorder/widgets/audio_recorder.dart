import 'package:audio_recorder/theme/app_colors.dart';
import 'package:audio_recorder/theme/dimensions.dart';
import 'package:audio_recorder/utils/app_logger.dart';
import 'package:flutter/material.dart';

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({Key? key}) : super(key: key);

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _isRecordingLockEnabled = false;

  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final Animation<double> _animation =
      Tween<double>(begin: 1, end: 1.8).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    ),
  );

  late final Animation<Offset> _positionAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0.0, -1.2),
  ).animate(CurvedAnimation(
    parent: _animationController,
    curve: Curves.linear,
  ));

  void _startRecording() {
    if (_isRecording) return;

    AppLogger.print('Recording started...');
    setState(() {
      _isRecording = true;
    });

    _animationController.forward();
  }

  void _endRecording() {
    if (!_isRecording) return;

    AppLogger.print('Recording saved...');

    setState(() {
      _isRecording = false;
      _isRecordingLockEnabled = false;
    });
    _animationController.reverse();
  }

  void _deleteRecording() {
    _endRecording();
  }

  void _saveRecording(DraggableDetails? details) {
    if (_isRecordingLockEnabled) return;

    _endRecording();
  }

  void _playPauseRecording() {}

  void _enableRecordingLock(data) {
    AppLogger.print('accepted!');
    setState(() {
      _isRecordingLockEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.smallMargin),
      child: _isRecordingLockEnabled ? _lockedRecorder() : _defaultRecorder(),
    );
  }

  Widget _lockedRecorder() {
    return Container(
      padding: const EdgeInsets.all(Dimensions.smallPadding),
      color: AppColors.grey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _deleteRecording,
                icon: const Icon(Icons.delete),
              ),
              IconButton(
                onPressed: _playPauseRecording,
                icon: const Icon(Icons.play_arrow),
              ),
              FloatingActionButton(
                onPressed: _endRecording,
                child: const Icon(Icons.send),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _defaultRecorder() {
    return SizedBox(
      height: Dimensions.barHeight * 2,
      child: Stack(
        children: [
          Positioned(
            bottom: -(Dimensions.barHeight + Dimensions.mediumMargin),
            right: 0,
            child: _lockBar(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: _messageBox(),
                ),
                LongPressDraggable<bool>(
                  data: true,
                  feedback: _button(),
                  onDragStarted: _startRecording,
                  onDragEnd: _saveRecording,
                  child: _isRecording ? SizedBox() : _button(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _lockBar() {
    return SlideTransition(
      position: _positionAnimation,
      child: Container(
        margin: const EdgeInsets.all(Dimensions.smallMargin),
        height: Dimensions.barHeight,
        width: Dimensions.chatBox,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.borderRadius),
          color: AppColors.grey,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DragTarget<bool>(
              builder: (context, accepted, rejected) {
                return const Padding(
                  padding: EdgeInsets.all(Dimensions.bigPadding),
                  child: Icon(Icons.lock),
                );
              },
              hitTestBehavior: HitTestBehavior.opaque,
              onAccept: _enableRecordingLock,
            ),
            const Icon(
              Icons.keyboard_arrow_up,
              size: 24,
            ),
            const Icon(
              Icons.keyboard_arrow_up,
              size: 24,
            ),
            const Icon(
              Icons.keyboard_arrow_up,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _button() {
    return ScaleTransition(
      scale: _animation,
      child: const CircleAvatar(
        radius: Dimensions.micSize,
        backgroundColor: AppColors.primaryColor,
        child: Icon(
          Icons.mic,
          color: Colors.white,
          size: Dimensions.micSize,
        ),
      ),
    );
  }

  Widget _messageBox() {
    return Container(
      margin: const EdgeInsets.all(Dimensions.smallMargin),
      padding: const EdgeInsets.all(Dimensions.bigPadding),
      height: Dimensions.chatBox,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.borderRadius),
        color: AppColors.grey,
      ),
      child: const TextField(
        maxLines: 1,
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
      ),
    );
  }
}
