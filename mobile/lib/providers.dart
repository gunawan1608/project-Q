import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'models.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final surahListProvider = FutureProvider<List<SurahSummary>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return api.getSurahList();
});

final surahDetailProvider = FutureProvider.family<SurahPageResponse, int>((ref, id) async {
  final api = ref.watch(apiClientProvider);
  return api.getSurahDetail(id);
});
