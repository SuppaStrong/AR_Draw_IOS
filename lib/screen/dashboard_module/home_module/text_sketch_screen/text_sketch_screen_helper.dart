import 'package:ar_draw/screen/dashboard_module/home_module/text_sketch_screen/text_sketch_screen.dart';

class TextSketchScreenHelper {
  TextSketchScreenState state;
  double sliderValue = 20.0;
  String enteredText = '';
  String selectedFontFamily = 'Roboto';
  List fontFamilies = ["Ubuntu", "Eagle Lake", "Lobster", "Bungee Spice", "Honk", "Kings"];
  TextSketchScreenHelper(this.state);
}