import 'package:audio_recorder/screens/recorder/recorder_viewmodel.dart';
import 'package:audio_recorder/theme/app_colors.dart';
import 'package:audio_recorder/theme/dimensions.dart';
import 'package:audio_recorder/utils/app_logger.dart';
import 'package:audio_recorder/widgets/blink_widget.dart';
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

  late final _screenWidth = MediaQuery.of(context).size.width;

  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final Animation<double> _buttonScaleAnimation =
      Tween<double>(begin: 1, end: 1.8).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticInOut,
    ),
  );

  late final Animation<Offset> _verticalBarAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0.0, -1.2),
  ).animate(CurvedAnimation(
    parent: _animationController,
    curve: Curves.linear,
  ));

  late final Animation<Offset> _horizontalBarAnimation = Tween<Offset>(
    end: Offset.zero,
    begin: const Offset(1.2, 0.0),
  ).animate(CurvedAnimation(
    parent: _animationController,
    curve: Curves.linear,
  ));

  final ValueNotifier<double> _positionValueNotifier = ValueNotifier(0);

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
    _positionValueNotifier.value = _screenWidth;
    widget.model.stopRecording(false);
  }

  void _saveRecording(dynamic details) {
    AppLogger.print('saved....');
    if (_isRecordingLockEnabled) return;

    _saveRecordingHelper();
  }

  void _saveRecordingHelper() {
    if (!_isRecording) return;

    widget.model.stopRecording(true);
    _endRecording();
  }

  void _enableRecordingLock(data) {
    AppLogger.print('accepted!');
    setState(() {
      _isRecordingLockEnabled = true;
    });
  }

  void _onDragMic(LongPressMoveUpdateDetails details) {
    final dx = details.globalPosition.dx;

    if (!_isRecording ||
        _animationController.isAnimating ||
        dx + Dimensions.micOffset > _screenWidth ||
        (_positionValueNotifier.value - dx).abs() < 0.5) return;

    AppLogger.print(dx);
    _positionValueNotifier.value = dx;
    if (dx < _screenWidth * 0.6) {
      _deleteRecording(null);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _positionValueNotifier.value = _screenWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.smallMargin),
      child: SizedBox(
        height: Dimensions.barHeight * 2,
        child: ValueListenableBuilder<double>(
          valueListenable: _positionValueNotifier,
          builder: (context, _micPos, child) {
            AppLogger.print(_micPos);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  bottom: -(Dimensions.barHeight + Dimensions.mediumMargin) +
                      (_micPos - _screenWidth),
                  right: 0,
                  child: _lockBar(),
                ),
                Container(
                  width: _micPos,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: _cancelBar(),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    children: [
                      if (!_isRecording)
                        Expanded(
                          child: _messageBox(),
                        ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: _isRecording
                                ? _micPos - Dimensions.micOffset + Dimensions.smallMargin
                                : 0),
                        child: GestureDetector(
                          onLongPress: _startRecording,
                          onLongPressMoveUpdate: _onDragMic,
                          onLongPressEnd: _saveRecording,
                          child: _button(!_isRecording),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _cancelBar() {
    return SlideTransition(
      position: _horizontalBarAnimation,
      child: Container(
        margin: const EdgeInsets.all(Dimensions.smallMargin),
        padding: const EdgeInsets.all(Dimensions.bigPadding),
        height: Dimensions.chatBox,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.borderRadius),
          color: AppColors.grey,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BlinkWidget(
                  child: Icon(
                    Icons.mic,
                    color: Colors.red,
                  ),
                  duration: 2000,
                ),
                CountdownTimer(model: widget.model),
              ],
            ),
            const SizedBox(
              width: 50,
            ),
            const Icon(
              Icons.arrow_back_ios,
              color: AppColors.lightGrey,
              size: 16,
            ),
            const Expanded(
              child: Text(
                'Slide to cancel',
                maxLines: 1,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  color: AppColors.lightGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lockBar() {
    return SlideTransition(
      position: _verticalBarAnimation,
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

  Widget _button(bool show) {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
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
        decoration: InputDecoration(border: InputBorder.none),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
