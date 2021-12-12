import 'package:audio_recorder/theme/app_colors.dart';
import 'package:audio_recorder/theme/dimensions.dart';
import 'package:flutter/material.dart';

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({Key? key}) : super(key: key);

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.smallMargin),
      child: Row(
        children: [
          Expanded(
            child: _messageBox(),
          ),
          FloatingActionButton(
            backgroundColor: AppColors.primaryColor,
            child: const Icon(
              Icons.mic,
              color: Colors.white,
              size: Dimensions.micSize,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _messageBox() {
    return Container(
      margin: EdgeInsets.all(Dimensions.smallMargin),
      padding: EdgeInsets.all(Dimensions.bigPadding),
      height: Dimensions.chatBox,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.borderRadius),
        color: Colors.grey[700],
      ),
      child: TextField(
        maxLines: 1,
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
      ),
    );
  }
}
