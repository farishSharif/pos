import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/savor_data_service.dart';
import '../models/app_settings.dart';

part 'settings_provider.g.dart';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  FutureOr<AppSettings> build() async {
    final service = ref.watch(savorServiceProvider);
    final map = await service.getAppSettings();
    return AppSettings.fromJson(map);
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(savorServiceProvider);
      final map = await service.updateAppSettings(newSettings.toJson());
      return AppSettings.fromJson(map);
    });
  }
}
