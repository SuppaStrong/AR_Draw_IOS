import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/widgets/app_app_bar.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:ar_draw/app/widgets/app_text.dart';
import 'package:ar_draw/app_routes/route_helper.dart';
import 'package:ar_draw/controller/category_controller.dart';
import 'package:ar_draw/screen/dashboard_module/home_module/favorite_screen/favorite_screen_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => FavoriteScreenState();
}

class FavoriteScreenState extends State<FavoriteScreen>
    with SingleTickerProviderStateMixin {
  CategoryController? categoryController;
  FavoriteScreenHelper? favoriteScreenHelper;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    "current screen --> $runtimeType".logs();

    favoriteScreenHelper ?? (favoriteScreenHelper = FavoriteScreenHelper(this));
    return GetBuilder(
        init: CategoryController(),
        builder: (CategoryController controller) {
          categoryController = controller;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppAppBarIOS(
              title: "Favorites",
              showBackButton: true,
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      CupertinoIcons.info,
                      color: AppColorConstant.appDeepPurple,
                    ),
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: const Text("About Favorites"),
                          content: const Text(
                            "Items you mark as favorites will appear here for easy access. Tap any item to view it in full screen.",
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text("Got it"),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            body: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _animationController,
                  child: child,
                );
              },
              child: buildBodyView(),
            ),
          );
        });
  }

  Widget buildBodyView() {
    if (favoriteScreenHelper?.favoriteItems?.isEmpty ?? true) {
      return _buildEmptyState();
    } else {
      return _buildFavoritesGrid();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppImageAsset(
            image: AppAsset.icNoData,
            height: 150,
            width: 150,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: const AppText(
              AppStringConstant.noFavorite,
              textAlign: TextAlign.center,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: AppColorConstant.appDeepPurple,
            child: const Text(
              "Explore Art",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: favoriteScreenHelper!.favoriteItems!.length,
        itemBuilder: (context, index) {
          final imagePath = favoriteScreenHelper!.favoriteItems![index];

          return _buildGridItem(imagePath, index);
        },
      ),
    );
  }

  Widget _buildGridItem(String imagePath, int index) {
    final Animation<double> itemAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.05 * index,
        0.05 * index + 0.5,
        curve: Curves.easeOut,
      ),
    );

    return AnimatedBuilder(
      animation: itemAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - itemAnimation.value)),
          child: Opacity(
            opacity: itemAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => RouteHelper.instance.gotoPreviewScreen(
              imagePath: imagePath, isImage: false, isText: false),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Container(
                  color: Colors.grey.shade100,
                  width: double.infinity,
                  height: double.infinity,
                ),
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: AppImageAsset(
                    fit: BoxFit.cover,
                    image: imagePath,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildFavoriteButton(imagePath),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Text(
                    "Artwork ${index + 1}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(String imagePath) {
    return Positioned(
      right: 8,
      top: 8,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          favoriteScreenHelper?.removeFromFavorite(imagePath);
        },
        child: Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              CupertinoIcons.heart_fill,
              color: Colors.red.shade400,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
