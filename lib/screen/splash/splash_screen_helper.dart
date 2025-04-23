import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app_routes/route_helper.dart';
import 'package:ar_draw/screen/splash/splash_screen.dart';
import 'package:ar_draw/service/share_preference.dart';

class SplashScreenHelper {
  SplashScreenState? state;
  static const String firstRunKey = 'isFirstRun';

  SplashScreenHelper(this.state) {
    manageSplashScreen();
  }

  void manageSplashScreen() async {
    bool isFirstRun = await SharedPrefService.instance.getPrefBoolValue(firstRunKey);
    "isFirstRun: $isFirstRun".infoLogs();

    Future.delayed(
      const Duration(seconds: 5),
          () {
        if (isFirstRun) {
          RouteHelper.instance.gotoOnboardingScreen();
          SharedPrefService.instance.setPrefBoolValue(firstRunKey, false);
        } else {
          RouteHelper.instance.gotoHomeScreen();
        }
      },
    );
  }
}
