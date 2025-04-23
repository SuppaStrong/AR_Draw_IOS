import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/screen/dashboard_module/preview_module/preview_screen.dart';
import 'package:get/get.dart';

class PreviewScreenHelper {
  PreviewScreenState? state;
  String? imagePath;
  bool? isImage;
  bool? isText;
  List<Map<String, String>> drawOptions = [
    {'title': 'Draw With The Camera', 'image': AppAsset.drawWithCamera},
    {'title': 'Draw With The Canvas Paper', 'image': AppAsset.drawWithCanvas}
  ];

  PreviewScreenHelper(this.state) {
    init();
  }

  void init() {
    imagePath = Get.arguments['imagePath'];
    isImage = Get.arguments['isImage'];
    isText = Get.arguments['isText'];
  }
}
