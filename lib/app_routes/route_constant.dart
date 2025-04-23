import 'package:ar_draw/app/widgets/web_view_helper.dart';
import 'package:ar_draw/screen/dashboard_module/canvas_draw/canvas_draw_screen.dart';
import 'package:ar_draw/screen/dashboard_module/home_module/category_screen/category_screen.dart';
import 'package:ar_draw/screen/dashboard_module/home_module/creation_screen/creation_screen.dart';
import 'package:ar_draw/screen/dashboard_module/home_module/drawing_screen/drawing_screen.dart';
import 'package:ar_draw/screen/dashboard_module/home_module/favorite_screen/favorite_screen.dart';
import 'package:ar_draw/screen/dashboard_module/home_module/home_screen.dart';
import 'package:ar_draw/screen/dashboard_module/home_module/photo_sketch_screen/photo_sketch_screen.dart';
import 'package:ar_draw/screen/dashboard_module/home_module/text_sketch_screen/text_sketch_screen.dart';
import 'package:ar_draw/screen/dashboard_module/how_to_use/how_to_use_screen.dart';
import 'package:ar_draw/screen/dashboard_module/preview_module/preview_screen.dart';
import 'package:ar_draw/screen/dashboard_module/sketch_draw/sketch_draw_screen.dart';
import 'package:ar_draw/screen/onboarding/onboarding_screen.dart';
import 'package:ar_draw/screen/splash/splash_screen.dart';
import 'package:get/get.dart';

class RouteConstant {
  static const String initial = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String drawing = '/drawing';
  static const String preview = '/preview';
  static const String sketchDrawing = '/sketchDrawing';
  static const String textSketch = '/textSketch';
  static const String category = '/category';
  static const String photoSketch = '/photoSketch';
  static const String canvasDrawing = '/canvasDrawing';
  static const String creation = '/creation';
  static const String favorites = '/favorites';
  static const String howToUse = '/howToUse';
  static const String webView = '/webView';
}
mixin GetPageRouteHelper {
  static List<GetPage> routes = [
    GetPage(name: RouteConstant.initial, page: () => const SplashScreen()),
    GetPage(name: RouteConstant.onboarding, page: () => const OnboardingScreen()),
    GetPage(name: RouteConstant.home, page: () => const HomeScreen()),
    GetPage(name: RouteConstant.drawing, page: () => const DrawingScreen()),
    GetPage(name: RouteConstant.preview, page: () => const PreviewScreen()),
    GetPage(name: RouteConstant.sketchDrawing, page: () => const SketchDrawScreen()),
    GetPage(name: RouteConstant.textSketch, page: () => const TextSketchScreen()),
    GetPage(name: RouteConstant.category, page: () => const CategoryScreen()),
    GetPage(name: RouteConstant.photoSketch, page: () => const PhotoSketchScreen()),
    GetPage(name: RouteConstant.canvasDrawing, page: () => const CanvasDrawScreen()),
    GetPage(name: RouteConstant.creation, page: () => const CreationScreen()),
    GetPage(name: RouteConstant.favorites, page: () => const FavoriteScreen()),
    GetPage(name: RouteConstant.howToUse, page: () => const HowToUseScreen()),
    GetPage(name: RouteConstant.webView, page: () => const WebViewHelper()),
  ];
}