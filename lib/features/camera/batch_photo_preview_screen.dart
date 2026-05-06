import 'dart:io';

import 'package:autograde_mobile/configs/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class BatchPhotoPreviewScreen extends HookWidget {
  final List<String> imagePaths;
  final String subject;

  const BatchPhotoPreviewScreen({
    super.key,
    required this.imagePaths,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = useState(0);
    final pageController = useMemoized(() => PageController(initialPage: 0));

    // Dispose PageController properly
    useEffect(() {
      return () {
        pageController.dispose();
      };
    }, []);

    // Add safety check for empty image paths
    if (imagePaths.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text(
            'No images to preview',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Preview Images',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: pageController,
              onPageChanged: (index) => currentIndex.value = index,
              itemCount: imagePaths.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 24.h),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18.r),
                    child: Container(
                      color: Colors.black,
                              child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        child: Image.file(
                          File(imagePaths[index]),
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
                );
              },
            ),
          ),
          if (imagePaths.length > 1)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildArrowButton(
                    icon: Icons.chevron_left,
                    enabled: currentIndex.value > 0,
                    onTap: () {
                      if (currentIndex.value > 0 && pageController.hasClients) {
                        pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${currentIndex.value + 1}/${imagePaths.length}',
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                    ),
                  ),
                  _buildArrowButton(
                    icon: Icons.chevron_right,
                    enabled: currentIndex.value < imagePaths.length - 1,
                    onTap: () {
                      if (currentIndex.value < imagePaths.length - 1 && pageController.hasClients) {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h),
            child: Column(
              children: [
                Text(
                  'Confirm each selected page before evaluation.',
                  style: TextStyle(color: const Color(0xFF333333), fontSize: 14.sp),
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
                        onPressed: () => _processAllPhotos(context),
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
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 46.w,
        height: 46.w,
        decoration: BoxDecoration(
          color: enabled ? Colors.white24 : Colors.white10,
          shape: BoxShape.circle,
          border: Border.all(color: enabled ? Colors.white : Colors.white30),
        ),
        child: Icon(icon, color: enabled ? Colors.white : Colors.white38, size: 24.sp),
      ),
    );
  }

  void _processAllPhotos(BuildContext context) {
    debugPrint('Processing ${imagePaths.length} photos for evaluation');

    // Navigate directly to evaluation results for bulk images
    context.push(
      Routes.evaluationResultsScreen.path,
      extra: {
        'path': imagePaths.first,
        'paths': List<String>.from(imagePaths),
        'subject': subject,
      },
    );
  }
}
