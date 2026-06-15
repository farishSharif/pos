// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$inventoryNotifierHash() => r'8087285ab6b877bd99af9faf1a1d6b0550af4a8a';

/// See also [InventoryNotifier].
@ProviderFor(InventoryNotifier)
final inventoryNotifierProvider = AutoDisposeAsyncNotifierProvider<
    InventoryNotifier, List<InventoryItem>>.internal(
  InventoryNotifier.new,
  name: r'inventoryNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventoryNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InventoryNotifier = AutoDisposeAsyncNotifier<List<InventoryItem>>;
String _$purchaseRecordsNotifierHash() =>
    r'3b90473a546119c43e51cf7b75bd2540e99add25';

/// See also [PurchaseRecordsNotifier].
@ProviderFor(PurchaseRecordsNotifier)
final purchaseRecordsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    PurchaseRecordsNotifier, List<PurchaseRecord>>.internal(
  PurchaseRecordsNotifier.new,
  name: r'purchaseRecordsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$purchaseRecordsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PurchaseRecordsNotifier
    = AutoDisposeAsyncNotifier<List<PurchaseRecord>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
