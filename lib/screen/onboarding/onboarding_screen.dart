import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app/widgets/app_text.dart';
import 'package:ar_draw/controller/onboarding_controller.dart';
import 'package:ar_draw/screen/onboarding/onboarding_screen_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  OnBoardingScreenHelper? onBoardingScreenHelper;
  OnboardingController? onboardingController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    onBoardingScreenHelper ??= OnBoardingScreenHelper(this);

    return GetBuilder(
      init: OnboardingController(),
      builder: (OnboardingController controller) {
        onboardingController = controller;
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Expandable page content
                Expanded(
                  child: PageView.builder(
                    controller: onBoardingScreenHelper?.pageController,
                    onPageChanged: (index) {
                      setState(() {
                        onBoardingScreenHelper?.currentPage = index;
                        onboardingController?.update();
                        onBoardingScreenHelper?.resetAutoSlide();
                      });

                      // Restart animation when page changes
                      _animationController.reset();
                      _animationController.forward();
                    },
                    itemCount: onBoardingScreenHelper!.onboardingData.length,
                    itemBuilder: (context, index) {
                      return buildOnboardingPage(index);
                    },
                  ),
                ),

                // Bottom controls
                Container(
                  padding: const EdgeInsets.only(
                      bottom: 40.0, left: 24.0, right: 24.0, top: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      buildPageIndicator(),
                      const SizedBox(height: 24),
                      _buildContinueButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Skip button removed as requested

  Widget buildOnboardingPage(int index) {
    final data = onBoardingScreenHelper!.onboardingData[index];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image with hero-like animation
          Hero(
            tag: 'onboarding_image_$index',
            child: Container(
              height: MediaQuery.of(context).size.height * 0.50,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: AppImageAsset(
                  image: data['image']!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Title with animation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: AppText(
              data['title']!,
              fontWeight: FontWeight.bold,
              fontSize: 28,
              textAlign: TextAlign.left,
            ),
          ),

          const SizedBox(height: 16),

          // Description with animation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: AppText(
              data['description']!,
              fontWeight: FontWeight.w400,
              fontSize: 16,
              textAlign: TextAlign.left,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          List.generate(onBoardingScreenHelper!.onboardingData.length, (index) {
        bool isCurrentPage = onBoardingScreenHelper?.currentPage == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isCurrentPage ? 24 : 8,
          decoration: BoxDecoration(
            color: isCurrentPage
                ? AppColorConstant.appDeepPurple
                : AppColorConstant.appGrey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(28),
        color: AppColorConstant.appDeepPurple,
        child: Text(
          onBoardingScreenHelper!.getButtonText(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        onPressed: () {
          onBoardingScreenHelper?.onNextButtonPressed();
        },
      ),
    );
  }
}
