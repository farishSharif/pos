// seed_data.dart
import 'package:uuid/uuid.dart';

class SeedData {
  static const uuid = Uuid();

  static final List<Map<String, dynamic>> categories = [
    {'id': 'cat-1', 'name': 'Starters', 'icon': 'appetizer', 'color': '#EF4444', 'sort_order': 1, 'is_active': true},
    {'id': 'cat-2', 'name': 'Main Course', 'icon': 'restaurant', 'color': '#F59E0B', 'sort_order': 2, 'is_active': true},
    {'id': 'cat-3', 'name': 'Beverages', 'icon': 'local_cafe', 'color': '#3B82F6', 'sort_order': 3, 'is_active': true},
    {'id': 'cat-4', 'name': 'Desserts', 'icon': 'cake', 'color': '#EC4899', 'sort_order': 4, 'is_active': true},
    {'id': 'cat-5', 'name': 'Combos', 'icon': 'dining', 'color': '#22C55E', 'sort_order': 5, 'is_active': true},
  ];

  static final List<Map<String, dynamic>> menuItems = [
    {'id': 'item-1', 'category_id': 'cat-2', 'name': 'Paneer Tikka', 'description': 'Cottage cheese marinated in spices, grilled in tandoor', 'price': 280.0, 'prep_time_minutes': 20, 'image_url': null, 'is_available': true},
    {'id': 'item-2', 'category_id': 'cat-1', 'name': 'Veg Spring Rolls', 'description': 'Crispy rolls with mixed vegetable filling', 'price': 160.0, 'prep_time_minutes': 15, 'image_url': null, 'is_available': true},
    {'id': 'item-3', 'category_id': 'cat-1', 'name': 'Chicken Seekh', 'description': 'Minced chicken kebab with herbs and spices', 'price': 240.0, 'prep_time_minutes': 18, 'image_url': null, 'is_available': true},
    {'id': 'item-4', 'category_id': 'cat-1', 'name': 'Samosa (2 pcs)', 'description': 'Fried pastry with spiced potato filling, chutneys', 'price': 80.0, 'prep_time_minutes': 10, 'image_url': null, 'is_available': true},
    {'id': 'item-5', 'category_id': 'cat-2', 'name': 'Dal Makhani', 'description': 'Slow-cooked black lentils in butter and cream', 'price': 220.0, 'prep_time_minutes': 25, 'image_url': null, 'is_available': true},
    {'id': 'item-6', 'category_id': 'cat-2', 'name': 'Butter Chicken', 'description': 'Tender chicken in rich tomato-cream gravy', 'price': 350.0, 'prep_time_minutes': 20, 'image_url': null, 'is_available': true},
    {'id': 'item-7', 'category_id': 'cat-2', 'name': 'Chicken Biryani', 'description': 'Aromatic basmati rice with spiced chicken', 'price': 380.0, 'prep_time_minutes': 30, 'image_url': null, 'is_available': true},
    {'id': 'item-8', 'category_id': 'cat-5', 'name': 'Veg Thali', 'description': 'Dal, sabzi, roti, rice, pickle, papad', 'price': 250.0, 'prep_time_minutes': 20, 'image_url': null, 'is_available': true},
    {'id': 'item-9', 'category_id': 'cat-2', 'name': 'Paneer Butter Masala', 'description': 'Paneer cubes in spiced tomato-butter gravy', 'price': 280.0, 'prep_time_minutes': 18, 'image_url': null, 'is_available': true},
    {'id': 'item-10', 'category_id': 'cat-2', 'name': 'Garlic Naan', 'description': 'Soft leavened bread with garlic butter', 'price': 60.0, 'prep_time_minutes': 10, 'image_url': null, 'is_available': true},
    {'id': 'item-11', 'category_id': 'cat-2', 'name': 'Biryani (Veg)', 'description': 'Fragrant basmati with mixed vegetables and saffron', 'price': 300.0, 'prep_time_minutes': 30, 'image_url': null, 'is_available': true},
    {'id': 'item-12', 'category_id': 'cat-2', 'name': 'Pasta Arrabiata', 'description': 'Penne in spicy tomato sauce with herbs', 'price': 240.0, 'prep_time_minutes': 20, 'image_url': null, 'is_available': true},
    {'id': 'item-13', 'category_id': 'cat-3', 'name': 'Masala Chai', 'description': 'Indian spiced tea with ginger and cardamom', 'price': 60.0, 'prep_time_minutes': 5, 'image_url': null, 'is_available': true},
    {'id': 'item-14', 'category_id': 'cat-3', 'name': 'Mango Lassi', 'description': 'Chilled yoghurt drink with Alphonso mango pulp', 'price': 120.0, 'prep_time_minutes': 5, 'image_url': null, 'is_available': true},
    {'id': 'item-15', 'category_id': 'cat-3', 'name': 'Cold Coffee', 'description': 'Blended coffee with milk and ice cream', 'price': 140.0, 'prep_time_minutes': 5, 'image_url': null, 'is_available': true},
    {'id': 'item-16', 'category_id': 'cat-3', 'name': 'Fresh Lime Soda', 'description': 'Sweet or salted with fresh lime', 'price': 80.0, 'prep_time_minutes': 3, 'image_url': null, 'is_available': true},
    {'id': 'item-17', 'category_id': 'cat-4', 'name': 'Gulab Jamun', 'description': 'Soft milk-solid dumplings in rose sugar syrup', 'price': 120.0, 'prep_time_minutes': 5, 'image_url': null, 'is_available': true},
    {'id': 'item-18', 'category_id': 'cat-4', 'name': 'Rasgulla', 'description': 'Spongy cottage cheese balls in light sugar syrup', 'price': 110.0, 'prep_time_minutes': 5, 'image_url': null, 'is_available': true},
    {'id': 'item-19', 'category_id': 'cat-4', 'name': 'Brownie with Ice Cream', 'description': 'Warm chocolate brownie, vanilla scoop, chocolate drizzle', 'price': 180.0, 'prep_time_minutes': 8, 'image_url': null, 'is_available': true},
    {'id': 'item-20', 'category_id': 'cat-4', 'name': 'Kulfi Falooda', 'description': 'Traditional Indian ice cream with vermicelli and rose syrup', 'price': 160.0, 'prep_time_minutes': 5, 'image_url': null, 'is_available': true},
    {'id': 'item-21', 'category_id': 'cat-5', 'name': 'Meal for 2', 'description': 'Butter Chicken + Naan x2 + Dal + Rice + Dessert', 'price': 650.0, 'prep_time_minutes': 30, 'image_url': null, 'is_available': true},
    {'id': 'item-22', 'category_id': 'cat-5', 'name': 'Veg Combo', 'description': 'Paneer Masala + Naan x2 + Dal + Rice', 'price': 520.0, 'prep_time_minutes': 25, 'image_url': null, 'is_available': true},
    {'id': 'item-23', 'category_id': 'cat-5', 'name': 'Starter Platter', 'description': 'Paneer Tikka + Seekh Kebab + Spring Rolls for 4', 'price': 680.0, 'prep_time_minutes': 25, 'image_url': null, 'is_available': true},
    {'id': 'item-24', 'category_id': 'cat-5', 'name': 'Sunday Brunch', 'description': 'Idli x4 + Vada x2 + Dosa + Sambhar + Chutney', 'price': 320.0, 'prep_time_minutes': 20, 'image_url': null, 'is_available': true},
    {'id': 'item-25', 'category_id': 'cat-5', 'name': 'Kids Meal', 'description': 'Mini Pizza / Pasta + Juice + Ice Cream', 'price': 280.0, 'prep_time_minutes': 15, 'image_url': null, 'is_available': true},
  ];

