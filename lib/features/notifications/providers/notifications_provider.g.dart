// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationsStreamHash() =>
    r'828851aea8d8b7e3e2adbb2db3ebb238dc6b0e53';

/// See also [notificationsStream].
@ProviderFor(notificationsStream)
final notificationsStreamProvider =
    AutoDisposeStreamProvider<List<AppNotification>>.internal(
  notificationsStream,
  name: r'notificationsStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationsStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NotificationsStreamRef
    = AutoDisposeStreamProviderRef<List<AppNotification>>;
String _$notificationsNotifierHash() =>
    r'bfdc5c392aa76f7a0ca6f5e5c53d5aa836178b21';

/// See also [NotificationsNotifier].
@ProviderFor(NotificationsNotifier)
final notificationsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<NotificationsNotifier, void>.internal(
  NotificationsNotifier.new,
  name: r'notificationsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationsNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
