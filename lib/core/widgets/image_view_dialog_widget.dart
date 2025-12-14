import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:autograde_mobile/configs/theme/app_colors.dart';

class ImageViewDialogWidget extends StatelessWidget {
  const ImageViewDialogWidget(this.image, {super.key});

  final File image;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InteractiveViewer(
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(100),
            minScale: 0.5,
            maxScale: 4,
            child: Image.file(image),
          ),
          Positioned(
            top: -12,
            right: -12,
            child: GestureDetector(
              onTap: () {
                context.pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(Icons.close, color: AppColors.lightColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
