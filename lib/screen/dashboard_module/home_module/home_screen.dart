import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/utills/dimension.dart';
import 'package:ar_draw/app/widgets/app_app_bar.dart';
import 'package:ar_draw/app/widgets/app_button.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app/widgets/app_text.dart';
import 'package:ar_draw/app_routes/route_helper.dart';
import 'package:ar_draw/controller/home_controller.dart';
import 'package:ar_draw/screen/dashboard_module/home_module/home_screen_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  HomeScreenHelper? homeScreenHelper;
  HomeController? homeController;

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    homeScreenHelper ?? (homeScreenHelper = HomeScreenHelper(this));
    return GetBuilder(
        init: HomeController(),
        builder: (HomeController controller) {
          homeController = controller;
          return Scaffold(
            key: controller.scaffoldKey,
            appBar: AppAppBar(
              isDrawer: true,
              appBarColor: AppColorConstant.appWhite,
              appbarTitle: AppStringConstant.arDrawing,
              prefixIcon: AppAsset.icDrawer,
              titleColor: AppColorConstant.appBlack,
              suffixIcon: AppAsset.icQuestion,
              onPrefixTap: () {
                controller.scaffoldKey.currentState?.openDrawer();
              },
              onSuffixTap: () => RouteHelper.instance.gotoHowToUseScreen(),
            ),
            drawer: buildDrawer(context),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  startDrawingView(),
                  Padding(
                    padding: const EdgeInsets.only(top: DimensPadding.paddingNormal,right: DimensPadding.paddingNormal,left: DimensPadding.paddingNormal),
                    child: Row(
                      children: [
                        buildOptions(
                            onTap: () => RouteHelper.instance.gotoTextSketchScreen(), background: AppAsset.textSketchBackGround, foreground: AppAsset.textSketchForeground, title: AppStringConstant.textToSketch),
                        const SizedBox(width: Dimens.heightVerySmall),
                        buildOptions(
                            onTap: () => RouteHelper.instance.gotoPhotoSketchScreen(),
                            background: AppAsset.photoSketchBackGround,
                            foreground: AppAsset.photoSketchForeground,
                            title: AppStringConstant.photoToSketch),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: DimensPadding.paddingNormal,horizontal: DimensPadding.paddingNormal),
                    child: Row(
                      children: [
                        buildOptions(onTap: () => RouteHelper.instance.gotoCreationScreen(), background: AppAsset.creationBackGround, foreground: AppAsset.creationForeground, title: AppStringConstant.creation),
                        const SizedBox(width: Dimens.heightVerySmall),
                        buildOptions(onTap: () => RouteHelper.instance.gotoFavoriteScreen(), background: AppAsset.favoriteBackGround, foreground: AppAsset.favoriteForeground, title: AppStringConstant.favorite),
                      ],
                    ),
                  ),
                  // buildCategoryView(homeController?.imagesMap['aesthetics'], 'Aesthetics'),
                  // buildCategoryView(homeController?.imagesMap['animals'], 'Animals'),
                  // buildCategoryView(homeController?.imagesMap['anime'], 'Anime'),
                  // buildCategoryView(homeController?.imagesMap['cars'], 'Cars'),
                  // buildCategoryView(homeController?.imagesMap['bakery'], 'Bakery'),
                  // buildCategoryView(homeController?.imagesMap['flower'], 'Flowers'),
                  // buildCategoryView(homeController?.imagesMap['fruit'], 'Fruit'),
                  // buildCategoryView(homeController?.imagesMap['space'], 'Space'),
                  // buildCategoryView(homeController?.imagesMap['vegetable'], 'Vegetable'),
                ],
              ),
            ),
          );
        });
  }

  Widget buildDrawer(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Drawer(
        child: Column(
          children: [
            AppAppBar(
              appbarTitle: AppStringConstant.setting,
            ),
            Column(
              children: [
                Stack(
                  children: [
                    const AppImageAsset(image: AppAsset.settingBackground),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(margin: const EdgeInsets.only(top: DimensPadding.paddingSmall),
                              width: MediaQuery.of(context).size.width * 0.30,
                              child: const AppImageAsset(
                                        image: AppAsset.photoSketchForeground,
                                      ),
                            ),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppText(
                                    AppStringConstant.arDraw,
                                    color: AppColorConstant.appWhite,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  SizedBox(height: Dimens.heightTiny),
                                  AppText(
                                    AppStringConstant.arDrawSettingDescription,
                                    color: AppColorConstant.appWhite,
                                    fontSize: Dimens.textSizeSmall,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ).paddingSymmetric(horizontal: DimensPadding.paddingExtraNormal),
            const SizedBox(height: Dimens.heightExtraSmall),
            Column(
              children: List.generate(
                homeScreenHelper!.staticDataModel.length,
                (index) {
                  return Column(
                    children: [
                      const SizedBox(
                        height: Dimens.heightExtraSmall,
                      ),
                      GestureDetector(onTap: homeScreenHelper!.staticDataModel[index].onTap,
                        child: Row(
                          children: [
                            Container(
                              height: Dimens.heightSmallExtraMedium,
                              width: Dimens.heightSmallExtraMedium,
                              padding: const EdgeInsets.all(DimensPadding.paddingExtraNormal),
                              decoration: BoxDecoration(shape: BoxShape.circle, color: homeScreenHelper?.staticDataModel[index].color.withOpacity(0.1)),
                              child: AppImageAsset(
                                image: homeScreenHelper!.staticDataModel[index].image,
                                height: 20,
                              ),
                            ),
                            AppText(
                              homeScreenHelper!.staticDataModel[index].title,
                              fontWeight: FontWeight.w500,
                              fontSize: Dimens.textSizeExtraMedium,
                            ).paddingOnly(left: DimensPadding.paddingNormal),
                            const Spacer(),
                            Container(height:40, width: 40,padding: const EdgeInsets.all(DimensPadding.paddingNormal),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimens.mediumBorderRadius), color: AppColorConstant.appLightGrey.withOpacity(0.5)),
                              child: const AppImageAsset(image: AppAsset.icSettingNext),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: Dimens.heightExtraSmall,
                      ),
                      if (index != homeScreenHelper!.staticDataModel.length - 1) const Divider(color: AppColorConstant.appLightGrey)
                    ],
                  ).paddingSymmetric(horizontal: DimensPadding.paddingExtraNormal);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget startDrawingView() {
    return InkWell(
      onTap: () => RouteHelper.instance.gotoDrawingScreen(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingNormal),
        child: Stack(
          children: [
            const AppImageAsset(image: AppAsset.startDrawBackGround),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.33,
                    ),
                    const Expanded(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.only(top: Dimens.heightTiny,  left: Dimens.widthSmall,right: Dimens.widthSmall),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppText(
                              AppStringConstant.startDrawing,
                              color: AppColorConstant.appWhite,
                              fontWeight: FontWeight.w600,
                            ),
                            SizedBox(height: Dimens.heightTiny),
                            AppText(
                              AppStringConstant.startDrawingJourney,
                              color: AppColorConstant.appWhite,
                              fontSize: Dimens.textSizeExtraSmall,
                              maxLines: 2,
                            ),
                            SizedBox(height: Dimens.heightExtraSmall),
                            AppButton(
                              title: AppStringConstant.letsGo,
                              color: AppColorConstant.appWhite,
                              titleColor: AppColorConstant.appBlack,
                              fontSize: Dimens.textSizeExtraSmall,
                              height: Dimens.heightSmall,
                              width: Dimens.widthLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOptions({required VoidCallback? onTap, required String background, required String foreground, required String title}) {
    return Expanded(
        child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                AppImageAsset(image: background),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              (title == AppStringConstant.creation || title == AppStringConstant.favorite)
                                  ? AppImageAsset(image: foreground)
                                  : AppImageAsset(
                                      image: foreground,
                                      width: Dimens.widthLarge,
                                      fit: BoxFit.cover,
                                    ),
                              const AppImageAsset(image: AppAsset.icNext)
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimens.heightExtraSmall),
                        AppText(
                          title,
                          color: AppColorConstant.appWhite,
                        )
                      ],
                    ),
                  ),
                )
              ],
            )));
  }

  Widget buildCategoryView(List<String>? imagesMap, String title) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingNormal),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                title,
                fontWeight: FontWeight.w600,
                fontSize: Dimens.textSizeMedium,
              ),
              InkWell(onTap: () => RouteHelper.instance.gotoCategoryScreen(imagesMap, title), child: const AppText(AppStringConstant.viewAll, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: Dimens.heightExtraSmall),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              5,
              (index) => Padding(
                padding: EdgeInsets.only(right: DimensPadding.paddingMedium,left: index == 0 ? DimensPadding.paddingNormal : 0),
                child: InkWell(
                  onTap: () => RouteHelper.instance.gotoPreviewScreen(imagePath: imagesMap![index], isImage: false, isText: false),
                  child: Container(
                    height: Dimens.heightVeryLarge,
                    width: Dimens.widthVeryLarge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimens.mediumBorderRadius),
                      border: Border.all(color: AppColorConstant.appGrey),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimens.mediumBorderRadius),
                      child: AppImageAsset(
                        fit: BoxFit.fill,
                        image: imagesMap?[index] ?? "",
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Dimens.heightMediumSmall),
      ],
    );
  }
}
