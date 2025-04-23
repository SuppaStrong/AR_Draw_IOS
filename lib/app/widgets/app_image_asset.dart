import 'dart:io';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ar_draw/app/widgets/app_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class AppImageAsset extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final Color? color;
  final BoxFit? fit;
  final bool isFile;
  final bool isError;
  final bool isMemory;

  const AppImageAsset({
    super.key,
    required this.image,
    this.fit,
    this.height,
    this.width,
    this.color,
    this.isFile = false,
    this.isError = false,
    this.isMemory = false,
  });

  @override
  Widget build(BuildContext context) {
    if (image.isEmpty) {
      return SizedBox(
        height: height,
        width: width,
        child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    }

    if (image.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: image,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        placeholder: (context, url) => AppShimmerEffectView(height: height, width: width),
        errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
      );
    } else if (image.endsWith('.json')) {
      return Lottie.asset(image, height: height, width: width, fit: fit);
    } else if (isFile) {
      return Image.file(File(image), height: height, width: width, color: color, fit: fit);
    } else if (isMemory) {
      return Image.memory(base64Decode(image), height: height, width: width, fit: fit, color: color);
    } else if (!image.endsWith('.svg')) {
      return Image.asset(image, fit: fit, height: height, width: width, color: color);
    } else {
      return SvgPicture.asset(image, height: height, width: width, color: color);
    }
  }
}