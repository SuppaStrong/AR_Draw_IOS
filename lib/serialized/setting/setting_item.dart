import 'dart:ui';
import 'package:json_annotation/json_annotation.dart';

part 'setting_item.g.dart';

class ColorConverter implements JsonConverter<Color, String> {
  const ColorConverter();

  @override
  Color fromJson(String json) {
    return Color(int.parse(json, radix: 16));
  }

  @override
  String toJson(Color color) {
    return color.value.toRadixString(16);
  }
}

@JsonSerializable()
class SettingItemModel {
  @JsonKey(name: "image")
  final String image;

  @JsonKey(name: "title")
  final String title;

  @ColorConverter()
  @JsonKey(name: "color")
  final Color color;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final VoidCallback? onTap;

  SettingItemModel({
    required this.image,
    required this.title,
    required this.color,
    this.onTap,
  });

  factory SettingItemModel.fromJson(Map<String, dynamic> json) =>
      _$SettingItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$SettingItemModelToJson(this);
}
