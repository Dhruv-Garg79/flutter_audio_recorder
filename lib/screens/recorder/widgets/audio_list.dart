import 'package:audio_recorder/screens/recorder/recorder_viewmodel.dart';
import 'package:audio_recorder/screens/recorder/widgets/audio_item.dart';
import 'package:audio_recorder/theme/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class AudioList extends ViewModelWidget<RecorderViewModel> {
  const AudioList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, RecorderViewModel model) {
    final list = model.audioFiles;
    return Container(
      margin: const EdgeInsets.only(
        bottom: Dimensions.messageBox,
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(Dimensions.mediumMargin),
        itemBuilder: (context, index) => AudioItem(
          model: model,
          itemIndex: index,
        ),
        itemCount: list.length,
      ),
    );
  }
}
