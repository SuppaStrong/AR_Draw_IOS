import 'dart:convert';

import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
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

class PreviewScreenState extends State<PreviewScreen>
    with SingleTickerProviderStateMixin {
  PreviewScreenHelper? previewScreenHelper;
  PreviewController? previewController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
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
    previewScreenHelper ?? (previewScreenHelper = PreviewScreenHelper(this));

    return GetBuilder(
        init: PreviewController(),
        builder: (PreviewController controller) {
          previewController = controller;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppAppBarIOS(
              title: previewScreenHelper?.isText == true
                  ? AppStringConstant.textPreview
                  : AppStringConstant.preview,
              elevation: 0.5,
              backgroundColor: Colors.white,
            ),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatusBar(),
                  if (previewScreenHelper?.imagePath != null)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 24, right: 24, top: 16, bottom: 8),
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: _buildImagePreview(),
                        ),
                      ),
                    ),
                  _buildBottomControls(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColorConstant.appLightPurple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  previewScreenHelper?.isText == true
                      ? Icons.text_fields
                      : Icons.image,
                  size: 16,
                  color: AppColorConstant.appDeepPurple,
                ),
                const SizedBox(width: 6),
                Text(
                  previewScreenHelper?.isText == true ? "Text" : "Image",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColorConstant.appDeepPurple,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            "Ready to draw",
            style: TextStyle(
              fontSize: 13,
              color: Colors.black.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColorConstant.appLightPurple.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColorConstant.appLightPurple.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColorConstant.appLightPurple.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: (previewScreenHelper?.isText == true)
                  ? Image.memory(
                      base64Decode(previewScreenHelper!.imagePath!),
                      fit: BoxFit.contain,
                    )
                  : AppImageAsset(
                      image: previewScreenHelper?.imagePath ?? "",
                      isFile: previewScreenHelper?.isImage == true &&
                              previewScreenHelper?.isText == false
                          ? true
                          : false,
                      fit: BoxFit.contain,
                    ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: _buildCornerDecoration(),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _buildCornerDecoration(),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: _buildCornerDecoration(),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: _buildCornerDecoration(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerDecoration() {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border.all(
          color: AppColorConstant.appLightPurple.withOpacity(0.4),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              "Your ${previewScreenHelper?.isText == true ? 'text' : 'image'} is ready for AR drawing.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return AppBottomSheet(
                    buttonTitle: AppStringConstant.draw,
                    drawOptions: previewScreenHelper!.drawOptions,
                    buttonCallback: () {
                      RouteHelper.instance.gotoBack();
                      if (previewController?.selectedIndex == 1) {
                        RouteHelper.instance.gotoCanvasScreen(
                          previewScreenHelper!.imagePath,
                          isText: previewScreenHelper?.isText == true
                              ? true
                              : false,
                          isImage: previewScreenHelper?.isImage == true
                              ? true
                              : false,
                        );
                      }
                      if (previewController?.selectedIndex == 0) {
                        RouteHelper.instance.gotoSketchDrawingScreen(
                          previewScreenHelper!.imagePath,
                          isText: previewScreenHelper?.isText == true
                              ? true
                              : false,
                          isImage: previewScreenHelper?.isImage == true
                              ? true
                              : false,
                        );
                      }
                      previewController?.selectedIndex = -1;
                    },
                  );
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColorConstant.appDeepPurple.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const AppButton(
                title: AppStringConstant.startDrawing,
                gradient: [
                  AppColorConstant.appLightPurple,
                  AppColorConstant.appDeepPurple
                ],
                height: 56,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Change Selection",
                style: TextStyle(
                  fontSize: 15,
                  color: AppColorConstant.appDeepPurple.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