  static final List<Map<String, dynamic>> restaurantTables = [
    {'id': 1, 'table_number': 1, 'capacity': 2, 'status': 'occupied', 'current_order_id': 'order-mock-3'},
    {'id': 2, 'table_number': 2, 'capacity': 2, 'status': 'ready', 'current_order_id': 'order-mock-4'},
    {'id': 3, 'table_number': 3, 'capacity': 4, 'status': 'ordered', 'current_order_id': 'order-mock-1'},
    {'id': 4, 'table_number': 4, 'capacity': 4, 'status': 'preparing', 'current_order_id': 'order-mock-2'},
    {'id': 5, 'table_number': 5, 'capacity': 4, 'status': 'billed', 'current_order_id': 'order-mock-5'},
  ];

  static final List<Map<String, dynamic>> inventory = [
    {'id': 'inv-1', 'name': 'Basmati Rice', 'unit': 'kg', 'current_stock': 45.0, 'minimum_stock': 10.0},
    {'id': 'inv-2', 'name': 'Wheat Flour', 'unit': 'kg', 'current_stock': 30.0, 'minimum_stock': 8.0},
    {'id': 'inv-3', 'name': 'Cooking Oil', 'unit': 'litre', 'current_stock': 18.0, 'minimum_stock': 5.0},
    {'id': 'inv-4', 'name': 'Milk', 'unit': 'litre', 'current_stock': 12.0, 'minimum_stock': 6.0},
    {'id': 'inv-5', 'name': 'Butter', 'unit': 'kg', 'current_stock': 4.0, 'minimum_stock': 2.0},
    {'id': 'inv-6', 'name': 'Cream', 'unit': 'litre', 'current_stock': 3.0, 'minimum_stock': 2.0},
    {'id': 'inv-7', 'name': 'Tomatoes', 'unit': 'kg', 'current_stock': 8.0, 'minimum_stock': 3.0},
    {'id': 'inv-8', 'name': 'Onions', 'unit': 'kg', 'current_stock': 15.0, 'minimum_stock': 5.0},
    {'id': 'inv-9', 'name': 'Garlic', 'unit': 'kg', 'current_stock': 2.0, 'minimum_stock': 1.0},
    {'id': 'inv-10', 'name': 'Ginger', 'unit': 'kg', 'current_stock': 1.5, 'minimum_stock': 0.5},
    {'id': 'inv-11', 'name': 'Paneer', 'unit': 'kg', 'current_stock': 6.0, 'minimum_stock': 2.0},
    {'id': 'inv-12', 'name': 'Chicken', 'unit': 'kg', 'current_stock': 12.0, 'minimum_stock': 4.0},
    {'id': 'inv-13', 'name': 'Cumin Seeds', 'unit': 'kg', 'current_stock': 0.8, 'minimum_stock': 0.3},
    {'id': 'inv-14', 'name': 'Garam Masala', 'unit': 'kg', 'current_stock': 0.5, 'minimum_stock': 0.2},
    {'id': 'inv-15', 'name': 'Turmeric', 'unit': 'kg', 'current_stock': 0.4, 'minimum_stock': 0.2},
    {'id': 'inv-16', 'name': 'Cardamom', 'unit': 'kg', 'current_stock': 0.2, 'minimum_stock': 0.1},
    {'id': 'inv-17', 'name': 'Sugar', 'unit': 'kg', 'current_stock': 10.0, 'minimum_stock': 3.0},
    {'id': 'inv-18', 'name': 'Salt', 'unit': 'kg', 'current_stock': 5.0, 'minimum_stock': 2.0},
    {'id': 'inv-19', 'name': 'Saffron', 'unit': 'g', 'current_stock': 20.0, 'minimum_stock': 10.0},
    {'id': 'inv-20', 'name': 'Rose Water', 'unit': 'litre', 'current_stock': 1.0, 'minimum_stock': 0.5},
  ];

