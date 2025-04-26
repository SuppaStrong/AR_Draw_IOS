import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/widgets/app_app_bar.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:flutter/material.dart';

class HowToUseScreen extends StatefulWidget {
  const HowToUseScreen({super.key});

  @override
  State<HowToUseScreen> createState() => _HowToUseScreenState();
}

class _HowToUseScreenState extends State<HowToUseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBarIOS(
        title: AppStringConstant.howToUse,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIntroSection(),
              const SizedBox(height: 20),
              _buildStepView(
                image: AppAsset.stepOne, 
                title: "Step 1", 
                description: AppStringConstant.howToUseStepOne,
                number: "1",
              ),
              _buildStepView(
                image: AppAsset.stepTwo, 
                title: "Step 2", 
                description: AppStringConstant.howToUseStepTwo,
                number: "2",
              ),
              _buildStepView(
                image: AppAsset.stepThree, 
                title: "Step 3", 
                description: AppStringConstant.howToUseStepThree,
                number: "3",
              ),
              const SizedBox(height: 24),
              _buildGetStartedButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFDEE8FF),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.tips_and_updates,
                color: Color(0xFF5F7AE8),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                "Getting Started",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Follow these simple steps to start using AR Draw. You'll be creating stunning AR experiences in no time.",
            style: TextStyle(
              fontSize: 15,
              color: Colors.black.withOpacity(0.7),
              height: 1.4,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepView({
    required String image, 
    required String title, 
    required String description,
    required String number,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: AppImageAsset(
                    image: image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF5F7AE8),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5F7AE8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black.withOpacity(0.8),
                    height: 1.4,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5F7AE8),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          "Let's Get Started",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}