import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/widgets/app_image_asset.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Drag indicator
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              AppColorConstant.appLightPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          CupertinoIcons.square_list,
                          color: AppColorConstant.appDeepPurple,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        AppStringConstant.chooseOneOption,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.xmark,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Options list
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: drawOptions.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      bool isSelected = controller.selectedIndex == index;
                      return _buildOptionItem(
                          context, index, isSelected, controller);
                    },
                  ),
                ),

                // Action button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppColorConstant.appDeepPurple.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(14),
                      color: controller.selectedIndex != -1
                          ? AppColorConstant.appDeepPurple
                          : Colors.grey.shade300,
                      onPressed: controller.selectedIndex != -1
                          ? buttonCallback
                          : null,
                      child: SizedBox(
                        height: 56,
                        child: Center(
                          child: Text(
                            buttonTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildOptionItem(BuildContext context, int index, bool isSelected,
      PreviewController controller) {
    return GestureDetector(
      onTap: () => controller.updateSelectedIndex(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColorConstant.appDeepPurple
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? AppColorConstant.appLightPurple.withOpacity(0.1)
              : Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Selection indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColorConstant.appDeepPurple
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                  color: isSelected
                      ? AppColorConstant.appDeepPurple
                      : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),

              const SizedBox(width: 16),

              // Option image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AppImageAsset(
                    image: drawOptions[index]['image']!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Option text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Option ${index + 1}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColorConstant.appDeepPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      drawOptions[index]['title']!,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(0.9),
                      ),
                    ),
                    if (drawOptions[index]['description'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        drawOptions[index]['description']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
