import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/controller/level_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CanvasDrawController extends GetxController {
  bool isLessonMode = false;
  String? levelKey;
  int? lessonIndex;
  List<String>? stepImages;
  int currentStepIndex = 0;

  List<bool> completedSteps = [];

  SharedPreferences? _prefs;
  String? _lessonProgressKey;

  @override
  void onInit() {
    super.onInit();
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      "Error initializing preferences: $e".errorLogs();
    }
  }

  void initLessonMode(List<String> steps, String levelKey, int lessonIndex) {
    isLessonMode = true;
    stepImages = steps;
    this.levelKey = levelKey;
    this.lessonIndex = lessonIndex;

    _lessonProgressKey = 'lesson_${levelKey}_${lessonIndex}_steps';

    completedSteps = List.generate(steps.length, (_) => false);

    loadStepProgress();

    update();
  }

  void loadStepProgress() {
    if (_prefs != null && _lessonProgressKey != null) {
      List<String> completedIndices =
          _prefs!.getStringList(_lessonProgressKey!) ?? [];

      for (int i = 0; i < completedSteps.length; i++) {
        completedSteps[i] = completedIndices.contains(i.toString());
      }
    }
  }

  Future<void> saveStepProgress() async {
    if (_prefs != null && _lessonProgressKey != null) {
      List<String> completedIndices = [];
      for (int i = 0; i < completedSteps.length; i++) {
        if (completedSteps[i]) {
          completedIndices.add(i.toString());
        }
      }

      await _prefs!.setStringList(_lessonProgressKey!, completedIndices);
    }
  }

  void markStepCompleted() {
    if (isLessonMode && currentStepIndex < completedSteps.length) {
      completedSteps[currentStepIndex] = true;
      saveStepProgress();
      update();
    }
  }

  bool goToNextStep() {
    if (isLessonMode && stepImages != null) {
      if (currentStepIndex < stepImages!.length - 1) {
        markStepCompleted();
        currentStepIndex++;
        update();
        return true;
      }
    }
    return false;
  }

  bool goToPreviousStep() {
    if (isLessonMode && currentStepIndex > 0) {
      currentStepIndex--;
      update();
      return true;
    }
    return false;
  }

  Future<void> completeLessonAndSave() async {
    if (isLessonMode && levelKey != null && lessonIndex != null) {
      for (int i = 0; i < completedSteps.length; i++) {
        completedSteps[i] = true;
      }
      await saveStepProgress();

      LevelController? levelController;
      try {
        levelController = Get.find<LevelController>(tag: levelKey);
      } catch (e) {
        levelController = Get.put(LevelController(levelKey!), tag: levelKey);
      }

      await levelController?.markLessonAsCompleted(lessonIndex!);
      update();
    }
  }

  String? getCurrentStepImage() {
    if (isLessonMode &&
        stepImages != null &&
        currentStepIndex >= 0 &&
        currentStepIndex < stepImages!.length) {
      return stepImages![currentStepIndex];
    }
    return null;
  }

  bool isLastStep() {
    return isLessonMode &&
        stepImages != null &&
        currentStepIndex == stepImages!.length - 1;
  }

  double getStepProgress() {
    if (isLessonMode && stepImages != null && stepImages!.isNotEmpty) {
      return (currentStepIndex + 1) / stepImages!.length;
    }
    return 0.0;
  }
}
