import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/controller/drawing_controller.dart';
import 'package:ar_draw/controller/level_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LessonStepController extends GetxController {
  final String? levelKey;
  final int lessonIndex;
  final LessonData lesson;

  int currentStepIndex = 0;
  List<bool> completedSteps = [];

  SharedPreferences? _prefs;
  String get _prefsKey => 'lesson_${levelKey}_${lessonIndex}_steps';

  LevelController? levelController;

  LessonStepController({
    required this.levelKey,
    required this.lessonIndex,
    required this.lesson,
  });

  @override
  void onInit() {
    super.onInit();

    completedSteps = List.generate(lesson.dataStep.length, (_) => false);
    _initPreferences();

    try {
      levelController = Get.find<LevelController>(tag: levelKey);
    } catch (e) {
      "LevelController not found, creating new one for $levelKey".logs();
      levelController = Get.put(LevelController(levelKey!), tag: levelKey);
    }
  }

  Future<void> _initPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      loadStepProgress();
    } catch (e) {
      "Error initializing preferences: $e".errorLogs();
    }
  }

  void loadStepProgress() {
    if (_prefs != null) {
      List<String> completedIndices = _prefs!.getStringList(_prefsKey) ?? [];

      for (int i = 0; i < completedSteps.length; i++) {
        completedSteps[i] = completedIndices.contains(i.toString());
      }

      "Loaded step progress from prefs: $completedSteps".logs();
      update();
    }
  }

  Future<void> saveStepProgress() async {
    if (_prefs != null) {
      List<String> completedIndices = [];
      for (int i = 0; i < completedSteps.length; i++) {
        if (completedSteps[i]) {
          completedIndices.add(i.toString());
        }
      }

      await _prefs!.setStringList(_prefsKey, completedIndices);
      "Saved step progress to prefs: $completedIndices".logs();
    }
  }

  void markStepCompleted() {
    if (currentStepIndex < completedSteps.length) {
      completedSteps[currentStepIndex] = true;
      saveStepProgress();
      update();
    }
  }

  bool goToNextStep() {
    if (currentStepIndex < lesson.dataStep.length - 1) {
      markStepCompleted();
      currentStepIndex++;
      update();
      return true;
    }
    return false;
  }

  bool goToPreviousStep() {
    if (currentStepIndex > 0) {
      currentStepIndex--;
      update();
      return true;
    }
    return false;
  }

  Future<void> completeLessonAndSave() async {
    for (int i = 0; i < completedSteps.length; i++) {
      completedSteps[i] = true;
    }
    await saveStepProgress();

    if (levelController != null) {
      await levelController!.markLessonAsCompleted(lessonIndex);
      "Marked lesson $lessonIndex as completed".logs();
    }

    update();
  }

  String? getCurrentStepImage() {
    if (currentStepIndex >= 0 && currentStepIndex < lesson.dataStep.length) {
      return lesson.dataStep[currentStepIndex];
    }
    return null;
  }

  bool isLastStep() {
    return currentStepIndex == lesson.dataStep.length - 1;
  }

  double getStepProgress() {
    if (lesson.dataStep.isNotEmpty) {
      return (currentStepIndex + 1) / lesson.dataStep.length;
    }
    return 0.0;
  }

  int getCompletedStepsCount() {
    return completedSteps.where((completed) => completed).length;
  }
}
