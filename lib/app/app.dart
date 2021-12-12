import 'package:audio_recorder/screens/recorder/recorder_view.dart';
import 'package:audio_recorder/screens/splash/splash_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

@StackedApp(routes: [
  MaterialRoute(page: RecorderView),
  MaterialRoute(page: SplashView, initial: true)
], dependencies: [
  Singleton(classType: NavigationService),
  LazySingleton(classType: SnackbarService),
])
class App {
  /** This class has no puporse besides housing the annotation that generates the required functionality **/
}
