import 'dart:async';

import 'package:audio_recorder/screens/recorder/recorder_viewmodel.dart';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final RecorderViewModel model;
  const CountdownTimer({Key? key, required this.model}) : super(key: key);

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  final interval = const Duration(seconds: 1);
  late Timer timer;

  startTimeout() {
    var duration = interval;
    timer = Timer.periodic(duration, (timer) {
      setState(() {
        widget.model.incrementTimeRecorder();
      });
    });
  }

  @override
  void initState() {
    startTimeout();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sec = widget.model.secondsRecorded;
    final timerText =
        '${((sec) ~/ 60).toString().padLeft(2, '0')}: ${((sec) % 60).toString().padLeft(2, '0')}';

    return Text(timerText);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
