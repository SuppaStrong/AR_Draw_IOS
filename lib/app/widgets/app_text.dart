import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/utills/dimension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppText extends StatelessWidget {
  final String title;
  final Color? color;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final double? fontSize;
  final TextAlign? textAlign;
  final double? height;
  final FontStyle? fontStyle;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextDecoration? decoration;
  final double? letterSpacing;
  final double? leftSpacing;

  const AppText(
    this.title, {
    super.key,
    this.color,
    this.fontWeight,
    this.fontFamily,
    this.fontSize,
    this.textAlign,
    this.height,
    this.fontStyle,
    this.maxLines,
    this.overflow,
    this.decoration = TextDecoration.none,
    this.letterSpacing,
    this.leftSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: leftSpacing ?? Dimens.noneSizeDouble),
      child: Text(
        title.tr,
        textAlign: textAlign,
        maxLines: maxLines,
        style: TextStyle(
          color: color ?? AppColorConstant.appBlack,
          fontWeight: fontWeight,
          fontSize: fontSize ?? Dimens.textSizeDefault,
          height: height,
          fontStyle: fontStyle,
          overflow: overflow,
          fontFamily: fontFamily,
          decoration: decoration,
          decorationColor: AppColorConstant.appGrey.withOpacity(Dimens.opacityHigh),
          letterSpacing: letterSpacing,
        ),
      ),
    );
  }
}
