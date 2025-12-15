import 'dart:io';

import 'package:autograde_mobile/configs/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class BatchPhotoPreviewScreen extends HookWidget {
  final List<String> imagePaths;

  const BatchPhotoPreviewScreen({super.key, required this.imagePaths});

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'CamScanner ${DateFormat('MM-dd-yyyy HH.mm').format(DateTime.now())}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        // actions: [
        //   TextButton(
        //     onPressed: () {
        //       // TODO: Implement compare functionality
        //     },
        //     child: Row(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         Icon(Icons.compare_arrows, color: Colors.white, size: 20.sp),
        //         SizedBox(width: 4.w),
        //         Text(
        //           'Compare',
        //           style: TextStyle(color: Colors.white, fontSize: 14.sp),
        //         ),
        //       ],
        //     ),
        //   ),
        // ],
        // elevation: 0,
      ),
      body: Stack(
        children: [
          // Main photo display
          Positioned.fill(
            child: PageView.builder(
              controller: pageController,
              onPageChanged: (index) => currentIndex.value = index,
              itemCount: imagePaths.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 40.h,
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.file(
                          File(imagePaths[index]),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white54,
                                  size: 50,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 10.h,
                        left: 10.w,
                        child: GestureDetector(
                          onTap: () => _showDeleteDialog(
                            context,
                            currentIndex.value,
                            imagePaths,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Delete button (top left of image)
          if (imagePaths.isNotEmpty)
            // Navigation arrows and page indicator
            if (imagePaths.length > 1)
              Positioned(
                bottom: 120.h,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Previous button
                    GestureDetector(
                      onTap: currentIndex.value > 0
                          ? () {
                              if (pageController.hasClients) {
                                pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            }
                          : null,
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: currentIndex.value > 0
                              ? Colors.white24
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: currentIndex.value > 0
                              ? Colors.white
                              : Colors.white38,
                          size: 20.sp,
                        ),
                      ),
                    ),

                    // Page indicator
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '${currentIndex.value + 1}/${imagePaths.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Next button
                    GestureDetector(
                      onTap: currentIndex.value < imagePaths.length - 1
                          ? () {
                              if (pageController.hasClients) {
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            }
                          : null,
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: currentIndex.value < imagePaths.length - 1
                              ? Colors.white24
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: currentIndex.value < imagePaths.length - 1
                              ? Colors.white
                              : Colors.white38,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

          // Bottom toolbar
          Positioned(
            bottom: 30.h,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildToolbarButton(
                    icon: Icons.camera_alt,
                    label: 'Retake',
                    onTap: () => context.pop(),
                  ),
                  _buildToolbarButton(
                    icon: Icons.rotate_left,
                    label: 'Left',
                    onTap: () {
                      // TODO: Implement rotate left
                    },
                  ),
                  _buildToolbarButton(
                    icon: Icons.filter,
                    label: 'Filter',
                    onTap: () {
                      // TODO: Implement filter
                    },
                  ),
                  _buildToolbarButton(
                    icon: Icons.crop,
                    label: 'Crop',
                    onTap: () {
                      // TODO: Implement crop
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Implement save/process all photos
                      _processAllPhotos(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: const BoxDecoration(
                        color: Colors.tealAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.black,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24.sp),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  void _processAllPhotos(BuildContext context) {
    debugPrint('Processing ${imagePaths.length} photos for evaluation');

    // Navigate to image evaluation screen
    context.push(
      Routes.imageEvaluationScreen.path,
      extra: List<String>.from(imagePaths),
    );
  }
}

void _showDeleteDialog(
  BuildContext context,
  int index,
  List<String> imagePaths,
) {
  if (index < 0 || index >= imagePaths.length) return;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Photo?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'This will permanently delete this photo from your batch.',
          style: TextStyle(color: Colors.white70, fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.tealAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement delete functionality
              // Remove the image from the list and update UI
              context.pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}
