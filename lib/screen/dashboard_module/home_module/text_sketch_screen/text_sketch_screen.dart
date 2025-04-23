import 'dart:convert';
import 'dart:typed_data';
import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/utills/dimension.dart';
import 'package:ar_draw/app/widgets/app_button.dart';
import 'package:ar_draw/app_routes/route_helper.dart';
import 'package:ar_draw/controller/text_sketch_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ar_draw/app/widgets/app_app_bar.dart';
import 'package:ar_draw/screen/dashboard_module/home_module/text_sketch_screen/text_sketch_screen_helper.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class TextSketchScreen extends StatefulWidget {
  const TextSketchScreen({super.key});

  @override
  State<TextSketchScreen> createState() => TextSketchScreenState();
}

class TextSketchScreenState extends State<TextSketchScreen> {
  TextSketchController? textSketchController;
  TextSketchScreenHelper? textSketchScreenHelper;
  final WidgetsToImageController _controller = WidgetsToImageController();
  Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    textSketchScreenHelper ?? (textSketchScreenHelper = TextSketchScreenHelper(this));
    return GetBuilder(
        init: TextSketchController(),
        builder: (TextSketchController controller) {
          textSketchController = controller;
          return Scaffold(
            appBar: AppAppBar(
              appbarTitle: AppStringConstant.textToSketch,
              appBarColor: AppColorConstant.appWhite,
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(DimensPadding.paddingSemiNormal),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildTextField(),
                          const SizedBox(height: Dimens.heightSmall),
                          const Text(AppStringConstant.selectTextSize, style: TextStyle(fontWeight: FontWeight.bold)),
                          Slider(
                            value: textSketchScreenHelper!.sliderValue,
                            min: 10.0,
                            max: 50.0,
                            divisions: 10,
                            activeColor: AppColorConstant.appDeepPurple.withOpacity(0.7),
                            label: textSketchScreenHelper?.sliderValue.round().toString(),
                            onChanged: (double value) {
                              textSketchScreenHelper?.sliderValue = value;
                              textSketchController?.update();
                            },
                          ),
                          const SizedBox(height: Dimens.heightSmall),
                          const Text(AppStringConstant.selectFont, style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: Dimens.heightVerySmall),
                          buildFontList(),
                          const SizedBox(height: Dimens.heightSmall),
                          const Text(AppStringConstant.imagePreview, style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: Dimens.heightVerySmall),
                          Center(
                            child: WidgetsToImage(
                              controller: _controller,
                              child: buildTextWidget(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Dimens.heightSmall),
                AppButton(
                  margin: const EdgeInsets.symmetric(horizontal: DimensPadding.paddingNormal),
                  title: AppStringConstant.continueText,
                  onTap: () async {
                    await captureTextAsImage();
                    RouteHelper.instance.gotoPreviewScreen(imagePath: base64Encode(imageBytes!), isImage: false,isText: true);
                  },
                  gradient: const [AppColorConstant.appLightPurple, AppColorConstant.appDeepPurple],
                  width: double.infinity,
                ),
                const SizedBox(height: Dimens.heightSmall),
              ],
            ),
          );
        });
  }

  Future<void> captureTextAsImage() async {
    final capturedImage = await _controller.capture();
    if (capturedImage != null) {
      imageBytes = capturedImage;
      textSketchController?.update();
    }
  }

  Widget buildTextWidget() {
    final enteredText = textSketchScreenHelper?.enteredText ?? '';

    if (enteredText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(DimensPadding.paddingSemiNormal),
      color: AppColorConstant.appTransparent,
      child: Text(
        enteredText,
        style: GoogleFonts.getFont(
          textSketchScreenHelper!.selectedFontFamily,
          fontSize: textSketchScreenHelper?.sliderValue ?? 14.0,
          color: AppColorConstant.appBlack,
        ),
      ),
    );
  }

  Widget buildTextField() {
    return Container(
      height: Dimens.heightVeryExtraLarge,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(DimensPadding.paddingSemiNormal),
      decoration: BoxDecoration(
        color: AppColorConstant.appLightPurple.withOpacity(0.1),
        border: Border.all(color: AppColorConstant.appDeepPurple),
        borderRadius: BorderRadius.circular(Dimens.defaultBorderRadius),
      ),
      child: TextField(
        textAlign: TextAlign.center,
        onChanged: (text) {
          textSketchScreenHelper?.enteredText = text;
          textSketchController?.update();
        },
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: AppStringConstant.enterText,
          hintStyle: TextStyle(fontSize: Dimens.textSizeLarge),
          border: InputBorder.none,
        ),
        style: GoogleFonts.getFont(
          textSketchScreenHelper!.selectedFontFamily,
          textStyle: TextStyle(
            fontSize: textSketchScreenHelper?.sliderValue,
          ),
        ),
      ),
    );
  }

  Widget buildFontOption({String fontFamily = 'Roboto'}) {
    return GestureDetector(
      onTap: () {
        textSketchScreenHelper?.selectedFontFamily = fontFamily;
        textSketchController?.update();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimens.defaultBorderRadius),
          color: (textSketchScreenHelper?.selectedFontFamily == fontFamily) ? AppColorConstant.appLightPurple : AppColorConstant.appLightPurple.withOpacity(Dimens.opacityTiny),
        ),
        alignment: Alignment.center,
        child: Text(
          AppStringConstant.helloText,
          style: GoogleFonts.getFont(
            fontFamily,
            textStyle: TextStyle(fontSize: Dimens.textSizeExtraMedium, color: (textSketchScreenHelper?.selectedFontFamily == fontFamily) ? AppColorConstant.appWhite : AppColorConstant.appBlack),
          ),
        ),
      ),
    );
  }

  Widget buildFontList() {
    return GridView.custom(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      childrenDelegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
          return buildFontOption(fontFamily: textSketchScreenHelper?.fontFamilies[index]);
        },
        childCount: textSketchScreenHelper?.fontFamilies.length,
      ),
    );
  }
}
