import 'package:ar_draw/app/constant/color_constant.dart';
import 'package:ar_draw/app/utills/dimension.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      decoration: BoxDecoration(color: AppColorConstant.appWhite.withOpacity(Dimens.opacityMedium)),
      child: LoadingAnimationWidget.beat(color: AppColorConstant.appGrey, size: Dimens.heightExtraMedium),
    );
  }
}
