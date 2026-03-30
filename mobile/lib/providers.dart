import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'language.dart';
import 'models.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// ── Theme Mode ───────────────────────────────────────────────────────────────
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

// ── Language ─────────────────────────────────────────────────────────────────
final languageProvider =
    StateProvider<AppLanguage>((ref) => AppLanguage.english);

// ── Reader settings (per-surah popup) ────────────────────────────────────────
class ReaderSettings {
  final AppLanguage language;
  final bool showLatin;
  final bool showTranslation;

  const ReaderSettings({
    this.language = AppLanguage.english,
    this.showLatin = true,
    this.showTranslation = true,
  });

  ReaderSettings copyWith({
    AppLanguage? language,
    bool? showLatin,
    bool? showTranslation,
  }) =>
      ReaderSettings(
        language: language ?? this.language,
        showLatin: showLatin ?? this.showLatin,
        showTranslation: showTranslation ?? this.showTranslation,
      );
}

class ReaderSettingsNotifier extends StateNotifier<ReaderSettings> {
  ReaderSettingsNotifier() : super(const ReaderSettings());

  void setLanguage(AppLanguage language) {
    state = state.copyWith(language: language);
  }

  void setShowLatin(bool value) {
    state = state.copyWith(showLatin: value);
  }

  void setShowTranslation(bool value) {
    state = state.copyWith(showTranslation: value);
  }
}

final readerSettingsProvider =
    StateNotifierProvider<ReaderSettingsNotifier, ReaderSettings>(
  (ref) => ReaderSettingsNotifier(),
);

// ── Surah list ────────────────────────────────────────────────────────────────
final surahListProvider = FutureProvider<List<SurahSummary>>((ref) async {
  return ref.watch(apiClientProvider).getSurahList();
});

// ── Surah detail ──────────────────────────────────────────────────────────────
final surahDetailProvider =
    FutureProvider.family<SurahPageResponse, ({int id, String edition})>(
  (ref, args) async {
    return ref
        .watch(apiClientProvider)
        .getSurahDetail(args.id, edition: args.edition);
  },
);

// ── Search query ──────────────────────────────────────────────────────────────
final searchQueryProvider = StateProvider<String>((ref) => '');
