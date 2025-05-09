import 'dart:ui';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/widgets/app_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArtStats {
  final int completedDrawings;
  final int completedLessons;
  final int timeSpentMinutes;
  
  ArtStats({this.completedDrawings = 0, this.completedLessons = 0, this.timeSpentMinutes = 0});
  
  String get rank {
    if (completedDrawings >= 100) return "Master Creator";
    if (completedDrawings >= 50) return "Pro Artist";
    if (completedDrawings >= 10) return "Artist";
    if (completedDrawings >= 3) return "Sketcher";
    return "Beginner";
  }
  
  int get level {
    if (completedDrawings >= 100) return 5;
    if (completedDrawings >= 50) return 4;
    if (completedDrawings >= 10) return 3;
    if (completedDrawings >= 3) return 2;
    return 1;
  }
  
  int get nextLevelAt {
    if (completedDrawings >= 100) return 100;
    if (completedDrawings >= 50) return 100;
    if (completedDrawings >= 10) return 50;
    if (completedDrawings >= 3) return 10;
    return 3;
  }
  
  // Progress to next level (0.0 to 1.0)
  double get progress {
    if (completedDrawings >= 100) return 1.0;
    if (completedDrawings >= 50) return completedDrawings / 100;
    if (completedDrawings >= 10) return completedDrawings / 50;
    if (completedDrawings >= 3) return completedDrawings / 10;
    return completedDrawings / 3;
  }
  
  // Format time spent as hours and minutes
  String get timeSpentFormatted {
    final hours = timeSpentMinutes ~/ 60;
    final minutes = timeSpentMinutes % 60;
    if (hours > 0) {
      return "$hours h $minutes min";
    } else {
      return "$minutes min";
    }
  }
  
  // Create from SharedPreferences
  static Future<ArtStats> fromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return ArtStats(
      completedDrawings: prefs.getInt('stats_completed_drawings') ?? 0,
      completedLessons: prefs.getInt('stats_completed_lessons') ?? 0,
      timeSpentMinutes: prefs.getInt('stats_time_spent_minutes') ?? 0,
    );
  }
  
  // Save to SharedPreferences
  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('stats_completed_drawings', completedDrawings);
    await prefs.setInt('stats_completed_lessons', completedLessons);
    await prefs.setInt('stats_time_spent_minutes', timeSpentMinutes);
  }
  
  // Create a copy with updated values
  ArtStats copyWith({
    int? completedDrawings,
    int? completedLessons,
    int? timeSpentMinutes,
  }) {
    return ArtStats(
      completedDrawings: completedDrawings ?? this.completedDrawings,
      completedLessons: completedLessons ?? this.completedLessons,
      timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
    );
  }
}

class StatsController extends GetxController {
  ArtStats stats = ArtStats();
  bool isLoading = true;
  
  @override
  void onInit() {
    super.onInit();
    loadStats();
  }
  
  Future<void> loadStats() async {
    isLoading = true;
    update();
    
    stats = await ArtStats.fromPrefs();
    
    isLoading = false;
    update();
  }
  
  Future<void> markDrawingComplete() async {
    stats = stats.copyWith(completedDrawings: stats.completedDrawings + 1);
    await stats.saveToPrefs();
    update();
  }
  
  Future<void> markLessonComplete() async {
    stats = stats.copyWith(
      completedLessons: stats.completedLessons + 1,
      completedDrawings: stats.completedDrawings + 1
    );
    await stats.saveToPrefs();
    update();
  }
  
