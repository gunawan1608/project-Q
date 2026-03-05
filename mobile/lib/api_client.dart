import 'dart:convert';

import 'package:flutter/foundation.dart'; // compute()
import 'package:http/http.dart' as http;

import 'app_config.dart';
import 'models.dart';

List<SurahSummary> _parseSurahList(String body) {
  final jsonBody = json.decode(body) as Map<String, dynamic>;
  final data = (jsonBody['data'] as List?) ?? const [];
  return data
      .whereType<Map<String, dynamic>>()
      .map(SurahSummary.fromJson)
      .toList(growable: false);
}

SurahPageResponse _parseSurahDetail(String body) {
  final jsonBody = json.decode(body) as Map<String, dynamic>;
  return SurahPageResponse.fromJson(jsonBody);
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = AppConfig.apiBaseUrl;
    final normalizedBase =
        base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath')
        .replace(queryParameters: query);
  }

  Future<List<SurahSummary>> getSurahList() async {
    final res = await _client.get(_uri('/surah'));
    _checkStatus(res);
    return compute(_parseSurahList, res.body);
  }

  Future<SurahPageResponse> getSurahDetail(
    int id, {
    String edition = 'en.asad',
  }) async {
    final res = await _client.get(_uri('/surah/$id', {'edition': edition}));
    _checkStatus(res);
    return compute(_parseSurahDetail, res.body);
  }

  void _checkStatus(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Request failed: ${res.statusCode}');
    }
  }
}