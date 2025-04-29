import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/screen/dashboard_module/sketch_draw/sketch_draw_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class SketchDrawScreenHelper {
  SketchDrawScreenState? state;
  CameraController? cameraController;
  List<CameraDescription>? cameras;
  bool isCameraInitialized = false;
  XFile? pictureFile;
  XFile? videoFile;
  bool isRecordingVideo = false;
  bool isPaused = false;
  Offset position = Offset.zero;
  Offset initialPosition = Offset.zero;
  double scale = 1.0;
  double baseScale = 1.0;
  String? imagePath;
  Uint8List? textImageBytes;
  double currentSliderValue = 1.0;
  bool flashEnabled = false;
  double rotationAngle = 0.0;
  bool isFlipped = false;
  bool isText = false;
  bool isImage = false;
  Timer? recordingTimer;
  Duration recordingDuration = Duration.zero;
  bool isLocked = false;
  bool isZoomed = false;

  // New variables for improved rotation and UI
  double previousRotation = 0.0; // Track previous rotation for gesture
  bool isUiHidden = false; // Control UI visibility

  SketchDrawScreenHelper(this.state) {
    init();
    initializeCamera();
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
    } else if (imagePath != null && File(imagePath!).existsSync()) {
      pictureFile = XFile(imagePath!);
    }
    setInitialPosition();
  }

  void setInitialPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = Get.size.width;
      final screenHeight = Get.size.height;

      final contentWidth = screenWidth / 1.2;
      final contentHeight =
          isText || !isImage ? screenHeight / 1.5 : screenHeight / 1.2;

      initialPosition = Offset(
        (screenWidth - contentWidth) / 2,
        (screenHeight - contentHeight) / 2.5,
      );
      position = initialPosition;

      state?.sketchDrawController?.update();
    });
  }

  void resetToInitialPosition() {
    position = initialPosition;
    scale = 1.0;
    baseScale = 1.0;
    rotationAngle = 0.0;
    previousRotation = 0.0; // Reset previous rotation
    isFlipped = false;
    isZoomed = false;
    currentSliderValue = 1.0;
    state?.sketchDrawController?.update();
  }

  void toggleLock() {
    isLocked = !isLocked;
    state?.sketchDrawController?.update();
  }

  void toggleFlip() {
    if (!isLocked) {
      isFlipped = !isFlipped;
    }
  }

  void toggleZoom() {
    if (!isLocked) {
      isZoomed = !isZoomed;
      state?.sketchDrawController?.update();
    }
  }

  // New method to toggle UI visibility
  void toggleUiVisibility() {
    isUiHidden = !isUiHidden;
    state?.sketchDrawController?.update();
  }

  // Updated to match CanvasDrawScreenHelper's approach
  void onScaleStart(ScaleStartDetails details) {
    if (isLocked) return;

    baseScale = scale;
    previousRotation = 0.0; // Reset for this gesture
  }

  // Updated to handle two-finger rotation
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

    state?.sketchDrawController?.update();
  }

  // Legacy rotation method kept for compatibility but no longer needed for UI button
  void rotateImage() {
    if (!isLocked) {
      rotationAngle += (90 * (3.14159 / 180));
      if (rotationAngle >= (2 * 3.14159)) {
        rotationAngle = 0.0;
      }
      state?.sketchDrawController?.update();
    }
  }

  Future<void> initializeCamera() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        cameraController = CameraController(cameras![0], ResolutionPreset.high);
        await cameraController?.initialize();
        isCameraInitialized = true;
        state?.sketchDrawController?.update();
      }
    } catch (e) {
      "Error initializing camera: $e".logs();
    }
  }

  Future<void> startVideoRecording() async {
    if (!cameraController!.value.isInitialized || isRecordingVideo) {
      return;
    }

    try {
      await cameraController!.startVideoRecording();
      isRecordingVideo = true;
      startRecordingTimer();
      state?.sketchDrawController?.update();
    } catch (e) {
      "Error while starting video recording: $e".logs();
    }
  }

  Future<void> toggleFlash() async {
    if (cameraController != null) {
      flashEnabled = !flashEnabled;
      await cameraController!.setFlashMode(
        flashEnabled ? FlashMode.torch : FlashMode.off,
      );
    }
    state?.sketchDrawController?.update();
  }

  Future<void> stopVideoRecording() async {
    if (!isRecordingVideo) {
      return;
    }

    try {
      stopRecordingTimer();
      videoFile = await cameraController!.stopVideoRecording();

      final Directory? directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationSupportDirectory();
      final String newPath = '${directory?.path}/Movies';
      await Directory(newPath).create(recursive: true);

      final String filePath =
          '$newPath/${DateTime.now().millisecondsSinceEpoch}.mp4';
      await videoFile!.saveTo(filePath);

      // notifyGallery(filePath);
      isRecordingVideo = false;
      videoFile = XFile(filePath);
      state?.sketchDrawController?.update();
      "Video Successfully saved to Creation Section in Home".showSuccess();

      "Video saved to: $filePath".logs();
    } catch (e) {
      "Error while stopping video recording: $e".logs();
    }
  }

  Future<void> notifyGallery(String filePath) async {
    try {
      const channel = MethodChannel('com.example.sketchdraw/gallery');
      await channel.invokeMethod('scanMediaFile', {'path': filePath});
    } catch (e) {
      "Error notifying gallery: $e".logs();
    }
  }

  // Legacy method replaced by onScaleUpdate
  void onImageDrag(ScaleUpdateDetails details) {
    onScaleUpdate(details);
  }

  void startRecordingTimer() {
    recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      recordingDuration += const Duration(seconds: 1);
      state?.sketchDrawController?.update();
    });
  }

  void stopRecordingTimer() {
    recordingTimer?.cancel();
    recordingTimer = null;
    recordingDuration = Duration.zero;
  }

  void pauseRecordingTimer() {
    recordingTimer?.cancel();
  }

  void resumeRecordingTimer() {
    startRecordingTimer();
  }

  Future<void> pauseVideoRecording() async {
    if (isRecordingVideo && !isPaused) {
      try {
        await cameraController!.pauseVideoRecording();
        isPaused = true;
        pauseRecordingTimer();
        state?.sketchDrawController?.update();
      } catch (e) {
        "Error while pausing video recording: $e".logs();
      }
    }
  }

  Future<void> resumeVideoRecording() async {
    if (isRecordingVideo && isPaused) {
      try {
        await cameraController!.resumeVideoRecording();
        isPaused = false;
        resumeRecordingTimer();
        state?.sketchDrawController?.update();
      } catch (e) {
        "Error while resuming video recording: $e".logs();
      }
    }
  }

  String getFormattedRecordingDuration() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(recordingDuration.inMinutes.remainder(60));
    String seconds = twoDigits(recordingDuration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
