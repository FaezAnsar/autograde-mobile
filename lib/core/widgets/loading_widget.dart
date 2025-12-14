import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    this.width,
    this.height,
    this.loadingStroke,
    this.color,
    super.key,
  });

  final double? width;
  final double? height;
  final double? loadingStroke;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width ?? 20.0,
        height: height ?? 20.0,
        child: CircularProgressIndicator(
          color: color ?? Theme.of(context).primaryColor,
          strokeWidth: loadingStroke ?? 2.0,
          strokeCap: StrokeCap.square,
        ),
      ),
    );
  }
}
