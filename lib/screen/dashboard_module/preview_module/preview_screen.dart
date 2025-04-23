import 'dart:convert';

import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/utills/dimension.dart';
import 'package:ar_draw/app/widgets/app_app_bar.dart';
import 'package:ar_draw/app/widgets/app_bottom_sheet.dart';
import 'package:ar_draw/app/widgets/app_button.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app_routes/route_helper.dart';
import 'package:ar_draw/controller/preview_controller.dart';
import 'package:ar_draw/screen/dashboard_module/preview_module/preview_screen_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => PreviewScreenState();
}

class PreviewScreenState extends State<PreviewScreen> {
  PreviewScreenHelper? previewScreenHelper;
  PreviewController? previewController;

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    previewScreenHelper ?? (previewScreenHelper = PreviewScreenHelper(this));

    return GetBuilder(
        init: PreviewController(),
        builder: (PreviewController controller) {
          previewController = controller;
          return Scaffold(
            appBar: AppAppBar(appbarTitle: previewScreenHelper?.isText == true ? AppStringConstant.textPreview : AppStringConstant.preview),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (previewScreenHelper?.imagePath != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingNormal, vertical: DimensPadding.paddingSemiNormal),
                      child: Container(
                          decoration: BoxDecoration(
                            color: AppColorConstant.appLightPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                Dimens.defaultBorderRadius,
                              ),
                              border: Border.all(color: AppColorConstant.appLightPurple)),
                          child: (previewScreenHelper?.isText == true)
                              ? Image.memory(
                                  base64Decode(previewScreenHelper!.imagePath!),
                                )
                              : AppImageAsset(
                                  image: previewScreenHelper?.imagePath ?? "",
                                  isFile: previewScreenHelper?.isImage == true && previewScreenHelper?.isText == false ? true : false,
                                )),
                    ),
                  ),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return AppBottomSheet(
                          buttonTitle: AppStringConstant.draw,
                          drawOptions: previewScreenHelper!.drawOptions,
                          buttonCallback: () {
                            RouteHelper.instance.gotoBack();
                            if (previewController?.selectedIndex == 1) {
                              RouteHelper.instance.gotoCanvasScreen(
                                previewScreenHelper!.imagePath,
                                isText: previewScreenHelper?.isText == true ? true : false,
                                isImage: previewScreenHelper?.isImage == true ? true : false,
                              );
                            }
                            if (previewController?.selectedIndex == 0) {
                              RouteHelper.instance.gotoSketchDrawingScreen(
                                previewScreenHelper!.imagePath,
                                isText: previewScreenHelper?.isText == true ? true : false,
                                isImage: previewScreenHelper?.isImage == true ? true : false,
                              );
                            }
                            previewController?.selectedIndex = -1;
                          },
                        );
                      },
                    );
                  },
                  child: const AppButton(margin: EdgeInsets.symmetric(horizontal: DimensPadding.paddingNormal),
                    title: AppStringConstant.startDrawing,
                    gradient: [AppColorConstant.appLightPurple, AppColorConstant.appDeepPurple],
                  ),
                ),
                const SizedBox(height: Dimens.heightSmallMedium),
              ],
            ),
          );
        });
  }
}
