import 'dart:io';

import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/utills/dimension.dart';
import 'package:ar_draw/app/widgets/app_button.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app/widgets/app_text.dart';
import 'package:ar_draw/app_routes/route_helper.dart';
import 'package:ar_draw/controller/creation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'creation_screen_helper.dart';

class CreationScreen extends StatefulWidget {
  const CreationScreen({super.key});

  @override
  State<CreationScreen> createState() => CreationScreenState();
}

class CreationScreenState extends State<CreationScreen> {
  CreationScreenHelper? creationScreenHelper;
  CreationController? creationController;

  @override
  Widget build(BuildContext context) {
    "Current screen --> $runtimeType".logs();
    creationScreenHelper ?? (creationScreenHelper = CreationScreenHelper(this));
    return GetBuilder(
        init: CreationController(),
        builder: (CreationController controller) {
          creationController = controller;
          return Scaffold(
            appBar: PreferredSize(preferredSize: const Size.fromHeight(Dimens.heightVeryLarge), child: buildTextAppBar()),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildVideoList(),
                if (creationScreenHelper!.selectedVideos.isNotEmpty)
                  AppButton(
                    title: AppStringConstant.delete,
                    width: double.infinity,
                    margin: const EdgeInsets.all(DimensPadding.paddingMedium),
                    onTap: () => deleteDialog(),
                    gradient: const [AppColorConstant.appLightPurple, AppColorConstant.appDeepPurple],
                  )
              ],
            ),
          );
        });
  }

  Widget buildTextAppBar() {
    return Container(
      height: Dimens.heightVeryLarge,
      padding: const EdgeInsets.only(
        left: DimensPadding.paddingSemiNormal,
        right: DimensPadding.paddingSemiNormal,
        top: DimensPadding.paddingSemiNormal,
      ),
      decoration: const BoxDecoration(
        color: AppColorConstant.appWhite,
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(width:Dimens.widthVeryLarge,alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => RouteHelper.instance.gotoBack(),
              child: const AppImageAsset(image: AppAsset.icBack),
            ),
          ),

          const Center(
            child: AppText(
              AppStringConstant.creation,
              fontSize: Dimens.textSizeDefault,
              fontWeight: FontWeight.w900,
              color: AppColorConstant.appBlack,
            ),
          ),

          GestureDetector(
            onTap: () => creationScreenHelper!.selectAllVideos(),
            child: Container(width: Dimens.widthVeryLarge,alignment: Alignment.centerRight,
              child: AppText(
                creationScreenHelper!.isAllSelected ? AppStringConstant.deselectAll : AppStringConstant.selectAll,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void deleteDialog() {
    Get.dialog(AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: Dimens.widthSmall,
              ),
              const AppImageAsset(image: AppAsset.icClose),
              InkWell(onTap: () => RouteHelper.instance.gotoBack(), child: const AppImageAsset(image: AppAsset.icCancel)),
            ],
          ),
          const AppText(
            AppStringConstant.delete,
            fontSize: Dimens.textSemiLarge,
            fontWeight: FontWeight.w900,
          ),
          const AppText(AppStringConstant.sureToDelete),
          const SizedBox(height: Dimens.heightSmall),
          Row(
            children: [
              Expanded(
                  child: AppButton(
                borderRadius: BorderRadius.circular(Dimens.defaultBorderRadius),
                title: AppStringConstant.cancel,
                color: AppColorConstant.appGrey,
                onTap: () {
                  RouteHelper.instance.gotoBack();
                },
              )),
              const SizedBox(
                width: Dimens.widthSmall,
              ),
              Expanded(
                  child: AppButton(
                borderRadius: BorderRadius.circular(Dimens.defaultBorderRadius),
                title: AppStringConstant.delete,
                color: AppColorConstant.appDarkRed,
                onTap: () {
                  RouteHelper.instance.gotoBack();
                  creationScreenHelper?.deleteSelectedVideos();
                },
              )),
            ],
          )
        ],
      ),
    ));
  }

  Widget buildVideoList() {
    if (creationScreenHelper?.videoFiles.isEmpty ?? true) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Change to min to keep it centered vertically
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppImageAsset(image: AppAsset.icNoData),
              SizedBox(height: Dimens.heightSmall), // Add some space between the image and text
              AppText(AppStringConstant.noVideos),
            ],
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingNormal),
        child: Column(
          children: [
            if (creationScreenHelper?.todayVideos.isNotEmpty == true) buildCategoryView(creationScreenHelper?.todayVideos, AppStringConstant.today),
            if (creationScreenHelper?.yesterdayVideos.isNotEmpty == true) buildCategoryView(creationScreenHelper?.yesterdayVideos, AppStringConstant.yesterday),
            if (creationScreenHelper?.last7DaysVideos.isNotEmpty == true) buildCategoryView(creationScreenHelper?.last7DaysVideos, AppStringConstant.last7Days),
          ],
        ),
      );
    }
  }

  Widget buildCategoryView(List<File>? videosMap, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          fontWeight: FontWeight.w600,
          fontSize: Dimens.textSizeExtraMedium,
        ),
        const SizedBox(
          height: Dimens.heightExtraSmall,
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: videosMap?.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            File? videoFile = videosMap?[index];
            String? thumbnailPath = creationScreenHelper!.videoThumbnails[videoFile];

            bool? isSelected = creationScreenHelper?.selectedVideos.contains(videoFile);

            return (creationScreenHelper!.selectedVideos.isEmpty)
                ? GestureDetector(
                    onLongPress: () {
                      if (creationScreenHelper!.selectedVideos.isEmpty) {
                        creationScreenHelper?.toggleVideoSelection(isSelected, videoFile);
                      }
                    },
                    child: buildImageView(isSelected!, thumbnailPath),
                  )
                : GestureDetector(
                    onTap: () => creationScreenHelper?.toggleVideoSelection(isSelected, videoFile),
                    child: buildImageView(isSelected!, thumbnailPath),
                  );
          },
        ),
        const SizedBox(height: Dimens.heightSmallMedium)
      ],
    );
  }

  Widget buildImageView(bool isSelected, String? thumbnailPath) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimens.semiBorderRadius),
            border: Border.all(width: 2, color: AppColorConstant.appLightPurple),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.defaultBorderRadius),
            child: AppImageAsset(
              image: thumbnailPath!,
              isFile: true,
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (creationScreenHelper!.selectedVideos.isNotEmpty)
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              height: Dimens.heightSmall,
              width: Dimens.widthSmall,
              decoration: BoxDecoration(
                  color: isSelected ? AppColorConstant.appLightPurple : AppColorConstant.appTransparent,
                  border: Border.all(width: 1.5, color: AppColorConstant.appLightPurple),
                  shape: BoxShape.circle),
              alignment: Alignment.center,
              child: isSelected ? const AppImageAsset(image: AppAsset.icRight) : null,
            ),
          ),
      ],
    );
  }
}
