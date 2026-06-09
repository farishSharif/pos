class AppSettings {
  final String id;
  final String restaurantName;
  final String? address;
  final String? phone;
  final String? gstin;
  final double cgstRate;
  final double sgstRate;
  final double serviceChargeRate;
  final bool serviceChargeEnabled;
  final String currencySymbol;
  final int receiptTemplate;
  final String? logoUrl;
  final String? updatedAt;

  AppSettings({
    required this.id,
    required this.restaurantName,
    this.address,
    this.phone,
    this.gstin,
    required this.cgstRate,
    required this.sgstRate,
    required this.serviceChargeRate,
    required this.serviceChargeEnabled,
    required this.currencySymbol,
    required this.receiptTemplate,
    this.logoUrl,
    this.updatedAt,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      id: json['id'] as String,
      restaurantName: json['restaurant_name'] as String? ?? 'SAVOR Kitchen',
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      gstin: json['gstin'] as String?,
      cgstRate: (json['cgst_rate'] as num? ?? 2.5).toDouble(),
      sgstRate: (json['sgst_rate'] as num? ?? 2.5).toDouble(),
      serviceChargeRate: (json['service_charge_rate'] as num? ?? 5.0).toDouble(),
      serviceChargeEnabled: json['service_charge_enabled'] as bool? ?? true,
      currencySymbol: json['currency_symbol'] as String? ?? '₹',
      receiptTemplate: json['receipt_template'] as int? ?? 1,
      logoUrl: json['logo_url'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_name': restaurantName,
      'address': address,
      'phone': phone,
      'gstin': gstin,
      'cgst_rate': cgstRate,
      'sgst_rate': sgstRate,
      'service_charge_rate': serviceChargeRate,
      'service_charge_enabled': serviceChargeEnabled,
      'currency_symbol': currencySymbol,
      'receipt_template': receiptTemplate,
      'logo_url': logoUrl,
      'updated_at': updatedAt,
    };
  }

  AppSettings copyWith({
    String? id,
    String? restaurantName,
    String? address,
    String? phone,
    String? gstin,
    double? cgstRate,
    double? sgstRate,
    double? serviceChargeRate,
    bool? serviceChargeEnabled,
    String? currencySymbol,
    int? receiptTemplate,
    String? logoUrl,
    String? updatedAt,
  }) {
    return AppSettings(
      id: id ?? this.id,
      restaurantName: restaurantName ?? this.restaurantName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      gstin: gstin ?? this.gstin,
      cgstRate: cgstRate ?? this.cgstRate,
      sgstRate: sgstRate ?? this.sgstRate,
      serviceChargeRate: serviceChargeRate ?? this.serviceChargeRate,
      serviceChargeEnabled: serviceChargeEnabled ?? this.serviceChargeEnabled,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      receiptTemplate: receiptTemplate ?? this.receiptTemplate,
      logoUrl: logoUrl ?? this.logoUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
