import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autograde_mobile/core/api/api_state.dart';
import 'package:autograde_mobile/core/api/models/api_base_paginated_model.dart';
import 'package:autograde_mobile/core/api/models/deserializable.dart';
import 'package:autograde_mobile/core/widgets/app_api_consumer.dart';
import 'package:autograde_mobile/core/widgets/loading_widget.dart';

class AppApiPaginatedConsumer<D extends Deserializable, B extends StateStreamable<S>,
    S extends ApiState<ApiBasePaginatedModel<D>>> extends StatefulWidget {
  const AppApiPaginatedConsumer({
    super.key,
    this.listener,
    required this.itemsBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    required this.onLoadMore,
    required this.onRefresh,
  });

  final void Function(BuildContext context, S state, List<D> listData)? listener;
  final Widget Function(BuildContext context, S state, List<D> listData) itemsBuilder;
  final Widget Function(BuildContext context, S state)? emptyBuilder;
  final Widget Function(BuildContext context, S state)? errorBuilder;
  final void Function(BuildContext context, int page) onLoadMore;
  final void Function(BuildContext context, int page) onRefresh;

  @override
  State<AppApiPaginatedConsumer<D, B, S>> createState() => AppApiPaginatedConsumerState<D, B, S>();
}

class AppApiPaginatedConsumerState<D extends Deserializable, B extends StateStreamable<S>,
    S extends ApiState<ApiBasePaginatedModel<D>>> extends State<AppApiPaginatedConsumer<D, B, S>> {
  int page = 1;
  List<D> dataList = [];
  bool hasNextPage = false;

  Future<void> refresh() async {
    dataList = [];
    page = 1;
    widget.onRefresh.call(context, page);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => refresh(),
      child: NotificationListener(
        onNotification: (notification) {
          if (!hasNextPage) return false;

          if (dataList.isEmpty) return false;

          if (notification is ScrollEndNotification) {
            if (notification.metrics.pixels == notification.metrics.maxScrollExtent) {
              page++;
              widget.onLoadMore.call(context, page);
            }
          }
          return false;
        },
        child: AppApiConsumer<B, S>(
          listener: (p0, p1) {
            if (p1 is ApiLoadedState<ApiBasePaginatedModel<D>>) {
              final data = p1.data;
              hasNextPage = data.nextPageUrl != null;
              if (dataList.isEmpty) {
                dataList = data.data;
              } else {
                dataList.addAll(data.data);
              }
            }

            widget.listener?.call(p0, p1, dataList);
          },
          successBuilder: (context, state) => widget.itemsBuilder(context, state, dataList),
          errorBuilder: widget.errorBuilder,
          emptyBuilder: widget.emptyBuilder,
          loadingBuilder: (context, state) {
            // Show loading for first time
            if (state is ApiLoadingState && dataList.isEmpty) {
              return const LoadingWidget();
            }

            return widget.itemsBuilder(context, state, dataList);
          },
        ),
      ),
    );
  }
}
