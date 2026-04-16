import 'package:flutter_test/flutter_test.dart';
import 'package:nowait_app/models/models.dart';

void main() {
  // ── ShopModel ──────────────────────────────────────────────────────────────

  group('ShopModel', () {
    Map<String, dynamic> baseShopJson() => {
          'id': 'shop-001',
          'name': 'Raj Hair Salon',
          'category': 'Salon',
          'address': '123 MG Road',
          'city': 'Pune',
          'rating': 4.2,
          'is_open': true,
          'queue_count': 5,
          'now_serving_token': 3,
          'avg_wait_minutes': 10,
          'images': <String>[],
          'description': 'Test salon',
          'is_promoted': false,
          'has_active_subscription': true,
          'active_promotions': <dynamic>[],
          'queue_paused': false,
          'max_queue_size': null,
        };

    test('parses all basic fields correctly', () {
      final shop = ShopModel.fromJson(baseShopJson());
      expect(shop.id, 'shop-001');
      expect(shop.name, 'Raj Hair Salon');
      expect(shop.city, 'Pune');
      expect(shop.rating, 4.2);
      expect(shop.isOpen, isTrue);
      expect(shop.queueCount, 5);
      expect(shop.currentToken, 3);
      expect(shop.avgWaitMinutes, 10);
      expect(shop.hasActiveSubscription, isTrue);
      expect(shop.queuePaused, isFalse);
    });

    test('canAcceptQueue is true when open, subscribed, and not paused', () {
      final shop = ShopModel.fromJson(baseShopJson());
      expect(shop.canAcceptQueue, isTrue);
    });

    test('canAcceptQueue is false when shop is closed', () {
      final json = {...baseShopJson(), 'is_open': false};
      final shop = ShopModel.fromJson(json);
      expect(shop.canAcceptQueue, isFalse);
    });

    test('canAcceptQueue is false when no active subscription', () {
      final json = {...baseShopJson(), 'has_active_subscription': false};
      final shop = ShopModel.fromJson(json);
      expect(shop.canAcceptQueue, isFalse);
    });

    test('canAcceptQueue is false when queue is paused', () {
      final json = {...baseShopJson(), 'queue_paused': true};
      final shop = ShopModel.fromJson(json);
      expect(shop.canAcceptQueue, isFalse);
    });

    test('canAcceptQueue is false when paused AND closed', () {
      final json = {...baseShopJson(), 'is_open': false, 'queue_paused': true};
      final shop = ShopModel.fromJson(json);
      expect(shop.canAcceptQueue, isFalse);
    });

    test('handles null now_serving_token as 0', () {
      final json = {...baseShopJson(), 'now_serving_token': null};
      final shop = ShopModel.fromJson(json);
      expect(shop.currentToken, 0);
    });

    test('handles missing rating gracefully (defaults to 0.0)', () {
      final json = Map<String, dynamic>.from(baseShopJson())..remove('rating');
      final shop = ShopModel.fromJson(json);
      expect(shop.rating, 0.0);
    });

    test('parses is_promoted flag', () {
      final json = {...baseShopJson(), 'is_promoted': true};
      final shop = ShopModel.fromJson(json);
      expect(shop.isPromoted, isTrue);
    });

    test('extracts activeScheme from non-featured promotions', () {
      final json = {
        ...baseShopJson(),
        'active_promotions': [
          {
            'id': 'promo-001',
            'title': '20% Off Haircut',
            'description': 'Show this coupon',
            'valid_until': '2099-01-01T00:00:00+00:00',
            'is_active': true,
          }
        ]
      };
      final shop = ShopModel.fromJson(json);
      expect(shop.activeScheme, isNotNull);
      expect(shop.activeScheme!.title, '20% Off Haircut');
    });

    test('featured promotion does not become activeScheme', () {
      final json = {
        ...baseShopJson(),
        'active_promotions': [
          {
            'id': 'promo-001',
            'title': 'Featured Promotion',
            'description': 'Boost',
            'valid_until': '2099-01-01T00:00:00+00:00',
            'is_active': true,
          }
        ]
      };
      final shop = ShopModel.fromJson(json);
      expect(shop.activeScheme, isNull);
    });

    test('parses services list', () {
      final json = {
        ...baseShopJson(),
        'services': [
          {'id': 'svc-001', 'name': 'Haircut', 'description': 'Classic', 'price': 150.0},
        ]
      };
      final shop = ShopModel.fromJson(json);
      expect(shop.services.length, 1);
      expect(shop.services.first.name, 'Haircut');
      expect(shop.services.first.price, 150.0);
    });
  });

  // ── QueueEntry ─────────────────────────────────────────────────────────────

  group('QueueEntry', () {
    Map<String, dynamic> baseEntryJson({
      String displayStatus = 'waiting',
      int position = 5,
      int? nowServingToken,
    }) =>
        {
          'id': 'entry-001',
          'shop_id': 'shop-001',
          'shop_name': 'Raj Salon',
          'user_id': 'cust-001',
          'token_number': 10,
          'status': 'waiting',
          'display_status': displayStatus,
          'position': position,
          'people_ahead': position - 1,
          'estimated_wait_minutes': (position - 1) * 10,
          'now_serving_token': nowServingToken,
          'staff_id': null,
          'joined_at': '2024-01-01T10:00:00+00:00',
        };

    test('parses waiting status', () {
      final entry = QueueEntry.fromJson(baseEntryJson());
      expect(entry.status, QueueStatus.waiting);
      expect(entry.token, '#10');
      expect(entry.position, 5);
    });

    test('parses yourTurn status', () {
      final entry = QueueEntry.fromJson(baseEntryJson(displayStatus: 'yourTurn', position: 1));
      expect(entry.status, QueueStatus.yourTurn);
    });

    test('parses almostThere status', () {
      final entry = QueueEntry.fromJson(baseEntryJson(displayStatus: 'almostThere', position: 2));
      expect(entry.status, QueueStatus.almostThere);
    });

    test('parses skipped status', () {
      final json = {...baseEntryJson(), 'display_status': 'skipped'};
      final entry = QueueEntry.fromJson(json);
      expect(entry.status, QueueStatus.skipped);
    });

    test('parses completed status', () {
      final json = {...baseEntryJson(), 'display_status': 'completed'};
      final entry = QueueEntry.fromJson(json);
      expect(entry.status, QueueStatus.completed);
    });

    test('parses cancelled status', () {
      final json = {...baseEntryJson(), 'display_status': 'cancelled'};
      final entry = QueueEntry.fromJson(json);
      expect(entry.status, QueueStatus.cancelled);
    });

    test('handles null now_serving_token (defaults to 0)', () {
      final entry = QueueEntry.fromJson(baseEntryJson(nowServingToken: null));
      expect(entry.nowServingToken, 0);
    });

    test('handles integer now_serving_token', () {
      final entry = QueueEntry.fromJson(baseEntryJson(nowServingToken: 7));
      expect(entry.nowServingToken, 7);
    });

    test('token format is # prefixed', () {
      final entry = QueueEntry.fromJson(baseEntryJson());
      expect(entry.token.startsWith('#'), isTrue);
    });
  });

  // ── StaffMember ────────────────────────────────────────────────────────────

  group('StaffMember', () {
    Map<String, dynamic> baseStaffJson() => {
          'id': 'sm-001',
          'shop_id': 'shop-001',
          'user_id': 'user-001',
          'display_name': 'Rahul',
          'phone': '+911234567890',
          'is_owner_staff': false,
          'is_active': true,
          'avg_service_minutes': 12.5,
        };

    test('parses all fields', () {
      final sm = StaffMember.fromJson(baseStaffJson());
      expect(sm.id, 'sm-001');
      expect(sm.userId, 'user-001');
      expect(sm.displayName, 'Rahul');
      expect(sm.isOwnerStaff, isFalse);
      expect(sm.isActive, isTrue);
      expect(sm.avgServiceMinutes, 12.5);
    });

    test('falls back to name field if display_name missing', () {
      final json = {...baseStaffJson()..remove('display_name'), 'name': 'Priya'};
      final sm = StaffMember.fromJson(json);
      expect(sm.displayName, 'Priya');
    });

    test('handles missing phone (empty string)', () {
      final json = Map<String, dynamic>.from(baseStaffJson())..remove('phone');
      final sm = StaffMember.fromJson(json);
      expect(sm.phone, '');
    });

    test('handles missing avg_service_minutes as null', () {
      final json = {...baseStaffJson(), 'avg_service_minutes': null};
      final sm = StaffMember.fromJson(json);
      expect(sm.avgServiceMinutes, isNull);
    });

    test('public endpoint response (no shop_id) gives empty shopId', () {
      final publicJson = {
        'id': 'sm-001',
        'user_id': 'user-001',
        'display_name': 'Rahul',
        'is_owner_staff': false,
        'avg_service_minutes': null,
        // no shop_id, no phone, no is_active
      };
      final sm = StaffMember.fromJson(publicJson);
      expect(sm.shopId, '');
      expect(sm.phone, '');
      expect(sm.isActive, isTrue); // default
    });
  });

  // ── NotificationModel ──────────────────────────────────────────────────────

  group('NotificationModel', () {
    Map<String, dynamic> baseNotifJson(String type) => {
          'id': 'notif-001',
          'type': type,
          'title': 'Test Title',
          'body': 'Test body',
          'shop_name': 'Raj Salon',
          'is_read': false,
          'created_at': '2024-01-01T10:00:00+00:00',
        };

    test('parses your_turn type', () {
      final n = NotificationModel.fromJson(baseNotifJson('your_turn'));
      expect(n.type, NotificationType.yourTurn);
    });

    test('parses almost_there type', () {
      final n = NotificationModel.fromJson(baseNotifJson('almost_there'));
      expect(n.type, NotificationType.almostThere);
    });

    test('parses skipped type', () {
      final n = NotificationModel.fromJson(baseNotifJson('skipped'));
      expect(n.type, NotificationType.skipped);
    });

    test('parses coming type', () {
      final n = NotificationModel.fromJson(baseNotifJson('coming'));
      expect(n.type, NotificationType.coming);
    });

    test('parses promotion type', () {
      final n = NotificationModel.fromJson(baseNotifJson('promotion'));
      expect(n.type, NotificationType.promotion);
    });

    test('unknown type defaults to yourTurn', () {
      final n = NotificationModel.fromJson(baseNotifJson('unknown_type'));
      expect(n.type, NotificationType.yourTurn);
    });

    test('parses is_read flag', () {
      final json = {...baseNotifJson('your_turn'), 'is_read': true};
      final n = NotificationModel.fromJson(json);
      expect(n.isRead, isTrue);
    });

    test('parses created_at as DateTime', () {
      final n = NotificationModel.fromJson(baseNotifJson('your_turn'));
      expect(n.time.year, 2024);
    });
  });

  // ── UserModel ──────────────────────────────────────────────────────────────

  group('UserModel', () {
    test('parses customer role', () {
      final user = UserModel.fromJson({
        'id': 'u-001', 'name': 'Ravi', 'phone': '+91111', 'city': 'Pune', 'role': 'customer'
      });
      expect(user.role, UserRole.customer);
    });

    test('parses owner role', () {
      final user = UserModel.fromJson({
        'id': 'u-001', 'name': 'Raj', 'phone': '+91111', 'city': 'Mumbai', 'role': 'owner'
      });
      expect(user.role, UserRole.owner);
    });

    test('unknown role defaults to customer', () {
      final user = UserModel.fromJson({
        'id': 'u-001', 'name': 'X', 'phone': '+91111', 'city': '', 'role': 'admin'
      });
      expect(user.role, UserRole.customer);
    });
  });

  // ── AnalyticsSummary ───────────────────────────────────────────────────────

  group('AnalyticsSummary', () {
    test('parses all fields', () {
      final summary = AnalyticsSummary.fromJson({
        'period': 'today',
        'total_joined': 20,
        'total_served': 16,
        'total_cancelled': 2,
        'total_skipped': 2,
        'avg_service_minutes': 13.5,
        'cancel_rate_pct': 10.0,
        'skip_rate_pct': 10.0,
        'peak_hour': 11,
      });
      expect(summary.totalJoined, 20);
      expect(summary.totalServed, 16);
      expect(summary.avgServiceMinutes, 13.5);
      expect(summary.peakHour, 11);
    });

    test('peakHourText formats AM correctly', () {
      final summary = AnalyticsSummary.fromJson({
        'period': 'today', 'total_joined': 0, 'total_served': 0,
        'total_cancelled': 0, 'total_skipped': 0,
        'cancel_rate_pct': 0.0, 'skip_rate_pct': 0.0,
        'peak_hour': 10,
      });
      expect(summary.peakHourText, '10 AM');
    });

    test('peakHourText formats PM correctly', () {
      final summary = AnalyticsSummary.fromJson({
        'period': 'today', 'total_joined': 0, 'total_served': 0,
        'total_cancelled': 0, 'total_skipped': 0,
        'cancel_rate_pct': 0.0, 'skip_rate_pct': 0.0,
        'peak_hour': 14,
      });
      expect(summary.peakHourText, '2 PM');
    });

    test('peakHourText returns N/A when null', () {
      final summary = AnalyticsSummary.fromJson({
        'period': 'today', 'total_joined': 0, 'total_served': 0,
        'total_cancelled': 0, 'total_skipped': 0,
        'cancel_rate_pct': 0.0, 'skip_rate_pct': 0.0,
        'peak_hour': null,
      });
      expect(summary.peakHourText, 'N/A');
    });
  });

  // ── VisitHistory ───────────────────────────────────────────────────────────

  group('VisitHistory', () {
    test('parses completed status label', () {
      final h = VisitHistory.fromJson({
        'id': 'h-001', 'shop_id': 'shop-001', 'shop_name': 'Raj Salon',
        'shop_category': 'Salon', 'shop_city': 'Pune',
        'token_number': 5, 'status': 'completed',
        'service_name': 'Haircut', 'joined_at': '2024-01-01T10:00:00+00:00',
        'served_at': '2024-01-01T10:15:00+00:00', 'actual_service_minutes': 15,
      });
      expect(h.statusLabel, 'Served');
      expect(h.serviceName, 'Haircut');
      expect(h.actualServiceMinutes, 15);
    });

    test('parses skipped status label', () {
      final h = VisitHistory.fromJson({
        'id': 'h-001', 'shop_id': 'shop-001', 'shop_name': 'S',
        'shop_category': 'C', 'shop_city': 'C',
        'token_number': 3, 'status': 'skipped',
        'joined_at': '2024-01-01T10:00:00+00:00',
      });
      expect(h.statusLabel, 'Skipped');
    });

    test('parses cancelled status label', () {
      final h = VisitHistory.fromJson({
        'id': 'h-001', 'shop_id': 'shop-001', 'shop_name': 'S',
        'shop_category': 'C', 'shop_city': 'C',
        'token_number': 2, 'status': 'cancelled',
        'joined_at': '2024-01-01T10:00:00+00:00',
      });
      expect(h.statusLabel, 'Cancelled');
    });

    test('handles null served_at', () {
      final h = VisitHistory.fromJson({
        'id': 'h-001', 'shop_id': 'shop-001', 'shop_name': 'S',
        'shop_category': 'C', 'shop_city': 'C',
        'token_number': 1, 'status': 'cancelled',
        'joined_at': '2024-01-01T10:00:00+00:00',
        'served_at': null,
      });
      expect(h.servedAt, isNull);
    });
  });

  // ── SchemeModel ────────────────────────────────────────────────────────────

  group('SchemeModel', () {
    test('isActive returns true for future date', () {
      final scheme = SchemeModel.fromJson({
        'id': 'promo-001',
        'title': 'Buy 2 Get 1',
        'description': 'Offer',
        'valid_until': '2099-01-01T00:00:00+00:00',
      });
      expect(scheme.isActive, isTrue);
    });

    test('isActive returns false for past date', () {
      final scheme = SchemeModel.fromJson({
        'id': 'promo-001',
        'title': 'Old Offer',
        'description': 'Expired',
        'valid_until': '2020-01-01T00:00:00+00:00',
      });
      expect(scheme.isActive, isFalse);
    });

    test('validityText shows expired for past date', () {
      final scheme = SchemeModel.fromJson({
        'id': 'promo-001',
        'title': 'Old Offer',
        'description': 'Expired',
        'valid_until': '2020-01-01T00:00:00+00:00',
      });
      expect(scheme.validityText, 'Expired');
    });
  });
}
