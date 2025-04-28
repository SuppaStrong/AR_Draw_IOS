import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/widgets/app_app_bar.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app_routes/route_helper.dart';
import 'package:ar_draw/controller/drawing_controller.dart';
import 'package:ar_draw/screen/dashboard_module/home_module/drawing_screen/drawing_screen_helper.dart';
import 'package:flutter/cupertino.dart';
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
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
                        _buildHotHeader(),
                        const SizedBox(height: 16),
                        _buildHotCategoryList(),
                        const SizedBox(height: 32),
                        _buildLearningHeader(),
                        const SizedBox(height: 16),
                        _buildLearningLevels(),
                        const SizedBox(height: 20),
                        _buildCategoryHeader(),
                        const SizedBox(height: 16),
                        _buildCategoryList(),
                        const SizedBox(height: 24),
                      ],
                    ),
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

  Widget _buildLearningHeader() {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF00B4D8).withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.school_rounded,
            size: 16,
            color: Color(0xFF00B4D8),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          "Learn to Draw",
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
            color: const Color(0xFF00B4D8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            "3 Levels",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF00B4D8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLearningLevels() {
    final levels = [
      {
        'key': 'beginner',
        'title': 'Beginner',
        'description': 'Start your drawing journey',
        'image': AppAsset.photoToSketch,
        'gradient': const [Color(0xFF00B4D8), Color(0xFF0077B6)],
        'icon': CupertinoIcons.star,
      },
      {
        'key': 'intermediate',
        'title': 'Intermediate',
        'description': 'Enhance your skills',
        'image': AppAsset.photoToSketch,
        'gradient': const [Color(0xFFFFA500), Color(0xFFFF8C00)],
        'icon': CupertinoIcons.star_lefthalf_fill,
      },
      {
        'key': 'expert',
        'title': 'Expert',
        'description': 'Master advanced techniques',
        'image': AppAsset.photoToSketch,
        'gradient': const [Color(0xFFFF4D6D), Color(0xFFC9184A)],
        'icon': CupertinoIcons.star_fill,
      },
    ];

    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final level = levels[index];
          final String levelKey = level['key'] as String;
          final List<Color> gradient = level['gradient'] as List<Color>;
          final IconData icon = level['icon'] as IconData;

          // Get lessons for this level and progress
          final lessonsList = drawingController?.lessonMap[levelKey] ?? [];
          final progress = drawingController?.levelProgress[levelKey] ?? 0.0;

          // Get total lessons and completed count for this level
          final totalLessons = lessonsList.length;
          final completedLessons = (progress * totalLessons).round();

          // Animation setup
          final double delayFactor = index * 0.1;
          final Animation<double> itemAnimation = CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              0.2 + delayFactor,
              0.5 + delayFactor,
              curve: Curves.easeOut,
            ),
          );

          return FadeTransition(
            opacity: itemAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.3, 0),
                end: Offset.zero,
              ).animate(itemAnimation),
              child: GestureDetector(
                onTap: () {
                  // Navigate to level's lessons
                  if (lessonsList.isNotEmpty) {
                    RouteHelper.instance.gotoLevelScreen(levelKey);
                  }
                },
                child: Container(
                  width: 280,
                  margin: EdgeInsets.only(
                      left: index == 0 ? 0 : 16,
                      right: index == levels.length - 1 ? 0 : 0,
                      top: 8,
                      bottom: 10),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Progress background (white background)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      // Progress fill (colored portion based on completion)
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: 280 * progress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),

                      // Card content
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Level info
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Level title and icon
                                  Row(
                                    children: [
                                      Icon(
                                        icon,
                                        color: progress >= 1.0
                                            ? Colors.white
                                            : gradient[0],
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        level['title'] as String,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: progress >= 1.0
                                              ? Colors.white
                                              : Colors.black.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Description
                                  Text(
                                    level['description'] as String,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: progress >= 1.0
                                          ? Colors.white.withOpacity(0.9)
                                          : Colors.black.withOpacity(0.6),
                                    ),
                                  ),

                                  const Spacer(),

                                  // Progress text
                                  Text(
                                    "$completedLessons/$totalLessons lessons",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: progress >= 1.0
                                          ? Colors.white
                                          : gradient[0],
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // Progress bar
                                  Stack(
                                    children: [
                                      // Background
                                      Container(
                                        height: 6,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: progress >= 1.0
                                              ? Colors.white.withOpacity(0.3)
                                              : Colors.grey.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                      ),

                                      // Progress fill
                                      Container(
                                        height: 6,
                                        width: 100 *
                                            progress, // Percentage of width
                                        decoration: BoxDecoration(
                                          color: progress >= 1.0
                                              ? Colors.white
                                              : Colors.grey.withOpacity(0.1),
                                          gradient: progress >= 1.0
                                              ? null
                                              : LinearGradient(
                                                  colors: [
                                                    gradient[0],
                                                    gradient[1],
                                                  ],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                ),
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  // Start button
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: progress >= 1.0
                                          ? Colors.white
                                          : gradient[0].withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          progress >= 1.0
                                              ? CupertinoIcons
                                                  .checkmark_circle_fill
                                              : CupertinoIcons.play_fill,
                                          size: 12,
                                          color: progress >= 1.0
                                              ? gradient[0]
                                              : gradient[0],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          progress >= 1.0
                                              ? "Completed"
                                              : "Start Learning",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: progress >= 1.0
                                                ? gradient[0]
                                                : gradient[0],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Level image
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 120,
                                alignment: Alignment.center,
                                child: AppImageAsset(
                                  image: level['image'] as String,
                                  fit: BoxFit.contain,
                                ),
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

  Widget _buildHotHeader() {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColorConstant.appErrorColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.local_fire_department_rounded,
            size: 16,
            color: AppColorConstant.appErrorColor,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          "Trending 🔥",
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
            color: AppColorConstant.appErrorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "${drawingController?.trendingMap.keys.length ?? 0} Hot picks",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColorConstant.appErrorColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHotCategoryList() {
    if (drawingController?.trendingMap.isEmpty ?? true) {
      return const SizedBox(height: 170);
    }

    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: drawingController?.trendingMap.keys.length ?? 0,
        itemBuilder: (context, index) {
          String? category =
              drawingController?.trendingMap.keys.elementAt(index);
          String? firstImage = drawingController?.trendingMap[category]!.first;

          final double delayFactor = 0.2 + (index * 0.1);
          final Animation<double> itemAnimation = CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              delayFactor.clamp(0.0, 0.8),
              (delayFactor + 0.2).clamp(0.0, 1.0),
              curve: Curves.easeOut,
            ),
          );

          final Color itemColor =
              index < (drawingController?.imageColorMap?.length ?? 0)
                  ? drawingController!.imageColorMap![index]
                  : AppColorConstant.appErrorColor;

          return FadeTransition(
            opacity: itemAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.3, 0),
                end: Offset.zero,
              ).animate(itemAnimation),
              child: GestureDetector(
                onTap: () => RouteHelper.instance.gotoCategoryScreen(
                  drawingController?.trendingMap[category],
                  category?.capitalizeFirst ?? "",
                ),
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: itemColor.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: itemColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: itemColor.withOpacity(0.1),
                                child: AppImageAsset(
                                  image: firstImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColorConstant.appErrorColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.local_fire_department_rounded,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      "Hot",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black.withOpacity(0.8),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${drawingController?.trendingMap[category]?.length ?? 0} items",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: itemColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12,
                                color: itemColor,
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
    return GridView.builder(
      shrinkWrap:
          true, // Important: Makes grid take only as much space as needed
      physics:
          const NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
      itemCount: drawingController?.imagesMap.keys.length ?? 0,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        // Handle possible null or empty map
        if (drawingController?.imagesMap.keys.isEmpty ?? true) {
          return const SizedBox.shrink();
        }

        // Get category safely
        String? category = drawingController?.imagesMap.keys.elementAt(index);
        if (category == null ||
            (drawingController?.imagesMap[category]?.isEmpty ?? true)) {
          return const SizedBox.shrink();
        }

        // Get first image safely
        String? firstImage = drawingController?.imagesMap[category]!.first;
        if (firstImage == null) {
          return const SizedBox.shrink();
        }

        // Ensure color index doesn't go out of bounds
        int colorIndex =
            index % (drawingController?.imageColorMap?.length ?? 1);
        Color itemColor =
            (drawingController?.imageColorMap?.isNotEmpty ?? false)
                ? drawingController!.imageColorMap![colorIndex]
                : Colors.purple;

        // Animation setup
        final double delayFactor = 0.2 + (index * 0.1);
        final Animation<double> itemAnimation = CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            delayFactor.clamp(0.0, 0.8),
            (delayFactor + 0.2).clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
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
                category.capitalizeFirst ?? "",
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: itemColor.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: itemColor.withOpacity(0.3),
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
                            color: itemColor.withOpacity(0.1),
                          ),
                          child: AppImageAsset(
                            image: firstImage,
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
                                  category.capitalizeFirst ?? "",
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
                              color: itemColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: itemColor,
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
