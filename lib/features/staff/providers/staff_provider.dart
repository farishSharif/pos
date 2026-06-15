import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/savor_data_service.dart';
import '../models/staff_member.dart';

part 'staff_provider.g.dart';

@riverpod
class StaffNotifier extends _$StaffNotifier {
  @override
  FutureOr<List<StaffMember>> build() async {
    final service = ref.watch(savorServiceProvider);
    final list = await service.getStaffProfiles();
    return list.map((e) => StaffMember.fromJson(e)).toList();
  }

  Future<void> createStaff(String name, String role, String email, String? phone, String? shiftStart, String? shiftEnd) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(savorServiceProvider);
      final profileData = {
        'name': name,
        'role': role,
        'email': email,
        'phone': phone,
        'shift_start': shiftStart,
        'shift_end': shiftEnd,
        'is_active': true,
      };
      await service.createStaffProfile(profileData);
      final list = await service.getStaffProfiles();
      return list.map((e) => StaffMember.fromJson(e)).toList();
    });
  }

  Future<void> updateStaff(String id, {
    String? name,
    String? role,
    String? phone,
    String? shiftStart,
    String? shiftEnd,
    bool? isActive,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(savorServiceProvider);
      final profileData = <String, dynamic>{};
      if (name != null) profileData['name'] = name;
      if (role != null) profileData['role'] = role;
      if (phone != null) profileData['phone'] = phone;
      if (shiftStart != null) profileData['shift_start'] = shiftStart;
      if (shiftEnd != null) profileData['shift_end'] = shiftEnd;
      if (isActive != null) profileData['is_active'] = isActive;

      await service.updateStaffProfile(id, profileData);
      final list = await service.getStaffProfiles();
      return list.map((e) => StaffMember.fromJson(e)).toList();
    });
  }

  Future<void> toggleActiveStatus(String id, bool currentStatus) async {
    await updateStaff(id, isActive: !currentStatus);
  }
}