  static final List<Map<String, dynamic>> purchaseRecords = [
    {'id': 'pr-1', 'inventory_id': 'inv-1', 'quantity': 25.0, 'supplier': 'Annapurna Traders', 'cost': 1850.0, 'purchased_at': '2026-06-05T10:30:00Z'},
    {'id': 'pr-2', 'inventory_id': 'inv-5', 'quantity': 2.0, 'supplier': 'Dairy Land', 'cost': 900.0, 'purchased_at': '2026-06-07T08:15:00Z'},
    {'id': 'pr-3', 'inventory_id': 'inv-12', 'quantity': 10.0, 'supplier': 'Fresh Cuts', 'cost': 2200.0, 'purchased_at': '2026-06-08T09:00:00Z'},
  ];

  static final List<Map<String, dynamic>> coupons = [
    {'id': 'c-1', 'code': 'SAVOR10', 'discount_type': 'percent', 'discount_value': 10.0, 'min_order_value': 300.0, 'max_uses': 100, 'used_count': 12, 'is_active': true, 'expires_at': '2026-12-31T23:59:59Z'},
    {'id': 'c-2', 'code': 'FLAT50', 'discount_type': 'flat', 'discount_value': 50.0, 'min_order_value': 500.0, 'max_uses': 100, 'used_count': 4, 'is_active': true, 'expires_at': '2026-12-31T23:59:59Z'},
    {'id': 'c-3', 'code': 'WELCOME20', 'discount_type': 'percent', 'discount_value': 20.0, 'min_order_value': 200.0, 'max_uses': 100, 'used_count': 99, 'is_active': true, 'expires_at': '2026-06-30T23:59:59Z'},
  ];

