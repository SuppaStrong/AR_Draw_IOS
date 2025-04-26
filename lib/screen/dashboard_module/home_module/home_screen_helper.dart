import 'package:ar_draw/screen/dashboard_module/home_module/home_screen.dart';
import 'package:ar_draw/serialized/setting/setting_item.dart';

class HomeScreenHelper {
  List<SettingItemModel> staticDataModel = [];

  HomeScreenState? state;

  HomeScreenHelper(this.state) {
    staticDataModel = [];
  }
}
