class TaxCalculator {
  static double calculateDiscount(double subtotal, double discountValue, bool isPercent) {
    if (isPercent) {
      return (subtotal * discountValue) / 100.0;
    }
    return discountValue;
  }

  static Map<String, double> calculate({
    required double subtotal,
    required double discount,
    required double cgstRate,
    required double sgstRate,
    required double serviceChargeRate,
    required bool serviceChargeEnabled,
  }) {
    final discountedSubtotal = subtotal - discount;
    final baseAmount = discountedSubtotal < 0 ? 0.0 : discountedSubtotal;

    final cgst = (baseAmount * cgstRate) / 100.0;
    final sgst = (baseAmount * sgstRate) / 100.0;
    final serviceCharge = serviceChargeEnabled ? (baseAmount * serviceChargeRate) / 100.0 : 0.0;
    final total = baseAmount + cgst + sgst + serviceCharge;

    return {
      'baseAmount': baseAmount,
      'cgst': cgst,
      'sgst': sgst,
      'serviceCharge': serviceCharge,
      'total': total,
    };
  }
}
