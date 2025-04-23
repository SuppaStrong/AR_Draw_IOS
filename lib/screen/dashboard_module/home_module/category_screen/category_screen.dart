import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/utills/dimension.dart';
import 'package:ar_draw/app/widgets/app_app_bar.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app_routes/route_helper.dart';
import 'package:ar_draw/controller/category_controller.dart';
import 'package:ar_draw/screen/dashboard_module/home_module/category_screen/category_screen_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => CategoryScreenState();
}

class CategoryScreenState extends State<CategoryScreen> {
  CategoryScreenHelper? categoryScreenHelper;
  CategoryController? categoryController;

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    categoryScreenHelper ?? (categoryScreenHelper = CategoryScreenHelper(this));

    return GetBuilder(
        init: CategoryController(),
        builder: (CategoryController controller) {
          categoryController = controller;
          return Scaffold(
            appBar: AppAppBar(
              appbarTitle: categoryScreenHelper!.appbarTitle ?? '',
            ),
            body: Column(
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
                      itemCount: categoryScreenHelper!.imagesMap!.length,
                      itemBuilder: (context, index) {
                        final imagePath = categoryScreenHelper!.imagesMap![index];
                        final isFavorite = categoryScreenHelper!.favorites.contains(imagePath);

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
                                Positioned(
                                  right: 7,
                                  top: 7,
                                  child: GestureDetector(
                                    onTap: () {
                                      categoryScreenHelper?.toggleFavorite(imagePath);
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(Dimens.defaultBorderRadius),
                                      child: Container(
                                        padding: const EdgeInsets.all(DimensPadding.paddingSmall),
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(colors: [AppColorConstant.appLightPurple, AppColorConstant.appDeepPurple], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                        ),
                                        child: AppImageAsset(
                                          image: isFavorite ? AppAsset.icFilledStar : AppAsset.icStar,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
