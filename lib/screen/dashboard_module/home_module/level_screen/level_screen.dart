import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/widgets/app_app_bar.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app_routes/route_helper.dart';
import 'package:ar_draw/controller/drawing_controller.dart';
import 'package:ar_draw/controller/level_controller.dart';
import 'package:ar_draw/screen/dashboard_module/home_module/level_screen/level_screen_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LevelScreen extends StatefulWidget {
  final String levelKey;

  const LevelScreen({
    super.key,
    this.levelKey = 'beginner',
  });

  @override
  State<LevelScreen> createState() => LevelScreenState();
}

class LevelScreenState extends State<LevelScreen>
    with SingleTickerProviderStateMixin {
  LevelScreenHelper? levelScreenHelper;
  LevelController? levelController;
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
    levelScreenHelper ?? (levelScreenHelper = LevelScreenHelper(this));

    final args = Get.arguments;
    final String levelKey = args != null && args['levelKey'] != null
        ? args['levelKey']
        : widget.levelKey;

    return GetBuilder(
        init: LevelController(levelKey),
        builder: (LevelController controller) {
          levelController = controller;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppAppBarIOS(
              title: _getLevelTitle(levelKey),
              backgroundColor: Colors.white,
              elevation: 0.5,
              onBackPressed: () => Get.back(),
            ),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildBody(),
            ),
          );
        });
  }

  String _getLevelTitle(String levelKey) {
    switch (levelKey) {
      case 'beginner':
        return 'Beginner Lessons';
      case 'intermediate':
        return 'Intermediate Lessons';
      case 'expert':
        return 'Expert Lessons';
      default:
        return 'Drawing Lessons';
    }
  }

  Widget _buildBody() {
    if (levelController?.lessons.isEmpty ?? true) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLevelHeader(),
          Expanded(
            child: _buildLessonsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelHeader() {
    Color headerColor = _getLevelColor(widget.levelKey);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: headerColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getLevelIcon(widget.levelKey),
                  size: 18,
                  color: headerColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLevelTitle(widget.levelKey),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getLevelDescription(widget.levelKey),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "${levelController?.getCompletedLessonsCount() ?? 0}/${levelController?.lessons.length ?? 0} lessons completed",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: headerColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "${((levelController?.getLevelProgress() ?? 0) * 100).toInt()}%",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: headerColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  // Background
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  // Progress fill
                  Container(
                    height: 6,
                    width: MediaQuery.of(context).size.width *
                        (levelController?.getLevelProgress() ?? 0) *
                        0.9, // 0.9 for padding
                    decoration: BoxDecoration(
                      color: headerColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const BouncingScrollPhysics(),
      itemCount: levelController?.lessons.length ?? 0,
      itemBuilder: (context, index) {
        final lesson = levelController!.lessons[index];
        final isCompleted = levelController?.isLessonCompleted(index) ?? false;

        // Create staggered animation for each item
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
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(itemAnimation),
            child: _buildLessonCard(lesson, index, isCompleted),
          ),
        );
      },
    );
  }

  Widget _buildLessonCard(LessonData lesson, int index, bool isCompleted) {
    Color levelColor = _getLevelColor(widget.levelKey);
    String difficultyText = _getDifficultyText(lesson.difficulty);
    Color difficultyColor = _getDifficultyColor(lesson.difficulty);

    return GestureDetector(
      onTap: () {
        // Navigate to canvas drawing screen in lesson mode
        RouteHelper.instance
            .gotoLessonStepScreen(lesson, index, widget.levelKey);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isCompleted
                ? levelColor.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            // Lesson Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isCompleted ? levelColor.withOpacity(0.08) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 60,
                      height: 60,
                      color: levelColor.withOpacity(0.1),
                      child: AppImageAsset(
                        image: lesson.icon,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Lesson Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: difficultyColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                difficultyText,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: difficultyColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              CupertinoIcons.eye,
                              size: 14,
                              color: Colors.black.withOpacity(0.4),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatViews(lesson.views),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status Icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? levelColor
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isCompleted
                          ? CupertinoIcons.checkmark
                          : CupertinoIcons.arrow_right,
                      size: 18,
                      color: isCompleted
                          ? Colors.white
                          : Colors.black.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),

            // Step Indicator
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Độ khó vẽ",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        "Các bước: ${lesson.dataStep.length}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: levelColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildDifficultyIndicator(lesson.difficulty),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyIndicator(String difficulty) {
    // Convert difficulty to numeric value
    int difficultyValue = _getDifficultyValue(difficulty);
    Color indicatorColor = _getDifficultyColor(difficulty);

    return Row(
      children: List.generate(10, (index) {
        bool isActive = index < difficultyValue;
        return Expanded(
          child: Container(
            height: 8,
            margin: EdgeInsets.only(right: index < 9 ? 4 : 0),
            decoration: BoxDecoration(
              color: isActive ? indicatorColor : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  int _getDifficultyValue(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 3;
      case 'medium':
        return 6;
      case 'hard':
        return 9;
      default:
        return 5;
    }
  }

  IconData _getLevelIcon(String levelKey) {
    switch (levelKey) {
      case 'beginner':
        return CupertinoIcons.star;
      case 'intermediate':
        return CupertinoIcons.star_lefthalf_fill;
      case 'expert':
        return CupertinoIcons.star_fill;
      default:
        return CupertinoIcons.star;
    }
  }

  String _getLevelDescription(String levelKey) {
    switch (levelKey) {
      case 'beginner':
        return 'Simple drawing tutorials for beginners';
      case 'intermediate':
        return 'More complex drawings for improving skills';
      case 'expert':
        return 'Advanced techniques for mastering drawing';
      default:
        return 'Drawing tutorials';
    }
  }

  Color _getLevelColor(String levelKey) {
    switch (levelKey) {
      case 'beginner':
        return const Color(0xFF00B4D8);
      case 'intermediate':
        return const Color(0xFFFFA500);
      case 'expert':
        return const Color(0xFFFF4D6D);
      default:
        return AppColorConstant.appDeepPurple;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF4CAF50);
      case 'medium':
        return const Color(0xFFFFA000);
      case 'hard':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 'Easy';
      case 'medium':
        return 'Medium';
      case 'hard':
        return 'Hard';
      default:
        return 'Normal';
    }
  }

  String _formatViews(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    } else {
      return views.toString();
    }
  }
}
