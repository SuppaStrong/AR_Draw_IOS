import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/utills/dimension.dart';
import 'package:ar_draw/app/widgets/app_app_bar.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app/widgets/app_text.dart';
import 'package:ar_draw/app_routes/route_helper.dart';
import 'package:ar_draw/controller/drawing_controller.dart';
import 'package:ar_draw/screen/dashboard_module/home_module/drawing_screen/drawing_screen_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => DrawingScreenState();
}

class DrawingScreenState extends State<DrawingScreen> {
  DrawingScreenHelper? drawingScreenHelper;
  DrawingController? drawingController;

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    drawingScreenHelper ?? (drawingScreenHelper = DrawingScreenHelper(this));
    return GetBuilder(
        init: DrawingController(),
        builder: (DrawingController controller) {
          drawingController = controller;
          return Scaffold(
            appBar: AppAppBar(appbarTitle: AppStringConstant.drawing),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingNormal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildImagePickerView(),
                  const SizedBox(height: Dimens.heightMediumSmall),
                  const AppText(
                    AppStringConstant.categories,
                    fontWeight: FontWeight.w600,
                    fontSize: Dimens.textSizeMedium,
                  ),
                  const SizedBox(height: Dimens.heightVerySmall),
                  buildCategoryList()
                ],
              ),
            ),
          );
        });
  }

  Widget buildCategoryList() {
    return Expanded(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: drawingController?.imagesMap.keys.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10),
        itemBuilder: (context, index) {
          String? category = drawingController?.imagesMap.keys.elementAt(index);
          String? firstImage = drawingController?.imagesMap[category]!.first;
          return GestureDetector(onTap: () => RouteHelper.instance.gotoCategoryScreen(drawingController?.imagesMap[category], category.capitalizeFirst!),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimens.defaultBorderRadius),
                border: Border.all(color: drawingController!.imageColorMap![index]),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimens.defaultBorderRadius),
                    child: AppImageAsset(image: firstImage!),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: drawingController!.imageColorMap?[index],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(Dimens.defaultBorderRadius),
                          bottomRight: Radius.circular(Dimens.defaultBorderRadius),
                        ),
                      ),
                      child: AppText(category!.capitalizeFirst!, color: AppColorConstant.appWhite),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildImagePickerView() {
    return Row(
      children: [
        buildOptions(
            onTap: () async {
              await drawingController?.getImageFromGallery();
              drawingController?.croppedFile = drawingController?.croppedFile;
            },
            background: AppAsset.galleryBackGround,
            foreground: AppAsset.icGallery,
            title: AppStringConstant.gallery),
        const SizedBox(width: Dimens.widthVerySmall),
        buildOptions(
            onTap: () async {
              await drawingController?.getImageFromCamera();
              drawingController?.croppedFile = drawingController?.croppedFile;
            },
            background: AppAsset.cameraBackGround,
            foreground: AppAsset.icCamera,
            title: AppStringConstant.camera),
      ],
    );
  }

  Widget buildOptions({required VoidCallback? onTap, required String background, required String foreground, required String title}) {
    return Expanded(
      child: InkWell(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AppImageAsset(image: background),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppImageAsset(image: foreground),
                  const SizedBox(width: Dimens.widthVerySmall),
                  AppText(
                    title,
                    color: AppColorConstant.appWhite,
                  ),
                ],
              )
            ],
          )),
    );
  }
}
