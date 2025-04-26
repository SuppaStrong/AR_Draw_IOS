import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/widgets/app_app_bar.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/controller/drawing_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class PhotoSketchScreen extends StatefulWidget {
  const PhotoSketchScreen({super.key});

  @override
  State<PhotoSketchScreen> createState() => _PhotoSketchScreenState();
}

class _PhotoSketchScreenState extends State<PhotoSketchScreen>
    with SingleTickerProviderStateMixin {
  DrawingController? drawingController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
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
    'Current screen --> $runtimeType'.logs();
    return GetBuilder(
        init: DrawingController(),
        builder: (DrawingController controller) {
          drawingController = controller;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppAppBarIOS(
              title: AppStringConstant.photoToSketch,
              backgroundColor: Colors.white,
              elevation: 0.5,
            ),
            body: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12),
                          _buildHeaderSection(),
                          const SizedBox(height: 32),
                          _buildIllustration(),
                          const SizedBox(height: 40),
                          _buildOptionsSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Transform Photos into AR Sketches",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black.withOpacity(0.85),
            letterSpacing: 0.3,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Select a photo or take a new one to begin creating your AR drawing experience",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black.withOpacity(0.6),
            height: 1.5,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildIllustration() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColorConstant.appLightPurple.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: const AppImageAsset(
          image: AppAsset.photoToSketch,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      children: [
        _buildOptionCard(
          icon: CupertinoIcons.photo_on_rectangle,
          title: "Choose from Gallery",
          description:
              "Select an existing photo to transform into an AR sketch",
          color: const Color(0xFF5E5CE6), // iOS indigo color
          onTap: () async {
            await drawingController?.getImageFromGallery();
          },
        ),
        const SizedBox(height: 20),
        _buildOptionCard(
          icon: CupertinoIcons.camera,
          title: "Take a Photo",
          description: "Capture a new photo to turn into an AR sketch",
          color: const Color(0xFF34C759), // iOS green color
          onTap: () async {
            await drawingController?.getImageFromCamera();
          },
        ),
        const SizedBox(height: 16),
        _buildImportButton(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.5),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              CupertinoIcons.chevron_right,
              size: 18,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportButton() {
    return TextButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not available right now!'),
            backgroundColor: Colors.orange,
          ),
        );
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        foregroundColor: AppColorConstant.appDeepPurple,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.arrow_down_doc,
            size: 18,
            color: AppColorConstant.appDeepPurple,
          ),
          SizedBox(width: 8),
          Text(
            "Import from Files",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColorConstant.appDeepPurple,
            ),
          ),
        ],
      ),
    );
  }
}
