import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/utills/dimension.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app/widgets/app_text.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final double? height;
  final double? width;
  final List<BoxShadow>? boxShadow;
  final BorderRadiusGeometry? borderRadius;
  final List<Color>? gradient;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final Color? titleColor;
  final String title;
  final String? image;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  const AppButton({
    super.key,
    this.height,
    this.width,
    this.boxShadow,
    this.borderRadius,
    this.gradient,
    this.color,
    this.titleColor,
    required this.title,
    this.image,
    this.onTap,
    this.fontSize,
    this.fontWeight,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? Dimens.heightSmallExtraMedium,
        width: width ?? Dimens.heightVeryExtraLarge,
        margin: margin ?? EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: borderRadius ??
              BorderRadius.circular(
                  height ?? Dimens.heightSmallExtraMedium / 2.0),
          boxShadow: boxShadow,
          gradient: (gradient != null && gradient!.isNotEmpty)
              ? LinearGradient(
                  colors: gradient!,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: (color != null) ? color ?? AppColorConstant.appBlack : null,
        ),
        child: (image != null)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppImageAsset(
                    image: image!,
                    height: Dimens.heightSmallLarge,
                  ),
                  const SizedBox(width: Dimens.widthVerySmall),
                  AppText(
                    title,
                    color: titleColor ?? AppColorConstant.appWhite,
                    fontWeight: FontWeight.w500,
                    fontSize: fontSize ?? Dimens.textSizeMedium,
                  ),
                ],
              )
            : Center(
                child: AppText(
                  title,
                  color: titleColor ?? AppColorConstant.appWhite,
                  fontWeight: fontWeight ?? FontWeight.w500,
                  fontSize: fontSize ?? Dimens.textSizeMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
      ),
    );
  }
}
