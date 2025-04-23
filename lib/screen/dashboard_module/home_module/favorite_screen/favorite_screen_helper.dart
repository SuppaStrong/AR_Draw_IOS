import 'package:ar_draw/screen/dashboard_module/home_module/favorite_screen/favorite_screen.dart';
import 'package:ar_draw/service/share_preference.dart';

class FavoriteScreenHelper {
  final FavoriteScreenState state;
  List<String>? favoriteItems = [];

  FavoriteScreenHelper(this.state) {
    loadFavoriteItems();
  }

  Future<void> loadFavoriteItems() async {
    favoriteItems = await SharedPrefService.instance.getPrefListValue('favorites') ?? [];
    state.categoryController?.update();
  }
  Future<void> removeFromFavorite(String imagePath) async {
      favoriteItems?.remove(imagePath);
    await SharedPrefService.instance.setPrefListValue('favorites', favoriteItems!); // Save updated favorites
    state.categoryController?.update();
  }
}
