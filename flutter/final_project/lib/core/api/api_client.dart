import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // for debugPrint
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// 🌐 عميل الـ API - يتعامل مع كل الطلبات للـ Backend
///
/// كل الـ endpoints ترجع البيانات بهذا الشكل:
/// ```json
/// { "success": true, "data": {...}, "message": "OK" }
/// ```
class ApiClient {
  ApiClient._();
  static final instance = ApiClient._();

  static const _headers = {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
    // 🔧 FIX: explicitly tell server we want UTF-8 back
    'Accept-Charset': 'utf-8',
  };

  // ═══════════════════════════════════════════════
  // 📢 رسائل عامّة موحّدة بالعربية الفصحى
  // ═══════════════════════════════════════════════

  static const String _msgNoInternet =
      'تعذّر الاتصال بالإنترنت، يُرجى التحقّق من الاتصال والمحاولة مرّة أخرى';
  static const String _msgServerError =
      'تعذّر إتمام العملية، يُرجى المحاولة لاحقاً';

  /// طلب GET
  Future<ApiResponse> get(String endpoint) async {
    return _request(
      'GET $endpoint',
      () => http
          .get(Uri.parse('${AppConfig.baseUrl}$endpoint'), headers: _headers)
          .timeout(const Duration(seconds: AppConfig.timeoutSeconds)),
    );
  }

  /// طلب POST
  Future<ApiResponse> post(String endpoint, Map<String, dynamic> body) async {
    return _request(
      'POST $endpoint',
      () => http
          .post(
            Uri.parse('${AppConfig.baseUrl}$endpoint'),
            headers: _headers,
            // 🔧 FIX: encode the body as UTF-8 bytes explicitly. Passing a
            // String here lets `http` pick its own charset (often Latin-1),
            // which silently corrupts Arabic input on the request side too.
            body: utf8.encode(jsonEncode(body)),
          )
          .timeout(const Duration(seconds: AppConfig.timeoutSeconds)),
    );
  }

  /// طلب PUT
  Future<ApiResponse> put(String endpoint, Map<String, dynamic> body) async {
    return _request(
      'PUT $endpoint',
      () => http
          .put(
            Uri.parse('${AppConfig.baseUrl}$endpoint'),
            headers: _headers,
            body: utf8.encode(jsonEncode(body)),
          )
          .timeout(const Duration(seconds: AppConfig.timeoutSeconds)),
    );
  }

  /// تنفيذ الطلب مع معالجة الأخطاء
  Future<ApiResponse> _request(
    String label,
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request();
      return _handleResponse(label, response);
    } on SocketException catch (e) {
      debugPrint('🔴 [API] $label SocketException: $e');
      return ApiResponse.error(_msgNoInternet);
    } on HttpException catch (e) {
      debugPrint('🔴 [API] $label HttpException: $e');
      return ApiResponse.error(_msgServerError);
    } on FormatException catch (e) {
      debugPrint('🔴 [API] $label FormatException: $e');
      return ApiResponse.error(_msgServerError);
    } catch (e, st) {
      debugPrint('🔴 [API] $label unknown: $e\n$st');
      return ApiResponse.error(_msgServerError);
    }
  }

  ApiResponse _handleResponse(String label, http.Response response) {
    // 🔧 FIX: this was the actual bug. `response.body` decodes using the
    // charset declared by the server's Content-Type header. If the server
    // doesn't declare charset=utf-8, the http package falls back to Latin-1,
    // which corrupts every Arabic byte and makes jsonDecode throw —
    // which then gets swallowed and reported as a generic server error.
    // Always decode the raw bytes as UTF-8 ourselves.
    final String bodyText;
    try {
      bodyText = utf8.decode(response.bodyBytes);
    } catch (e) {
      debugPrint('🔴 [API] $label utf8.decode failed: $e');
      return ApiResponse.error(_msgServerError);
    }

    debugPrint('🟢 [API] $label → ${response.statusCode}');

    Map<String, dynamic>? body;
    try {
      final decoded = jsonDecode(bodyText);
      if (decoded is Map<String, dynamic>) {
        body = decoded;
      }
    } catch (e) {
      // truncate body for log readability
      final preview =
          bodyText.length > 200 ? '${bodyText.substring(0, 200)}…' : bodyText;
      debugPrint('🔴 [API] $label JSON decode failed: $e\n  body: $preview');
      return ApiResponse.error(_msgServerError);
    }

    if (body == null) {
      debugPrint('🔴 [API] $label body was not a JSON object');
      return ApiResponse.error(_msgServerError);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.success(
        data: body['data'],
        message: body['message'] as String? ?? 'OK',
      );
    }

    // ✅ surface the actual server error so we can diagnose, instead of
    // hiding everything behind one generic Arabic message
    final serverMsg =
        body['message'] as String? ?? body['detail']?.toString();
    debugPrint('🔴 [API] $label HTTP ${response.statusCode} '
        'server message: $serverMsg');
    return ApiResponse.error(serverMsg ?? _msgServerError);
  }
}

/// 📦 شكل الاستجابة الموحّد
class ApiResponse {
  final bool success;
  final dynamic data;
  final String message;

  ApiResponse._({
    required this.success,
    this.data,
    required this.message,
  });

  factory ApiResponse.success({dynamic data, required String message}) {
    return ApiResponse._(success: true, data: data, message: message);
  }

  factory ApiResponse.error(String message) {
    return ApiResponse._(success: false, message: message);
  }
}
