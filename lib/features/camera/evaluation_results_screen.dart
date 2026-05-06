import 'dart:async';
import 'dart:io';
import 'dart:math';

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
  final List<String> filePaths;

  const EvaluationResultsScreen({
    super.key,
    required this.filePath,
    required this.subject,
    this.filePaths = const [],
  });

  @override
  State<EvaluationResultsScreen> createState() =>
      _EvaluationResultsScreenState();
}

class _EvaluationResultsScreenState extends State<EvaluationResultsScreen>
    with TickerProviderStateMixin {
  late final EvaluateAnswerCubit _evalCubit;
  late final AnimationController _heroController;
  Timer? _statusTimer;
  Timer? _tipTimer;
  Timer? _progressTimer;

  double _progress = 0.0;
  int _statusIndex = 0;
  int _tipIndex = 0;
  int _progressStageIndex = 0;
  int _progressHoldCount = 0;
  final List<double> _progressStages = [30, 55, 78, 92, 98];
  final List<double> _progressSpeeds = [1.2, 0.9, 0.6, 0.35, 0.2];
  final List<int> _progressHoldTicks = [5, 6, 8, 10, 999];
  final List<String> _statusMessages = [
    'Scanning handwriting...',
    'Reading keywords...',
    'Comparing with marking scheme...',
    'Detecting missing points...',
    'Calculating score...',
    'Preparing feedback...',
    'Almost done...',
  ];
  final List<String> _tips = [
    'Use bullet points for theory answers.',
    'Underline keywords for clarity.',
    'Add diagrams where relevant.',
    'Manage time according to marks.',
    'Definitions first, then explanation.',
    'Practice improves speed and accuracy.',
    'Keep answers concise and structured.',
    'Use separate paragraphs for each point.',
    'Check for neat and readable handwriting.',
    'Link examples directly to the question.',
  ];
  final List<int> _targetStats = [3, 12, 8, 94];
  List<int> _currentStats = [0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    _evalCubit = EvaluateAnswerCubit();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _startLoadingAnimations();
    _submitForEvaluation();
  }

  void _submitForEvaluation() {
    final List<File> uploadFiles = widget.filePaths.isNotEmpty
        ? widget.filePaths.map((path) => File(path)).toList()
        : [File(widget.filePath)];
    _evalCubit.evalAns(files: uploadFiles, subject: widget.subject);
  }

  void _startLoadingAnimations() {
    _statusTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      setState(() {
        _statusIndex = (_statusIndex + 1) % _statusMessages.length;
      });
    });

    _tipTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() {
        _tipIndex = (_tipIndex + 1) % _tips.length;
      });
    });

    _progressTimer = Timer.periodic(const Duration(milliseconds: 180), (_) {
      setState(() {
        if (_progress >= 98) return;

        final target = _progressStages[_progressStageIndex];
        if (_progress >= target) {
          if (_progressHoldCount < _progressHoldTicks[_progressStageIndex]) {
            _progressHoldCount += 1;
            return;
          }
          if (_progressStageIndex < _progressStages.length - 1) {
            _progressStageIndex += 1;
            _progressHoldCount = 0;
          }
        }

        final increment = _progressSpeeds[_progressStageIndex];
        _progress = min(target, _progress + increment);
        _currentStats = _updateStatsFromProgress(_progress);
      });
    });
  }

  void _stopLoadingAnimations() {
    _statusTimer?.cancel();
    _tipTimer?.cancel();
    _progressTimer?.cancel();
  }

  List<int> _updateStatsFromProgress(double progress) {
    final int modules = 2 + min(3, (progress / 30).floor());
    final int concepts = min(16, 4 + (progress / 8).floor());
    final int points = min(12, 3 + (progress / 10).floor());
    final int confidence = min(99, 82 + (progress / 2).floor());
    return [modules, concepts, points, confidence];
  }

  @override
  void dispose() {
    _heroController.dispose();
    _stopLoadingAnimations();
    _evalCubit.close();
    super.dispose();
  }

  Map<String, dynamic> _parseEvaluationText(String input) {
    final raw = input.trim();
    final score = _extractScore(raw);
    final intro = _extractIntroText(raw);
    final suggestions = _extractSectionBulletPoints(raw, 'Suggestions for Improvement');
    final breakdown = _extractSectionBulletPoints(raw, 'Breakdown');
    final paragraphs = suggestions.isEmpty && breakdown.isEmpty
        ? _extractParagraphs(raw)
        : <String>[];

    return {
      'raw': raw,
      'score': score,
      'intro': intro,
      'suggestions': suggestions,
      'breakdown': breakdown,
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

  List<String> _extractSectionBulletPoints(String raw, String sectionTitle) {
    if (raw.isEmpty) return <String>[];

    final split = raw.split(
      RegExp('${RegExp.escape(sectionTitle)}\\s*[:\\n]+', caseSensitive: false),
    );
    if (split.length < 2) return <String>[];

    final section = split.sublist(1).join(' ').trim();
    return _extractBulletPoints(section);
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

  Widget _buildWaitingHero() {
    return AnimatedBuilder(
      animation: _heroController,
      builder: (context, child) {
        final floatY = sin(_heroController.value * 2 * pi) * 12;
        final floatX = cos(_heroController.value * 3 * pi) * 10;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [Color(0xFF162145), Color(0xFF2E4C7E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 30,
                offset: Offset(0, 16.h),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -16.h,
                right: -16.w,
                child: Container(
                  width: 88.w,
                  height: 88.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.white.withOpacity(0.15), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -18.w,
                bottom: 16.h,
                child: Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                top: 36.h + floatY,
                left: 24.w + floatX,
                child: Transform.rotate(
                  angle: _heroController.value * 0.4,
                  child: Container(
                    width: 100.w,
                    height: 140.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      color: Colors.white.withOpacity(0.12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.18),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 46.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          SizedBox(height: 18.h),
                          Container(
                            width: 30.w,
                            height: 6.h,
                            color: Colors.white.withOpacity(0.4),
                          ),
                          SizedBox(height: 10.h),
                          Container(
                            width: 70.w,
                            height: 6.h,
                            color: Colors.white.withOpacity(0.4),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Container(
                                width: 14.w,
                                height: 14.w,
                                decoration: BoxDecoration(
                                  color: Colors.tealAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Container(
                                  height: 8.h,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 18.w,
                bottom: 22.h,
                child: Container(
                  width: 74.w,
                  height: 74.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.tealAccent.withOpacity(0.35), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 24.w,
                bottom: 28.h,
                child: Transform.rotate(
                  angle: _heroController.value * 2 * pi,
                  child: Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.tealAccent.withOpacity(0.65),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.auto_graph,
                        size: 28.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Evaluating Your Answer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _statusMessages[_statusIndex],
                      key: ValueKey(_statusIndex),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14.sp,
                        height: 1.55,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.flash_on, color: Colors.tealAccent, size: 18.sp),
                            SizedBox(width: 10.w),
                            Text(
                              '${_progress.round()}% Complete',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 14.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_progress.round()}% Complete',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Finalizing results...',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: LinearProgressIndicator(
                  value: _progress / 100,
                  minHeight: 12.h,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(Colors.teal),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fast scan',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                  ),
                  Text(
                    'Preparing insights',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String label, required int value, required IconData icon, required Color color}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: color, size: 20.sp),
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 18.h),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: value),
              duration: const Duration(milliseconds: 700),
              builder: (context, animatedValue, child) {
                return Text(
                  '$animatedValue',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                );
              },
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Icons.lightbulb,
              color: Colors.teal[700],
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Tip',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Text(
                    _tips[_tipIndex],
                    key: ValueKey(_tipIndex),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultMetric({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: color, size: 20.sp),
                ),
                const Spacer(),
              ],
            ),
            SizedBox(height: 18.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _scorePercentage(String? score) {
    if (score == null) return '--';
    final match = RegExp(r'([0-9]+)\s*/\s*([0-9]+)').firstMatch(score);
    if (match == null) return score;
    final achieved = int.tryParse(match.group(1)!) ?? 0;
    final total = int.tryParse(match.group(2)!) ?? 1;
    if (total == 0) return '--';
    return '${((achieved / total) * 100).round()}%';
  }

  String _scoreTag(String? score) {
    final percentString = _scorePercentage(score);
    final percent = int.tryParse(percentString.replaceAll('%', '')) ?? 0;
    if (percent >= 90) return 'Exceptional';
    if (percent >= 75) return 'Strong';
    if (percent >= 60) return 'Good';
    if (percent > 0) return 'Needs polish';
    return 'Ready';
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }

  Widget _buildQuestionResultCard(EvalQuestionModel question) {
    final parsed = _parseEvaluationText(question.comments ?? '');
    final suggestions = parsed['suggestions'] as List<String>;
    final breakdown = parsed['breakdown'] as List<String>;
    final paragraphs = parsed['paragraphs'] as List<String>;
    final title = question.questionText?.isNotEmpty == true
        ? question.questionText!
        : 'Question ID: ${question.questionId ?? 'Unknown'}';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.help_outline,
                  color: Colors.teal,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Score: ${question.score ?? '--'}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (question.answerText?.isNotEmpty ?? false) ...[
            SizedBox(height: 14.h),
            Text(
              'Submitted answer',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              question.answerText!.trim(),
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[800],
                height: 1.6,
              ),
            ),
          ],
          if (breakdown.isNotEmpty || suggestions.isNotEmpty || paragraphs.isNotEmpty) ...[
            SizedBox(height: 14.h),
            if (breakdown.isNotEmpty) ...[
              Text(
                'Highlights',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 10.h),
              _buildSuggestionList(breakdown),
            ],
            if (suggestions.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Text(
                'Suggestions',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 10.h),
              _buildSuggestionList(suggestions),
            ],
            if (breakdown.isEmpty && suggestions.isEmpty && paragraphs.isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: paragraphs.map((paragraph) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: Text(
                      paragraph,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[800],
                        height: 1.7,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ] else ...[
            SizedBox(height: 14.h),
            Text(
              question.comments ?? 'No detailed feedback was returned for this question.',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[800],
                height: 1.7,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMotivationSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Great effort! Your paper looks promising 👏',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Personalized feedback is being prepared. Please stay here — results are almost ready.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterPulse() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final delay = (index + 1) * 0.2;
        final scale = 0.8 + 0.2 * sin((_heroController.value + delay) * 2 * pi);
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.85),
            shape: BoxShape.circle,
          ),
          transform: Matrix4.identity()..scale(scale, scale),
        );
      }),
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
          if (state is ApiLoadingState) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWaitingHero(),
                  SizedBox(height: 24.h),
                  _buildProgressSection(),
                  SizedBox(height: 24.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatCard(
                        label: 'AI modules active',
                        value: _currentStats[0],
                        icon: Icons.memory,
                        color: Colors.indigo,
                      ),
                      SizedBox(width: 14.w),
                      _buildStatCard(
                        label: 'Key concepts',
                        value: _currentStats[1],
                        icon: Icons.lightbulb,
                        color: Colors.teal,
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatCard(
                        label: 'Points matched',
                        value: _currentStats[2],
                        icon: Icons.check_circle,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 14.w),
                      _buildStatCard(
                        label: 'Confidence',
                        value: _currentStats[3],
                        icon: Icons.shield,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  _buildTipCard(),
                  SizedBox(height: 24.h),
                  _buildMotivationSection(),
                  SizedBox(height: 28.h),
                  Center(child: _buildFooterPulse()),
                ],
              ),
            );
          }

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
                            final model = state.data;
                            final questions = model.questions;
                            final primaryQuestion = questions.isNotEmpty ? questions.first : null;
                            final isBatch = questions.length > 1;
                            final parsed = _parseEvaluationText(
                              model.comments ?? model.eval ?? primaryQuestion?.comments ?? '',
                            );
                            final score = primaryQuestion?.score ?? model.score ?? parsed['score'] as String?;
                            final intro = parsed['intro'] as String;
                            final suggestions = parsed['suggestions'] as List<String>;
                            final breakdown = parsed['breakdown'] as List<String>;
                            final paragraphs = parsed['paragraphs'] as List<String>;
                            final scorePercent = _scorePercentage(score);
                            final gradeTag = _scoreTag(score);
                            final headline = isBatch
                                ? '${questions.length} questions evaluated successfully.'
                                : intro.isNotEmpty
                                    ? intro.replaceAll('*', '')
                                    : 'Detailed evaluation complete. Your AI examiner is ready with feedback.';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(22.w),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: const [
                                        Color(0xFF2B3A80),
                                        Color(0xFF5A72C8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.14),
                                        blurRadius: 24,
                                        offset: Offset(0, 14.h),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 56.w,
                                            height: 56.w,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.18),
                                              borderRadius: BorderRadius.circular(16.r),
                                            ),
                                            child: Icon(
                                              Icons.verified,
                                              color: Colors.white,
                                              size: 28.sp,
                                            ),
                                          ),
                                          SizedBox(width: 14.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Evaluation Complete',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                SizedBox(height: 6.h),
                                                Text(
                                                  'Your answer has been reviewed by our AI examiner.',
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14.sp,
                                                    height: 1.6,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 22.h),
                                      Row(
                                        children: [
                                          _buildResultMetric(
                                            title: 'Score',
                                            value: score ?? '--',
                                            icon: Icons.star,
                                            color: Colors.amber,
                                          ),
                                          SizedBox(width: 14.w),
                                          _buildResultMetric(
                                            title: 'Accuracy',
                                            value: scorePercent,
                                            icon: Icons.speed,
                                            color: Colors.lightBlue,
                                          ),
                                          SizedBox(width: 14.w),
                                          _buildResultMetric(
                                            title: 'Rating',
                                            value: gradeTag,
                                            icon: Icons.trending_up,
                                            color: Colors.green,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                if (!isBatch &&
                                    ((model.questionText?.isNotEmpty ?? false) ||
                                        (model.questionId?.isNotEmpty ?? false))) ...[
                                  _buildSectionCard(
                                    title: 'Question details',
                                    child: Text(
                                      model.questionText?.isNotEmpty == true
                                          ? model.questionText!
                                          : 'Question ID: ${model.questionId}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey[800],
                                        height: 1.7,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 18.h),
                                ],
                                if (!isBatch && (model.answerText?.isNotEmpty ?? false)) ...[
                                  _buildSectionCard(
                                    title: 'Your submitted answer',
                                    child: Text(
                                      model.answerText!.trim(),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey[800],
                                        height: 1.7,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 18.h),
                                ],
                                _buildSectionCard(
                                  title: isBatch ? 'Batch summary' : 'What the AI found',
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        headline,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[800],
                                          height: 1.7,
                                        ),
                                      ),
                                      if (isBatch) ...[
                                        SizedBox(height: 10.h),
                                        Text(
                                          '${questions.length} items were evaluated. Review the question-by-question feedback below.',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: Colors.grey[700],
                                            height: 1.6,
                                          ),
                                        ),
                                      ],
                                      if (breakdown.isNotEmpty && !isBatch) ...[
                                        SizedBox(height: 14.h),
                                        _buildSuggestionList(breakdown),
                                      ],
                                    ],
                                  ),
                                ),
                                SizedBox(height: 18.h),
                                _buildSectionCard(
                                  title: 'Suggested improvements',
                                  child: suggestions.isNotEmpty
                                      ? _buildSuggestionList(suggestions)
                                      : paragraphs.isNotEmpty
                                          ? Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: paragraphs.map(
                                                (paragraph) {
                                                  return Padding(
                                                    padding: EdgeInsets.only(bottom: 12.h),
                                                    child: Text(
                                                      paragraph,
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        color: Colors.grey[800],
                                                        height: 1.7,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ).toList(),
                                            )
                                          : Text(
                                              model.comments ?? model.eval ??
                                                  'No detailed feedback was returned.',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.grey[800],
                                                height: 1.7,
                                              ),
                                            ),
                                ),
                                if (questions.length > 1) ...[
                                  SizedBox(height: 18.h),
                                  _buildSectionCard(
                                    title: 'Question-by-question results',
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: questions
                                          .map(
                                            (question) => Padding(
                                              padding: EdgeInsets.only(bottom: 16.h),
                                              child: _buildQuestionResultCard(question),
                                            ),
                                          )
                                          .toList(),
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
                  ElevatedButton(
                    onPressed: () {
                      context.go(Routes.homeScreen.path);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      minimumSize: Size(double.infinity, 48.h),
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
