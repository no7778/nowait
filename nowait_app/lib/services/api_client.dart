import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient instance = ApiClient._();
  ApiClient._();

  Map<String, String> get _headers {
    final token = AuthService.instance.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse('${AppConfig.baseUrl}$path');
    if (query == null) return uri;
    final filtered = Map<String, String>.from(
      query.map((k, v) => MapEntry(k, v.toString())),
    )..removeWhere((_, v) => v == 'null');
    return uri.replace(queryParameters: filtered.isEmpty ? null : filtered);
  }

  static const _timeout = Duration(seconds: 30);

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final res = await http.get(_uri(path, query), headers: _headers).timeout(_timeout);
    return _handle(res);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body, Map<String, dynamic>? query}) async {
    final res = await http.post(
      _uri(path, query),
      headers: _headers,
      body: jsonEncode(body ?? {}),
    ).timeout(_timeout);
    return _handle(res);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final res = await http.put(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body ?? {}),
    ).timeout(_timeout);
    return _handle(res);
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    final res = await http.patch(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body ?? {}),
    ).timeout(_timeout);
    return _handle(res);
  }

  Future<dynamic> delete(String path) async {
    final res = await http.delete(_uri(path), headers: _headers).timeout(_timeout);
    return _handle(res);
  }

  dynamic _handle(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(utf8.decode(res.bodyBytes));
    }
    String message = 'Request failed';
    try {
      final body = jsonDecode(utf8.decode(res.bodyBytes));
      message = body['detail'] ?? message;
    } catch (_) {}
    throw ApiException(res.statusCode, message);
  }
}
