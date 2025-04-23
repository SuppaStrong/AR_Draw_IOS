import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/utills/dimension.dart';
import 'package:ar_draw/app/widgets/app_button.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app/widgets/app_text.dart';
import 'package:ar_draw/controller/onboarding_controller.dart';
import 'package:ar_draw/screen/onboarding/onboarding_screen_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  OnBoardingScreenHelper? onBoardingScreenHelper;
  OnboardingController? onboardingController;

  @override
  Widget build(BuildContext context) {
    onBoardingScreenHelper ??= OnBoardingScreenHelper(this);

    return GetBuilder(
      init: OnboardingController(),
      builder: (OnboardingController controller) {
        onboardingController = controller;
        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PageView.builder(
                  controller: onBoardingScreenHelper?.pageController,
                  onPageChanged: (index) {
                    onBoardingScreenHelper?.currentPage = index;
                    onboardingController?.update();
                    onBoardingScreenHelper?.resetAutoSlide();
                  },
                  itemCount: onBoardingScreenHelper!.onboardingData.length,
                  itemBuilder: (context, index) {
                    return buildOnboardingPage(index);
                  },
                ),
              ),
              buildPageIndicator(),
              const SizedBox(height: Dimens.heightSmallMedium),
              AppButton(
                onTap: () {
                  onBoardingScreenHelper?.onNextButtonPressed();
                },
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingNormal),
                title: onBoardingScreenHelper!.getButtonText(),
                gradient: const [AppColorConstant.appLightPurple, AppColorConstant.appDeepPurple],
              ),
              const SizedBox(height: Dimens.heightSmall),

            ],
          ),
        );
      },
    );
  }

  Widget buildOnboardingPage(int index) {
    final data = onBoardingScreenHelper!.onboardingData[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppImageAsset(
          image: data['image']!,
          height: MediaQuery.of(context).size.height * 0.60,
          fit: BoxFit.fill,
          width: double.infinity,
        ),
        const SizedBox(height: Dimens.heightSmallMedium),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingNormal),
          child: AppText(
            data['title']!,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: Dimens.heightVerySmall),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingNormal),
          child: AppText(
            data['description']!,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(onBoardingScreenHelper!.onboardingData.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            color: onBoardingScreenHelper?.currentPage == index ? AppColorConstant.appDeepPurple : AppColorConstant.appGrey,
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}
