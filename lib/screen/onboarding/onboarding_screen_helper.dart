import 'dart:async';
import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app_routes/route_helper.dart';
import 'package:ar_draw/screen/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';

class OnBoardingScreenHelper {
  OnboardingScreenState state;
  PageController pageController = PageController();
  int currentPage = 0;
  Timer? autoSlideTimer;

  final List<Map<String, String>> onboardingData = [
    {
      'image': AppAsset.firstOnboarding,
      'title': AppStringConstant.onBoardingTitleOne,
      'description': AppStringConstant.onBoardingDescriptionOne,
    },
    {
      'image': AppAsset.secondOnboarding,
      'title': AppStringConstant.onBoardingTitleTwo,
      'description': AppStringConstant.onBoardingDescriptionTwo,
    },
    {
      'image': AppAsset.thirdOnboarding,
      'title': AppStringConstant.onBoardingTitleThree,
      'description': AppStringConstant.onBoardingDescriptionThree,
    },
  ];

  OnBoardingScreenHelper(this.state) {
    startAutoSlide();
  }

  void startAutoSlide() {
    autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (currentPage < onboardingData.length - 1) {
        currentPage++;
        pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        state.onboardingController?.update();
      } else {
        stopAutoSlide();
      }
    });
  }

  void stopAutoSlide() {
    autoSlideTimer?.cancel();
  }

  void resetAutoSlide() {
    stopAutoSlide();
    startAutoSlide();
  }

  void onNextButtonPressed() {
    if (currentPage == onboardingData.length - 1) {
      RouteHelper.instance.gotoHomeScreen();
    } else {
      currentPage++;
      pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      resetAutoSlide();
      state.onboardingController?.update();
    }
  }

  String getButtonText() {
    return currentPage == onboardingData.length - 1 ? AppStringConstant.letsStarted : AppStringConstant.next;
  }
}
