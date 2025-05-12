import 'dart:ui';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/widgets/app_app_bar.dart';
import 'package:ar_draw/app_routes/route_helper.dart';
import 'package:ar_draw/controller/drawing_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class AllLevelScreen extends StatefulWidget {
  const AllLevelScreen({super.key});

  @override
  State<AllLevelScreen> createState() => AllLevelScreenState();
}

class AllLevelScreenState extends State<AllLevelScreen>
    with TickerProviderStateMixin {
  DrawingController? drawingController;
  late AnimationController _pulseAnimationController;
  late AnimationController _rotateAnimationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late AnimationController _cardsAnimationController;

  final List<Map<String, dynamic>> _levels = [
    {
      'key': 'beginner',
      'title': 'Beginner',
      'description': 'Simple drawing tutorials for beginners',
      'gradient': const [Color(0xFF00B4D8), Color(0xFF0077B6)],
      'icon': CupertinoIcons.star,
    },
    {
      'key': 'intermediate',
      'title': 'Intermediate',
      'description': 'More complex drawings for improving skills',
      'gradient': const [Color(0xFFFFA500), Color(0xFFFF8C00)],
      'icon': CupertinoIcons.star_lefthalf_fill,
    },
    {
      'key': 'expert',
      'title': 'Expert',
      'description': 'Advanced techniques for mastering drawing',
      'gradient': const [Color(0xFFFF4D6D), Color(0xFFC9184A)],
      'icon': CupertinoIcons.star_fill,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _rotateAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _cardsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(
        parent: _rotateAnimationController,
        curve: Curves.linear,
      ),
    );

    _cardsAnimationController.forward();
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    _rotateAnimationController.dispose();
    _cardsAnimationController.dispose();
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
          backgroundColor: const Color(0xFF121212),
          appBar: AppAppBarIOS(
            title: "Learning Levels",
            backgroundColor: Colors.transparent,
            titleColor: Colors.white,
            showBackButton: false,
            backButtonBackgroundColor: Colors.white.withOpacity(0.1),
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              _buildAnimatedBackground(),
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 30),
                        _buildLevelCards(),
                        const SizedBox(height: 30),
                        _buildTotalProgressSection(),
                        const SizedBox(height: 20),
                        _buildRecommendedLessons(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _rotateAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotateAnimation.value,
              origin: const Offset(0, 0),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.2, -0.8),
                    radius: 1.2,
                    colors: [
                      Color(0x3000D2FF),
                      Color(0x00121212),
                    ],
                    stops: [0.0, 0.7],
                  ),
                ),
              ),
            );
          },
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.1,
          right: MediaQuery.of(context).size.width * 0.2,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0x7000D2FF),
                        const Color(0x0000D2FF).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: -30,
          left: -20,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.2 - (_pulseAnimation.value - 1.0) * 0.5,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0x40FF6B6B),
                        const Color(0x00FF6B6B).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Master the art of",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            color: Colors.white.withOpacity(0.7),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 5),
        const Row(
          children: [
            Text(
              "AR Drawing",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10),
            Icon(
              Icons.star,
              color: Color(0xFF00D2FF),
              size: 24,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFFFFA500),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                "Choose a level to start your journey",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLevelCards() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _levels.length,
      itemBuilder: (context, index) {
        final level = _levels[index];
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
        final Animation<double> itemAnimation = CurvedAnimation(
          parent: _cardsAnimationController,
          curve: Interval(
            0.1 * index,
            0.1 * index + 0.6,
            curve: Curves.easeOut,
          ),
        );

        return FadeTransition(
          opacity: itemAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(itemAnimation),
            child: GestureDetector(
              onTap: () {
                RouteHelper.instance.gotoLevelScreen(levelKey);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: gradient[0].withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  icon,
                                  color: gradient[0],
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      level['title'] as String,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      level['description'] as String,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: gradient,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: gradient[0].withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "$completedLessons/$totalLessons lessons",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: gradient[0],
                                ),
                              ),
                              Text(
                                "${(progress * 100).toInt()}% Complete",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Progress bar
                          Stack(
                            children: [
                              // Background
                              Container(
                                height: 8,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              // Progress
                              Container(
                                height: 8,
                                width: MediaQuery.of(context).size.width *
                                    progress *
                                    0.85,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: gradient,
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: gradient[0].withOpacity(0.3),
                                      blurRadius: 5,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotalProgressSection() {
    // Calculate overall progress across all levels
    double totalProgress = 0;
    int totalLessons = 0;
    int totalCompletedLessons = 0;

    for (var level in _levels) {
      final String levelKey = level['key'] as String;
      final lessonsList = drawingController?.lessonMap[levelKey] ?? [];
      final progress = drawingController?.levelProgress[levelKey] ?? 0.0;

      totalLessons += lessonsList.length;
      totalCompletedLessons += (progress * lessonsList.length).round();
    }

    totalProgress = totalLessons > 0 ? totalCompletedLessons / totalLessons : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Overall Progress",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$totalCompletedLessons/$totalLessons Lessons",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Across all levels",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D2FF).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${(totalProgress * 100).toInt()}% Complete",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00D2FF),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Stack(
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Container(
                    height: 12,
                    width: MediaQuery.of(context).size.width *
                        0.85 *
                        totalProgress,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF00D2FF),
                          Color(0xFF3A7BD5),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D2FF).withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Visual representation of level completion
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _levels.map((level) {
                  final String levelKey = level['key'] as String;
                  final List<Color> gradient = level['gradient'] as List<Color>;
                  final double progress =
                      drawingController?.levelProgress[levelKey] ?? 0.0;

                  return Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer circle
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  gradient[0],
                                  gradient[0].withOpacity(0.1),
                                ],
                                stops: [progress, progress],
                                startAngle: 0,
                                endAngle: 3.14 * 2,
                              ),
                            ),
                          ),
                          // Inner circle
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "${(progress * 100).toInt()}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        level['title'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedLessons() {
    // Find lessons to recommend based on progress
    List<LessonData> recommendedLessons = [];
    String recommendationSource = "";

    // Logic to find incomplete lessons from the level with least progress
    double lowestProgress = 1.0;
    String lowestProgressKey = "";

    for (var level in _levels) {
      final String levelKey = level['key'] as String;
      final double progress = drawingController?.levelProgress[levelKey] ?? 0.0;

      if (progress < lowestProgress) {
        lowestProgress = progress;
        lowestProgressKey = levelKey;
      }
    }

    // Get lessons from the level with lowest progress
    if (lowestProgressKey.isNotEmpty) {
      final List<LessonData> levelLessons =
          drawingController?.lessonMap[lowestProgressKey] ?? [];
      recommendationSource = _levels
          .firstWhere((l) => l['key'] == lowestProgressKey)['title'] as String;

      // Get incomplete lessons
      if (levelLessons.isNotEmpty) {
        recommendedLessons = levelLessons.take(3).toList();
      }
    }

    if (recommendedLessons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recommended $recommendationSource Lessons",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: recommendedLessons.length,
            itemBuilder: (context, index) {
              final lesson = recommendedLessons[index];
              final difficulty = lesson.difficulty.toLowerCase();

              Color difficultyColor;
              switch (difficulty) {
                case 'easy':
                  difficultyColor = const Color(0xFF4CAF50);
                  break;
                case 'medium':
                  difficultyColor = const Color(0xFFFFA000);
                  break;
                case 'hard':
                  difficultyColor = const Color(0xFFE53935);
                  break;
                default:
                  difficultyColor = const Color(0xFF4CAF50);
              }

              return GestureDetector(
                onTap: () {
                  RouteHelper.instance
                      .gotoLessonStepScreen(lesson, index, lowestProgressKey);
                },
                child: Container(
                  width: 200,
                  margin: EdgeInsets.only(
                    right: 16,
                    left: index == 0 ? 0 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lesson Image
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: SizedBox(
                          height: 120,
                          width: double.infinity,
                          child: Image.asset(
                            lesson.icon,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: difficultyColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                difficulty.capitalize!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: difficultyColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              lesson.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${lesson.dataStep.length} steps",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
