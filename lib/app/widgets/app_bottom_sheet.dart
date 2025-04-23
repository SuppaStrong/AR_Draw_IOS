import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/utills/dimension.dart';
import 'package:ar_draw/app/widgets/app_app_bar.dart';
import 'package:ar_draw/app/widgets/app_button.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app/widgets/app_text.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ar_draw/controller/preview_controller.dart';

class AppBottomSheet extends StatelessWidget {
  final String buttonTitle;
  final VoidCallback buttonCallback;
  final List<Map<String, String>> drawOptions;

  const AppBottomSheet({
    super.key,
    required this.buttonTitle,
    required this.buttonCallback,
    required this.drawOptions,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PreviewController>(builder: (controller) {
      return Container(
        padding: const EdgeInsets.all(DimensPadding.paddingSemiNormal),
        width: double.infinity,
        height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
        color: Colors.white,
        child: Column(
          children: [
            AppAppBar(
              appbarTitle: AppStringConstant.chooseOneOption,
            ),
            const SizedBox(height: Dimens.heightMediumSmall),
            Expanded(
              child: ListView.builder(
                itemCount: drawOptions.length,
                itemBuilder: (context, index) {
                  bool isSelected = controller.selectedIndex == index;
                  return InkWell(
                    onTap: () => controller.updateSelectedIndex(index),
                    child: Container(
                      padding: const EdgeInsets.all(DimensPadding.paddingNormal),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimens.defaultBorderRadius),
                        border: isSelected? Border.all(color: AppColorConstant.appLightPurple) : null,
                        color: isSelected
                            ? AppColorConstant.appLightPurple.withOpacity(0.2)
                            : AppColorConstant.appGrey.withOpacity(0.1),
                      ),
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Container(
                              width: 150,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimens.defaultBorderRadius),
                                color: AppColorConstant.appWhite,
                              ),
                              child: AppImageAsset(image: drawOptions[index]['image']!),
                            ),
                          ),
                          const SizedBox(width: Dimens.widthSmall),
                          AppText(
                            '${index + 1}. ',
                            color: AppColorConstant.appBlack,
                            fontWeight: FontWeight.w600,
                          ).paddingOnly(top: DimensPadding.paddingNormal),
                          Expanded(
                            child: AppText(
                              drawOptions[index]['title']!,
                              color: AppColorConstant.appBlack,
                              fontWeight: FontWeight.w600,
                            ).paddingOnly(top: DimensPadding.paddingNormal),
                          ),
                        ],
                      ),
                    ).paddingOnly(bottom: DimensPadding.paddingNormal),
                  );
                },
              ),
            ),
            const SizedBox(height: Dimens.heightMediumSmall),
            AppButton(
              width: double.infinity,
              gradient: const [AppColorConstant.appLightPurple, AppColorConstant.appDeepPurple],
              title: buttonTitle,
              onTap: buttonCallback,
            ),
          ],
        ),
      );
    });
  }
}
