import 'dart:io';

import 'package:autograde_mobile/core/api/api_state.dart';
import 'package:autograde_mobile/configs/routing/routes.dart';
import 'package:autograde_mobile/features/camera/cubits/eval_cubit.dart';
import 'package:autograde_mobile/features/camera/models/extract_text_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class EvaluationResultsScreen extends StatefulWidget {
  final String filePath;
  final String subject;

  const EvaluationResultsScreen({
    super.key,
    required this.filePath,
    required this.subject,
  });

  @override
  State<EvaluationResultsScreen> createState() =>
      _EvaluationResultsScreenState();
}

class _EvaluationResultsScreenState extends State<EvaluationResultsScreen> {
  late final EvaluateAnswerCubit _evalCubit;

  @override
  void initState() {
    super.initState();
    _evalCubit = EvaluateAnswerCubit();
    _submitForEvaluation();
  }

  void _submitForEvaluation() {
    final file = File(widget.filePath);
    _evalCubit.evalAns(file: file, subject: widget.subject);
  }

  @override
  void dispose() {
    _evalCubit.close();
    super.dispose();
  }

  Map<String, dynamic> _parseEvaluationText(String input) {
    final raw = input.replaceAll('', '').trim();
    final score = _extractScore(raw);
    final body = _extractSuggestionBody(raw);
    final bullets = _extractBulletPoints(body);
    final paragraphs = bullets.isEmpty ? _extractParagraphs(body) : <String>[];
    final intro = _extractIntroText(raw);

    return {
      'raw': raw,
      'score': score,
      'intro': intro,
      'bullets': bullets,
      'paragraphs': paragraphs,
    };
  }

  String? _extractScore(String raw) {
    final match = RegExp(
      r'Score\s*:\s*([0-9]+\s*/\s*[0-9]+)',
      caseSensitive: false,
    ).firstMatch(raw);
    return match?.group(1)?.replaceAll(' ', '');
  }

  String _extractSuggestionBody(String raw) {
    if (raw.isEmpty) return raw;

    final split = raw.split(
      RegExp(r'Suggestions\s*for\s*Improvement\s*[:\n]+', caseSensitive: false),
    );
    return split.length > 1 ? split.sublist(1).join(' ').trim() : raw;
  }

  List<String> _extractBulletPoints(String body) {
    final lines = body
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final points = <String>[];
    for (final line in lines) {
      final bulletMatch = RegExp(r'^[\-\*\d+\.]+\s*(.*)').firstMatch(line);
      if (bulletMatch != null && bulletMatch.group(1)?.isNotEmpty == true) {
        points.add(bulletMatch.group(1)!.trim());
      }
    }

    return points;
  }

  List<String> _extractParagraphs(String body) {
    return body
        .split(RegExp(r'\n\s*\n'))
        .map((line) => line.replaceAll('*', '').trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  String _extractIntroText(String raw) {
    final lines = raw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) return '';
    if (lines.first.toLowerCase().startsWith('score')) {
      return lines.length > 1 ? lines[1] : '';
    }
    return lines.first;
  }

  Widget _buildStepItem(String title, bool completed) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        margin: EdgeInsets.only(right: 10.w),
        decoration: BoxDecoration(
          color: completed ? const Color(0xFFE8F5E9) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: completed ? const Color(0xFF81C784) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              completed ? Icons.check_circle : Icons.radio_button_unchecked,
              color: completed ? Colors.green[700] : Colors.grey[500],
              size: 18.sp,
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: completed ? Colors.green[800] : Colors.grey[700],
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionList(List<String> suggestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: suggestions.asMap().entries.map((entry) {
        final text = entry.value
            .replaceAll('*', '')
            .replaceAll(RegExp(r'\s{2,}'), ' ')
            .trim();
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 4.h),
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCF8E8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: const Color(0xFF2E7D32),
                  size: 14.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Evaluation Results',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<EvaluateAnswerCubit, ApiState>(
        bloc: _evalCubit,
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 200.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 18,
                        offset: Offset(0, 8.h),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18.r),
                    child: Builder(
                      builder: (context) {
                        final isImage = RegExp(
                                r'\.(jpe?g|png|gif|bmp|webp)$',
                                caseSensitive: false)
                            .hasMatch(widget.filePath);

                        if (isImage) {
                          return Image.file(
                            File(widget.filePath),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[100],
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        color: Colors.grey[400],
                                        size: 32.sp,
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        'Failed to load image',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        return Container(
                          color: Colors.grey[100],
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.picture_as_pdf_rounded,
                                color: Colors.grey[700],
                                size: 44.sp,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                widget.filePath.split(RegExp(r'[\\/]+')).last,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Container(
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 18,
                        offset: Offset(0, 10.h),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Autograde Summary',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Row(
                        children: [
                          Icon(
                            Icons.rocket_launch,
                            color: Colors.teal,
                            size: 24.sp,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'Your answer has been checked and detailed suggestions are ready below.',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      Row(
                        children: [
                          _buildStepItem('Scan', true),
                          _buildStepItem('Autograde', true),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 16.h,
                                horizontal: 12.w,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEBF4FF),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: const Color(0xFF90CAF9),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: const Color(0xFF1976D2),
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Flexible(
                                    child: Text(
                                      'Ready to Improve',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(0xFF1565C0),
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 18,
                        offset: Offset(0, 10.h),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.assessment,
                            color: Colors.teal,
                            size: 24.sp,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            'Autograde Feedback',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      if (state is ApiLoadingState) ...[
                        Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.teal,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'Evaluating your answer...',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Please wait while we analyze your response.',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ] else if (state is ApiLoadedState<EvalAnswerModel>) ...[
                        Builder(
                          builder: (context) {
                            final parsed = _parseEvaluationText(
                              state.data.eval ?? '',
                            );
                            final score = parsed['score'] as String?;
                            final intro = parsed['intro'] as String;
                            final bullets = parsed['bullets'] as List<String>;
                            final paragraphs =
                                parsed['paragraphs'] as List<String>;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (score != null) ...[
                                  Text(
                                    'Score: $score',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                ],
                                if (intro.isNotEmpty) ...[
                                  Text(
                                    intro.replaceAll('*', ''),
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                ],
                                if (bullets.isNotEmpty) ...[
                                  Text(
                                    'Suggested improvements:',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  _buildSuggestionList(bullets),
                                ] else if (paragraphs.isNotEmpty) ...[
                                  ...paragraphs.map(
                                    (paragraph) => Padding(
                                      padding: EdgeInsets.only(bottom: 12.h),
                                      child: Text(
                                        paragraph,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          color: Colors.black87,
                                          height: 1.6,
                                        ),
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  Text(
                                    state.data.eval ??
                                        'No detailed feedback was returned.',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      color: Colors.black87,
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ] else if (state is ApiErrorState) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.red[200]!,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 32.sp,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Evaluation Failed',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[700],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                state.error,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.red[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16.h),
                              ElevatedButton(
                                onPressed: _submitForEvaluation,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                    vertical: 12.h,
                                  ),
                                ),
                                child: Text(
                                  'Retry Evaluation',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                if (state is ApiLoadedState<EvalAnswerModel>) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.grey[400]!,
                              width: 1,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                          ),
                          child: Text(
                            'Take Another Photo',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.go(Routes.dashboardScreen.path);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                          ),
                          child: Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
