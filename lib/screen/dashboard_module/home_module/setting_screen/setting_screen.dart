import 'dart:io';

import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app_routes/route_helper.dart';
import 'package:ar_draw/screen/dashboard_module/home_module/setting_screen/feedback.dart';
import 'package:ar_draw/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

String appLink = Platform.isAndroid
    ? "https://play.google.com/store/apps/details?id=com.modmpe.modmpe"
    : "https://apps.apple.com/app/id6745116433";
String policyLink = "https://nganha1997.netlify.app/policy.txt";
String termsLink = "https://nganha1997.netlify.app/policy.txt";

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    return Scaffold(
      backgroundColor: ArDrawTheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ArDrawTheme.background,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ArDrawTheme.textPrimary,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                _buildProfileSection(),
                const SizedBox(height: 24),
                _buildSectionTitle(
                    "App setting", CupertinoIcons.settings_solid),
                _buildAnimatedSettingsList([
                  _buildSettingsTile(
                    "Select Language",
                    CupertinoIcons.globe,
                    Colors.blue,
                    onTap: () {
                      RouteHelper.instance.gotoSelectLanguageScreen();
                    },
                  ),
                  _buildSettingsTile(
                    "App Update",
                    CupertinoIcons.arrow_counterclockwise,
                    Colors.green,
                    onTap: () {
                      "App is up to date".showSuccess();
                    },
                  ),
                ], 0.0),
                const SizedBox(height: 24),
                _buildSectionTitle("Feedback", CupertinoIcons.chat_bubble_2),
                _buildAnimatedSettingsList([
                  _buildSettingsTile(
                    "Send Feedback",
                    CupertinoIcons.chat_bubble_text,
                    Colors.orange,
                    onTap: () => showFeedBackBottomSheet(context),
                  ),
                  _buildSettingsTile(
                    "Share App",
                    CupertinoIcons.share,
                    Colors.purple,
                    onTap: () {
                      Share.share(appLink);
                    },
                  ),
                  _buildSettingsTile(
                    "Vote 5 Stars",
                    CupertinoIcons.star_fill,
                    Colors.amber,
                    onTap: () {
                      "Vote 5 Stars is not available right now".showSuccess();
                    },
                  ),
                ], 0.0),
                const SizedBox(height: 24),
                _buildSectionTitle("Information", CupertinoIcons.info_circle),
                _buildAnimatedSettingsList([
                  _buildSettingsTile(
                    "Privacy Policy",
                    CupertinoIcons.shield,
                    Colors.red,
                    onTap: () async {
                      final url = Uri.parse(policyLink);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                  ),
                  _buildSettingsTile(
                    "Term of Use",
                    CupertinoIcons.doc_text_search,
                    Colors.brown,
                    onTap: () async {
                      final url = Uri.parse(termsLink);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                  ),
                  _buildSettingsTile(
                    "Instructions",
                    CupertinoIcons.book,
                    Colors.teal,
                    onTap: () {
                      RouteHelper.instance.gotoInstructionScreen();
                    },
                  ),
                ], 0.1),
                const SizedBox(height: 24),
                _buildAppInfo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return GestureDetector(
      onTap: () {
        RouteHelper.instance.gotoIAPScreen();
      },
      onDoubleTap: () {},
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ArDrawTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: ArDrawTheme.softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: ArDrawTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: ArDrawTheme.primary.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  CupertinoIcons.person_fill,
                  color: ArDrawTheme.primary,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Free User",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ArDrawTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Upgrade to remove ads",
                    style: TextStyle(
                      fontSize: 14,
                      color: ArDrawTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (true)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFD700),
                      Color(0xFFFFA500),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  "Upgrade",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: ArDrawTheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ArDrawTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSettingsList(List<Widget> children, double delay) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: children.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final Animation<double> animation = CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            delay + (index / children.length) * 0.5,
            delay + (index / children.length) * 0.5 + 0.3,
            curve: Curves.easeOut,
          ),
        );

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - animation.value)),
              child: Opacity(
                opacity: animation.value,
                child: child,
              ),
            );
          },
          child: children[index],
        );
      },
    );
  }

  Widget _buildSettingsTile(
    String title,
    IconData icon,
    Color iconColor, {
    Widget? customWidget,
    void Function()? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ArDrawTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ArDrawTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                customWidget ??
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          color: iconColor,
                          size: 20,
                        ),
                      ),
                    ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ArDrawTheme.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  CupertinoIcons.chevron_right,
                  color: ArDrawTheme.textLight,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return const Center(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.paintbrush_fill,
                color: AppColorConstant.appDeepPurple,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                "Ar Draw",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ArDrawTheme.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            "Version 1.0.0",
            style: TextStyle(
              fontSize: 12,
              color: ArDrawTheme.textLight,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "© 2025 Meta Game Studio. All rights reserved.",
            style: TextStyle(
              fontSize: 10,
              color: ArDrawTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  void showFeedBackBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: ArDrawTheme.cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const FeedbackBottomSheet(),
      ),
    );
  }
}
