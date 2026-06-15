// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoriesHash() => r'b6c5a3e4f98a781f26541f5df95befe7d44b18cc';

/// See also [categories].
@ProviderFor(categories)
final categoriesProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
  categories,
  name: r'categoriesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$categoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CategoriesRef
    = AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$menuItemsHash() => r'a7c7b4d267066bad7119e2ec1b25c42d769abe67';

/// See also [menuItems].
@ProviderFor(menuItems)
final menuItemsProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
  menuItems,
  name: r'menuItemsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$menuItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MenuItemsRef = AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$ordersListHash() => r'dffe1e5663fc32a175f889ac5eb0adc044946fce';

/// See also [ordersList].
@ProviderFor(ordersList)
final ordersListProvider = AutoDisposeFutureProvider<List<Order>>.internal(
  ordersList,
  name: r'ordersListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$ordersListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef OrdersListRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$validateCouponHash() => r'baf42cfd7f930c9b2d6b70c73cdb7186650978be';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [validateCoupon].
@ProviderFor(validateCoupon)
const validateCouponProvider = ValidateCouponFamily();

/// See also [validateCoupon].
class ValidateCouponFamily extends Family<AsyncValue<Map<String, dynamic>?>> {
  /// See also [validateCoupon].
  const ValidateCouponFamily();

  /// See also [validateCoupon].
  ValidateCouponProvider call(
    String code,
  ) {
    return ValidateCouponProvider(
      code,
    );
  }

  @override
  ValidateCouponProvider getProviderOverride(
    covariant ValidateCouponProvider provider,
  ) {
    return call(
      provider.code,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'validateCouponProvider';
}

/// See also [validateCoupon].
class ValidateCouponProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>?> {
  /// See also [validateCoupon].
  ValidateCouponProvider(
    String code,
  ) : this._internal(
          (ref) => validateCoupon(
            ref as ValidateCouponRef,
            code,
          ),
          from: validateCouponProvider,
          name: r'validateCouponProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$validateCouponHash,
          dependencies: ValidateCouponFamily._dependencies,
          allTransitiveDependencies:
              ValidateCouponFamily._allTransitiveDependencies,
          code: code,
        );

  ValidateCouponProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.code,
  }) : super.internal();

  final String code;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>?> Function(ValidateCouponRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ValidateCouponProvider._internal(
        (ref) => create(ref as ValidateCouponRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        code: code,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>?> createElement() {
    return _ValidateCouponProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ValidateCouponProvider && other.code == code;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, code.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ValidateCouponRef on AutoDisposeFutureProviderRef<Map<String, dynamic>?> {
  /// The parameter `code` of this provider.
  String get code;
}

class _ValidateCouponProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>?>
    with ValidateCouponRef {
  _ValidateCouponProviderElement(super.provider);

  @override
  String get code => (origin as ValidateCouponProvider).code;
}

String _$ordersNotifierHash() => r'767e14ed2a104a4a97c17827b42d1a97fcf713f8';

/// See also [OrdersNotifier].
@ProviderFor(OrdersNotifier)
final ordersNotifierProvider =
    AutoDisposeAsyncNotifierProvider<OrdersNotifier, void>.internal(
  OrdersNotifier.new,
  name: r'ordersNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ordersNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OrdersNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
