import 'api_client.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  Future<Map<String, dynamic>> getNotifications() async {
    return await ApiClient.instance.get('/notifications');
  }

  Future<void> markRead(String notificationId) async {
    await ApiClient.instance.patch('/notifications/$notificationId/read');
  }

  Future<void> markAllRead() async {
    await ApiClient.instance.patch('/notifications/read-all');
  }
}
