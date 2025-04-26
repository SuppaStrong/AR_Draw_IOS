import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
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

class CategoryScreenState extends State<CategoryScreen>
    with SingleTickerProviderStateMixin {
  CategoryScreenHelper? categoryScreenHelper;
  CategoryController? categoryController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    categoryScreenHelper ?? (categoryScreenHelper = CategoryScreenHelper(this));

    return GetBuilder(
        init: CategoryController(),
        builder: (CategoryController controller) {
          categoryController = controller;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppAppBarIOS(
              title: categoryScreenHelper!.appbarTitle ?? '',
              backgroundColor: Colors.white,
              elevation: 0.5,
              actions: [
                _buildFilterButton(),
                const SizedBox(width: 8),
              ],
            ),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildCategoryHeader(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        padding: const EdgeInsets.only(top: 16, bottom: 24),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: categoryScreenHelper!.imagesMap!.length,
                        itemBuilder: (context, index) {
                          final imagePath =
                              categoryScreenHelper!.imagesMap![index];
                          final isFavorite = categoryScreenHelper!.favorites
                              .contains(imagePath);

                          final double delayFactor = 0.2 + (index * 0.05);
                          final Animation<double> itemAnimation =
                              CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(delayFactor.clamp(0.0, 0.8),
                                (delayFactor + 0.2).clamp(0.0, 1.0),
                                curve: Curves.easeOut),
                          );

                          return FadeTransition(
                            opacity: itemAnimation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.2),
                                end: Offset.zero,
                              ).animate(itemAnimation),
                              child:
                                  _buildImageCard(imagePath, isFavorite, index),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: _buildFloatingActionButton(),
          );
        });
  }

  Widget _buildFilterButton() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: IconButton(
        icon: const Icon(
          Icons.filter_list_rounded,
          color: AppColorConstant.appDeepPurple,
          size: 24,
        ),
        onPressed: () {
          _showFilterOptions();
        },
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.filter_list_rounded,
                    color: AppColorConstant.appDeepPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Filter Options",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFilterOption("Show Favorites Only", false),
              _buildFilterOption("Sort by Recent", true),
              _buildFilterOption("Sort by Popular", false),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorConstant.appDeepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "Apply Filters",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String title, bool selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            selected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: selected ? AppColorConstant.appDeepPurple : Colors.grey,
            size: 22,
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: selected ? Colors.black : Colors.black.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                categoryScreenHelper!.appbarTitle ?? 'Category',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "${categoryScreenHelper!.imagesMap!.length} items available",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColorConstant.appLightPurple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.favorite,
                  size: 16,
                  color: AppColorConstant.appErrorColor,
                ),
                const SizedBox(width: 6),
                Text(
                  "${categoryScreenHelper!.favorites.length} favorites",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColorConstant.appDeepPurple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(String imagePath, bool isFavorite, int index) {
    return InkWell(
      onTap: () => RouteHelper.instance.gotoPreviewScreen(
          imagePath: imagePath, isImage: false, isText: false),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      color: Colors.grey.shade100,
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: AppImageAsset(
                        fit: BoxFit.cover,
                        image: imagePath,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: GestureDetector(
                      onTap: () {
                        categoryScreenHelper?.toggleFavorite(imagePath);
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            isFavorite ? Icons.star : Icons.star_border_rounded,
                            color: isFavorite
                                ? const Color(0xFFFFB800)
                                : Colors.grey.shade400,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Item ${index + 1}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getImageType(imagePath),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColorConstant.appLightPurple.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColorConstant.appDeepPurple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getImageType(String imagePath) {
    if (imagePath.toLowerCase().contains('flower')) {
      return 'Flower';
    } else if (imagePath.toLowerCase().contains('animal')) {
      return 'Animal';
    } else if (imagePath.toLowerCase().contains('car')) {
      return 'Vehicle';
    } else {
      return 'Object';
    }
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColorConstant.appDeepPurple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: AppColorConstant.appDeepPurple,
        onPressed: () {
          RouteHelper.instance.gotoBack();
        },
        child: const Icon(
          Icons.brush_rounded,
          color: Colors.white,
        ),
      ),
    );
  }
}
