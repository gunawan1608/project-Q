import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'language.dart';
import 'models.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final languageProvider = StateProvider<AppLanguage>((ref) => AppLanguage.english);

final surahListProvider = FutureProvider<List<SurahSummary>>((ref) async {
  return ref.watch(apiClientProvider).getSurahList();
});

// Watch languageProvider agar otomatis re-fetch saat bahasa berubah
final surahDetailProvider = FutureProvider.family<SurahPageResponse, int>((ref, id) async {
  final lang = ref.watch(languageProvider);
  return ref.watch(apiClientProvider).getSurahDetail(id, edition: lang.edition);
});