  Future<void> addTimeSpent(int minutes) async {
    stats = stats.copyWith(timeSpentMinutes: stats.timeSpentMinutes + minutes);
    await stats.saveToPrefs();
    update();
  }
}

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> with TickerProviderStateMixin {
  final List<Color> _accentColors = [
    const Color(0xFF00D2FF),
    const Color(0xFFFFA500),
    const Color(0xFFFF6B6B),
    const Color(0xFF46DB54),
  ];
  
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  late AnimationController _rotateAnimationController;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _rotateAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
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
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    _rotateAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    
    return GetBuilder<StatsController>(
      init: StatsController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          appBar: AppAppBarIOS(
            title: "Your Achievements",
            backgroundColor: Colors.transparent,
            titleColor: Colors.white,
            backButtonIconColor: Colors.white,
            backButtonBackgroundColor: Colors.white.withOpacity(0.1),
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              _buildAnimatedBackground(),
              
              SafeArea(
                child: controller.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              _buildUserRankSection(controller.stats),
                              const SizedBox(height: 30),
                              _buildStatsCards(controller.stats),
                              const SizedBox(height: 30),
                              _buildAchievementSection(controller.stats),
                              const SizedBox(height: 30),
                              _buildStreakSection(),
                              const SizedBox(height: 30),
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
        // Rotating gradient background
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
        // Second gradient
        Positioned(
          bottom: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Color(0x30FF6B6B),
                  Color(0x00121212),
                ],
                stops: [0.0, 0.7],
              ),
            ),
          ),
        ),
        // Blurred overlay
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }

  Widget _buildUserRankSection(ArtStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "You are a",
          style: TextStyle(
            fontSize: 22,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              alignment: Alignment.centerLeft,
              child: Text(
                stats.rank,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: _accentColors[0],
                  shadows: [
                    Shadow(
                      color: _accentColors[0].withOpacity(0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        
        // Level progress
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Level ${stats.level}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  stats.level < 5 ? "${stats.completedDrawings}/${stats.nextLevelAt}" : "Mastered",
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
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                
                // Progress
                Container(
                  height: 12,
                  width: MediaQuery.of(context).size.width * 0.9 * stats.progress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _accentColors[0],
                        _accentColors[1],
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: _accentColors[0].withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCards(ArtStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Stats",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                "Drawings",
                "${stats.completedDrawings}",
                Icons.brush_outlined,
                _accentColors[0],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                "Lessons",
                "${stats.completedLessons}",
                Icons.school_outlined,
                _accentColors[1],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                "Time Spent",
                stats.timeSpentFormatted,
                Icons.timer_outlined,
                _accentColors[2],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementSection(ArtStats stats) {
    final List<Map<String, dynamic>> achievements = [
      {
        'title': 'First Drawing',
        'description': 'Complete your first drawing',
        'icon': CupertinoIcons.pencil_outline,
        'isComplete': stats.completedDrawings >= 1,
        'color': _accentColors[0],
      },
      {
        'title': 'Quick Learner',
        'description': 'Complete 3 drawings',
        'icon': CupertinoIcons.star,
        'isComplete': stats.completedDrawings >= 3,
        'color': _accentColors[1],
      },
      {
        'title': 'Dedicated Artist',
        'description': 'Complete 10 drawings',
        'icon': CupertinoIcons.paintbrush,
        'isComplete': stats.completedDrawings >= 10,
        'color': _accentColors[2],
      },
      {
        'title': 'Art Professional',
        'description': 'Complete 50 drawings',
        'icon': CupertinoIcons.wand_stars,
        'isComplete': stats.completedDrawings >= 50,
        'color': _accentColors[3],
      },
      {
        'title': 'Master Creator',
        'description': 'Complete 100 drawings',
        'icon': CupertinoIcons.star_circle,
        'isComplete': stats.completedDrawings >= 100,
        'color': _accentColors[0],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Achievements",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 16),
        ...achievements.map((achievement) => _buildAchievementItem(achievement)),
      ],
    );
  }

  Widget _buildAchievementItem(Map<String, dynamic> achievement) {
    final bool isComplete = achievement['isComplete'] as bool;
    final Color color = achievement['color'] as Color;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete ? color.withOpacity(0.3) : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isComplete ? color.withOpacity(0.15) : Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: isComplete ? color : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Icon(
              achievement['icon'] as IconData,
              color: isComplete ? color : Colors.white.withOpacity(0.4),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isComplete ? Colors.white : Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement['description'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isComplete ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: isComplete ? color : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Icon(
              isComplete ? CupertinoIcons.checkmark : CupertinoIcons.lock,
              color: isComplete ? color : Colors.white.withOpacity(0.4),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Drawing Streak",
          style: TextStyle(
            fontSize: 20,
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
                      const Text(
                        "2 Day Streak",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Keep up the good work!",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _accentColors[1].withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.flame,
                      color: _accentColors[1],
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (index) {
                  final bool isActive = index < 2;
                  final bool isToday = index == 1;
                  final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  
                  return Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isActive
                              ? _accentColors[1].withOpacity(isToday ? 0.3 : 0.2)
                              : Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive
                                ? _accentColors[1].withOpacity(isToday ? 1 : 0.5)
                                : Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: isActive
                            ? Icon(
                                CupertinoIcons.checkmark,
                                color: isToday
                                    ? _accentColors[1]
                                    : _accentColors[1].withOpacity(0.7),
                                size: 18,
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weekdays[index],
                        style: TextStyle(
                          fontSize: 12,
                          color: isToday
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}