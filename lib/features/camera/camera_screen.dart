import 'dart:io';

import 'package:autograde_mobile/configs/routing/routes.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends HookWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraController = useState<CameraController?>(null);
    final isInitialized = useState(false);
    final isSingleMode = useState(true); // true for single, false for batch
    final capturedImages = useState<List<String>>([]);
    final selectedFiles = useState<List<String>>([]);
    final showPreview = useState(false); // Show image preview in single mode

    // Debug logging
    debugPrint(
      'UI Build - showPreview: ${showPreview.value}, isSingleMode: ${isSingleMode.value}, capturedImages: ${capturedImages.value.length}',
    );

    // Initialize camera
    useEffect(() {
      _initializeCamera(cameraController, isInitialized);
      return () {
        cameraController.value?.dispose();
      };
    }, []);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview or captured image preview
          if (showPreview.value && capturedImages.value.isNotEmpty)
            // Show captured image preview
            Positioned.fill(
              child: Image.file(
                File(capturedImages.value.first),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading preview image: $error');
                  return Container(
                    color: Colors.red,
                    child: const Center(
                      child: Text(
                        'Image Load Error',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (frame == null) {
                    debugPrint('Loading preview image...');
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }
                  debugPrint('Preview image loaded successfully');
                  return child;
                },
              ),
            )
          else if (isInitialized.value && cameraController.value != null)
            // Show camera preview
            Positioned.fill(child: CameraPreview(cameraController.value!))
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Top close/retake button
          Positioned(
            top: 50.h,
            left: 20.w,
            child: GestureDetector(
              onTap: () {
                if (showPreview.value) {
                  // Retake photo
                  showPreview.value = false;
                  capturedImages.value = [];
                } else {
                  SystemNavigator.pop();
                }
              },
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white, size: 24.sp),
              ),
            ),
          ),

          // Mode selector (Single/Batch) - hide in preview mode
          if (!showPreview.value)
            Positioned(
              bottom: 180.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildModeButton('Single', isSingleMode.value, () {
                    isSingleMode.value = true;
                    capturedImages.value = [];
                    showPreview.value = false;
                  }),
                  // SizedBox(width: 40.w),
                  // _buildModeButton('Batch', !isSingleMode.value, () {
                  //   isSingleMode.value = false;
                  //   showPreview.value = false;
                  // }),
                ],
              ),
            ),

          // Bottom controls or send button
          if (showPreview.value && isSingleMode.value)
            // Show send button in preview mode
            Positioned(
              bottom: 50.h,
              left: 20.w,
              right: 20.w,
              child: Container(
                width: double.infinity,
                height: 56.h,
                decoration: BoxDecoration(
                  color: Colors.tealAccent,
                  borderRadius: BorderRadius.circular(28.r),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28.r),
                    onTap: () =>
                        _sendForEvaluation(capturedImages.value.first, context),
                    child: Center(
                      child: Text(
                        'Send for Evaluation',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            // Show camera controls
            Positioned(
              bottom: 50.h,
              left: 0,
              right: 0,
              child: !isSingleMode.value
                  ? // Batch mode controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Undo button (left)
                        GestureDetector(
                          onTap: () =>
                              _showDiscardDialog(context, capturedImages),
                          child: Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black54,
                              border: Border.all(
                                color: Colors.white54,
                                width: 1.w,
                              ),
                            ),
                            child: Icon(
                              Icons.undo,
                              color: Colors.white,
                              size: 28.sp,
                            ),
                          ),
                        ),

                        // Camera capture button (center)
                        GestureDetector(
                          onTap: () => _capturePhoto(
                            cameraController.value,
                            capturedImages,
                            isSingleMode.value,
                            showPreview,
                          ),
                          child: Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4.w,
                              ),
                              color: Colors.transparent,
                            ),
                            child: Container(
                              margin: EdgeInsets.all(6.r),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // Thumbnail counter (right)
                        _buildThumbnailCounter(capturedImages.value, context),
                      ],
                    )
                  : // Single mode controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Documents button (left)
                        _buildControlButton(
                          icon: Icons.description,
                          label: 'Documents',
                          onTap: () => _selectDocuments(selectedFiles),
                        ),

                        // Camera capture button (center)
                        GestureDetector(
                          onTap: () => _capturePhoto(
                            cameraController.value,
                            capturedImages,
                            isSingleMode.value,
                            showPreview,
                          ),
                          child: Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4.w,
                              ),
                              color: Colors.transparent,
                            ),
                            child: Container(
                              margin: EdgeInsets.all(6.r),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // Gallery button (right)
                        _buildControlButton(
                          icon: Icons.photo_library,
                          label: 'Gallery',
                          onTap: () => _selectFromGallery(
                            capturedImages,
                            isSingleMode.value,
                            showPreview,
                          ),
                        ),
                      ],
                    ),
            ),

          // Show captured images count in batch mode
          if (!isSingleMode.value && capturedImages.value.isNotEmpty)
            Positioned(
              bottom: 140.h,
              right: 10.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  '${capturedImages.value.length} photos captured',
                  style: TextStyle(color: Colors.white, fontSize: 12.sp),
                ),
              ),
            ),

          // Show selected files count
          if (selectedFiles.value.isNotEmpty)
            Positioned(
              bottom: 140.h,
              left: 20.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  '${selectedFiles.value.length} files selected',
                  style: TextStyle(color: Colors.white, fontSize: 12.sp),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.tealAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? Colors.tealAccent : Colors.white54,
            width: 1.w,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black54,
              border: Border.all(color: Colors.white54, width: 1.w),
            ),
            child: Icon(icon, color: Colors.white, size: 28.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailCounter(List<String> images, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (images.isNotEmpty) {
          context.push(
            Routes.batchPhotoPreviewScreen.path,
            extra: List<String>.from(images),
          );
        }
      },
      child: Stack(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.white, width: 2.w),
              color: Colors.black54,
            ),
            child: images.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: Image.file(File(images.last), fit: BoxFit.cover),
                  )
                : Icon(Icons.photo_library, color: Colors.white, size: 24.sp),
          ),
          if (images.isNotEmpty)
            Positioned(
              top: -5.h,
              right: -2.w,
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                child: Text(
                  '${images.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> _initializeCamera(
  ValueNotifier<CameraController?> controllerNotifier,
  ValueNotifier<bool> isInitializedNotifier,
) async {
  // Request camera permission
  final cameraPermission = await Permission.camera.request();
  if (cameraPermission != PermissionStatus.granted) {
    return;
  }

  try {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await controller.initialize();
    controllerNotifier.value = controller;
    isInitializedNotifier.value = true;
  } catch (e) {
    debugPrint('Camera initialization error: $e');
  }
}

Future<void> _capturePhoto(
  CameraController? controller,
  ValueNotifier<List<String>> capturedImages,
  bool isSingleMode,
  ValueNotifier<bool> showPreview,
) async {
  if (controller == null || !controller.value.isInitialized) return;

  try {
    final image = await controller.takePicture();

    if (isSingleMode) {
      capturedImages.value = [image.path];
      showPreview.value = true; // Show preview in single mode
      debugPrint('Single photo captured: ${image.path}');
      debugPrint('showPreview set to: ${showPreview.value}');
      debugPrint('capturedImages count: ${capturedImages.value.length}');
    } else {
      capturedImages.value = [...capturedImages.value, image.path];
      debugPrint('Batch photo added: ${image.path}');
    }
  } catch (e) {
    debugPrint('Error capturing photo: $e');
  }
}

Future<void> _selectFromGallery(
  ValueNotifier<List<String>> capturedImages,
  bool isSingleMode,
  ValueNotifier<bool> showPreview,
) async {
  final ImagePicker picker = ImagePicker();

  try {
    if (isSingleMode) {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        capturedImages.value = [image.path];
        showPreview.value = true; // Show preview in single mode
        debugPrint('Single image selected from gallery: ${image.path}');
      }
    } else {
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        final newPaths = images.map((img) => img.path).toList();
        capturedImages.value = [...capturedImages.value, ...newPaths];
        debugPrint('${images.length} images selected from gallery');
      }
    }
  } catch (e) {
    debugPrint('Error selecting from gallery: $e');
  }
}

Future<void> _selectDocuments(ValueNotifier<List<String>> selectedFiles) async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final newPaths = result.files
          .where((file) => file.path != null)
          .map((file) => file.path!)
          .toList();

      selectedFiles.value = [...selectedFiles.value, ...newPaths];
      debugPrint('${newPaths.length} documents selected');
    }
  } catch (e) {
    debugPrint('Error selecting documents: $e');
  }
}

void _sendForEvaluation(String imagePath, BuildContext context) {
  debugPrint('Sending image for evaluation: $imagePath');

  // Navigate to evaluation results screen
  context.push(Routes.evaluationResultsScreen.path, extra: imagePath);
}

void _showDiscardDialog(
  BuildContext context,
  ValueNotifier<List<String>> capturedImages,
) {
  if (capturedImages.value.isEmpty) return;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Discard all snaps?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'This will remove all ${capturedImages.value.length} captured photos.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.tealAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              capturedImages.value = [];
              Navigator.of(context).pop();
            },
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}
