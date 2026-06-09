import 'order_item.dart';

class Order {
  final String id;
  final int? tableId;
  final String? customerName;
  final String orderType; // 'dine_in','takeaway'
  final String status; // 'draft','pending','preparing','ready','served','billed','cancelled'
  final double subtotal;
  final double cgst;
  final double sgst;
  final double serviceCharge;
  final double discount;
  final double total;
  final String? paymentMethod; // 'cash','upi','card','wallet'
  final String? couponCode;
  final String? notes;
  final String? createdBy;
  final String createdAt;
  final String updatedAt;
  final List<OrderItem> orderItems;
  final Map<String, dynamic>? tableDetails;

  Order({
    required this.id,
    this.tableId,
    this.customerName,
    required this.orderType,
    required this.status,
    required this.subtotal,
    required this.cgst,
    required this.sgst,
    required this.serviceCharge,
    required this.discount,
    required this.total,
    this.paymentMethod,
    this.couponCode,
    this.notes,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.orderItems,
    this.tableDetails,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = <OrderItem>[];
    if (json['order_items'] != null) {
      itemsList = (json['order_items'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return Order(
      id: json['id'] as String,
      tableId: json['table_id'] as int?,
      customerName: json['customer_name'] as String?,
      orderType: json['order_type'] as String? ?? 'dine_in',
      status: json['status'] as String? ?? 'pending',
      subtotal: (json['subtotal'] as num? ?? 0.0).toDouble(),
      cgst: (json['cgst'] as num? ?? 0.0).toDouble(),
      sgst: (json['sgst'] as num? ?? 0.0).toDouble(),
      serviceCharge: (json['service_charge'] as num? ?? 0.0).toDouble(),
      discount: (json['discount'] as num? ?? 0.0).toDouble(),
      total: (json['total'] as num? ?? 0.0).toDouble(),
      paymentMethod: json['payment_method'] as String?,
      couponCode: json['coupon_code'] as String?,
      notes: json['notes'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      orderItems: itemsList,
      tableDetails: json['restaurant_tables'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_id': tableId,
      'customer_name': customerName,
      'order_type': orderType,
      'status': status,
      'subtotal': subtotal,
      'cgst': cgst,
      'sgst': sgst,
      'service_charge': serviceCharge,
      'discount': discount,
      'total': total,
      'payment_method': paymentMethod,
      'coupon_code': couponCode,
      'notes': notes,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Order copyWith({
    String? id,
    int? tableId,
    String? customerName,
    String? orderType,
    String? status,
    double? subtotal,
    double? cgst,
    double? sgst,
    double? serviceCharge,
    double? discount,
    double? total,
    String? paymentMethod,
    String? couponCode,
    String? notes,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
    List<OrderItem>? orderItems,
    Map<String, dynamic>? tableDetails,
  }) {
    return Order(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      customerName: customerName ?? this.customerName,
      orderType: orderType ?? this.orderType,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      cgst: cgst ?? this.cgst,
      sgst: sgst ?? this.sgst,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      couponCode: couponCode ?? this.couponCode,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      orderItems: orderItems ?? this.orderItems,
      tableDetails: tableDetails ?? this.tableDetails,
    );
  }
}
