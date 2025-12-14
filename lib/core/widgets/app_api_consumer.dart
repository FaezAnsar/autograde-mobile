import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autograde_mobile/core/api/api_state.dart';
import 'package:autograde_mobile/core/widgets/loading_widget.dart';

class AppApiConsumer<B extends StateStreamable<S>, S extends ApiState<dynamic>>
    extends StatelessWidget {
  const AppApiConsumer({
    super.key,
    this.listener,
    required this.successBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.loadingBuilder,
  });

  final void Function(BuildContext, S)? listener;
  final Widget Function(BuildContext context, S state) successBuilder;
  final Widget Function(BuildContext context, S state)? emptyBuilder;
  final Widget Function(BuildContext context, S state)? loadingBuilder;
  final Widget Function(BuildContext context, S state)? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<B, S>(
      listener: (context, state) {
        listener?.call(context, state);
      },
      builder: (context, state) {
        if (state is ApiLoadingState) {
          if (loadingBuilder != null) {
            return loadingBuilder!(context, state);
          } else {
            return const LoadingWidget();
          }
        } else if (state is ApiLoadedState) {
          return successBuilder(context, state);
        } else if (state is ApiErrorState) {
          if (errorBuilder != null) {
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[SliverFillRemaining(child: errorBuilder!(context, state))],
            );
          } else {
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                SliverFillRemaining(child: Center(child: Text(state.error.toString()))),
              ],
            );
          }
        } else {
          if (emptyBuilder == null) {
            return const CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                SliverFillRemaining(child: Center(child: Text('No Data Available'))),
              ],
            );
          } else {
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[SliverFillRemaining(child: emptyBuilder!(context, state))],
            );
          }
        }
      },
    );
  }
}
