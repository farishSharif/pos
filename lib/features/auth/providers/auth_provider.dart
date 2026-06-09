import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/savor_data_service.dart';
import '../models/profile.dart';

part 'auth_provider.g.dart';

class AuthState {
  final Profile? profile;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.profile,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isLoggedIn => profile != null;
  String get role => profile?.role ?? 'waiter';

  AuthState copyWith({
    Profile? profile,
    bool? isLoading,
    String? errorMessage,
    bool clearProfile = false,
  }) {
    return AuthState(
      profile: clearProfile ? null : (profile ?? this.profile),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  static const _spKey = 'savor_cached_user';

  @override
  AuthState build() {
    _loadSession();
    return AuthState();
  }

  Future<void> _loadSession() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final savedUser = sp.getString(_spKey);
      if (savedUser != null) {
        final Map<String, dynamic> json = jsonDecode(savedUser);
        state = AuthState(profile: Profile.fromJson(json));
      }
    } catch (_) {}
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final service = ref.read(savorServiceProvider);
      final profileMap = await service.signIn(email, password);
      
      if (profileMap != null) {
        final profile = Profile.fromJson(profileMap);
        
        final sp = await SharedPreferences.getInstance();
        await sp.setString(_spKey, jsonEncode(profileMap));
        
        state = AuthState(profile: profile);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid credentials. If offline, use (admin@savor.pos / password).',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(savorServiceProvider).signOut();
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_spKey);
      state = AuthState(profile: null);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}
