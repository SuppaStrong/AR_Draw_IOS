import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en': enEn, 'hi': hiIn, 'gu': guIn};
  static final Map<String, String> enEn = {
    'hello': 'Hello',
  };
  static final Map<String, String> hiIn = {
    'hello': 'नमस्ते',
  };
  static final Map<String, String> guIn = {
    'hello': 'હોલો',
  };
 }