import 'dart:convert';
import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/controller/drawing_controller.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LevelController extends GetxController {
  final String levelKey;
  List<LessonData> lessons = [];
  List<bool> completedLessons = [];
  DrawingController? drawingController;
  SharedPreferences? _prefs;

  String get _prefsKey => 'level_${levelKey}_progress';

  LevelController(this.levelKey);

  @override
  void onInit() {
    super.onInit();
    _initPreferences();

    drawingController = Get.isRegistered<DrawingController>()
        ? Get.find<DrawingController>()
        : null;
  }

  Future<void> _initPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await loadLessonsForLevel();
    } catch (e) {
      "Error initializing preferences: $e".errorLogs();
    }
  }

  Future<void> loadLessonsForLevel() async {
    try {
      if (drawingController != null &&
          drawingController!.lessonMap.isNotEmpty &&
          drawingController!.lessonMap.containsKey(levelKey)) {
        lessons = drawingController!.lessonMap[levelKey] ?? [];
        "Reused ${lessons.length} lessons from DrawingController for $levelKey"
            .logs();
      } else {
        String jsonString = await rootBundle.loadString(AppAsset.lessonsJson);
        List<dynamic> jsonData = json.decode(jsonString);

        lessons = jsonData
            .map((item) => LessonData.fromJson(item))
            .where((lesson) => lesson.level == levelKey)
            .toList();

        "Loaded ${lessons.length} lessons from assets for $levelKey".logs();
      }

      loadCompletedLessonsFromPrefs();
      update();
    } catch (e) {
      "Error loading lessons: $e".errorLogs();
    }
  }

  void loadCompletedLessonsFromPrefs() {
    if (_prefs != null) {
      List<String> completedIndices = _prefs!.getStringList(_prefsKey) ?? [];

      completedLessons = List.generate(lessons.length, (index) {
        return completedIndices.contains(index.toString());
      });

      "Loaded completed lessons from prefs: $completedLessons".logs();

      updateLevelProgressInDrawingController();
    } else {
      completedLessons = List.generate(lessons.length, (_) => false);
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

  Future<void> markLessonAsCompleted(int index) async {
    "Marking lesson as completed for index: $index in level: $levelKey".logs();
    if (index < 0 || index >= completedLessons.length) return;

    completedLessons[index] = true;

    await _saveCompletedLessonsToPrefs();
    updateLevelProgressInDrawingController();

    // Force UI update
    update();

    // Notify any listening screens - important for UI refresh
    Get.forceAppUpdate();
  }

  Future<void> _saveCompletedLessonsToPrefs() async {
    if (_prefs != null) {
      List<String> completedIndices = [];
      for (int i = 0; i < completedLessons.length; i++) {
        if (completedLessons[i]) {
          completedIndices.add(i.toString());
        }
      }

      await _prefs!.setStringList(_prefsKey, completedIndices);
      "Saved completion status to preferences: $completedIndices for level: $levelKey"
          .logs();
    }
  }

  void updateLevelProgressInDrawingController() {
    if (drawingController != null &&
        drawingController!.levelProgress.containsKey(levelKey)) {
      double progress = getLevelProgress();
      drawingController!.levelProgress[levelKey] = progress;
      drawingController!.update();
      "Updated progress in DrawingController for level $levelKey: $progress"
          .logs();
    }
  }
}
