import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:ar_draw/app/widgets/app_app_bar.dart';
import 'package:ar_draw/app/widgets/app_loader.dart';
import 'package:ar_draw/controller/web_view_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewHelper extends StatelessWidget {

  const WebViewHelper({super.key});

  @override
  Widget build(BuildContext context) {
    String appbarTitle=Get.arguments['appbarTitle'];
    return GetBuilder<AppWebViewController>(
      init: AppWebViewController(),
      builder: (AppWebViewController controller) {
        return AnnotatedRegion(
          value: changeStatusBarIconColor(lightColor: true),
          child: Scaffold(
            appBar: AppAppBar(appbarTitle: appbarTitle),
            body: Stack(
              children: [
                WebViewWidget(controller: controller.webViewController ?? WebViewController()),
                if (controller.isLoading == true) const AppLoader(),
              ],
            ),
          ),
        );
      },
    );
  }
}
