import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/utills/dimension.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app/widgets/app_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    this.isDrawer = false,
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
      decoration: BoxDecoration(
          color: appBarColor,
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onPrefixTap ?? () => Get.back(),
                child: AppImageAsset(image: prefixIcon ?? AppAsset.icBack),
              ),
              const SizedBox(
                width: Dimens.widthVerySmall,
              ),
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
          if (isDrawer == false)
            AppText(
              appbarTitle ?? '',
              fontSize: Dimens.textSizeDefault,
              fontWeight: FontWeight.w900,
              color: titleColor ?? AppColorConstant.appBlack,
            ),
          (suffixIcon != null)
              ? SizedBox(
                  child: GestureDetector(
                    onTap: onSuffixTap,
                    child: isText == true
                        ? AppText(suffixIcon!)
                        : AppImageAsset(image: suffixIcon ?? ""),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}

class AppAppBarIOS extends PreferredSize {
  final String title;
  final Color titleColor;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? leadingWidget;
  final List<Widget>? actions;
  final Color backgroundColor;
  final bool showElevation;
  final double elevation;
  final Color? backButtonBackgroundColor;
  final Color? backButtonIconColor;
  final TextStyle? titleStyle;
  final double? leadingWidth;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;

  AppAppBarIOS({
    super.key,
    this.title = '',
    this.titleColor = Colors.black87,
    this.centerTitle = true,
    this.showBackButton = true,
    this.onBackPressed,
    this.leadingWidget,
    this.actions,
    this.backgroundColor = Colors.white,
    this.showElevation = false,
    this.elevation = 0,
    this.backButtonBackgroundColor,
    this.backButtonIconColor,
    this.titleStyle,
    this.leadingWidth,
    this.flexibleSpace,
    this.bottom,
  }) : super(
          preferredSize: Size.fromHeight(
              bottom == null ? 56.0 : 56.0 + bottom.preferredSize.height),
          child: const SizedBox(),
        );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: showElevation ? elevation : 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leadingWidth: leadingWidth,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      title: Text(
        title,
        style: titleStyle ??
            TextStyle(
              color: titleColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
      ),
      leading: showBackButton ? _buildBackButton() : leadingWidget,
      actions: actions,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: backgroundColor.computeLuminance() > 0.5
            ? Brightness.dark
            : Brightness.light,
        statusBarBrightness: backgroundColor.computeLuminance() > 0.5
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

  Widget _buildBackButton() {
    if (leadingWidget != null) return leadingWidget!;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onBackPressed != null) {
          onBackPressed!();
        } else {
          Get.back();
        }
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backButtonBackgroundColor ?? Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          CupertinoIcons.back,
          color: backButtonIconColor ?? Colors.black87,
        ),
      ),
    );
  }
}
