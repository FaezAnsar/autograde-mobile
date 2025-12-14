// import 'dart:async';
// import 'dart:developer';

// import 'package:dart_pusher_channels/dart_pusher_channels.dart';
// import 'package:flutter/material.dart';

// class ChannelListener<T extends Channel> extends StatefulWidget {
//   final T channel;
//   final void Function(T channel)? onSubscribed;
//   final void Function(T channel)? onUnsubscribed;
//   final Map<String, void Function(ChannelReadEvent event)>? eventListeners;
//   final Widget Function(BuildContext context, T? channel) builder;

//   const ChannelListener({
//     required this.channel,
//     this.onSubscribed,
//     this.onUnsubscribed,
//     this.eventListeners,
//     required this.builder,
//     super.key,
//   });

//   @override
//   State<ChannelListener<T>> createState() => ChannelListenerState<T>();
// }

// class ChannelListenerState<T extends Channel>
//     extends State<ChannelListener<T>> {
//   bool isSubscribed() {
//     return ([ChannelStatus.subscribed, ChannelStatus.pendingSubscription]
//         .contains(widget.channel.state?.status));
//   }

//   final List<StreamSubscription> _subscriptions = [];
//   StreamSubscription? _subscriptionSuccessListener;
//   StreamSubscription? _subscriptionErrorListener;
//   bool _isSubscribing = false;

//   void _clearAllSubscriptions() {
//     log('Clearing all subscriptions for channel: ${widget.channel.name}',
//         name: 'ChannelListener');

//     // Cancel all event subscriptions
//     for (final subscription in _subscriptions) {
//       subscription.cancel();
//     }
//     _subscriptions.clear();

//     // Cancel subscription listeners
//     _subscriptionSuccessListener?.cancel();
//     _subscriptionSuccessListener = null;
//     _subscriptionErrorListener?.cancel();
//     _subscriptionErrorListener = null;
//   }

//   subscribe() {
//     // Prevent multiple simultaneous subscription attempts
//     if (_isSubscribing || isSubscribed()) {
//       log('Already subscribing or subscribed to channel: ${widget.channel.name}',
//           name: 'ChannelListener');
//       return;
//     }

//     log('Trying to subscribe to channel: ${widget.channel.name}',
//         name: 'ChannelListener');
//     _isSubscribing = true;

//     // Clear any existing subscriptions first
//     _clearAllSubscriptions();

//     widget.channel.subscribe();

//     _subscriptionSuccessListener =
//         widget.channel.whenSubscriptionSucceeded().listen((_) {
//       log('Subscription succeeded: ${widget.channel.name}',
//           name: 'ChannelListener');
//       _isSubscribing = false;

//       widget.onSubscribed?.call(widget.channel);

//       final bindAllSub = widget.channel.bindToAll().listen((event) {
//         log('${event.channelName} | ${event.name} : ${event.data}');
//       });

//       _subscriptions.add(bindAllSub);

//       widget.eventListeners?.forEach((event, listener) {
//         log('Binding to event: $event', name: 'ChannelListener');
//         _subscriptions.add(
//             widget.channel.bind(event).listen(listener, cancelOnError: false));
//       });
//     });

//     _subscriptionErrorListener =
//         widget.channel.onSubscriptionError().listen((error) {
//       log('Subscription error: ${error.channelName} - ${error.data}',
//           name: 'ChannelListener');
//       _isSubscribing = false;
//     });
//   }

//   unsubscribe() {
//     if (!isSubscribed()) {
//       //? if the channel is not subscribed or pending subscription, do nothing
//       return;
//     }
//     log('Unsubscribing from channel: ${widget.channel.name}',
//         name: 'ChannelListener');

//     _clearAllSubscriptions();
//     widget.channel.unsubscribe();
//     widget.onUnsubscribed?.call(widget.channel);
//     _isSubscribing = false;
//   }

//   @override
//   void didUpdateWidget(covariant ChannelListener<T> oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     log('DidUpdateWidget: ${widget.channel.name}', name: 'ChannelListener');

//     if (oldWidget.channel != widget.channel) {
//       log('Channel changed from ${oldWidget.channel.name} to ${widget.channel.name}',
//           name: 'ChannelListener');

//       // Unsubscribe from old channel
//       if ([ChannelStatus.subscribed, ChannelStatus.pendingSubscription]
//           .contains(oldWidget.channel.state?.status)) {
//         log('Unsubscribing from old channel: ${oldWidget.channel.name}',
//             name: 'ChannelListener');
//         oldWidget.channel.unsubscribe();
//       }

//       // Clear current subscriptions
//       _clearAllSubscriptions();
//       _isSubscribing = false;

//       // Subscribe to new channel if not already subscribed
//       if (!isSubscribed()) {
//         subscribe();
//       }
//     }
//   }

//   @override
//   void initState() {
//     if (!isSubscribed()) {
//       subscribe();
//     }
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return widget.builder(context, widget.channel);
//   }

//   @override
//   void dispose() {
//     log('Disposing ChannelListener for: ${widget.channel.name}',
//         name: 'ChannelListener');
//     unsubscribe();
//     _clearAllSubscriptions();
//     super.dispose();
//   }
// }
