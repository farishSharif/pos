import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/breakpoints.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_bar_widget.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../../core/widgets/badge_widget.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/app_drawer.dart';
import '../models/staff_member.dart';
import '../providers/staff_provider.dart';

class StaffScreen extends ConsumerStatefulWidget {
  const StaffScreen({super.key});

  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen> {
  String _selectedRoleFilter = 'All';

  Color _getRoleColor(String role) {
    return switch (role.toLowerCase()) {
      'admin' => kAccent,
      'cashier' => kInfo,
      'waiter' => kSuccess,
      'kitchen' => kWarning,
      _ => kTextSecondary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Breakpoints.isLargeScreen(context);
    final staffAsync = ref.watch(staffNotifierProvider);

    return Scaffold(
      appBar: isTablet ? null : const AppBarWidget(title: 'Staff Directory'),
      drawer: isTablet ? null : const AppDrawer(),
      bottomNavigationBar: isTablet ? null : const BottomNav(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kAccent,
        foregroundColor: Colors.black,
        onPressed: () => _showAddStaffDialog(),
        child: const Icon(Icons.person_add_alt_1),
      ),
      body: Row(
        children: [
          if (isTablet) const SidebarNavigation(),
          Expanded(
            child: SafeArea(
              child: staffAsync.when(
                data: (staffList) {
                  final activeCount = staffList.where((s) => s.isActive).length;
                  final totalCount = staffList.length;

                  final filteredStaff = staffList.where((s) {
                    if (_selectedRoleFilter == 'All') return true;
                    return s.role.toLowerCase() == _selectedRoleFilter.toLowerCase();
                  }).toList();

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Padding(
                        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isTablet) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Staff Management', style: kHeadline.copyWith(fontSize: 28)),
                                      const SizedBox(height: 4),
                                      Text('Manage roles, shifts, and active status.', style: kCaption),
                                    ],
                                  ),
                                  _buildSummaryRow(activeCount, totalCount),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ] else ...[
                              _buildSummaryCard(activeCount, totalCount),
                              const SizedBox(height: 16),
                            ],
                            _buildRoleFilters(),
                            const SizedBox(height: 16),
                            Expanded(
                              child: filteredStaff.isEmpty
                                  ? const EmptyStateWidget(
                                      title: 'No Staff Found',
                                      subtitle: 'Try changing your filter or add a new member.',
                                      fallbackIcon: Icons.people_outline,
                                    )
                                  : isTablet
                                      ? _buildStaffGrid(filteredStaff)
                                      : _buildStaffList(filteredStaff),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(child: LoadingShimmer.list(count: 6)),
                ),
                error: (err, __) => Center(child: Text('Error: $err', style: kBody)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(int active, int total) {
    return Row(
      children: [
        _buildSummaryItem('Active Now', '$active', kSuccess),
        const SizedBox(width: 24),
        _buildSummaryItem('Total Staff', '$total', kAccent),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String val, Color col) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: kCaption),
        Text(val, style: kHeadline.copyWith(fontSize: 24, color: col)),
      ],
    );
  }

  Widget _buildSummaryCard(int active, int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(color: kSuccess, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text('Active: $active', style: kBody.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          Container(width: 1, height: 24, color: kDivider),
          Row(
            children: [
              const Icon(Icons.people, color: kAccent, size: 16),
              const SizedBox(width: 8),
              Text('Total: $total', style: kBody.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFilters() {
    final roles = ['All', 'Admin', 'Cashier', 'Waiter', 'Kitchen'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: roles.map((role) {
          final isSel = _selectedRoleFilter == role;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(role),
              selected: isSel,
              selectedColor: kAccent,
              backgroundColor: kSurface,
              labelStyle: kCaption.copyWith(
                color: isSel ? Colors.black : kTextSecondary,
                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (val) {
                if (val) setState(() => _selectedRoleFilter = role);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStaffGrid(List<StaffMember> list) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 160,
      ),
      itemCount: list.length,
      itemBuilder: (context, idx) => _buildStaffCard(list[idx]),
    );
  }

  Widget _buildStaffList(List<StaffMember> list) {
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, idx) => _buildStaffTile(list[idx]),
    );
  }

  Widget _buildStaffCard(StaffMember staff) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: staff.isActive ? Colors.transparent : kDivider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _getRoleColor(staff.role).withOpacity(0.15),
                child: Text(
                  staff.name.substring(0, 1).toUpperCase(),
                  style: kHeadline.copyWith(fontSize: 16, color: _getRoleColor(staff.role)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(staff.name, style: kBody.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(staff.email ?? '', style: kCaption, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BadgeWidget(
                label: staff.role.toUpperCase(),
                color: _getRoleColor(staff.role),
              ),
              Text(
                staff.shiftStart != null && staff.shiftEnd != null
                    ? '${staff.shiftStart} - ${staff.shiftEnd}'
                    : 'No Shift Set',
                style: kCaption.copyWith(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(staff.isActive ? 'Active Shift' : 'Inactive', style: kCaption.copyWith(color: staff.isActive ? kSuccess : kTextSecondary)),
              Row(
                children: [
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: kBg, foregroundColor: kAccent),
                    icon: const Icon(Icons.edit, size: 16),
                    onPressed: () => _showEditStaffDialog(staff),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: staff.isActive,
                    activeColor: kSuccess,
                    onChanged: (val) {
                      ref.read(staffNotifierProvider.notifier).toggleActiveStatus(staff.id, staff.isActive);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStaffTile(StaffMember staff) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(staff.role).withOpacity(0.15),
          child: Text(
            staff.name.substring(0, 1).toUpperCase(),
            style: kHeadline.copyWith(fontSize: 16, color: _getRoleColor(staff.role)),
          ),
        ),
        title: Text(staff.name, style: kBody.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text('${staff.role.toUpperCase()} • ${staff.shiftStart ?? "N/A"} - ${staff.shiftEnd ?? "N/A"}', style: kCaption),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: staff.isActive,
              activeColor: kSuccess,
              onChanged: (val) {
                ref.read(staffNotifierProvider.notifier).toggleActiveStatus(staff.id, staff.isActive);
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 18, color: kAccent),
              onPressed: () => _showEditStaffDialog(staff),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStaffDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final shiftStartController = TextEditingController(text: '09:00 AM');
    final shiftEndController = TextEditingController(text: '05:00 PM');
    String selectedRole = 'waiter';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: kSurface,
              title: Text('Add Staff Member', style: kHeadline.copyWith(fontSize: 20)),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        style: kBody,
                        decoration: InputDecoration(labelText: 'Name', labelStyle: kCaption),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        dropdownColor: kSurface,
                        value: selectedRole,
                        style: kBody,
                        decoration: InputDecoration(labelText: 'Role', labelStyle: kCaption),
                        items: ['admin', 'cashier', 'waiter', 'kitchen'].map((role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedRole = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        style: kBody,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(labelText: 'Email', labelStyle: kCaption),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Enter email' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneController,
                        style: kBody,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(labelText: 'Phone (Optional)', labelStyle: kCaption),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: shiftStartController,
                              style: kBody,
                              decoration: InputDecoration(labelText: 'Shift Start', labelStyle: kCaption),
                              onTap: () async {
                                FocusScope.of(context).requestFocus(FocusNode());
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (time != null) {
                                  shiftStartController.text = time.format(context);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: shiftEndController,
                              style: kBody,
                              decoration: InputDecoration(labelText: 'Shift End', labelStyle: kCaption),
                              onTap: () async {
                                FocusScope.of(context).requestFocus(FocusNode());
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (time != null) {
                                  shiftEndController.text = time.format(context);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: kTextSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kAccent, foregroundColor: Colors.black),
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      await ref.read(staffNotifierProvider.notifier).createStaff(
                            nameController.text.trim(),
                            selectedRole,
                            emailController.text.trim(),
                            phoneController.text.isEmpty ? null : phoneController.text.trim(),
                            shiftStartController.text,
                            shiftEndController.text,
                          );
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditStaffDialog(StaffMember staff) {
    final nameController = TextEditingController(text: staff.name);
    final phoneController = TextEditingController(text: staff.phone ?? '');
    final shiftStartController = TextEditingController(text: staff.shiftStart ?? '09:00 AM');
    final shiftEndController = TextEditingController(text: staff.shiftEnd ?? '05:00 PM');
    String selectedRole = staff.role;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: kSurface,
              title: Text('Edit ${staff.name}', style: kHeadline.copyWith(fontSize: 20)),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        style: kBody,
                        decoration: InputDecoration(labelText: 'Name', labelStyle: kCaption),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        dropdownColor: kSurface,
                        value: selectedRole,
                        style: kBody,
                        decoration: InputDecoration(labelText: 'Role', labelStyle: kCaption),
                        items: ['admin', 'cashier', 'waiter', 'kitchen'].map((role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedRole = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneController,
                        style: kBody,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(labelText: 'Phone', labelStyle: kCaption),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: shiftStartController,
                              style: kBody,
                              decoration: InputDecoration(labelText: 'Shift Start', labelStyle: kCaption),
                              onTap: () async {
                                FocusScope.of(context).requestFocus(FocusNode());
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (time != null) {
                                  shiftStartController.text = time.format(context);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: shiftEndController,
                              style: kBody,
                              decoration: InputDecoration(labelText: 'Shift End', labelStyle: kCaption),
                              onTap: () async {
                                FocusScope.of(context).requestFocus(FocusNode());
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (time != null) {
                                  shiftEndController.text = time.format(context);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: kTextSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kAccent, foregroundColor: Colors.black),
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      await ref.read(staffNotifierProvider.notifier).updateStaff(
                            staff.id,
                            name: nameController.text.trim(),
                            role: selectedRole,
                            phone: phoneController.text.isEmpty ? null : phoneController.text.trim(),
                            shiftStart: shiftStartController.text,
                            shiftEnd: shiftEndController.text,
                          );
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
