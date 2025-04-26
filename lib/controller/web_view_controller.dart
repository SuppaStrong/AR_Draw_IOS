import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppWebViewController extends GetxController {
  WebViewController? webViewController;
bool isLoading = false;
  @override
  void onInit() {
    super.onInit();
    webViewInitialize();
  }

  void webViewInitialize() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColorConstant.appTransparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            isLoading = true;
            update();
          },
          onPageStarted: (String url) {
            isLoading = true;
            update();
          },
          onPageFinished: (String url) {
            isLoading = false;
            update();
          },
          onHttpError: (HttpResponseError error) {
            '${error.response}'.showError();
          },
          onWebResourceError: (WebResourceError error) {
            error.description.showError();
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://codecanyon.net/user/nur-codes/portfolio')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(Get.arguments?['url'] ?? 'https://codecanyon.net/user/nur-codes/portfolio'));
  }
}
