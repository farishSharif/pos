import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/breakpoints.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_bar_widget.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/app_settings.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _gstinController;
  late TextEditingController _cgstController;
  late TextEditingController _sgstController;
  late TextEditingController _serviceChargeController;
  bool _serviceChargeEnabled = true;
  int _receiptTemplate = 1;

  bool _isInitialized = false;

  @override
  void dispose() {
    if (_isInitialized) {
      _nameController.dispose();
      _addressController.dispose();
      _phoneController.dispose();
      _gstinController.dispose();
      _cgstController.dispose();
      _sgstController.dispose();
      _serviceChargeController.dispose();
    }
    super.dispose();
  }

  void _initControllers(AppSettings settings) {
    if (_isInitialized) return;
    _nameController = TextEditingController(text: settings.restaurantName);
    _addressController = TextEditingController(text: settings.address ?? '');
    _phoneController = TextEditingController(text: settings.phone ?? '');
    _gstinController = TextEditingController(text: settings.gstin ?? '');
    _cgstController = TextEditingController(text: settings.cgstRate.toString());
    _sgstController = TextEditingController(text: settings.sgstRate.toString());
    _serviceChargeController = TextEditingController(text: settings.serviceChargeRate.toString());
    _serviceChargeEnabled = settings.serviceChargeEnabled;
    _receiptTemplate = settings.receiptTemplate;
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Breakpoints.isLargeScreen(context);
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final role = authState.role;

    if (role != 'admin') {
      return Scaffold(
        appBar: isTablet ? null : const AppBarWidget(title: 'Settings'),
        drawer: isTablet ? null : const AppDrawer(),
        bottomNavigationBar: isTablet ? null : const BottomNav(),
        body: Row(
          children: [
            if (isTablet) const SidebarNavigation(),
            Expanded(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isTablet) ...[
                        Text('Settings', style: kHeadline.copyWith(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text('Manage your session and view profile details.', style: kCaption),
                        const SizedBox(height: 24),
                      ],
                      _buildNonAdminProfileCard(authState),
                      const SizedBox(height: 16),
                      _buildAppInfoCard(),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kError,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusButton)),
                          ),
                          onPressed: () {
                            ConfirmationDialog.show(
                              context: context,
                              title: 'Sign Out',
                              content: 'Are you sure you want to sign out from ROYAL FF?',
                              confirmLabel: 'Sign Out',
                              confirmColor: kError,
                              onConfirm: () => ref.read(authNotifierProvider.notifier).signOut(),
                            );
                          },
                          icon: const Icon(Icons.logout),
                          label: Text('Sign Out', style: kTitle.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: isTablet ? null : const AppBarWidget(title: 'App Settings'),
      drawer: isTablet ? null : const AppDrawer(),
      bottomNavigationBar: isTablet ? null : const BottomNav(),
      body: Row(
        children: [
          if (isTablet) const SidebarNavigation(),
          Expanded(
            child: SafeArea(
              child: settingsAsync.when(
                data: (settings) {
                  _initControllers(settings);

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final content = Form(
                        key: _formKey,
                        child: SingleChildScrollView(
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
                                        Text('App Settings', style: kHeadline.copyWith(fontSize: 28)),
                                        const SizedBox(height: 4),
                                        Text('Configure business details, taxes, and receipt templates.', style: kCaption),
                                      ],
                                    ),
                                    _buildSaveButton(settings),
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ],
                              if (isTablet)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: _buildFormContent(context),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      flex: 2,
                                      child: _buildReceiptPreviewSection(),
                                    ),
                                  ],
                                )
                              else ...[
                                _buildFormContent(context),
                                const SizedBox(height: 20),
                                _buildReceiptPreviewSection(),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: _buildSaveButton(settings),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                      return content;
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

  Widget _buildSaveButton(AppSettings settings) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: kAccent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusButton)),
      ),
      onPressed: () async {
        if (_formKey.currentState?.validate() ?? false) {
          final updated = settings.copyWith(
            restaurantName: _nameController.text.trim(),
            address: _addressController.text.trim(),
            phone: _phoneController.text.trim(),
            gstin: _gstinController.text.trim(),
            cgstRate: double.tryParse(_cgstController.text) ?? settings.cgstRate,
            sgstRate: double.tryParse(_sgstController.text) ?? settings.sgstRate,
            serviceChargeRate: double.tryParse(_serviceChargeController.text) ?? settings.serviceChargeRate,
            serviceChargeEnabled: _serviceChargeEnabled,
            receiptTemplate: _receiptTemplate,
          );
          await ref.read(settingsNotifierProvider.notifier).updateSettings(updated);
          if (mounted) {
            CustomSnackBar.showSuccess(context, 'Settings saved successfully!');
          }
        }
      },
      child: Text('Save Settings', style: kTitle.copyWith(color: Colors.black)),
    );
  }

  Widget _buildFormContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Business Information'),
        const SizedBox(height: 12),
        _buildCard([
          TextFormField(
            controller: _nameController,
            style: kBody,
            decoration: InputDecoration(labelText: 'Restaurant Name', labelStyle: kCaption),
            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            style: kBody,
            maxLines: 2,
            decoration: InputDecoration(labelText: 'Business Address', labelStyle: kCaption),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  style: kBody,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: 'Phone Number', labelStyle: kCaption),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _gstinController,
                  style: kBody,
                  decoration: InputDecoration(labelText: 'GSTIN', labelStyle: kCaption),
                ),
              ),
            ],
          ),
        ]),
        const SizedBox(height: 24),
        _buildSectionHeader('Taxation & Service Charges'),
        const SizedBox(height: 12),
        _buildCard([
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cgstController,
                  style: kBody,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'CGST (%)', labelStyle: kCaption),
                  validator: (val) => double.tryParse(val ?? '') == null ? 'Invalid' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _sgstController,
                  style: kBody,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'SGST (%)', labelStyle: kCaption),
                  validator: (val) => double.tryParse(val ?? '') == null ? 'Invalid' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _serviceChargeController,
                  enabled: _serviceChargeEnabled,
                  style: kBody,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'Service Charge (%)', labelStyle: kCaption),
                  validator: (val) => double.tryParse(val ?? '') == null ? 'Invalid' : null,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Service Charge', style: kCaption),
                  Row(
                    children: [
                      Switch(
                        value: _serviceChargeEnabled,
                        activeColor: kSuccess,
                        onChanged: (val) => setState(() => _serviceChargeEnabled = val),
                      ),
                      Text(_serviceChargeEnabled ? 'ON' : 'OFF', style: kCaption.copyWith(color: _serviceChargeEnabled ? kSuccess : kTextSecondary)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ]),
      ],
    );
  }

  Widget _buildReceiptPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Receipt Styling'),
        const SizedBox(height: 12),
        _buildCard([
          Text('Select Receipt Template', style: kBody.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTemplateRadio(1, 'Compact'),
              const SizedBox(width: 16),
              _buildTemplateRadio(2, 'Detailed (GST)'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.circular(kRadiusCard),
              border: Border.all(color: kDivider, width: 1),
            ),
            child: Column(
              children: [
                Text(
                  _nameController.text.isEmpty ? 'RESTAURANT NAME' : _nameController.text.toUpperCase(),
                  style: const TextStyle(fontFamily: 'monospace', color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  _addressController.text.isEmpty ? '123 Main St, City' : _addressController.text,
                  style: const TextStyle(fontFamily: 'monospace', color: kTextSecondary, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
                if (_phoneController.text.isNotEmpty)
                  Text(
                    'Ph: ${_phoneController.text}',
                    style: const TextStyle(fontFamily: 'monospace', color: kTextSecondary, fontSize: 10),
                  ),
                const Divider(color: kTextSecondary, thickness: 1, height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1x Paneer Butter Masala', style: TextStyle(fontFamily: 'monospace', color: Colors.white, fontSize: 11)),
                    Text('320.00', style: TextStyle(fontFamily: 'monospace', color: Colors.white, fontSize: 11)),
                  ],
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('2x Garlic Naan', style: TextStyle(fontFamily: 'monospace', color: Colors.white, fontSize: 11)),
                    Text('120.00', style: TextStyle(fontFamily: 'monospace', color: Colors.white, fontSize: 11)),
                  ],
                ),
                const Divider(color: kTextSecondary, thickness: 1, height: 16),
                if (_receiptTemplate == 2) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal', style: TextStyle(fontFamily: 'monospace', color: kTextSecondary, fontSize: 10)),
                      Text((440.00).toStringAsFixed(2), style: const TextStyle(fontFamily: 'monospace', color: kTextSecondary, fontSize: 10)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('CGST (${_cgstController.text}%)', style: const TextStyle(fontFamily: 'monospace', color: kTextSecondary, fontSize: 10)),
                      Text((440 * (double.tryParse(_cgstController.text) ?? 2.5) / 100).toStringAsFixed(2), style: const TextStyle(fontFamily: 'monospace', color: kTextSecondary, fontSize: 10)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SGST (${_sgstController.text}%)', style: const TextStyle(fontFamily: 'monospace', color: kTextSecondary, fontSize: 10)),
                      Text((440 * (double.tryParse(_sgstController.text) ?? 2.5) / 100).toStringAsFixed(2), style: const TextStyle(fontFamily: 'monospace', color: kTextSecondary, fontSize: 10)),
                    ],
                  ),
                  if (_serviceChargeEnabled)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Service Charge (${_serviceChargeController.text}%)', style: const TextStyle(fontFamily: 'monospace', color: kTextSecondary, fontSize: 10)),
                        Text((440 * (double.tryParse(_serviceChargeController.text) ?? 5.0) / 100).toStringAsFixed(2), style: const TextStyle(fontFamily: 'monospace', color: kTextSecondary, fontSize: 10)),
                      ],
                    ),
                ],
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('GRAND TOTAL', style: TextStyle(fontFamily: 'monospace', color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(
                      _calculateGrandTotalMock().toStringAsFixed(2),
                      style: const TextStyle(fontFamily: 'monospace', color: kAccent, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(color: kTextSecondary, thickness: 1, height: 16),
                const Text('Thank you! Visit again.', style: TextStyle(fontFamily: 'monospace', color: kTextSecondary, fontSize: 10)),
              ],
            ),
          ),
        ]),
      ],
    );
  }

  double _calculateGrandTotalMock() {
    double sub = 440.0;
    double cgst = sub * (double.tryParse(_cgstController.text) ?? 2.5) / 100.0;
    double sgst = sub * (double.tryParse(_sgstController.text) ?? 2.5) / 100.0;
    double sc = _serviceChargeEnabled ? sub * (double.tryParse(_serviceChargeController.text) ?? 5.0) / 100.0 : 0.0;
    return sub + cgst + sgst + sc;
  }

  Widget _buildTemplateRadio(int val, String title) {
    return GestureDetector(
      onTap: () => setState(() => _receiptTemplate = val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _receiptTemplate == val ? kAccent.withOpacity(0.12) : kBg,
          borderRadius: BorderRadius.circular(kRadiusCard),
          border: Border.all(color: _receiptTemplate == val ? kAccent : kDivider, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(
              _receiptTemplate == val ? Icons.radio_button_checked : Icons.radio_button_off,
              color: _receiptTemplate == val ? kAccent : kTextSecondary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(title, style: kCaption.copyWith(color: _receiptTemplate == val ? kTextPrimary : kTextSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: kHeadline.copyWith(fontSize: 18, color: kAccent),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildNonAdminProfileCard(AuthState authState) {
    final name = authState.profile?.name ?? 'Staff Member';
    final email = authState.profile?.email ?? 'N/A';
    final role = authState.role.toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: kAccent.withValues(alpha: 0.15),
            child: Text(
              name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'S',
              style: kHeadline.copyWith(fontSize: 24, color: kAccent),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: kTitle.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(email, style: kBody.copyWith(color: kTextSecondary)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kSurface2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    role,
                    style: kCaption.copyWith(color: kAccent, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Information', style: kTitle.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildInfoRow('App Version', '1.0.0'),
          const Divider(color: kDivider, height: 16),
          _buildInfoRow('Mode', 'ROYAL FF - Connected'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: kCaption),
        Text(value, style: kBody.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
