// import 'package:ar_draw/screen/dashboard_module/home_module/category_screen/category_screen.dart';
// import 'package:get/get.dart';
//
// class CategoryScreenHelper {
//   CategoryScreenState state;
//   List<String>? imagesMap;
//   String? appbarTitle;
//
//   CategoryScreenHelper(this.state) {
//     init();
//   }
//
//   void init() {
//     imagesMap = Get.arguments['imagesMap'];
//     appbarTitle = Get.arguments['title'];
//   }
// }
import 'package:ar_draw/screen/dashboard_module/home_module/category_screen/category_screen.dart';
import 'package:ar_draw/service/share_preference.dart';
import 'package:get/get.dart';

class CategoryScreenHelper {
  CategoryScreenState state;
  List<String>? imagesMap;
  String? appbarTitle;
  List<String> favorites = [];

  CategoryScreenHelper(this.state) {
    init();
  }

  void init() async {
    imagesMap = Get.arguments['imagesMap'];
    appbarTitle = Get.arguments['title'];

    // Load favorites from SharedPreferences
    favorites = await SharedPrefService.instance.getPrefListValue('favorites') ?? [];
    state.categoryController?.update(); // Refresh UI
  }

  Future<void> toggleFavorite(String imagePath) async {
    if (favorites.contains(imagePath)) {
      favorites.remove(imagePath); // Remove from favorites
    } else {
      favorites.add(imagePath); // Add to favorites
    }
    await SharedPrefService.instance.setPrefListValue('favorites', favorites); // Save updated favorites
    state.categoryController?.update(); // Refresh UI
  }
}
