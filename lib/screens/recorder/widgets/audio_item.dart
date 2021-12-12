import 'package:audio_recorder/models/audio_model.dart';
import 'package:audio_recorder/theme/dimensions.dart';
import 'package:flutter/material.dart';

class AudioItem extends StatefulWidget {
  const AudioItem({required AudioModel audioModel, Key? key}) : super(key: key);

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
          margin: const EdgeInsets.symmetric(
            vertical: Dimensions.smallMargin,
            horizontal: Dimensions.bigMargin,
          ),
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
