import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/widgets/app_app_bar.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app_routes/route_helper.dart';
import 'package:ar_draw/controller/sketch_draw_controller.dart';
import 'package:ar_draw/screen/dashboard_module/sketch_draw/sketch_draw_screen_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SketchDrawScreen extends StatefulWidget {
  const SketchDrawScreen({super.key});

  @override
  State<SketchDrawScreen> createState() => SketchDrawScreenState();
}

class SketchDrawScreenState extends State<SketchDrawScreen> {
  SketchDrawScreenHelper? sketchDrawScreenHelper;
  SketchDrawController? sketchDrawController;

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    sketchDrawScreenHelper ??= SketchDrawScreenHelper(this);

    return GetBuilder(
      init: SketchDrawController(),
      builder: (SketchDrawController controller) {
        sketchDrawController = controller;
        return Scaffold(
          appBar: AppAppBarIOS(
            title: AppStringConstant.sketchDraw,
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
                  onPressed: () => RouteHelper.instance.gotoHowToUseScreen(),
                ),
              ),
            ],
          ),
          body: CupertinoPageScaffold(
            backgroundColor: CupertinoColors.systemBackground,
            child: SafeArea(
              top: !sketchDrawScreenHelper!.isUiHidden,
              bottom: false,
              child: Column(
                children: [
                  sketchDrawScreenHelper!.isCameraInitialized
                      ? buildCameraView()
                      : const Expanded(
                          child: Center(child: CircularProgressIndicator())),
                  if (!sketchDrawScreenHelper!.isUiHidden) ...[
                    buildOpacityView(),
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

  Widget buildCameraView() {
    return Expanded(
      child: SizedBox(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
                width: double.infinity,
                child:
                    CameraPreview(sketchDrawScreenHelper!.cameraController!)),
            Positioned(
              left: sketchDrawScreenHelper?.position.dx,
              top: sketchDrawScreenHelper?.position.dy,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: sketchDrawScreenHelper?.onScaleStart,
                onScaleUpdate: sketchDrawScreenHelper?.onScaleUpdate,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..scale(
                      sketchDrawScreenHelper?.isZoomed == true
                          ? (sketchDrawScreenHelper?.scale ?? 1.0)
                          : 1.0,
                    )
                    ..rotateZ(sketchDrawScreenHelper?.rotationAngle ?? 0.0)
                    ..scale(
                        sketchDrawScreenHelper!.isFlipped ? -1.0 : 1.0, 1.0),
                  child: Opacity(
                      opacity: sketchDrawScreenHelper!.currentSliderValue,
                      child: (sketchDrawScreenHelper?.isText == true)
                          ? Image.memory(
                              sketchDrawScreenHelper?.textImageBytes ??
                                  Uint8List(0),
                              width: Get.size.width / 1.2,
                              fit: BoxFit.fill)
                          : AppImageAsset(
                              image: sketchDrawScreenHelper?.imagePath ?? "",
                              isFile: sketchDrawScreenHelper?.isImage == true &&
                                      sketchDrawScreenHelper?.isText == false
                                  ? true
                                  : false,
                              width: Get.size.width / 1.2,
                              fit: BoxFit.cover,
                            )),
                ),
              ),
            ),
            // Recording indicator
            if (sketchDrawScreenHelper!.isRecordingVideo)
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          sketchDrawScreenHelper!.isPaused
                              ? CupertinoIcons.pause_fill
                              : CupertinoIcons.recordingtape,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          sketchDrawScreenHelper!
                              .getFormattedRecordingDuration(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: sketchDrawScreenHelper!.isPaused
                              ? sketchDrawScreenHelper!.resumeVideoRecording
                              : sketchDrawScreenHelper!.pauseVideoRecording,
                          child: Icon(
                            sketchDrawScreenHelper!.isPaused
                                ? CupertinoIcons.play_fill
                                : CupertinoIcons.pause_fill,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Bottom floating buttons
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
                        icon: sketchDrawScreenHelper!.isLocked
                            ? CupertinoIcons.lock_fill
                            : CupertinoIcons.lock_open_fill,
                        isActive: sketchDrawScreenHelper!.isLocked,
                        onTap: () => sketchDrawScreenHelper!.toggleLock(),
                      ),
                      const SizedBox(width: 12),
                      _buildFloatingButton(
                        icon: CupertinoIcons.arrow_counterclockwise,
                        onTap: () =>
                            sketchDrawScreenHelper!.resetToInitialPosition(),
                      ),
                    ],
                  ),
                  _buildFloatingButton(
                    icon: sketchDrawScreenHelper!.isUiHidden
                        ? CupertinoIcons.eye
                        : CupertinoIcons.eye_slash,
                    isActive: true,
                    onTap: () => sketchDrawScreenHelper!.toggleUiVisibility(),
                  ),
                ],
              ),
            )
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
                      value: sketchDrawScreenHelper!.currentSliderValue,
                      min: 0.2,
                      max: 1.0,
                      activeColor: Colors.white,
                      thumbColor: Colors.white,
                      onChanged: (double value) {
                        sketchDrawScreenHelper!.currentSliderValue = value;
                        sketchDrawController?.update();
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
            isActive: sketchDrawScreenHelper!.isZoomed,
            onTap: () => sketchDrawScreenHelper?.toggleZoom(),
            activeColor: const Color(0xFF6C63FF),
            inactiveColor: Colors.white.withOpacity(0.2),
            textColor: Colors.white,
          ),
          _buildOptionButton(
            icon: CupertinoIcons.bolt_fill,
            label: AppStringConstant.flash,
            isActive: sketchDrawScreenHelper!.flashEnabled,
            onTap: () => sketchDrawScreenHelper!.toggleFlash(),
            activeColor: const Color(0xFF3498DB),
            inactiveColor: Colors.white.withOpacity(0.2),
            textColor: Colors.white,
          ),
          _buildOptionButton(
            icon: CupertinoIcons.arrow_left_right,
            label: AppStringConstant.flip,
            isActive: sketchDrawScreenHelper!.isFlipped,
            onTap: () {
              sketchDrawScreenHelper!.toggleFlip();
              sketchDrawController?.update();
            },
            activeColor: const Color(0xFFE67E22),
            inactiveColor: Colors.white.withOpacity(0.2),
            textColor: Colors.white,
          ),
          _buildOptionButton(
            icon: CupertinoIcons.videocam_fill,
            label: AppStringConstant.record,
            isActive: sketchDrawScreenHelper!.isRecordingVideo,
            onTap: sketchDrawScreenHelper!.isRecordingVideo
                ? sketchDrawScreenHelper!.stopVideoRecording
                : sketchDrawScreenHelper!.startVideoRecording,
            activeColor: const Color(0xFFE74C3C),
            inactiveColor: Colors.white.withOpacity(0.2),
            textColor: Colors.white,
          ),
          _buildOptionButton(
            icon: CupertinoIcons.rotate_right,
            label: AppStringConstant.rotate,
            isActive: sketchDrawScreenHelper!.rotationAngle != 0.0,
            description: "Use two fingers",
            onTap: null, // No onTap as rotation is now handled via gestures
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
