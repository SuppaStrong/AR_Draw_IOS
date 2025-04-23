import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/utills/dimension.dart';
import 'package:ar_draw/app/widgets/app_app_bar.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app/widgets/app_text.dart';
import 'package:ar_draw/app_routes/route_helper.dart';
import 'package:ar_draw/controller/sketch_draw_controller.dart';
import 'package:ar_draw/screen/dashboard_module/sketch_draw/sketch_draw_screen_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SketchDrawScreen extends StatefulWidget {
  const SketchDrawScreen({super.key});

  @override
  State<SketchDrawScreen> createState() => SketchDrawScreenState();
}

class SketchDrawScreenState extends State<SketchDrawScreen> {
  SketchDrawScreenHelper? sketchDrawScreenHelper;
  SketchDrawController? sketchDrawController;

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    sketchDrawScreenHelper ??= SketchDrawScreenHelper(this);

    return GetBuilder(
      init: SketchDrawController(),
      builder: (SketchDrawController controller) {
        sketchDrawController = controller;
        return Scaffold(
          appBar: AppAppBar(appbarTitle: AppStringConstant.sketchDraw,suffixIcon: AppAsset.icQuestion, onSuffixTap: () => RouteHelper.instance.gotoHowToUseScreen()),
          body: Center(
            child: Column(
              children: [
                sketchDrawScreenHelper!.isCameraInitialized ? buildCameraView() : const Expanded(child: Center(child: CircularProgressIndicator())),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [buildOpacityView(), buildOptionsView()],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildCameraView() {
    return Expanded(
      child: SizedBox(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(width: double.infinity, child: CameraPreview(sketchDrawScreenHelper!.cameraController!)),
            Positioned(
              left: sketchDrawScreenHelper?.position.dx,
              top: sketchDrawScreenHelper?.position.dy,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: (details) => sketchDrawScreenHelper?.baseScale = sketchDrawScreenHelper!.scale,
                onScaleUpdate: (details) => sketchDrawScreenHelper?.onImageDrag(details),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..scale(
                      sketchDrawScreenHelper?.isZoomed == true ? (sketchDrawScreenHelper?.scale ?? 1.0) : 1.0,
                    )
                    ..rotateZ(sketchDrawScreenHelper?.rotationAngle ?? 0.0)
                    ..scale(sketchDrawScreenHelper!.isFlipped ? -1.0 : 1.0, 1.0),
                  child: Opacity(
                      opacity: sketchDrawScreenHelper!.currentSliderValue,
                      child: (sketchDrawScreenHelper?.isText == true)
                          ? Image.memory(sketchDrawScreenHelper?.textImageBytes ?? Uint8List(0), width: Get.size.width / 1.2, fit: BoxFit.fill)
                          : AppImageAsset(
                              image: sketchDrawScreenHelper?.imagePath ?? "",
                              isFile: sketchDrawScreenHelper?.isImage == true && sketchDrawScreenHelper?.isText == false ? true : false,
                              width: Get.size.width / 1.2,
                              fit: BoxFit.cover,
                            )),
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
                  GestureDetector(
                    onTap: () => sketchDrawScreenHelper!.toggleLock(),
                    child: Container(
                      height: Dimens.heightExtraMedium,
                      width: Dimens.widthExtraMedium,
                      padding: const EdgeInsets.all(DimensPadding.paddingSmallNormal),
                      decoration: BoxDecoration(
                        color: AppColorConstant.appLightPurple,
                        borderRadius: BorderRadius.circular(Dimens.defaultBorderRadius),
                      ),
                      child: AppImageAsset(image: AppAsset.icLock, color: sketchDrawScreenHelper!.isLocked ? AppColorConstant.appWhite : AppColorConstant.appLightGrey),
                    ),
                  ),
                  if (sketchDrawScreenHelper!.isRecordingVideo)
                    Padding(
                      padding: const EdgeInsets.all(DimensPadding.paddingSmallNormal),
                      child: Container(
                        width: Dimens.widthVeryExtraLarge,
                        padding: const EdgeInsets.all(DimensPadding.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppColorConstant.appWhite.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(Dimens.defaultBorderRadius),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: sketchDrawScreenHelper!.isPaused ? sketchDrawScreenHelper!.resumeVideoRecording : sketchDrawScreenHelper!.pauseVideoRecording,
                              child: AppImageAsset(
                                image: sketchDrawScreenHelper!.isPaused ? AppAsset.icPlay : AppAsset.icStop,
                              ),
                            ),
                            const SizedBox(width: Dimens.widthVerySmall),
                            AppText(
                              sketchDrawScreenHelper!.getFormattedRecordingDuration(),
                              color: AppColorConstant.appWhite,
                            )
                          ],
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: () => sketchDrawScreenHelper!.resetToInitialPosition(),
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
        ),
      ),
    );
  }

  Widget buildOpacityView() {
    return Container(
      width: double.infinity,
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
              value: sketchDrawScreenHelper!.currentSliderValue,
              min: 0.2,
              activeColor: AppColorConstant.appLightPurple,
              inactiveColor: AppColorConstant.appWhite,
              max: 1.0,
              thumbColor: AppColorConstant.appLightPurple,
              label: (sketchDrawScreenHelper!.currentSliderValue * 100).round().toString(),
              onChanged: (double value) {
                sketchDrawScreenHelper!.currentSliderValue = value;
                sketchDrawController?.update();
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
            onTap: () => sketchDrawScreenHelper?.toggleZoom(),
            child: Column(
              children: [
                AppImageAsset(
                  color: sketchDrawScreenHelper!.isZoomed ? AppColorConstant.appWhite : AppColorConstant.appLightGrey,
                  image: AppAsset.icZoom,
                  height: Dimens.heightSmall,
                ),
                AppText(
                  AppStringConstant.zoom,
                  color: sketchDrawScreenHelper!.isZoomed ? AppColorConstant.appWhite : AppColorConstant.appLightGrey,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              sketchDrawScreenHelper!.toggleFlash();
            },
            child: Column(
              children: [
                AppImageAsset(
                  image: AppAsset.icFlash,
                  color: (sketchDrawScreenHelper?.flashEnabled == true) ? AppColorConstant.appWhite : AppColorConstant.appLightGrey,
                  height: Dimens.heightSmall,
                ),
                AppText(AppStringConstant.flash, color: (sketchDrawScreenHelper?.flashEnabled == true) ? AppColorConstant.appWhite : AppColorConstant.appLightGrey),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              sketchDrawScreenHelper!.toggleFlip();
              sketchDrawController?.update();
            },
            child: Column(
              children: [
                AppImageAsset(
                  color: sketchDrawScreenHelper!.isFlipped ? AppColorConstant.appWhite : AppColorConstant.appLightGrey,
                  image: AppAsset.icFlip,
                  height: Dimens.heightSmall,
                ),
                AppText(
                  AppStringConstant.flip,
                  color: sketchDrawScreenHelper!.isFlipped ? AppColorConstant.appWhite : AppColorConstant.appLightGrey,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: sketchDrawScreenHelper!.isRecordingVideo ? sketchDrawScreenHelper!.stopVideoRecording : sketchDrawScreenHelper!.startVideoRecording,
            child: Column(
              children: [
                AppImageAsset(
                  color: sketchDrawScreenHelper!.isRecordingVideo ? AppColorConstant.appWhite : AppColorConstant.appLightGrey,
                  image: AppAsset.icRecord,
                  height: Dimens.heightSmall,
                ),
                AppText(AppStringConstant.record, color: sketchDrawScreenHelper!.isRecordingVideo ? AppColorConstant.appWhite : AppColorConstant.appLightGrey),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              sketchDrawScreenHelper!.rotateImage();
              sketchDrawController?.update();
            },
            child: Column(
              children: [
                AppImageAsset(
                  color: sketchDrawScreenHelper!.rotationAngle != 0.0 ? AppColorConstant.appWhite : AppColorConstant.appLightGrey,
                  image: AppAsset.icRotate,
                  height: Dimens.heightSmall,
                ),
                AppText(AppStringConstant.rotate, color: sketchDrawScreenHelper!.rotationAngle != 0.0 ? AppColorConstant.appWhite : AppColorConstant.appLightGrey),
              ],
            ),
          )
        ],
      ),
    );
  }
}
