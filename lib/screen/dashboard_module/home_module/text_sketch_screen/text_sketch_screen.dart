import 'dart:convert';
import 'dart:typed_data';
import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/widgets/app_button.dart';
import 'package:ar_draw/app_routes/route_helper.dart';
import 'package:ar_draw/controller/text_sketch_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ar_draw/app/widgets/app_app_bar.dart';
import 'package:ar_draw/screen/dashboard_module/home_module/text_sketch_screen/text_sketch_screen_helper.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TextSketchScreen extends StatefulWidget {
  const TextSketchScreen({super.key});

  @override
  State<TextSketchScreen> createState() => TextSketchScreenState();
}

class TextSketchScreenState extends State<TextSketchScreen>
    with SingleTickerProviderStateMixin {
  TextSketchController? textSketchController;
  TextSketchScreenHelper? textSketchScreenHelper;
  final WidgetsToImageController _controller = WidgetsToImageController();
  Uint8List? imageBytes;
  late AnimationController _animationController;
  late Animation<double> _previewAnimation;
  final FocusNode _textFocusNode = FocusNode();
  bool _isPreviewVisible = false;

  // Default text color
  Color _textColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _previewAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _textFocusNode.addListener(() {
      if (!_textFocusNode.hasFocus) {
        _isPreviewVisible = true;
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    textSketchScreenHelper ??
        (textSketchScreenHelper = TextSketchScreenHelper(this));
    return GetBuilder(
        init: TextSketchController(),
        builder: (TextSketchController controller) {
          textSketchController = controller;

          if ((textSketchScreenHelper?.enteredText ?? '').isNotEmpty &&
              !_isPreviewVisible) {
            _isPreviewVisible = true;
            _animationController.forward();
          }

          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppAppBarIOS(
                title: AppStringConstant.textToSketch,
                elevation: 0.5,
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        _showColorPicker();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              AppColorConstant.appLightPurple.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.color_lens_outlined,
                              color: AppColorConstant.appDeepPurple,
                              size: 22,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: _textColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              "Create Text",
                              Icons.text_fields_rounded,
                              marginTop: 0,
                            ),
                            _buildTextField(),
                            _buildPreviewSection(),
                            _buildSectionHeader(
                              AppStringConstant.selectFont,
                              Icons.font_download_outlined,
                            ),
                            _buildFontList(),
                            _buildSectionHeader(
                              AppStringConstant.selectTextSize,
                              Icons.format_size_rounded,
                            ),
                            _buildSizeSlider(),
                            _buildSectionHeader(
                              "Text Color",
                              Icons.color_lens_rounded,
                            ),
                            _buildColorPreview(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildBottomBar(),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildSectionHeader(String title, IconData icon,
      {double marginTop = 24}) {
    return Container(
      margin: EdgeInsets.only(top: marginTop, bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColorConstant.appLightPurple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColorConstant.appDeepPurple,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColorConstant.appLightPurple.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColorConstant.appLightPurple.withOpacity(0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: TextField(
            focusNode: _textFocusNode,
            textAlign: TextAlign.center,
            onChanged: (text) {
              textSketchScreenHelper?.enteredText = text;
              textSketchController?.update();

              if (text.isNotEmpty && !_isPreviewVisible) {
                _isPreviewVisible = true;
                _animationController.forward();
              } else if (text.isEmpty && _isPreviewVisible) {
                _isPreviewVisible = false;
                _animationController.reverse();
              }
            },
            maxLines: 3,
            decoration: InputDecoration(
              hintText: AppStringConstant.enterText,
              hintStyle: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade400,
              ),
              border: InputBorder.none,
            ),
            style: GoogleFonts.getFont(
              textSketchScreenHelper!.selectedFontFamily,
              textStyle: TextStyle(
                fontSize: 18,
                height: 1.5,
                color: _textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    final enteredText = textSketchScreenHelper?.enteredText ?? '';

    if (enteredText.isEmpty) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _previewAnimation,
      child: SizeTransition(
        sizeFactor: _previewAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                AppStringConstant.imagePreview,
                Icons.preview_rounded,
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColorConstant.appLightPurple.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: WidgetsToImage(
                    controller: _controller,
                    child: buildTextWidget(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSizeSlider() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Small",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColorConstant.appLightPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${textSketchScreenHelper?.sliderValue.round()}pt",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColorConstant.appDeepPurple,
                  ),
                ),
              ),
              Text(
                "Large",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        SliderTheme(
          data: const SliderThemeData(
            trackHeight: 4,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 8,
            ),
            overlayShape: RoundSliderOverlayShape(
              overlayRadius: 20,
            ),
            valueIndicatorShape: PaddleSliderValueIndicatorShape(),
            valueIndicatorTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            valueIndicatorColor: AppColorConstant.appDeepPurple,
          ),
          child: Slider(
            value: textSketchScreenHelper!.sliderValue,
            min: 10.0,
            max: 50.0,
            divisions: 10,
            activeColor: AppColorConstant.appDeepPurple,
            inactiveColor: AppColorConstant.appLightPurple.withOpacity(0.3),
            label: textSketchScreenHelper?.sliderValue.round().toString(),
            onChanged: (double value) {
              textSketchScreenHelper?.sliderValue = value;
              textSketchController?.update();
            },
          ),
        ),
      ],
    );
  }

  Widget buildTextWidget() {
    final enteredText = textSketchScreenHelper?.enteredText ?? '';

    if (enteredText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      enteredText,
      textAlign: TextAlign.center,
      style: GoogleFonts.getFont(
        textSketchScreenHelper!.selectedFontFamily,
        fontSize: textSketchScreenHelper?.sliderValue ?? 14.0,
        color: _textColor,
        height: 1.3,
      ),
    );
  }

  Widget _buildFontList() {
    return Container(
      height: 56,
      margin: const EdgeInsets.only(top: 8, bottom: 24),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: textSketchScreenHelper?.fontFamilies.length,
        itemBuilder: (context, index) {
          return _buildFontOption(
              fontFamily:
                  textSketchScreenHelper?.fontFamilies[index] ?? 'Roboto');
        },
      ),
    );
  }

  Widget _buildFontOption({String fontFamily = 'Roboto'}) {
    final isSelected = textSketchScreenHelper?.selectedFontFamily == fontFamily;

    return GestureDetector(
      onTap: () {
        textSketchScreenHelper?.selectedFontFamily = fontFamily;
        textSketchController?.update();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColorConstant.appDeepPurple : Colors.white,
          border: Border.all(
            color: isSelected
                ? AppColorConstant.appDeepPurple
                : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColorConstant.appDeepPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          fontFamily,
          style: GoogleFonts.getFont(
            fontFamily,
            textStyle: TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.white : Colors.black.withOpacity(0.7),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
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
          child: AppButton(
            title: AppStringConstant.continueText,
            onTap: () async {
              await captureTextAsImage();
              if (imageBytes != null) {
                RouteHelper.instance.gotoPreviewScreen(
                  imagePath: base64Encode(imageBytes!),
                  isImage: false,
                  isText: true,
                );
              }
            },
            gradient: const [
              AppColorConstant.appLightPurple,
              AppColorConstant.appDeepPurple
            ],
            width: double.infinity,
            height: 56,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
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
                    Icons.color_lens_rounded,
                    color: AppColorConstant.appDeepPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Choose Text Color",
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

              // Current color indicator
              // Center(
              //   child: Container(
              //     margin: const EdgeInsets.only(bottom: 16),
              //     width: 60,
              //     height: 60,
              //     decoration: BoxDecoration(
              //       color: _textColor,
              //       shape: BoxShape.circle,
              //       border: Border.all(color: Colors.grey.shade300),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.black.withOpacity(0.1),
              //           blurRadius: 8,
              //           offset: const Offset(0, 4),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              // Color picker
              SizedBox(
                height: 350,
                child: ColorPicker(
                  pickerColor: _textColor,
                  onColorChanged: (color) {
                    setState(() {
                      _textColor = color;
                    });
                  },
                  pickerAreaHeightPercent: 0.7,
                  enableAlpha: false,
                  displayThumbColor: true,
                  hexInputBar: true,
                  portraitOnly: true,
                  pickerAreaBorderRadius:
                      const BorderRadius.all(Radius.circular(16)),
                  labelTypes: const [],
                ),
              ),

              const SizedBox(height: 20),

              // Apply button
              SafeArea(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      // Update the text color and refresh the UI
                      setState(() {});
                      textSketchController?.update();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorConstant.appDeepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Apply Color",
                      style: TextStyle(
                        fontSize: 16,
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

  Widget _buildColorPreview() {
    final List<Color> presetColors = [
      Colors.black,
      Colors.white,
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
    ];

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 24),
      height: 60,
      child: Row(
        children: [
          // Current color preview
          GestureDetector(
            onTap: () {
              _showColorPicker();
            },
            child: Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: _textColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.colorize,
                  color: _textColor.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // Color palette
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: presetColors.length,
              itemBuilder: (context, index) {
                final color = presetColors[index];
                final isSelected = color.value == _textColor.value;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _textColor = color;
                    });
                    textSketchController?.update();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColorConstant.appDeepPurple
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColorConstant.appDeepPurple
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: color.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white,
                            size: 18,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> captureTextAsImage() async {
    final capturedImage = await _controller.capture();
    if (capturedImage != null) {
      imageBytes = capturedImage;
      textSketchController?.update();
    }
  }
}
