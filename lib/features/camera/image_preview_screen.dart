import 'dart:io';

import 'package:autograde_mobile/configs/routing/routes.dart';
import 'package:autograde_mobile/core/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ImagePreviewScreen extends StatelessWidget {
  final String imagePath;
  final String subject;

  const ImagePreviewScreen({
    super.key,
    required this.imagePath,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Preview Image',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18.r),
                    child: Container(
                      color: Colors.black,
                      child: InteractiveViewer(
                        panEnabled: true,
                        minScale: 1,
                        maxScale: 4,
                        child: Image.file(
                          File(imagePath),
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                          cacheWidth: (MediaQuery.of(context).size.width * 1.5).toInt(),
                          filterQuality: FilterQuality.medium,
                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                            if (frame == null) {
                              return const Center(child: CircularProgressIndicator(color: Colors.white));
                            }
                            return child;
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[900],
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.broken_image, color: Colors.white54, size: 48.sp),
                                  SizedBox(height: 12.h),
                                  Text(
                                    'Unable to load image',
                                    style: TextStyle(color: Colors.white54, fontSize: 14.sp),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Confirm the complete image before evaluation.',
                    style: TextStyle(
                      color: const Color(0xFF333333),
                      fontSize: 14.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF1A1A1A)),
                            foregroundColor: const Color(0xFF1A1A1A),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: Text(
                            'Clear',
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (subject.isEmpty) {
                              showSnackBar(context, 'Please select a subject before evaluating the image.');
                              return;
                            }
                            context.push(
                              Routes.evaluationResultsScreen.path,
                              extra: {
                                'path': imagePath,
                                'subject': subject,
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1A1A),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: Text(
                            'Evaluate',
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
