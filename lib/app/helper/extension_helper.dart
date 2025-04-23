import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/widgets/app_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';


SystemUiOverlayStyle changeStatusBarIconColor({bool lightColor = false}) {
  return SystemUiOverlayStyle(
    statusBarIconBrightness: (lightColor) ? Brightness.light : Brightness.dark,
  );
}

extension SnackBar on String {

  showError() {
    Get.snackbar(
      'error'.tr,
      this,
      backgroundColor: AppColorConstant.appErrorColor,
      colorText: AppColorConstant.appWhite,
    );
  }

  showSuccess() {
    Get.snackbar(
      'success'.tr,
      this,
      backgroundColor: AppColorConstant.appGreenColor,
      colorText: AppColorConstant.appWhite,
    );
  }

  void logs() {
    if (kDebugMode) {
      Logger(printer: PrettyPrinter(methodCount: 0)).d(this);
    }
  }

  void infoLogs() {
    if (kDebugMode) {
      Logger(printer: PrettyPrinter(methodCount: 0)).i(this);
    }
  }

  void traceLogs() {
    if (kDebugMode) {
      Logger(printer: PrettyPrinter(methodCount: 0)).t(this);
    }
  }

  void warningLogs() {
    if (kDebugMode) {
      Logger(printer: PrettyPrinter(methodCount: 0)).w(this);
    }
  }

  void errorLogs() {
    if (kDebugMode) {
      Logger(printer: PrettyPrinter(methodCount: 0)).e(this);
    }
  }

  dynamic showUnauthorizedDialog() {
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText('Error', fontSize: 18, fontWeight: FontWeight.bold),
              SizedBox(height: 2),
              AppText('You are logged out. Please login again.', textAlign: TextAlign.center),
              SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
