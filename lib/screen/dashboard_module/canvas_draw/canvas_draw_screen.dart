import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/utills/dimension.dart';
import 'package:ar_draw/app/widgets/app_app_bar.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app/widgets/app_text.dart';
import 'package:ar_draw/app_routes/route_helper.dart';
import 'package:ar_draw/controller/canvas_draw_controller.dart';
import 'package:ar_draw/screen/dashboard_module/canvas_draw/canvas_draw_screen_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CanvasDrawScreen extends StatefulWidget {
  const CanvasDrawScreen({super.key});

  @override
  State<CanvasDrawScreen> createState() => CanvasDrawScreenState();
}

class CanvasDrawScreenState extends State<CanvasDrawScreen> {
  CanvasDrawScreenHelper? canvasDrawScreenHelper;
  CanvasDrawController? canvasDrawController;

  @override
  Widget build(BuildContext context) {
    "current screen --> $runtimeType".logs();
    canvasDrawScreenHelper ?? (canvasDrawScreenHelper = CanvasDrawScreenHelper(this));

    return GetBuilder(
        init: CanvasDrawController(),
        builder: (CanvasDrawController controller) {
          canvasDrawController = controller;
          return Scaffold(
            appBar: AppAppBar(
              appbarTitle: AppStringConstant.canvasDraw,
              onSuffixTap: () => RouteHelper.instance.gotoHowToUseScreen(),
              suffixIcon: AppAsset.icQuestion,
            ),
            body: Column(
              children: [buildCanvasView(), (canvasDrawScreenHelper?.isColorTap == true) ? buildColorView() : buildOpacityView(), buildOptionsView()],
            ),
          );
        });
  }

