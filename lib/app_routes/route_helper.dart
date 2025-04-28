import 'package:ar_draw/app_routes/route_constant.dart';
import 'package:get/get.dart';

class RouteHelper {
  static final RouteHelper instance = RouteHelper._internal();

  factory RouteHelper() => instance;

  RouteHelper._internal();

  void gotoBack() => Get.back();

  void gotoOnboardingScreen() => Get.offAllNamed(RouteConstant.onboarding);

  void gotoHomeScreen() => Get.offAllNamed(RouteConstant.home);

  void gotoSettingScreen() => Get.toNamed(RouteConstant.setting);
  
  void gotoIAPScreen() => Get.toNamed(RouteConstant.iap);

  void gotoInstructionScreen() => Get.toNamed(RouteConstant.instruction);

  void gotoSelectLanguageScreen() => Get.toNamed(RouteConstant.selectLanguage);

  void gotoLevelScreen(String levelKey) => 
      Get.toNamed(RouteConstant.level, arguments: {'levelKey': levelKey});

  void gotoDrawingScreen() => Get.toNamed(RouteConstant.drawing);

  void gotoPreviewScreen({required String imagePath, required bool isImage, required bool isText}) =>
      Get.toNamed(RouteConstant.preview, arguments: {"imagePath": imagePath, "isImage": isImage, 'isText': isText});

  void gotoSketchDrawingScreen(String? imagePath, {required bool isText, required bool isImage}) =>
      Get.toNamed(RouteConstant.sketchDrawing, arguments: {"isText": isText, "isImage": isImage, "imagePath": imagePath});

  void gotoTextSketchScreen() => Get.toNamed(RouteConstant.textSketch);

  void gotoCategoryScreen(List<String>? imagesMap, String title) => Get.toNamed(RouteConstant.category, arguments: {'title': title, 'imagesMap': imagesMap});

  void gotoPhotoSketchScreen() => Get.toNamed(RouteConstant.photoSketch);

  void gotoCanvasScreen(String? imagePath, {required bool isText, required bool isImage}) =>
      Get.toNamed(RouteConstant.canvasDrawing, arguments: {"isText": isText, "isImage": isImage, "imagePath": imagePath});

  void gotoCreationScreen() => Get.toNamed(RouteConstant.creation);
  void gotoFavoriteScreen() => Get.toNamed(RouteConstant.favorites);
  void gotoHowToUseScreen() => Get.toNamed(RouteConstant.howToUse);
  void gotoWebView({required String appbarTitle}) => Get.toNamed(RouteConstant.webView, arguments: {'appbarTitle': appbarTitle});
}
