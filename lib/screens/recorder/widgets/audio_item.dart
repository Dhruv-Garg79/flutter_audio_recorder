import 'package:audio_recorder/screens/recorder/recorder_viewmodel.dart';
import 'package:audio_recorder/theme/dimensions.dart';
import 'package:flutter/material.dart';

class AudioItem extends StatefulWidget {
  final RecorderViewModel model;
  final int itemIndex;

  const AudioItem({Key? key, required this.model, required this.itemIndex}) : super(key: key);

  @override
  _AudioItemState createState() => _AudioItemState();
}

class _AudioItemState extends State<AudioItem> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: Dimensions.mediumMargin),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.smallPadding),
            child: Row(
              children: [
                InkWell(
                  onTap: () {},
                  child: Icon(Icons.play_arrow),
                ),
                Text('audio'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