  static final Map<String, dynamic> appSettings = {
    'id': 'settings-1',
    'restaurant_name': 'SAVOR Kitchen',
    'address': '12, Brigade Road, Bengaluru – 560001',
    'phone': '+91 98765 43210',
    'gstin': '29ABCDE1234F1Z5',
    'cgst_rate': 2.5,
    'sgst_rate': 2.5,
    'service_charge_rate': 5.0,
    'service_charge_enabled': true,
    'currency_symbol': '₹',
    'receipt_template': 1,
    'logo_url': null,
  };

  static final List<Map<String, dynamic>> profiles = [
    {'id': 'admin-id', 'name': 'Aditya Sen', 'role': 'admin', 'phone': '+91 90000 11111', 'email': 'admin@savor.pos', 'shift_start': '08:00:00', 'shift_end': '18:00:00', 'avatar_url': null, 'is_active': true},
    {'id': 'cashier-id', 'name': 'Pooja Roy', 'role': 'cashier', 'phone': '+91 90000 22222', 'email': 'cashier@savor.pos', 'shift_start': '09:00:00', 'shift_end': '19:00:00', 'avatar_url': null, 'is_active': true},
    {'id': 'waiter-id', 'name': 'Rohan Das', 'role': 'waiter', 'phone': '+91 90000 33333', 'email': 'waiter@savor.pos', 'shift_start': '10:00:00', 'shift_end': '22:00:00', 'avatar_url': null, 'is_active': true},
    {'id': 'kitchen-id', 'name': 'Chef Kabir', 'role': 'kitchen', 'phone': '+91 90000 44444', 'email': 'kitchen@savor.pos', 'shift_start': '11:00:00', 'shift_end': '23:00:00', 'avatar_url': null, 'is_active': true},
  ];

  static final List<Map<String, dynamic>> orders = [
    {
      'id': 'order-mock-1',
      'table_id': 3,
      'customer_name': 'Sarah Connor',
      'order_type': 'dine_in',
      'status': 'pending',
      'subtotal': 440.0,
      'cgst': 11.0,
      'sgst': 11.0,
      'service_charge': 22.0,
      'discount': 0.0,
      'total': 484.0,
      'payment_method': null,
      'coupon_code': null,
      'notes': 'No spicy for starters',
      'created_by': 'waiter-id',
      'created_at': DateTime.now().subtract(const Duration(minutes: 4)).toIso8601String(),
    },
    {
      'id': 'order-mock-2',
      'table_id': 4,
      'customer_name': 'Tony Stark',
      'order_type': 'dine_in',
      'status': 'preparing',
      'subtotal': 630.0,
      'cgst': 15.75,
      'sgst': 15.75,
      'service_charge': 31.5,
      'discount': 50.0,
      'total': 643.0,
      'payment_method': null,
      'coupon_code': 'FLAT50',
      'notes': 'Extra butter on Naan',
      'created_by': 'waiter-id',
      'created_at': DateTime.now().subtract(const Duration(minutes: 8)).toIso8601String(),
    },
    {
      'id': 'order-mock-3',
      'table_id': 1,
      'customer_name': 'Bruce Wayne',
      'order_type': 'dine_in',
      'status': 'preparing',
      'subtotal': 1300.0,
      'cgst': 32.5,
      'sgst': 32.5,
      'service_charge': 65.0,
      'discount': 130.0,
      'total': 1300.0,
      'payment_method': null,
      'coupon_code': 'SAVOR10',
      'notes': 'Make it fast',
      'created_by': 'waiter-id',
      'created_at': DateTime.now().subtract(const Duration(minutes: 12)).toIso8601String(),
    },
    {
      'id': 'order-mock-4',
      'table_id': 2,
      'customer_name': 'Peter Parker',
      'order_type': 'dine_in',
      'status': 'ready',
      'subtotal': 220.0,
      'cgst': 5.5,
      'sgst': 5.5,
      'service_charge': 11.0,
      'discount': 0.0,
      'total': 242.0,
      'payment_method': null,
      'coupon_code': null,
      'notes': 'Deliver fresh lassi at the end',
      'created_by': 'waiter-id',
      'created_at': DateTime.now().subtract(const Duration(minutes: 2)).toIso8601String(),
    },
    {
      'id': 'order-mock-5',
      'table_id': 5,
      'customer_name': 'Clark Kent',
      'order_type': 'dine_in',
      'status': 'billed',
      'subtotal': 560.0,
      'cgst': 14.0,
      'sgst': 14.0,
      'service_charge': 28.0,
      'discount': 0.0,
      'total': 616.0,
      'payment_method': 'card',
      'coupon_code': null,
      'notes': '',
      'created_by': 'waiter-id',
      'created_at': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
    },
  ];

