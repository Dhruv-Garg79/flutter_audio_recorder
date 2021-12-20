import 'package:audio_recorder/app/app.locator.dart';
import 'package:audio_recorder/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class SplashViewModel extends BaseViewModel {
  final _navigator = locator<NavigationService>();

  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));

    _navigator.replaceWith(Routes.recorderView);
  }
}
