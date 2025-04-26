import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/widgets/app_app_bar.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app_routes/route_helper.dart';
import 'package:ar_draw/controller/drawing_controller.dart';
import 'package:ar_draw/screen/dashboard_module/home_module/drawing_screen/drawing_screen_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => DrawingScreenState();
}

class DrawingScreenState extends State<DrawingScreen>
    with SingleTickerProviderStateMixin {
  DrawingScreenHelper? drawingScreenHelper;
  DrawingController? drawingController;
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
        curve: Curves.easeOut,
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
    drawingScreenHelper ?? (drawingScreenHelper = DrawingScreenHelper(this));
    return GetBuilder(
        init: DrawingController(),
        builder: (DrawingController controller) {
          drawingController = controller;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppAppBarIOS(
              title: AppStringConstant.drawing,
              backgroundColor: Colors.white,
              elevation: 0.5,
            ),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildPageHeader(),
                      const SizedBox(height: 24),
                      _buildImagePickerView(),
                      const SizedBox(height: 32),
                      _buildCategoryHeader(),
                      const SizedBox(height: 16),
                      _buildCategoryList(),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Create Your AR Drawing",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black.withOpacity(0.8),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Select from our categories or use your own image",
          style: TextStyle(
            fontSize: 14,
            color: Colors.black.withOpacity(0.5),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryHeader() {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColorConstant.appLightPurple.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.grid_view_rounded,
            size: 16,
            color: AppColorConstant.appDeepPurple,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          AppStringConstant.categories,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black.withOpacity(0.8),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColorConstant.appLightPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "${drawingController?.imagesMap.keys.length ?? 0} Categories",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColorConstant.appDeepPurple,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList() {
    return Expanded(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: drawingController?.imagesMap.keys.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          String? category = drawingController?.imagesMap.keys.elementAt(index);
          String? firstImage = drawingController?.imagesMap[category]!.first;
          final double delayFactor = 0.2 + (index * 0.1);
          final Animation<double> itemAnimation = CurvedAnimation(
            parent: _animationController,
            curve: Interval(delayFactor.clamp(0.0, 0.8),
                (delayFactor + 0.2).clamp(0.0, 1.0),
                curve: Curves.easeOut),
          );

          return FadeTransition(
            opacity: itemAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(itemAnimation),
              child: GestureDetector(
                onTap: () => RouteHelper.instance.gotoCategoryScreen(
                  drawingController?.imagesMap[category],
                  category?.capitalizeFirst ?? "",
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: drawingController!.imageColorMap![index]
                            .withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: drawingController!.imageColorMap![index]
                          .withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: drawingController!.imageColorMap![index]
                                  .withOpacity(0.1),
                            ),
                            child: AppImageAsset(
                              image: firstImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category?.capitalizeFirst ?? "",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black.withOpacity(0.8),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${drawingController?.imagesMap[category]?.length ?? 0} items",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: drawingController!.imageColorMap![index]
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: drawingController!.imageColorMap![index],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePickerView() {
    return Row(
      children: [
        _buildOption(
          onTap: () async {
            await drawingController?.getImageFromGallery();
            drawingController?.croppedFile = drawingController?.croppedFile;
          },
          icon: Icons.photo_library_rounded,
          title: AppStringConstant.gallery,
          color: const Color(0xFF6C5CE7),
          description: "Select from photos",
          background: AppAsset.galleryBackGround,
        ),
        const SizedBox(width: 16),
        _buildOption(
          onTap: () async {
            await drawingController?.getImageFromCamera();
            drawingController?.croppedFile = drawingController?.croppedFile;
          },
          icon: Icons.camera_alt_rounded,
          title: AppStringConstant.camera,
          color: const Color(0xFF00B894),
          description: "Take a photo",
          background: AppAsset.cameraBackGround,
        ),
      ],
    );
  }

  Widget _buildOption({
    required VoidCallback? onTap,
    required IconData icon,
    required String title,
    required Color color,
    required String description,
    required String background,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Image background
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: AppImageAsset(
                    image: background,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Overlay
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withOpacity(0.6),
                      color.withOpacity(0.9),
                    ],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(
                          icon,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
