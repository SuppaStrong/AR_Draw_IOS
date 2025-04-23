import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/utills/dimension.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app/widgets/app_text.dart';
import 'package:ar_draw/screen/splash/splash_screen_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  SplashScreenHelper ? splashScreenHelper;
  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    splashScreenHelper ?? (splashScreenHelper = SplashScreenHelper(this));
    return Scaffold(
      body: Stack(
        children: [
          const SizedBox(height: double.infinity,width: double.infinity,child: AppImageAsset(image: AppAsset.splashBackground,fit: BoxFit.fill),),
          Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppImageAsset(image: AppAsset.splashImage,width: MediaQuery.of(context).size.width * 0.5),
              const SizedBox(height: Dimens.heightMediumSmall,),
              AppText(AppStringConstant.appName,color: AppColorConstant.appWhite,fontFamily: GoogleFonts.lobster().fontFamily,fontSize: Dimens.textSizeExtraLarge,)
            ],
          ),),
        ],
      ),
    );
  }
}
