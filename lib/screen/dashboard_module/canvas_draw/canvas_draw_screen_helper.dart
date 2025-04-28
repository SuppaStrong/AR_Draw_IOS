import 'dart:convert';
import 'dart:typed_data';

import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/screen/dashboard_module/canvas_draw/canvas_draw_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CanvasDrawScreenHelper {
  final CanvasDrawScreenState state;
  bool isText = false;
  bool isImage = false;
  String? imagePath;
  Offset position = Offset.zero;
  Offset initialPosition = Offset.zero;
  double scale = 1.0;
  double baseScale = 1.0;
  double rotationAngle = 0.0;
  bool isFlipped = false;
  bool isColorTap = false;
  double currentSliderValue = 1.0;
  Color selectedColor = AppColorConstant.appWhite;
  Uint8List? textImageBytes;
  
  // For gesture handling
  double previousRotation = 0.0;
  
  // UI visibility control
  bool isUiHidden = false;
  
  List<Color>? colorList = [
    AppColorConstant.appWhite,
    AppColorConstant.appBlack,
    AppColorConstant.appBlue,
    AppColorConstant.appOrange,
    AppColorConstant.appViolate,
    AppColorConstant.appPastelGreen,
    AppColorConstant.appBlueberry,
    AppColorConstant.appBegoniaRed,
    AppColorConstant.appDarkPink,
    AppColorConstant.appAquamarine
  ];

  bool isLocked = false;
  bool isZoomed = false;

  CanvasDrawScreenHelper(this.state) {
    init();
  }

  void init() {
    imagePath = Get.arguments['imagePath'];
    isText = Get.arguments['isText'];
    isImage = Get.arguments['isImage'];
    if (isText == true && imagePath != null) {
      try {
        textImageBytes = base64Decode(imagePath!);
      } catch (e) {
        'Error decoding base64 image: $e'.errorLogs();
      }
    }
    setInitialPosition();
  }

  void setInitialPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = Get.size.width;
      final screenHeight = Get.size.height;

      final contentWidth = screenWidth / 1.2;
      final contentHeight = isText || !isImage 
          ? screenHeight / 1.5 
          : screenHeight / 1.2;

      initialPosition = Offset(
        (screenWidth - contentWidth) / 2,
        (screenHeight - contentHeight) / 2.5,
      );
      position = initialPosition;

      state.canvasDrawController?.update();
    });
  }

  void resetToInitialPosition() {
    position = initialPosition;
    scale = 1.0;
    baseScale = 1.0;
    rotationAngle = 0.0;
    previousRotation = 0.0;
    isFlipped = false;
    isZoomed = false;
    currentSliderValue = 1.0;
    state.canvasDrawController?.update();
  }

  void onScaleStart(ScaleStartDetails details) {
    if (isLocked) return;
    
    baseScale = scale;
    previousRotation = 0.0; // Reset for this gesture
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    if (isLocked) return;

    // Handle position (pan)
    position += details.focalPointDelta;
    
    // Handle scaling if zoom is enabled
    if (isZoomed) {
      scale = (baseScale * details.scale).clamp(1.0, 3.0);
    }

    // Handle rotation with two fingers
    if (details.pointerCount >= 2) {
      // The rotation value in details represents the angle between two fingers
      final double delta = details.rotation - previousRotation;
      rotationAngle += delta;
      previousRotation = details.rotation;
    }

    state.canvasDrawController?.update();
  }

  void toggleLock() {
    isLocked = !isLocked;
    state.canvasDrawController?.update();
  }

  void toggleFlip() {
    if (!isLocked) {
      isFlipped = !isFlipped;
    }
  }

  void toggleZoom() {
    if (!isLocked) {
      isZoomed = !isZoomed;
      state.canvasDrawController?.update();
    }
  }

  void toggleColor() {
    isColorTap = !isColorTap;
    state.canvasDrawController?.update();
  }

  void changeColor(int index) {
    selectedColor = colorList![index];
    state.canvasDrawController?.update();
  }
  
  void toggleUiVisibility() {
    isUiHidden = !isUiHidden;
    state.canvasDrawController?.update();
  }
}