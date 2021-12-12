import 'package:audio_recorder/screens/recorder/recorder_viewmodel.dart';
import 'package:audio_recorder/screens/recorder/widgets/audio_list.dart';
import 'package:audio_recorder/screens/recorder/widgets/audio_recorder.dart';
import 'package:audio_recorder/utils/constants.dart';
import 'package:audio_recorder/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

class RecorderView extends StatelessWidget {
  const RecorderView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constants.appName),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).primaryColor,
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(Images.background),
          ),
        ),
        child: ViewModelBuilder<RecorderViewModel>.nonReactive(
          viewModelBuilder: () => RecorderViewModel(),
          onModelReady: (model) => model.initialize(),
          builder: (context, model, child) => _body(model),
        ),
      ),
    );
  }

  Widget _body(RecorderViewModel model) {
    return Stack(
      children: [
        const AudioList(),
        Align(
          alignment: Alignment.bottomCenter,
          child: AudioRecorder(
            model: model,
          ),
        ),
      ],
    );
  }
}
