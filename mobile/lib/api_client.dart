import 'dart:convert';

import 'package:http/http.dart' as http;

import 'app_config.dart';
import 'models.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = AppConfig.apiBaseUrl;
    final normalizedBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath').replace(queryParameters: query);
  }

  Future<List<SurahSummary>> getSurahList() async {
    final res = await _client.get(_uri('/surah'));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Request failed: ${res.statusCode}');
    }
    final jsonBody = json.decode(res.body) as Map<String, dynamic>;
    final data = (jsonBody['data'] as List?) ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(SurahSummary.fromJson)
        .toList(growable: false);
  }

  Future<SurahPageResponse> getSurahDetail(int id, {String edition = 'en.asad'}) async {
    final res = await _client.get(_uri('/surah/$id', {'edition': edition}));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Request failed: ${res.statusCode}');
    }
    final jsonBody = json.decode(res.body) as Map<String, dynamic>;
    return SurahPageResponse.fromJson(jsonBody);
  }
}
