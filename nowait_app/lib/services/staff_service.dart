import '../models/models.dart';
import 'api_client.dart';

class StaffService {
  static final StaffService instance = StaffService._();
  StaffService._();

  /// Public — any authenticated user can call this to see staff for a shop (customer info view).
  Future<List<StaffMember>> getStaffForCustomers(String shopId) async {
    final res = await ApiClient.instance.get('/staff/shops/$shopId/public');
    return (res as List).map((e) => StaffMember.fromJson(e)).toList();
  }

  Future<List<StaffMember>> getStaff(String shopId) async {
    final res = await ApiClient.instance.get('/staff/shops/$shopId');
    return (res as List).map((e) => StaffMember.fromJson(e)).toList();
  }

  /// Add staff by name only — no registered phone required.
  Future<StaffMember> addStaffByName(String shopId, String name) async {
    final res = await ApiClient.instance.post('/staff/shops/$shopId/by-name', body: {'name': name});
    return StaffMember.fromJson(res);
  }

  Future<StaffMember> addStaff(String shopId, String phone) async {
    final res = await ApiClient.instance.post('/staff/shops/$shopId', body: {'phone': phone});
    return StaffMember.fromJson(res);
  }

  /// Remove staff by staff record ID (staff_members.id).
  Future<void> removeStaff(String shopId, String staffId) async {
    await ApiClient.instance.delete('/staff/shops/$shopId/$staffId');
  }

  Future<Map<String, dynamic>> selfRegisterAsStaff() async {
    return await ApiClient.instance.post('/staff/self-register');
  }

  Future<List<Map<String, dynamic>>> getMyAssignments() async {
    final res = await ApiClient.instance.get('/staff/my-assignments');
    return (res as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
