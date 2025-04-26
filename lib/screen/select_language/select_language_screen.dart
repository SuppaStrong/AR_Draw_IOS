// ignore_for_file: avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class SelectLanguageScreen extends StatefulWidget {
  const SelectLanguageScreen({super.key, required this.canGoNext});
  final bool canGoNext;

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  String? selectedLanguage;
  // late FlutterLocalization flutterLocalization;
  // NativeAd? nativeAdLanguage;
  // final bool _isAdLoaded = false;
  final ScrollController _scrollController = ScrollController();

  final Color _backgroundColor = const Color(0xFF121212);
  final Color _surfaceColor = const Color(0xFF1E1E1E);
  final Color _primaryColor = const Color(0xFF007AFF);
  final Color _textColor = Colors.white;
  final Color _subtleTextColor = const Color(0xFFAAAAAA);

  @override
  void initState() {
    super.initState();
    // flutterLocalization = FlutterLocalization.instance;
    // if (AdManager().adsConfigId.nativeId1 != null &&
    //     OnePref.getPremium() == false) {
    //   _loadAds();
    // }
  }

  @override
  void dispose() {
    // AdManager().nativeAdLanguage?.dispose();
    // AdManager().nativeAdLanguage = null;
    // nativeAdLanguage?.dispose();
    // nativeAdLanguage = null;
    _scrollController.dispose();
    super.dispose();
  }

  // void _loadAds() async {
  //   if (AdManager().nativeAdLanguage != null) {
  //     nativeAdLanguage = AdManager().nativeAdLanguage;
  //     setState(() {
  //       _isAdLoaded = true;
  //     });
  //   } else {
  //     AdManager().loadNativeAdTarget(
  //         (ad) {
  //           nativeAdLanguage = ad;
  //         },
  //         (AdManager().adsConfigId.nativeId5 ?? ''),
  //         "nativeAddLargeSize",
  //         context,
  //         (isLoadSuccess) {
  //           if (isLoadSuccess == true && mounted) {
  //             print('Suppa : ============> Loaded nativeAdLanguage');
  //             setState(() {
  //               _isAdLoaded = true;
  //             });
  //           } else if (mounted) {
  //             setState(() {
  //               _isAdLoaded = false;
  //             });
  //           }
  //         });
  //   }
  // }

  Future<void> _selectLanguage(Language language) async {
    // widget.canGoNext
    //     ? null
    //     : ref.read(wifiTVRemoteProvider).appLanguageSet(language.name);
    setState(() {
      selectedLanguage = language.languageCode;
      // flutterLocalization.translate(language.languageCode);
    });
  }

  Widget _buildLanguageTile(Language language) {
    final bool isSelected = selectedLanguage == language.languageCode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? _primaryColor.withOpacity(0.2) : _surfaceColor,
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: _primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
        border: Border.all(
          color: isSelected ? _primaryColor : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _selectLanguage(language),
          splashColor: _primaryColor.withOpacity(0.1),
          highlightColor: _primaryColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      language.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    language.name,
                    style: TextStyle(
                      color: isSelected ? _primaryColor : _textColor,
                      fontSize: 17,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.check_mark,
                      color: Colors.white,
                      size: 14,
                    ),
                  )
                else
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _surfaceColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _subtleTextColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageList() {
    return Expanded(
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 12, bottom: 24),
          itemCount: languages.length,
          itemBuilder: (context, index) => _buildLanguageTile(languages[index]),
        ),
      ),
    );
  }

  Widget _buildDoneButton() {
    final bool canProceed = selectedLanguage != null;

    return AnimatedOpacity(
      opacity: canProceed ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        onPressed: canProceed ? () {} : null,
        borderRadius: BorderRadius.circular(30),
        color: _primaryColor,
        child: Text(
          "Select Language",
          style: TextStyle(
            color: canProceed ? Colors.white : Colors.white.withOpacity(0.7),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        toolbarHeight: 70,
        leadingWidth: widget.canGoNext ? 0 : null,
        leading: widget.canGoNext
            ? const SizedBox.shrink()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  CupertinoIcons.xmark,
                  color: _textColor,
                  size: 24,
                ),
                onPressed: () => Navigator.pop(context),
              ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Language",
              style: TextStyle(
                fontSize: 24,
                color: _textColor,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Choose your preferred language',
              style: TextStyle(
                fontSize: 14,
                color: _subtleTextColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          widget.canGoNext ? _buildDoneButton() : const SizedBox.shrink(),
          const SizedBox(height: 10),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [_buildLanguageList()],
        ),
      ),
    );
  }

  // Widget _buildAds() {
  //   if (AdManager().isPremiumUser || AdManager().adsConfigId.nativeId5 == '') {
  //     return const SizedBox.shrink();
  //   }

  //   return Container(
  //     margin: const EdgeInsets.all(10),
  //     height: 350,
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //         color: Colors.white30, borderRadius: BorderRadius.circular(5)),
  //     child: _isAdLoaded
  //         ? AdWidget(ad: nativeAdLanguage!)
  //         : const ShimmerPlaceholder(),
  //   );
  // }
}

List<Language> languages = [
  Language('English', 'assets/images/img_language_en.png', "en"),
  Language('German', 'assets/images/img_language_de.png', "de"),
  Language('French', 'assets/images/img_language_fr.png', "fr"),
  Language('Portuguese', 'assets/images/img_language_pt.png', "pt"),
  Language('Japanese', 'assets/images/img_language_japan.png', "ja"),
  Language('Italian', 'assets/images/img_language_it.png', "it"),
  Language('Korean', 'assets/images/img_language_korean.png', "kr"),
  Language('Chinese', 'assets/images/img_language_china.png', "zh"),
  Language('Hindi', 'assets/images/img_language_india.png', "hi"),
  Language('Russian', 'assets/images/img_language_ru.png', "ru"),
  Language('Vietnamese', 'assets/images/img_language_vi.png', "vi"),
];

class Language {
  final String name;
  final String imageUrl;
  final String languageCode;
  Language(this.name, this.imageUrl, this.languageCode);
}
