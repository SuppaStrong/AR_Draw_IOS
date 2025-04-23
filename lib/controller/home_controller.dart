import 'dart:convert';

import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, List<String>> imagesMap = {};
  @override
  void onInit() {
    loadImagesFromJson();
    super.onInit();
  }

  Future<void> loadImagesFromJson() async {
    try {
      String jsonString = await rootBundle.loadString(AppAsset.staticImagesJson);
      Map<String, dynamic> jsonData = json.decode(jsonString);
      imagesMap = jsonData.map((key, value) => MapEntry(key, List<String>.from(value)));
      update();
    } catch (e) {
      "Error loading JSON: $e".errorLogs();
    }
  }
}