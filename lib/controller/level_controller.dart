import 'dart:convert';

import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/controller/drawing_controller.dart';
import 'package:flutter/services.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class LevelController extends GetxController {
  final String levelKey;
  List<LessonData> lessons = [];
  List<bool> completedLessons = [];

  LevelController(this.levelKey);

  @override
  void onInit() {
    super.onInit();
    loadLessonsForLevel();
  }

  Future<void> loadLessonsForLevel() async {
    try {
      // Load from assets or API
      String jsonString = await rootBundle.loadString(AppAsset.lessonsJson);
      List<dynamic> jsonData = json.decode(jsonString);

      // Filter lessons for this level
      lessons = jsonData
          .map((item) => LessonData.fromJson(item))
          .where((lesson) => lesson.level == levelKey)
          .toList();

      // Initialize completed lessons (would typically come from local storage)
      // For demo, set some lessons as completed
      completedLessons = List.generate(lessons.length, (index) => index < 2);

      update();
    } catch (e) {
      "Error loading lessons: $e".errorLogs();
    }
  }

  bool isLessonCompleted(int index) {
    if (index < 0 || index >= completedLessons.length) return false;
    return completedLessons[index];
  }

  int getCompletedLessonsCount() {
    return completedLessons.where((completed) => completed).length;
  }

  double getLevelProgress() {
    if (lessons.isEmpty) return 0.0;
    return getCompletedLessonsCount() / lessons.length;
  }

  void markLessonAsCompleted(int index) {
    if (index < 0 || index >= completedLessons.length) return;
    completedLessons[index] = true;
    update();
    // Here you would save to local storage or server
  }
}
