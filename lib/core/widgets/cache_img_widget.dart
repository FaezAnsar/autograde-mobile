import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:autograde_mobile/core/constants/constants.dart';

class CacheImgWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  const CacheImgWidget(
    this.imageUrl, {
    super.key,
    this.width,
    this.height,
    this.borderRadius = borderRadiusMd8,
    this.fit = BoxFit.fill,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        width: width,
        height: height,
        imageUrl: imageUrl,
        fit: fit,
        placeholder: (context, url) =>
            Image.asset(placeHolderImagePath, fit: BoxFit.cover),
        errorWidget: (context, url, error) =>
            Image.asset(noImageAvailableImagePath, fit: BoxFit.cover),
      ),
    );
  }
}
