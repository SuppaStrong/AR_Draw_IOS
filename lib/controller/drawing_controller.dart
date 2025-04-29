import 'dart:convert';

import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app_routes/route_helper.dart';
import 'package:ar_draw/service/permission_service.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class LessonData {
  final String title;
  final String icon;
  final int steps;
  final List<String> dataStep;
  final int views;
  final String level;
  final String difficulty;

  LessonData({
    required this.title,
    required this.icon,
    required this.steps,
    required this.dataStep,
    required this.views,
    required this.level,
    required this.difficulty,
  });

  factory LessonData.fromJson(Map<String, dynamic> json) {
    return LessonData(
      title: json['title'] ?? '',
      icon: json['icon'] ?? '',
      steps: (json['dataStep'] as List).length,
      dataStep: List<String>.from(json['dataStep'] ?? []),
      views: json['views'] ?? 0,
      level: json['level'] ?? '',
      difficulty: json['difficulty'] ?? '',
    );
  }
}

class DrawingController extends GetxController {
  Map<String, List<String>> imagesMap = {};
  Map<String, List<String>> trendingMap = {};
  Map<String, List<LessonData>> lessonMap = {
    'beginner': [],
    'intermediate': [],
    'expert': [],
  };
  Map<String, double> levelProgress = {
    'beginner': 0.0,
    'intermediate': 0.0,
    'expert': 0.0,
  };

  XFile? categoryImage;
  CroppedFile? croppedFile;
  bool isImagePickerActive = false;
  List<Color>? imageColorMap = [
    AppColorConstant.appBlue,
    AppColorConstant.appOrange,
    AppColorConstant.appViolate,
    AppColorConstant.appGreenSheen,
    AppColorConstant.appPastelGreen,
    AppColorConstant.appBlueberry,
    AppColorConstant.appBegoniaRed,
    AppColorConstant.appDarkPink,
    AppColorConstant.appAquamarine
  ];
  @override
  void onInit() {
    loadImagesFromJson();
    super.onInit();
  }

  Future<void> loadImagesFromJson() async {
    try {
      String jsonString =
          await rootBundle.loadString(AppAsset.staticImagesJson);
      String trendingJsonString =
          await rootBundle.loadString(AppAsset.trendingImagesJson);
      String lessonJsonString =
          await rootBundle.loadString(AppAsset.lessonsJson);
      Map<String, dynamic> jsonData = json.decode(jsonString);
      Map<String, dynamic> trendingJsonData = json.decode(trendingJsonString);
      List<dynamic> lessonJsonData = json.decode(lessonJsonString);
      for (var lessonItem in lessonJsonData) {
        LessonData lesson = LessonData.fromJson(lessonItem);

        if (lessonMap.containsKey(lesson.level)) {
          lessonMap[lesson.level]!.add(lesson);
        } else {
          'Unknown level found in lesson JSON: ${lesson.level}'.errorLogs();
        }
      }
      imagesMap =
          jsonData.map((key, value) => MapEntry(key, List<String>.from(value)));
      trendingMap = trendingJsonData
          .map((key, value) => MapEntry(key, List<String>.from(value)));
      update();
    } catch (e) {
      "Error loading JSON: $e".errorLogs();
    }
  }

  Future<void> getImageFromGallery() async {
    if (isImagePickerActive) return;
    final permissionGranted =
        await PermissionService.instance.requestStorageOrMediaPermission();
    if (permissionGranted) {
      isImagePickerActive = true;
      categoryImage = await selectImage(false);

      if (categoryImage != null) {
        await cropImage();
      } else {
        'No image selected'.infoLogs();
      }
    }
    isImagePickerActive = false;
  }

  Future<void> getImageFromCamera() async {
    if (isImagePickerActive) return;

    isImagePickerActive = true;
    if (await PermissionService.instance.requestPermission(Permission.camera)) {
      categoryImage = await selectImage(true);
      if (categoryImage != null) {
        await cropImage();
      } else {
        'No image selected'.infoLogs();
      }
    }
    isImagePickerActive = false;
  }

  Future<XFile?> selectImage(bool isCamera) async {
    XFile? pickedFile;
    if (isCamera) {
      pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    } else {
      pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    }

    if (pickedFile != null) {
      'Picked file --> ${pickedFile.path}'.infoLogs();
      return pickedFile;
    }
    return null;
  }

  Future<void> cropImage() async {
    if (categoryImage != null) {
      croppedFile = await ImageCropper().cropImage(
        sourcePath: categoryImage!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Profile',
            toolbarColor: AppColorConstant.appWhite,
            toolbarWidgetColor: AppColorConstant.appBlack,
            initAspectRatio: CropAspectRatioPreset.original,
            backgroundColor: AppColorConstant.appWhite200,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Cropper',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        'Cropped file --> ${croppedFile!.path}'.infoLogs();
        RouteHelper.instance.gotoPreviewScreen(
            imagePath: croppedFile!.path, isImage: true, isText: false);
        update();
      }
    }
  }
}
