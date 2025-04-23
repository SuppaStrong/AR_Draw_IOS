import 'package:ar_draw/app/constant/app_asset.dart';
import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/constant/string_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app_routes/route_helper.dart';
import 'package:ar_draw/screen/dashboard_module/home_module/home_screen.dart';
import 'package:ar_draw/serialized/setting/setting_item.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreenHelper {
  List<SettingItemModel> staticDataModel = [];

  HomeScreenState? state;

  HomeScreenHelper(this.state) {
    staticDataModel = [
      SettingItemModel(
        image: AppAsset.icMoreApp,
        color: AppColorConstant.appChromeYellow,
        title: AppStringConstant.moreApp,
        onTap: () async {
          const url = 'https://codecanyon.net/user/nur-codes/portfolio'; // Placeholder URL
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          } else {
            'Could not launch $url'.showError();
          }
        },
      ),
      SettingItemModel(
        image: AppAsset.icShare,
        color: AppColorConstant.appCarolinaBlue,
        title: AppStringConstant.shareApp,
        onTap: () async {
          const String playStoreUrl = '✨ Discover the smarter way to get things done!\nUnlock powerful features, seamless experience, and effortless access — all in one app.\n🚀 Download now and elevate your workflow: 👉 https://codecanyon.net/item/ar-draw-trace-to-sketch-the-ultimate-sketch-art-app-in-flutter/54997753';
          await Share.share(playStoreUrl);
        },
    ),
      SettingItemModel(
        image: AppAsset.icRate,
        color: AppColorConstant.appYellow,
        title: AppStringConstant.rateUs,
        onTap: () async {
          const url = 'https://codecanyon.net/downloads';
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          } else {
            'Could not launch $url'.showError();
          }
        },
      ),
      SettingItemModel(
        image: AppAsset.icPrivacy,
        color: AppColorConstant.appStrawberryPink,
        title: AppStringConstant.privacyPolicy,
        onTap: () => RouteHelper.instance.gotoWebView(appbarTitle: AppStringConstant.privacyPolicy),
      ),
      SettingItemModel(
        image: AppAsset.icTerms,
        color: AppColorConstant.appIrisBlue,
        title: AppStringConstant.termsAndConditions,
        onTap: () => RouteHelper.instance.gotoWebView(appbarTitle: AppStringConstant.termsAndConditions),
      ),
    ];
  }
}
