import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/utills/dimension.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppAppBar extends PreferredSize {
  final Color? appBarColor;
  final Color? titleColor;
  final String? appbarTitle;
  final String? prefixIcon;
  final String? suffixIcon;
  final bool? isDrawer;
  final VoidCallback? onSuffixTap;
  final VoidCallback? onPrefixTap;
  final bool? isText;

  AppAppBar({
    super.key,
    this.appbarTitle,
    this.prefixIcon,
    this.isText,
    this.isDrawer=false,
    this.suffixIcon,
    this.titleColor,
    this.onSuffixTap,
    this.onPrefixTap,
    Widget? child,
    this.appBarColor = AppColorConstant.appTransparent,
    Size? preferredSize,
  }) : super(
          child: Container(),
          preferredSize: const Size.fromHeight(Dimens.heightVeryLarge),
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.only(
        left: DimensPadding.paddingSemiNormal,
        right: DimensPadding.paddingSemiNormal,
        top: DimensPadding.paddingSemiNormal,
      ),
      decoration: BoxDecoration(color: appBarColor, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onPrefixTap??() => Get.back(),
                child: AppImageAsset(image: prefixIcon ?? AppAsset.icBack),
              ),
              const SizedBox(width: Dimens.widthVerySmall,),
              if (isDrawer == true)
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'AR ',
                        style: TextStyle(
                          fontSize: Dimens.textSizeMedium,
                          fontWeight: FontWeight.bold,
                          color: AppColorConstant.appLightPurple,
                        ),
                      ),
                      TextSpan(
                        text: 'Drawing',
                        style: TextStyle(
                          fontSize: Dimens.textSizeMedium,
                          fontWeight: FontWeight.bold,
                          color: titleColor ?? AppColorConstant.appBlack,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          if(isDrawer==false)AppText(
            appbarTitle ?? '',
            fontSize: Dimens.textSizeDefault,
            fontWeight: FontWeight.w900,
            color: titleColor ?? AppColorConstant.appBlack,
          ),
          (suffixIcon!=null)?SizedBox(
            child: GestureDetector(
              onTap: onSuffixTap,
              child: isText==true?AppText(suffixIcon!):AppImageAsset(image: suffixIcon ?? ""),
            ),
          ):const SizedBox(),
        ],
      ),
    );
  }
}