  static final List<Map<String, dynamic>> orderItems = [
    // Order 1 items
    {'id': 'oi-1', 'order_id': 'order-mock-1', 'menu_item_id': 'item-2', 'name': 'Veg Spring Rolls', 'price': 160.0, 'quantity': 1, 'notes': '', 'status': 'pending'},
    {'id': 'oi-2', 'order_id': 'order-mock-1', 'menu_item_id': 'item-1', 'name': 'Paneer Tikka', 'price': 280.0, 'quantity': 1, 'notes': 'Less spicy', 'status': 'pending'},
    
    // Order 2 items
    {'id': 'oi-3', 'order_id': 'order-mock-2', 'menu_item_id': 'item-6', 'name': 'Butter Chicken', 'price': 350.0, 'quantity': 1, 'notes': '', 'status': 'preparing'},
    {'id': 'oi-4', 'order_id': 'order-mock-2', 'menu_item_id': 'item-10', 'name': 'Garlic Naan', 'price': 60.0, 'quantity': 3, 'notes': 'Extra butter', 'status': 'preparing'},
    {'id': 'oi-5', 'order_id': 'order-mock-2', 'menu_item_id': 'item-14', 'name': 'Mango Lassi', 'price': 120.0, 'quantity': 1, 'notes': '', 'status': 'ready'},

    // Order 3 items
    {'id': 'oi-6', 'order_id': 'order-mock-3', 'menu_item_id': 'item-21', 'name': 'Meal for 2', 'price': 650.0, 'quantity': 2, 'notes': '', 'status': 'preparing'},

    // Order 4 items
    {'id': 'oi-7', 'order_id': 'order-mock-4', 'menu_item_id': 'item-5', 'name': 'Dal Makhani', 'price': 220.0, 'quantity': 1, 'notes': '', 'status': 'ready'},

    // Order 5 items (billed)
    {'id': 'oi-8', 'order_id': 'order-mock-5', 'menu_item_id': 'item-9', 'name': 'Paneer Butter Masala', 'price': 280.0, 'quantity': 2, 'notes': '', 'status': 'served'},
  ];

  static final List<Map<String, dynamic>> notifications = [
    {'id': 'n-1', 'title': 'Low Stock Alert', 'body': 'Milk stock is low (12 litre left). Minimum is 6 litre.', 'type': 'low_stock', 'target_role': 'admin', 'is_read': false, 'created_at': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String()},
    {'id': 'n-2', 'title': 'Order Ready', 'body': 'Order #4 is ready for Table 7.', 'type': 'order_ready', 'target_role': 'waiter', 'is_read': false, 'created_at': DateTime.now().subtract(const Duration(minutes: 2)).toIso8601String()},
    {'id': 'n-3', 'title': 'Payment Confirmed', 'body': 'Payment of ₹616 received for Table 9.', 'type': 'payment', 'target_role': 'cashier', 'is_read': false, 'created_at': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String()},
  ];
}
