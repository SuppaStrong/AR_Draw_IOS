// ignore_for_file: use_build_context_synchronously

import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/widgets/app_app_bar.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app_routes/route_helper.dart';
import 'package:ar_draw/controller/canvas_draw_controller.dart';
import 'package:ar_draw/screen/dashboard_module/canvas_draw/canvas_draw_screen_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CanvasDrawScreen extends StatefulWidget {
  final List<String>? stepImages;
  final bool isLessonMode;
  final String? lessonId;
  final String? levelKey;
  final int? lessonIndex;

  const CanvasDrawScreen({
    super.key,
    this.stepImages,
    this.isLessonMode = false,
    this.lessonId,
    this.levelKey,
    this.lessonIndex,
  });

  @override
  State<CanvasDrawScreen> createState() => CanvasDrawScreenState();
}

class CanvasDrawScreenState extends State<CanvasDrawScreen>
    with SingleTickerProviderStateMixin {
  CanvasDrawScreenHelper? canvasDrawScreenHelper;
  CanvasDrawController? canvasDrawController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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
    "current screen --> $runtimeType".logs();

    return GetBuilder(
      init: CanvasDrawController(),
      builder: (CanvasDrawController controller) {
        canvasDrawController = controller;

        if (widget.isLessonMode &&
            widget.stepImages != null &&
            widget.stepImages!.isNotEmpty &&
            widget.levelKey != null &&
            widget.lessonIndex != null &&
            !controller.isLessonMode) {
          "Initializing lesson mode with ${widget.stepImages!.length} steps"
              .logs();

          controller.initLessonMode(
              widget.stepImages!, widget.levelKey!, widget.lessonIndex!);
        }

        canvasDrawScreenHelper ??= CanvasDrawScreenHelper(this);

        if (widget.isLessonMode && controller.isLessonMode) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            canvasDrawScreenHelper?.updateLessonStepImage();
          });
        }

        return Scaffold(
          appBar: AppAppBarIOS(
            title: widget.isLessonMode
                ? "${widget.lessonId} - Step ${controller.currentStepIndex + 1}/${widget.stepImages?.length ?? 0}"
                : AppStringConstant.canvasDraw,
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    CupertinoIcons.question,
                    color: AppColorConstant.appDeepPurple,
                  ),
                  onPressed: () {
                    RouteHelper.instance.gotoHowToUseScreen();
                  },
                ),
              ),
            ],
          ),
          body: CupertinoPageScaffold(
            backgroundColor: CupertinoColors.systemBackground,
            child: SafeArea(
              top: !canvasDrawScreenHelper!.isUiHidden,
              bottom: false,
              child: Column(
                children: [
                  buildCanvasView(),
                  if (widget.isLessonMode) buildStepControls(),
                  if (!canvasDrawScreenHelper!.isUiHidden) ...[
                    canvasDrawScreenHelper!.isColorTap
                        ? buildColorView()
                        : buildOpacityView(),
                    buildOptionsView()
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildCanvasView() {
    return Expanded(
      child: Container(
        color: canvasDrawScreenHelper?.selectedColor,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: canvasDrawScreenHelper?.position.dx,
              top: canvasDrawScreenHelper?.position.dy,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: canvasDrawScreenHelper?.onScaleStart,
                onScaleUpdate: canvasDrawScreenHelper?.onScaleUpdate,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..scale(
                      canvasDrawScreenHelper?.isZoomed == true
                          ? (canvasDrawScreenHelper?.scale ?? 1.0)
                          : 1.0,
                    )
                    ..rotateZ(canvasDrawScreenHelper?.rotationAngle ?? 0.0)
                    ..scale(
                        canvasDrawScreenHelper!.isFlipped ? -1.0 : 1.0, 1.0),
                  child: Opacity(
                    opacity: canvasDrawScreenHelper!.currentSliderValue,
                    child: (canvasDrawScreenHelper?.isText != true)
                        ? canvasDrawScreenHelper?.imagePath != null
                            ? AppImageAsset(
                                image: canvasDrawScreenHelper?.imagePath ?? "",
                                isFile: canvasDrawScreenHelper?.isImage ==
                                            true &&
                                        canvasDrawScreenHelper?.isText == false
                                    ? true
                                    : false,
                                width: Get.size.width / 1.2,
                                fit: BoxFit.cover,
                              )
                            : const SizedBox.shrink()
                        : (canvasDrawScreenHelper!.textImageBytes != null)
                            ? Image.memory(
                                canvasDrawScreenHelper!.textImageBytes!,
                                width: Get.size.width / 1.2,
                                fit: BoxFit.fill,
                              )
                            : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildFloatingButton(
                        icon: canvasDrawScreenHelper!.isLocked
                            ? CupertinoIcons.lock_fill
                            : CupertinoIcons.lock_open_fill,
                        isActive: canvasDrawScreenHelper!.isLocked,
                        onTap: () => canvasDrawScreenHelper!.toggleLock(),
                      ),
                      const SizedBox(width: 12),
                      _buildFloatingButton(
                        icon: CupertinoIcons.arrow_counterclockwise,
                        onTap: () =>
                            canvasDrawScreenHelper?.resetToInitialPosition(),
                      ),
                    ],
                  ),
                  _buildFloatingButton(
                    icon: canvasDrawScreenHelper!.isUiHidden
                        ? CupertinoIcons.eye
                        : CupertinoIcons.eye_slash,
                    isActive: true,
                    onTap: () => canvasDrawScreenHelper!.toggleUiVisibility(),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildStepControls() {
    if (!widget.isLessonMode || canvasDrawController == null) {
      return const SizedBox.shrink();
    }

    final bool isLastStep = canvasDrawController!.isLastStep();
    final double progress = canvasDrawController!.getStepProgress();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "Step ${canvasDrawController!.currentStepIndex + 1}/${widget.stepImages?.length ?? 0}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColorConstant.appDeepPurple,
                  ),
                ),
                const Spacer(),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColorConstant.appDeepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Stack(
              children: [
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Container(
                  height: 6,
                  width: MediaQuery.of(context).size.width * progress * 0.9,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColorConstant.appLightPurple,
                        AppColorConstant.appDeepPurple,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.stepImages?.length ?? 0,
                (index) {
                  bool isCurrent =
                      index == canvasDrawController!.currentStepIndex;
                  bool isCompleted =
                      index < canvasDrawController!.currentStepIndex;

                  return Container(
                    width: isCurrent ? 10 : 8,
                    height: isCurrent ? 10 : 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrent
                          ? AppColorConstant.appDeepPurple
                          : isCompleted
                              ? AppColorConstant.appLightPurple
                              : Colors.grey.withOpacity(0.3),
                      border: isCurrent
                          ? Border.all(
                              color: AppColorConstant.appDeepPurple
                                  .withOpacity(0.3),
                              width: 2,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStepNavigationButton(
                    icon: CupertinoIcons.arrow_left,
                    label: "Previous",
                    onTap: canvasDrawController!.currentStepIndex > 0
                        ? () {
                            if (canvasDrawController!.goToPreviousStep()) {
                              canvasDrawScreenHelper?.updateLessonStepImage();
                              _animationController.reset();
                              _animationController.forward();
                            }
                          }
                        : null,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildStepNavigationButton(
                    icon: isLastStep
                        ? CupertinoIcons.checkmark_circle
                        : CupertinoIcons.arrow_right,
                    label: isLastStep ? "Complete" : "Next",
                    isPrimary: true,
                    onTap: () async {
                      if (isLastStep) {
                        canvasDrawController!.markStepCompleted();
                        await canvasDrawController!.completeLessonAndSave();

                        if (context.mounted) {
                          await showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: const Text("Lesson Completed!"),
                              content: const Text(
                                  "Great job! You've completed this lesson."),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text("OK"),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                          );
                        }

                        Get.back();
                      } else {
                        if (canvasDrawController!.goToNextStep()) {
                          canvasDrawScreenHelper?.updateLessonStepImage();
                          _animationController.reset();
                          _animationController.forward();
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepNavigationButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool isPrimary = false,
  }) {
    final bool isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isPrimary && isEnabled
              ? const LinearGradient(
                  colors: [
                    AppColorConstant.appLightPurple,
                    AppColorConstant.appDeepPurple,
                  ],
                )
              : null,
          color: !isPrimary && isEnabled
              ? Colors.white
              : !isEnabled
                  ? Colors.grey.withOpacity(0.1)
                  : null,
          borderRadius: BorderRadius.circular(12),
          border: !isPrimary && isEnabled
              ? Border.all(color: AppColorConstant.appDeepPurple)
              : null,
          boxShadow: isEnabled && isPrimary
              ? [
                  BoxShadow(
                    color: AppColorConstant.appDeepPurple.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary
                  ? Colors.white
                  : isEnabled
                      ? AppColorConstant.appDeepPurple
                      : Colors.grey,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary
                    ? Colors.white
                    : isEnabled
                        ? AppColorConstant.appDeepPurple
                        : Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: isActive ? AppColorConstant.appDeepPurple : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : AppColorConstant.appDeepPurple,
          size: 22,
        ),
      ),
    );
  }

  Widget buildColorView() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9C27B0),
            Color(0xFF673AB7),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 1,
            color: Colors.white24,
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Row(
                children: List.generate(
                  canvasDrawScreenHelper!.colorList!.length,
                  (index) {
                    bool isSelected = canvasDrawScreenHelper?.selectedColor ==
                        canvasDrawScreenHelper?.colorList![index];
                    return buildColorButton(index, isSelected);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildColorButton(int index, bool isSelected) {
    return GestureDetector(
      onTap: () => canvasDrawScreenHelper!.changeColor(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.all(isSelected ? 3 : 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: canvasDrawScreenHelper!.colorList![index],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 3,
                spreadRadius: 0.5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: isSelected
              ? const Icon(
                  CupertinoIcons.checkmark,
                  color: Colors.white,
                  size: 18,
                )
              : null,
        ),
      ),
    );
  }

  Widget buildOpacityView() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9C27B0),
            Color(0xFF673AB7),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 1,
            color: Colors.white24,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.circle,
                    color: Colors.white54,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CupertinoSlider(
                      value: canvasDrawScreenHelper!.currentSliderValue,
                      min: 0.2,
                      max: 1.0,
                      activeColor: Colors.white,
                      thumbColor: Colors.white,
                      onChanged: (double value) {
                        canvasDrawScreenHelper!.currentSliderValue = value;
                        canvasDrawController?.update();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    CupertinoIcons.circle_fill,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOptionsView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9C27B0),
            Color(0xFF673AB7),
          ],
        ),
      ),
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 30,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildOptionButton(
            icon: CupertinoIcons.zoom_in,
            label: AppStringConstant.zoom,
            isActive: canvasDrawScreenHelper!.isZoomed,
            onTap: () => canvasDrawScreenHelper?.toggleZoom(),
            activeColor: const Color(0xFF6C63FF),
            inactiveColor: Colors.white.withOpacity(0.2),
            textColor: Colors.white,
          ),
          _buildOptionButton(
            icon: CupertinoIcons.paintbrush_fill,
            label: AppStringConstant.color,
            isActive: canvasDrawScreenHelper!.isColorTap,
            onTap: () => canvasDrawScreenHelper!.toggleColor(),
            activeColor: const Color(0xFF3498DB),
            inactiveColor: Colors.white.withOpacity(0.2),
            textColor: Colors.white,
          ),
          _buildOptionButton(
            icon: CupertinoIcons.arrow_left_right,
            label: AppStringConstant.flip,
            isActive: canvasDrawScreenHelper!.isFlipped,
            onTap: () {
              canvasDrawScreenHelper!.toggleFlip();
              canvasDrawController?.update();
            },
            activeColor: const Color(0xFFE67E22),
            inactiveColor: Colors.white.withOpacity(0.2),
            textColor: Colors.white,
          ),
          _buildOptionButton(
            icon: CupertinoIcons.rotate_right,
            label: AppStringConstant.rotate,
            isActive: canvasDrawScreenHelper!.rotationAngle != 0.0,
            description: "Use two fingers",
            onTap: null,
            activeColor: const Color(0xFF2ECC71),
            inactiveColor: Colors.white.withOpacity(0.2),
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    String? description,
    VoidCallback? onTap,
    Color activeColor = const Color(0xFF6C63FF),
    Color inactiveColor = const Color(0xFFF5F5F5),
    Color textColor = const Color(0xFF6C63FF),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(27),
              boxShadow: [
                BoxShadow(
                  color: isActive
                      ? activeColor.withOpacity(0.3)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : textColor,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          if (description != null)
            Text(
              description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }
}
