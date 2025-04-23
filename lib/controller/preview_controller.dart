import 'package:get/get.dart';

class PreviewController extends GetxController {
  int selectedIndex = -1;

  void updateSelectedIndex(int index) {
    selectedIndex = index;
    update();
  }
}
