import 'package:flutter/material.dart';

mixin AppColorConstant {
  static const Color appTransparent = Colors.transparent;
  static const Color appBlack = Color(0xFF000000);
  static const Color appWhite = Color(0xffFFFFFF);
  static const Color appGrey = Color(0xFFA0A0A0);
  static const Color appLightGrey = Color(0xFFD6D6D6);
  static const Color appWhite100 = Color(0xFFFCFAFF);
  static const Color appWhite200 = Color(0xffF2F2F2);
  static const Color appErrorColor = Color(0xffff0000);
  static const Color appDarkRed = Color(0xffFF3B30);
  static const Color appGreenColor = Color(0xff008000);
  static const Color appRed = Color(0xfffe6174);
  static const Color appLightPurple = Color(0xffBB65FF);
  static const Color appDeepPurple = Color(0xff8F00FF);
  static const Color appPink = Color(0xffF55987);
  static const Color appBlue = Color(0xff54C1FF);
  static const Color appOrange = Color(0xffFFA842);
  static const Color appViolate = Color(0xff8371F8);
  static const Color appGreenSheen = Color(0xff65B6A6);
  static const Color appPastelGreen = Color(0xff84D369);
  static const Color appBlueberry = Color(0xff488DED);
  static const Color appBegoniaRed = Color(0xffFC7070);
  static const Color appDarkPink = Color(0xffF559DC);
  static const Color appAquamarine = Color(0xff5FDDA0);
  static const Color appSkyBlue = Color(0xff5DDCE4);
  static const Color appLavender = Color(0xff9E59F5);
  static const Color appChromeYellow = Color(0xffFFA700);
  static const Color appCarolinaBlue = Color(0xff54A6D2);
  static const Color appYellow = Color(0xffF8DE00);
  static const Color appStrawberryPink = Color(0xffFF4F90);
  static const Color appIrisBlue = Color(0xff5D46D4);

  static Color hex(String hexString) {
    var buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
