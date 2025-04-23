import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/utills/dimension.dart';
import 'package:ar_draw/app/widgets/app_app_bar.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app/widgets/app_text.dart';
import 'package:ar_draw/app_routes/route_helper.dart';
import 'package:ar_draw/controller/category_controller.dart';
import 'package:ar_draw/screen/dashboard_module/home_module/favorite_screen/favorite_screen_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/constant/color_constant.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => FavoriteScreenState();
}

class FavoriteScreenState extends State<FavoriteScreen> {
  CategoryController? categoryController;
  FavoriteScreenHelper? favoriteScreenHelper;
  @override
  Widget build(BuildContext context) {
    "current screen --> $runtimeType".logs();

    favoriteScreenHelper ?? (favoriteScreenHelper = FavoriteScreenHelper(this));
    return GetBuilder(init: CategoryController(),
      builder: (CategoryController controller) {
        categoryController = controller;
        return Scaffold(
          appBar: AppAppBar(appbarTitle: AppStringConstant.favorite),
          body: buildBodyView(),
        );
      }
    );
  }
  Widget buildBodyView()
  {
    return (favoriteScreenHelper?.favoriteItems?.isEmpty ?? true)
        ? const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppImageAsset(image: AppAsset.icNoData),
              SizedBox(height: Dimens.heightSmall),
              AppText(AppStringConstant.noFavorite),
            ],
          ),
        )
        : Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingNormal),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: favoriteScreenHelper!.favoriteItems!.length,
              itemBuilder: (context, index) {
                final imagePath = favoriteScreenHelper!.favoriteItems![index];

                return InkWell(
                  onTap: () => RouteHelper.instance.gotoPreviewScreen(imagePath: imagePath, isImage: false, isText: false),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimens.mediumBorderRadius),
                      border: Border.all(color: AppColorConstant.appGrey),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(Dimens.mediumBorderRadius),
                          child: AppImageAsset(
                            fit: BoxFit.fill,
                            image: imagePath,
                          ),
                        ),
                        buildStackView(imagePath),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
  Widget buildStackView(String imagePath)
  {
    return Positioned(
      right: 7,
      top: 7,
      child: GestureDetector(
        onTap: () {
          favoriteScreenHelper?.removeFromFavorite(imagePath);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimens.defaultBorderRadius),
          child: Container(
            padding: const EdgeInsets.all(DimensPadding.paddingSmall),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColorConstant.appLightPurple, AppColorConstant.appDeepPurple], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: const AppImageAsset(
              image: AppAsset.icFilledStar ,
            ),
          ),
        ),
      ),
    );
  }
}
