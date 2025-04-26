import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/helper/app_enum.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/localization/app_localization.dart';
import 'package:ar_draw/app_routes/route_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: AppColorConstant.appTransparent,
      statusBarColor: AppColorConstant.appTransparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    return GetMaterialApp(
      title: 'AI Draw',
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: Locale(LocalisationEnum.en.name),
      fallbackLocale: Locale(LocalisationEnum.hi.name),
      initialRoute: RouteConstant.initial,
      defaultTransition: Transition.fadeIn,
      getPages: GetPageRouteHelper.routes,
      theme: ThemeData(fontFamily: AppAsset.defaultFont, scaffoldBackgroundColor: AppColorConstant.appWhite),
      builder: (context, child) {
        child = MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child ?? Container(),
        );
        return child;
      },
    );
  }
}
