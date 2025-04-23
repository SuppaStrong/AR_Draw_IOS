import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/utills/dimension.dart';
import 'package:ar_draw/app/widgets/app_app_bar.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HowToUseScreen extends StatefulWidget {
  const HowToUseScreen({super.key});

  @override
  State<HowToUseScreen> createState() => _HowToUseScreenState();
}

class _HowToUseScreenState extends State<HowToUseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(appbarTitle:  AppStringConstant.howToUse,),
      body: SingleChildScrollView(
        child: Column(children: [
          buildStepView(AppAsset.stepOne, AppStringConstant.howToUseStepOne),
          buildStepView(AppAsset.stepTwo, AppStringConstant.howToUseStepTwo),
          buildStepView(AppAsset.stepThree, AppStringConstant.howToUseStepThree),
        ],).paddingSymmetric(horizontal: DimensPadding.paddingNormal),
      ),
    );
  }
  Widget buildStepView(String image, String title) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
      AppImageAsset(image: image),
      const SizedBox(height: Dimens.heightVerySmall,),
      AppText(title,fontSize: Dimens.textSizeSemiSmall,).paddingSymmetric(horizontal: DimensPadding.paddingTiny),
      const SizedBox(height: Dimens.heightSmallMedium,)
    ],);
  }

}
