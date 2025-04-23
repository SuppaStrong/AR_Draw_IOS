import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService instance = PermissionService._internal();

  factory PermissionService() => instance;

  PermissionService._internal();

  Future<bool> requestStorageOrMediaPermission() async {
    if (await isAndroid13orAbove()) {
      return await requestPermission(Permission.videos);
    } else {
      return await requestPermission(Permission.storage);
    }
  }

  Future<bool> isAndroid13orAbove() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        return true;
      }
    }
    return false;
  }

  Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status == PermissionStatus.granted) {
      return true;
    } else if (status == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return false;
  }
}
