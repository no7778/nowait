import '../models/models.dart';
import 'api_client.dart';

class AnalyticsService {
  static final AnalyticsService instance = AnalyticsService._();
  AnalyticsService._();

  Future<AnalyticsSummary> getSummary(String shopId, {String period = 'today'}) async {
    final res = await ApiClient.instance.get(
      '/analytics/shops/$shopId/summary',
      query: {'period': period},
    );
    return AnalyticsSummary.fromJson(res);
  }

  Future<List<Map<String, dynamic>>> getHourlyStats(String shopId, {int days = 7}) async {
    final res = await ApiClient.instance.get(
      '/analytics/shops/$shopId/hourly',
      query: {'days': days.toString()},
    );
    return (res as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<Map<String, dynamic>>> getStaffPerformance(String shopId) async {
    final res = await ApiClient.instance.get('/analytics/shops/$shopId/staff');
    return (res as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