  Widget buildCanvasView() {
    return Expanded(
        child: Stack(
      children: [
        Container(
          width: double.infinity,
          color: canvasDrawScreenHelper?.selectedColor,
        ),
        Positioned(
          left: canvasDrawScreenHelper?.position.dx,
          top: canvasDrawScreenHelper?.position.dy,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onScaleStart: (details) => canvasDrawScreenHelper?.baseScale = canvasDrawScreenHelper!.scale,

            onScaleUpdate: (details) => canvasDrawScreenHelper?.onImageDrag(details),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..scale(
                  canvasDrawScreenHelper?.isZoomed == true
                      ? (canvasDrawScreenHelper?.scale ?? 1.0)
                      : 1.0,
                )
                ..rotateZ(canvasDrawScreenHelper?.rotationAngle ?? 0.0)
                ..scale(canvasDrawScreenHelper!.isFlipped ? -1.0 : 1.0, 1.0),
              child: Opacity(
                opacity: canvasDrawScreenHelper!.currentSliderValue,
                child: (canvasDrawScreenHelper?.isText != true)
                    ? AppImageAsset(
                        image: canvasDrawScreenHelper?.imagePath ?? "",
                        isFile: canvasDrawScreenHelper?.isImage == true && canvasDrawScreenHelper?.isText == false ? true : false,
                        width: Get.size.width / 1.2,
                        fit: BoxFit.cover,
                      )
                    : (canvasDrawScreenHelper!.textImageBytes != null)
                        ? Image.memory(
                            canvasDrawScreenHelper!.textImageBytes!,
                            width: Get.size.width / 1.2,
                            fit: BoxFit.fill,
                          )
                        : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 12,
          right: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => canvasDrawScreenHelper!.toggleLock(),
                child: Container(
                  height: Dimens.heightExtraMedium,
                  width: Dimens.widthExtraMedium,
                  padding: const EdgeInsets.all(DimensPadding.paddingSmallNormal),
                  decoration: BoxDecoration(
                    color: AppColorConstant.appLightPurple,
                    borderRadius: BorderRadius.circular(Dimens.defaultBorderRadius),
                  ),
                  child: AppImageAsset(image: AppAsset.icLock, color: canvasDrawScreenHelper!.isLocked ? AppColorConstant.appWhite : AppColorConstant.appLightGrey),
                ),
              ),
              GestureDetector(onTap: () => canvasDrawScreenHelper?.resetToInitialPosition(),
                child: Container(
                  height: Dimens.heightExtraMedium,
                  width: Dimens.widthExtraMedium,
                  padding: const EdgeInsets.all(DimensPadding.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColorConstant.appLightPurple,
                    borderRadius: BorderRadius.circular(Dimens.defaultBorderRadius),
                  ),
                  child: const AppImageAsset(image: AppAsset.icRefresh, color: AppColorConstant.appWhite),
                ),
              ),
            ],
          ),
        )
      ],
    ));
  }

  Widget buildColorView() {
    return Container(
      height: Dimens.heightSemiMedium,
      width: double.infinity,
      alignment: Alignment.center,
      color: AppColorConstant.appLightPurple.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(vertical: DimensPadding.paddingSmallNormal),
      child: SingleChildScrollView(scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(canvasDrawScreenHelper!.colorList!.length, (index) {
            bool isSelected = canvasDrawScreenHelper?.selectedColor == canvasDrawScreenHelper?.colorList![index];
            return buildColorButton(index, isSelected);
          }),
        ),
      ),
    );
  }

  Widget buildColorButton(int index, bool isSelected) {
    return GestureDetector(
      onTap: () => canvasDrawScreenHelper!.changeColor(index),
      child: Container(
        padding: const EdgeInsets.all(2),
        margin: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingUltraTiny),
        decoration: BoxDecoration(
            color: isSelected ? AppColorConstant.appTransparent : null, shape: BoxShape.circle, border: isSelected ? Border.all(color: canvasDrawScreenHelper!.colorList![index], width: 2) : null),
        child: Container(
          height: Dimens.heightSmallMedium,
          width: Dimens.heightSmallMedium,
          decoration: BoxDecoration(
            color: canvasDrawScreenHelper!.colorList![index],
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget buildOpacityView() {
    return Container(
      width: double.infinity,
      height: Dimens.heightSemiMedium,
      color: AppColorConstant.appLightPurple.withOpacity(0.2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppImageAsset(
            image: AppAsset.icGallery,
            height: Dimens.heightSmallMedium,
            color: AppColorConstant.appLightPurple.withOpacity(0.3),
          ),
          Expanded(
            child: Slider(
              value: canvasDrawScreenHelper!.currentSliderValue,
              min: 0.2,
              activeColor: AppColorConstant.appLightPurple,
              inactiveColor: AppColorConstant.appWhite,
              max: 1.0,
              thumbColor: AppColorConstant.appLightPurple,
              label: (canvasDrawScreenHelper!.currentSliderValue * 100).round().toString(),
              onChanged: (double value) {
                canvasDrawScreenHelper!.currentSliderValue = value;
                canvasDrawController?.update();
              },
            ),
          ),
          const AppImageAsset(
            image: AppAsset.icGallery,
            color: AppColorConstant.appLightPurple,
            height: Dimens.heightSmallMedium,
          )
        ],
      ).paddingSymmetric(horizontal: DimensPadding.paddingNormal, vertical: DimensPadding.paddingSmallNormal),
    );
  }

  Widget buildOptionsView() {
    return Container(
      color: AppColorConstant.appLightPurple,
      padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingNormal, vertical: DimensPadding.paddingSemiNormal),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => canvasDrawScreenHelper?.toggleZoom(),
            child: Column(
              children: [
                AppImageAsset(
                  color: canvasDrawScreenHelper!.isZoomed ? AppColorConstant.appWhite : AppColorConstant.appLightGrey,
                  image: AppAsset.icZoom,
                  height: Dimens.heightSmall,
                ),
                AppText(
                  AppStringConstant.zoom,
                  color: canvasDrawScreenHelper!.isZoomed ? AppColorConstant.appWhite : AppColorConstant.appLightGrey,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => canvasDrawScreenHelper!.toggleColor(),
            child: Column(
              children: [
                AppImageAsset(
                  color: (canvasDrawScreenHelper?.isColorTap == true) ? AppColorConstant.appWhite : AppColorConstant.appLightGrey,
                  image: AppAsset.icColor,
                  height: Dimens.heightSmall,
                ),
                AppText(
                  AppStringConstant.color,
                  color: (canvasDrawScreenHelper?.isColorTap == true) ? AppColorConstant.appWhite : AppColorConstant.appLightGrey,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              canvasDrawScreenHelper!.toggleFlip();
              canvasDrawController?.update();
            },
            child: Column(
              children: [
                AppImageAsset(
                  color: canvasDrawScreenHelper!.isFlipped ? AppColorConstant.appWhite : AppColorConstant.appLightGrey,
                  image: AppAsset.icFlip,
                  height: Dimens.heightSmall,
                ),
                AppText(
                  AppStringConstant.flip,
                  color: canvasDrawScreenHelper!.isFlipped ? AppColorConstant.appWhite : AppColorConstant.appLightGrey,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              canvasDrawScreenHelper!.rotateImage();
              canvasDrawController?.update();
            },
            child: Column(
              children: [
                AppImageAsset(
                  color: canvasDrawScreenHelper!.rotationAngle != 0.0 ? AppColorConstant.appWhite : AppColorConstant.appLightGrey,
                  image: AppAsset.icRotate,
                  height: Dimens.heightSmall,
                ),
                AppText(AppStringConstant.rotate, color: canvasDrawScreenHelper!.rotationAngle != 0.0 ? AppColorConstant.appWhite : AppColorConstant.appLightGrey),
              ],
            ),
          )
        ],
      ),
    );
  }
}
