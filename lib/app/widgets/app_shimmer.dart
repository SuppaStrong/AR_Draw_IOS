import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppShimmerEffectView extends StatelessWidget {
  final double? height;
  final double? width;
  final double? borderRadius;

  const AppShimmerEffectView({super.key, this.height, this.width, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColorConstant.appWhite200,
      highlightColor: AppColorConstant.appWhite100,
      child: Container(
        height: height ?? 30,
        width: width ?? 1.0,
        decoration: BoxDecoration(
          color: AppColorConstant.appWhite200,
          borderRadius: BorderRadius.circular(borderRadius ?? 10),
        ),
      ),
    );
  }
}
