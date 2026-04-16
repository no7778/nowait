import 'api_client.dart';

class PromotionService {
  static final PromotionService instance = PromotionService._();
  PromotionService._();

  Future<Map<String, dynamic>> createPromotion(
    String shopId, {
    required String title,
    required String description,
    required String validUntil,
  }) async {
    return await ApiClient.instance.post('/promotions/shop/$shopId', body: {
      'title': title,
      'description': description,
      'valid_until': validUntil,
    });
  }
}
