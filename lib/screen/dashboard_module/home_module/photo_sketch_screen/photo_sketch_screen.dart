import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/utills/dimension.dart';
import 'package:ar_draw/app/widgets/app_app_bar.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app/widgets/app_text.dart';
import 'package:ar_draw/controller/drawing_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PhotoSketchScreen extends StatefulWidget {
  const PhotoSketchScreen({super.key});

  @override
  State<PhotoSketchScreen> createState() => _PhotoSketchScreenState();
}

class _PhotoSketchScreenState extends State<PhotoSketchScreen> {
  DrawingController? drawingController;

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    return GetBuilder(
        init: DrawingController(),
        builder: (DrawingController controller) {
          drawingController = controller;
          return Scaffold(
            appBar: AppAppBar(
              appbarTitle: AppStringConstant.photoToSketch,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingNormal),
                child: Column(
                  children: [
                    const AppImageAsset(image: AppAsset.photoToSketch),
                    const SizedBox(height: Dimens.heightSmallMedium),
                    buildImagePickerView(
                      background: AppAsset.cameraBackGround,
                      foreground: AppAsset.photoGallery,
                      title: AppStringConstant.fromGallery,
                      description: AppStringConstant.toStartDrawing,
                      onTap: () async {
                        await drawingController?.getImageFromGallery();
                      },
                    ),
                    const SizedBox(height: Dimens.heightSmall),
                    buildImagePickerView(
                        background: AppAsset.galleryBackGround,
                        foreground: AppAsset.photoCamera,
                        title: AppStringConstant.fromCamera,
                      description: AppStringConstant.toStartDrawing,
                      onTap: () async {
                        await drawingController?.getImageFromCamera();
                      },),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget buildImagePickerView({required String background, required String foreground, required String title, required String description, required VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AppImageAsset(
            image: background,
            height: 100,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
          Padding(
            padding: const EdgeInsets.all(DimensPadding.paddingNormal),
            child: Row(
              children: [
                AppImageAsset(
                  image: foreground,
                  width: Dimens.widthLarge,
                  fit: BoxFit.fill,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        title,
                        color: AppColorConstant.appWhite,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: Dimens.heightExtraSmall),
                      AppText(
                        description,
                        color: AppColorConstant.appWhite,
                        fontSize: Dimens.textSizeSmall,
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
