import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

@riverpod
class ConnectivityNotifier extends _$ConnectivityNotifier {
  late final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  bool build() {
    _connectivity = Connectivity();
    _init();
    ref.onDispose(() {
      _subscription?.cancel();
    });
    return true; // Assume online initially
  }

  Future<void> _init() async {
    try {
      final results = await _connectivity.checkConnectivity();
      state = _updateState(results);
    } catch (_) {
      state = true;
    }

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      state = _updateState(results);
    });
  }

  bool _updateState(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    if (results.contains(ConnectivityResult.none)) return false;
    return true;
  }
}
