// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tables_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tablesStreamHash() => r'df0a9cd3fa64a7685ae8e51b6f6f24044341a585';

/// See also [tablesStream].
@ProviderFor(tablesStream)
final tablesStreamProvider =
    AutoDisposeStreamProvider<List<RestaurantTable>>.internal(
  tablesStream,
  name: r'tablesStreamProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tablesStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TablesStreamRef = AutoDisposeStreamProviderRef<List<RestaurantTable>>;
String _$tablesNotifierHash() => r'93c562f4a5e2fa6357dfc3954fcb32379c0d6435';

/// See also [TablesNotifier].
@ProviderFor(TablesNotifier)
final tablesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<TablesNotifier, void>.internal(
  TablesNotifier.new,
  name: r'tablesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tablesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TablesNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
