import 'package:audio_recorder/screens/recorder/recorder_viewmodel.dart';
import 'package:audio_recorder/theme/app_colors.dart';
import 'package:audio_recorder/theme/dimensions.dart';
import 'package:audio_recorder/utils/app_logger.dart';
import 'package:audio_recorder/widgets/countdown_timer.dart';
import 'package:flutter/material.dart';

class AudioRecorder extends StatefulWidget {
  final RecorderViewModel model;
  const AudioRecorder({Key? key, required this.model}) : super(key: key);

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

  void _startRecording() async {
    if (_isRecording) return;

    widget.model.startRecording();
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

  void _deleteRecording(data) {
    AppLogger.print('delete....');
    _endRecording();
    widget.model.stopRecording(false);
  }

  void _saveRecording(DraggableDetails? details) {
    AppLogger.print('saved....');
    if (_isRecordingLockEnabled || !_isRecording) return;

    widget.model.stopRecording(true);
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
                onPressed: () => _deleteRecording(null),
                icon: const Icon(Icons.delete),
              ),
              CountdownTimer(model: widget.model),
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
                  child: _isRecording ? const SizedBox() : _button(),
                ),
              ],
            ),
          ),
          if (_isRecording)
            Align(
              alignment: Alignment.bottomCenter,
              child: DragTarget<bool>(
                builder: (context, accepted, rejected) {
                  return Padding(
                    padding: const EdgeInsets.all(Dimensions.bigPadding),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        Text('Cancel')
                      ],
                    ),
                  );
                },
                hitTestBehavior: HitTestBehavior.opaque,
                onAccept: _deleteRecording,
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
      child: TextField(
        maxLines: 1,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: _isRecording ? CountdownTimer(model: widget.model) : null,
        ),
      ),
    );
  }
}
