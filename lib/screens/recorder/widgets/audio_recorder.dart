import 'dart:math';

import 'package:audio_recorder/screens/recorder/recorder_viewmodel.dart';
import 'package:audio_recorder/theme/app_colors.dart';
import 'package:audio_recorder/theme/dimensions.dart';
import 'package:audio_recorder/utils/app_logger.dart';
import 'package:audio_recorder/widgets/blink_widget.dart';
import 'package:audio_recorder/widgets/countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AudioRecorder extends StatefulWidget {
  final RecorderViewModel model;
  const AudioRecorder({Key? key, required this.model}) : super(key: key);

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder>
    with TickerProviderStateMixin {
  bool _isRecording = false;
  bool _isRecordingLockEnabled = false;

  late final _screenWidth = MediaQuery.of(context).size.width;

  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  late final Animation<double> _buttonScaleAnimation =
      Tween<double>(begin: 1, end: 1.8).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticInOut,
    ),
  );

  late final AnimationController _lockbarController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final Animation<Offset> _verticalBarAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0.0, -1.0),
  ).animate(CurvedAnimation(
    parent: _lockbarController,
    curve: Curves.linear,
  ));

  late final AnimationController _horizontalBarController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  late final Animation<Offset> _horizontalBarAnimation = Tween<Offset>(
    end: Offset.zero,
    begin: const Offset(1.2, 0.0),
  ).animate(CurvedAnimation(
    parent: _horizontalBarController,
    curve: Curves.linear,
  ));

  late final AnimationController _trashController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  late final AnimationController _positionValueNotifier = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  );

  void _startRecording() async {
    if (_isRecording) return;

    widget.model.startRecording();
    AppLogger.print('Recording started...');
    setState(() {
      _isRecording = true;
    });

    _animationController.forward();
    _lockbarController.forward();
    _horizontalBarController.forward();
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
    _positionValueNotifier.forward();
    _trashController.forward(from: 0);
    _horizontalBarController.value = 0;
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
    _lockbarController.reverse();
    _horizontalBarController.reverse();
  }

  void _enableRecordingLock(data) {
    AppLogger.print('accepted!');
    setState(() {
      _isRecordingLockEnabled = true;
    });
  }

  void _onDragMic(LongPressMoveUpdateDetails details) {
    final dx =
        min(details.globalPosition.dx, _screenWidth - Dimensions.micOffset);

    if (!_isRecording ||
        _animationController.isAnimating ||
        (_positionValueNotifier.value - dx).abs() < 0.5) return;

    // AppLogger.print('dx $dx');
    _positionValueNotifier.value = dx / _screenWidth;
    if (_positionValueNotifier.value < 0.75 &&
        _lockbarController.value > 0.0 &&
        !_lockbarController.isAnimating) {
      _lockbarController.reverse();
    }

    if (_positionValueNotifier.value >= 0.75 &&
        _lockbarController.value < 1.0 &&
        !_lockbarController.isAnimating) {
      _lockbarController.forward();
    }

    if (dx < _screenWidth * 0.6) {
      _deleteRecording(null);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _positionValueNotifier.value = _screenWidth - Dimensions.micOffset;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.smallMargin),
      child: SizedBox(
        height: Dimensions.barHeight + Dimensions.messageBox,
        child: AnimatedBuilder(
          animation: _positionValueNotifier,
          builder: (context, child) {
            final val = _positionValueNotifier.value;
            final _micPos =
                min(val * _screenWidth, _screenWidth - Dimensions.micOffset);
            AppLogger.print('$_micPos $val');

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  bottom: -(Dimensions.barHeight + Dimensions.mediumMargin),
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
                              ? _micPos - Dimensions.mediumMargin
                              : 0,
                        ),
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
                Positioned(
                  left: 0,
                  bottom: 8,
                  child: child!,
                ),
              ],
            );
          },
          child: Lottie.asset(
            'assets/delete-animation.json',
            width: 48,
            height: 48,
            repeat: false,
            controller: _trashController,
            fit: BoxFit.cover,
          ),
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
      child: AnimatedBuilder(
        animation: _verticalBarAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _lockbarController.value,
            child: child,
          );
        },
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
    _lockbarController.dispose();
    _positionValueNotifier.dispose();
    super.dispose();
  }
}
