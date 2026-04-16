import 'api_client.dart';

class SubscriptionService {
  static final SubscriptionService instance = SubscriptionService._();
  SubscriptionService._();

  Future<Map<String, dynamic>> getSubscription(String shopId) async {
    return await ApiClient.instance.get('/subscriptions/shop/$shopId');
  }

  Future<Map<String, dynamic>> createSubscription(
    String shopId, {
    String plan = 'basic',
    int durationDays = 30,
  }) async {
    return await ApiClient.instance.post('/subscriptions/shop/$shopId', body: {
      'plan': plan,
      'duration_days': durationDays,
    });
  }

  Future<Map<String, dynamic>> cancelSubscription(String shopId) async {
    return await ApiClient.instance.delete('/subscriptions/shop/$shopId');
  }
}
