import 'dart:io';

import 'package:autograde_mobile/configs/routing/routes.dart';
import 'package:autograde_mobile/configs/service_locator.dart';
import 'package:autograde_mobile/core/data_source/app_remote_data_source.dart';
import 'package:autograde_mobile/core/utils/helpers.dart';
import 'package:autograde_mobile/features/home/models/history_item_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  final String? name;
  const HomeScreen({super.key, this.name});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedImagePath;
  String? _selectedPdfName;
  String? _selectedSubject;
  int _bulkUploadCount = 0;
  int _bottomNavIndex = 0;

  static const Map<String, String> _subjectOptions = {
    'Islamiat': 'isl',
    'Chemistry': 'chem',
    'Math': 'math',
    'Physics': 'physics',
  };

  List<HistoryItemModel> _historyItems = [];
  bool _isHistoryLoading = true;
  String? _historyError;
  int _visibleHistoryCount = 3;
  final Set<int> _expandedHistoryIndices = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isHistoryLoading = true;
      _historyError = null;
    });

    final response = await locator<AppRemoteDataSource>().getHistory();
    if (!mounted) return;

    response.fold(
      (error) {
        setState(() {
          _historyError = error.message;
          _historyItems = [];
          _isHistoryLoading = false;
        });
      },
      (items) {
        setState(() {
          _historyItems = items;
          _isHistoryLoading = false;
        });
      },
    );
  }

  Future<void> _pickImage() async {
    if (_selectedSubject == null) {
      showSnackBar(context, 'Please select a subject before choosing an image.');
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    if (image != null) {
      setState(() => _selectedImagePath = image.path);
      context.push(
        Routes.evaluationResultsScreen.path,
        extra: {
          'path': image.path,
          'subject': _selectedSubject!,
        },
      );
    }
  }

  Future<void> _pickBulkFiles() async {
    if (_selectedSubject == null) {
      showSnackBar(context, 'Please select a subject before choosing bulk files.');
      return;
    }

    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );
    if (result != null && result.files.isNotEmpty) {
      final paths = result.files
          .where((file) => file.path != null)
          .map((file) => file.path!)
          .toList();

      if (paths.isEmpty) return;

      setState(() => _bulkUploadCount = paths.length);
      context.push(
        Routes.batchPhotoPreviewScreen.path,
        extra: {
          'imagePaths': paths,
          'subject': _selectedSubject!,
        },
      );
    }
  }

  Future<void> _pickPdf() async {
    if (_selectedSubject == null) {
      showSnackBar(context, 'Please select a subject before choosing a file.');
      return;
    }

    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );
    if (!mounted) return;
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedPdfName = result.files.first.name);
      final selectedPath = result.files.first.path;
      if (selectedPath != null) {
        context.push(
          Routes.evaluationResultsScreen.path,
          extra: {
            'path': selectedPath,
            'subject': _selectedSubject!,
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayName =
        widget.name?.trim().isNotEmpty == true ? widget.name! : 'Learner';
    final int totalHistoryCount = _historyItems.length;
    final List<HistoryItemModel> displayHistoryItems =
        _historyItems.take(_visibleHistoryCount).toList();
    final bool hasMoreHistory = _visibleHistoryCount < totalHistoryCount;
    final bool canShowLess = _visibleHistoryCount > 3;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: _buildAppBar(context),
      bottomNavigationBar: _buildBottomNav(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(displayName),
              SizedBox(height: 20.h),
              _buildStatsRow(),
              SizedBox(height: 24.h),
              _buildSectionLabel('Upload'),
              SizedBox(height: 10.h),
              _buildSubjectSelector(),
              SizedBox(height: 16.h),
              _buildUploadGrid(),
              SizedBox(height: 10.h),
              _buildPickImageTile(),
              if (_selectedImagePath != null) ...[
                SizedBox(height: 20.h),
                _buildImagePreview(),
              ],
              if (_selectedPdfName != null) ...[
                SizedBox(height: 20.h),
                _buildPdfPreview(),
              ],
              if (_bulkUploadCount > 0) ...[
                SizedBox(height: 12.h),
                _buildBulkBadge(),
              ],
              SizedBox(height: 24.h),
              _buildHistoryHeader(),
              SizedBox(height: 12.h),
              if (_isHistoryLoading) ...[
                Center(
                  child: SizedBox(
                    height: 32.h,
                    width: 32.h,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ] else if (_historyError != null) ...[
                Text(
                  _historyError!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFFD32F2F),
                  ),
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: _loadHistory,
                  child: Text(
                    'Retry',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ),
              ] else if (_historyItems.isEmpty) ...[
                Text(
                  'No history available yet.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF999999),
                  ),
                ),
              ] else ...[
                ...displayHistoryItems.asMap().entries.map(
                  (entry) => _buildHistoryCard(entry.key, entry.value),
                ),
                if (hasMoreHistory || canShowLess) ...[
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (hasMoreHistory)
                        TextButton(
                          onPressed: () => setState(() {
                            _visibleHistoryCount = (_visibleHistoryCount + 5)
                                .clamp(3, totalHistoryCount);
                          }),
                          child: Text(
                            'Show more',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ),
                      if (canShowLess)
                        TextButton(
                          onPressed: () => setState(() {
                            _visibleHistoryCount = 3;
                          }),
                          child: Text(
                            'Show less',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ],
        ),
      ),
    ));
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFFF8F7F5),
      titleSpacing: 20.w,
      title: Row(
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.bar_chart_rounded,
                color: Colors.white, size: 16.sp),
          ),
          SizedBox(width: 8.w),
          Text(
            'AutoGrade',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 20.w),
          child: GestureDetector(
            onTap: () => context.go(Routes.signInScreen.path),
            child: CircleAvatar(
              radius: 17.r,
              backgroundColor: const Color(0xFFEDEDEB),
              child: Icon(Icons.person_outline,
                  size: 18.sp, color: const Color(0xFF666666)),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Bottom Nav ───────────────────────────────────────────────────────────

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8E6E0), width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: Icons.home_filled,
                label: 'Home',
                selected: _bottomNavIndex == 0,
                onTap: () => setState(() => _bottomNavIndex = 0),
              ),
              GestureDetector(
                onTap: () => context.push(Routes.cameraScreen.path),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 46.w,
                      height: 46.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 20.sp),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Camera',
                      style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFAAAAAA)),
                    ),
                  ],
                ),
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: 'Profile',
                selected: _bottomNavIndex == 2,
                onTap: () => setState(() => _bottomNavIndex = 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Greeting ─────────────────────────────────────────────────────────────

  Widget _buildGreeting(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GOOD MORNING',
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFAAAAAA),
            letterSpacing: 1.0,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Hello, $name 👋',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Review your uploads or add new files.',
          style: TextStyle(fontSize: 13.sp, color: const Color(0xFF999999)),
        ),
      ],
    );
  }

  // ─── Stats ────────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _StatCard(value: '12', label: 'Total uploads', dark: true)),
        SizedBox(width: 10.w),
        Expanded(child: _StatCard(value: '9', label: 'Completed', dark: false)),
      ],
    );
  }

  // ─── Upload ───────────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF999999),
        letterSpacing: 0.9,
      ),
    );
  }

  Widget _buildUploadGrid() {
    return Row(
      children: [
        Expanded(
          child: _UploadTile(
            icon: Icons.picture_as_pdf_rounded,
            label: 'Upload PDF',
            sub: 'Tap to select',
            bgColor: const Color(0xFFEFF5FF),
            iconColor: const Color(0xFF378ADD),
            onTap: _pickPdf,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _UploadTile(
            icon: Icons.grid_view_rounded,
            label: 'Bulk upload',
            sub: 'Multiple images',
            bgColor: const Color(0xFFF3F0FF),
            iconColor: const Color(0xFF7F77DD),
            onTap: _pickBulkFiles,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose subject',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        SizedBox(height: 10.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _subjectOptions.entries.map((entry) {
              final selected = _selectedSubject == entry.value;
              return Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSubject = entry.value),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF1A1A1A) : Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: selected ? const Color(0xFF1A1A1A) : const Color(0xFFE8E6E0),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPickImageTile() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE8E6E0), width: 0.5),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: const Color(0xFFEDFAF4),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.photo_library_rounded,
                  color: const Color(0xFF1D9E75), size: 17.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pick image',
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A))),
                  Text('Preview before uploading',
                      style: TextStyle(
                          fontSize: 11.sp, color: const Color(0xFFAAAAAA))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: const Color(0xFFCCCCCC), size: 18.sp),
          ],
        ),
      ),
    );
  }

  // ─── Previews ─────────────────────────────────────────────────────────────

  Widget _buildImagePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Selected image'),
        SizedBox(height: 10.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Image.file(
            File(_selectedImagePath!),
            width: double.infinity,
            height: 200.h,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Widget _buildPdfPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Selected PDF'),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE8E6E0), width: 0.5),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.picture_as_pdf_rounded,
                    color: const Color(0xFFE24B4A), size: 17.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  _selectedPdfName!,
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1A1A)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulkBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded,
              color: const Color(0xFF7F77DD), size: 15.sp),
          SizedBox(width: 6.w),
          Text(
            '$_bulkUploadCount files selected',
            style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF534AB7)),
          ),
        ],
      ),
    );
  }

  // ─── History ──────────────────────────────────────────────────────────────

  Widget _buildHistoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'RECENT HISTORY',
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF999999),
            letterSpacing: 0.9,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(int index, HistoryItemModel item) {
    final bool isPdf = item.paperCode.toLowerCase() == 'pdf';
    final bool isCompleted = true;
    final bool isExpanded = _expandedHistoryIndices.contains(index);

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE8E6E0), width: 0.5),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: ExpansionTile(
          key: ValueKey(item.questionId.isNotEmpty ? item.questionId : index),
          tilePadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 0),
          childrenPadding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          onExpansionChanged: (expanded) {
            setState(() {
              if (expanded) {
                _expandedHistoryIndices.add(index);
              } else {
                _expandedHistoryIndices.remove(index);
              }
            });
          },
          title: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: isPdf
                      ? const Color(0xFFFEF2F2)
                      : const Color(0xFFF3F0FF),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                  color: isPdf ? const Color(0xFFE24B4A) : const Color(0xFF7F77DD),
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.questionId,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.createdAt,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFFAAAAAA),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFEDFAF4)
                      : const Color(0xFFFAEEDA),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Checked',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? const Color(0xFF0F6E56)
                        : const Color(0xFF854F0B),
                  ),
                ),
              ),
            ],
          ),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evaluation result',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  item.evaluationText.isNotEmpty
                      ? item.evaluationText
                      : 'No detailed result available.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF666666),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable widgets ──────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final bool dark;

  const _StatCard({
    required this.value,
    required this.label,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1A1A1A) : Colors.white,
        border: dark
            ? null
            : Border.all(color: const Color(0xFFE8E6E0), width: 0.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: dark ? Colors.white : const Color(0xFF1A1A1A),
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: dark
                  ? Colors.white.withOpacity(0.5)
                  : const Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _UploadTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE8E6E0), width: 0.5),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: iconColor, size: 17.sp),
            ),
            SizedBox(height: 10.h),
            Text(
              label,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A)),
            ),
            SizedBox(height: 2.h),
            Text(
              sub,
              style:
                  TextStyle(fontSize: 11.sp, color: const Color(0xFFAAAAAA)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 22.sp,
            color: selected
                ? const Color(0xFF1A1A1A)
                : const Color(0xFFAAAAAA),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected
                  ? const Color(0xFF1A1A1A)
                  : const Color(0xFFAAAAAA),
            ),
          ),
        ],
      ),
    );
  }
}