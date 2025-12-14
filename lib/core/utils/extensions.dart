import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

extension StringExtensions on String {
  // Validate email
  bool isValidEmail() {
    return RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    ).hasMatch(this);
  }

  // Capitalize first letter of a string
  String capitalizeFirst() {
    if (isEmpty) return this; // Return empty string as-is
    return this[0].toUpperCase() + substring(1);
  }

  String limitTo(int maxLength) {
    if (length <= maxLength) return this; // Return original string if within limit
    return '${substring(0, maxLength)}...'; // Append ellipsis if truncated
  }
}

extension BuildContextExtensions on BuildContext {
  // AppLocalizations get localization => AppLocalizations.of(this)!;
  Future<T?> showFullscreenDialog<T>({
    required Widget child,
    Color? backgroundColor,
    bool barrierDismissible = false,
  }) {
    return showGeneralDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(this).modalBarrierDismissLabel,
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return Material(
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: child,
          ),
        );
      },
      // transitionBuilder: (context, animation, secondaryAnimation, child) {
      //   const begin = Offset(0.0, 1.0);
      //   const end = Offset.zero;
      //   const curve = Curves.easeInOut;
      //   var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      //   var offsetAnimation = animation.drive(tween);

      //   return SlideTransition(
      //     position: offsetAnimation,
      //     child: child,
      //   );
      // },
    );
  }

  Future<bool?> showOptionsDialog({
    required String title,
    required String content,
    required Map<String, void Function()> options,
  }) async {
    return await showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: options.entries.map((entry) {
          return TextButton(
            onPressed: entry.value,
            child: Text(entry.key),
          );
        }).toList(),
      ),
    );
  }

  Future<T?> showAppBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = false,
    Color? backgroundColor,
    ShapeBorder? shape,
    BoxConstraints? constraints,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor ?? Theme.of(this).colorScheme.surface,
      // Set the default height to 80% of the screen height
      constraints: constraints,
      shape: shape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(6.0)),
          ),
      builder: (context) => child,
    );
  }

  Future<bool?> showConfirmationDialog({
    required String title,
    required String content,
    required void Function()? onPressed,
  }) async {
    return await showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('No'),
          ),
          TextButton(onPressed: onPressed, child: const Text('Yes')),
        ],
      ),
    );
  }

  Future<DateTime?> showDateTimePicker({
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    initialDate ??= DateTime.now();
    firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
    lastDate ??= firstDate.add(const Duration(days: 365 * 200));

    final DateTime? selectedDate = await showDatePicker(
      context: this,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate == null) return null;

    if (!mounted) return selectedDate;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: this,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    return selectedTime == null
        ? selectedDate
        : DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
  }
}

extension DateTimeExtensions on DateTime {
  // YYYY-MM-DD (e.g., 2025-04-04)
  String toYMD() {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  // MM/DD/YYYY (e.g., 04/04/2025)
  String toMDY() {
    return DateFormat('MM/dd/yyyy').format(this);
  }

  // DD-MM-YYYY (e.g., 04-04-2025)
  String toDMY() {
    return DateFormat('dd-MM-yyyy').format(this);
  }

  // MMMM D, YYYY (e.g., April 4, 2025)
  String toFullDate() {
    return DateFormat('MMMM d, yyyy').format(this);
  }

  // DD MMM YYYY (e.g., 04 Apr 2025)
  String toShortDate() {
    return DateFormat('dd MMM yyyy').format(this);
  }

  // HH:MM:SS (24-hour, e.g., 14:30:00)
  String toTime() {
    return DateFormat('HH:mm:ss').format(this);
  }

  // hh:MM AM/PM (12-hour, e.g., 02:30 PM)
  String toTime12() {
    return DateFormat('hh:mm a').format(this);
  }

  // YYYY-MM-DD HH:MM:SS (e.g., 2025-04-04 14:30:00)
  String toYMDHMS() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(this);
  }

  String timeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }
}

extension TimeOfDayExtension on TimeOfDay {
  // Format TimeOfDay to a readable string (e.g., "3:30 PM")
  String format(BuildContext context) {
    return MaterialLocalizations.of(context).formatTimeOfDay(
      this,
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );
  }

  // Convert TimeOfDay to a string in "HH:MM:SS" format
  String toTimeString() {
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  // Check if this time is before another time
  bool isBefore(TimeOfDay other) {
    return hour < other.hour || (hour == other.hour && minute < other.minute);
  }

  // Check if this time is after another time
  bool isAfter(TimeOfDay other) {
    return hour > other.hour || (hour == other.hour && minute > other.minute);
  }

  // Check if this time is the same as or before another time
  bool isSameOrBefore(TimeOfDay other) {
    return hour < other.hour || (hour == other.hour && minute <= other.minute);
  }

  // Check if this time is the same as or after another time
  bool isSameOrAfter(TimeOfDay other) {
    return hour > other.hour || (hour == other.hour && minute >= other.minute);
  }
}

// Additional BuildContext extension for time pickers
extension TimePickerExtension on BuildContext {
  // Show a time picker with theme that matches the app's theme
  Future<TimeOfDay?> showThemedTimePicker({
    required TimeOfDay initialTime,
  }) async {
    return showTimePicker(
      context: this,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Theme.of(context).primaryColor,
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
            buttonTheme: ButtonThemeData(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}

extension DurationExtension on Duration {
  // Convert Duration to a human-readable string (e.g., "2 hours, 30 minutes")
  String toReadableString({bool includeSeconds = false}) {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    final parts = <String>[];
    if (hours > 0) parts.add('$hours hour${hours > 1 ? 's' : ''}');
    if (minutes > 0) parts.add('$minutes minute${minutes > 1 ? 's' : ''}');
    if (includeSeconds && seconds > 0) parts.add('$seconds second${seconds > 1 ? 's' : ''}');

    return parts.join(', ');
  }
}
