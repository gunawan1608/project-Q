import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../language.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/green_background.dart';
import 'surah_detail_screen.dart';

class SurahListScreen extends ConsumerWidget {
  const SurahListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahAsync = ref.watch(surahListProvider);
    final lang = ref.watch(languageProvider);

    return Scaffold(
      body: GreenBackground(
        child: surahAsync.when(
          data: (surah) => _SurahListBody(surah: surah, lang: lang),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorView(
            message: lang.strings.failedLoadList,
            detail: e.toString(),
            retryLabel: lang.strings.retry,
            onRetry: () => ref.invalidate(surahListProvider),
          ),
        ),
      ),
    );
  }
}

class _SurahListBody extends StatelessWidget {
  const _SurahListBody({required this.surah, required this.lang});
  final List surah;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: _Header(lang: lang, total: surah.length),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          sliver: SliverList.separated(
            itemCount: surah.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final s = surah[index];
              final isId = lang == AppLanguage.indonesian;
              final surahIndex = s.number - 1;
              final displayName = isId && surahIndex < surahNamesId.length
                  ? surahNamesId[surahIndex]
                  : s.englishName;
              final displayTranslation = isId && surahIndex < surahTranslationsId.length
                  ? surahTranslationsId[surahIndex]
                  : s.englishNameTranslation;

              return RepaintBoundary(
                child: _SurahCard(
                  number: s.number,
                  displayName: displayName,
                  translation: displayTranslation,
                  revelationType: s.revelationType,
                  ayahCount: s.numberOfAyahs,
                  arabicName: s.name,
                  lang: lang,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SurahDetailScreen(surahNumber: s.number),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends ConsumerWidget {
  const _Header({required this.lang, required this.total});
  final AppLanguage lang;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = lang.strings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppTheme.heroGradient,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(color: AppTheme.green800op35, blurRadius: 20, offset: Offset(0, 8)),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 16, 20),
          child: Column(
            children: [
              // ── Baris 1: toggle di kanan, teks Arab di kiri mengisi sisa ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 22,
                        height: 2.0,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Toggle — berdiri sendiri di kanan, tidak overlap teks Arab
                  _LangToggle(current: lang),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                s.bismillahTranslation,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppTheme.white75,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppTheme.white15, height: 1),
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  _Pill(icon: Icons.menu_book_rounded, label: '$total Surah'),
                  _Pill(icon: Icons.translate_rounded, label: lang.fullLabel),
                  const _Pill(icon: Icons.abc_rounded, label: 'Latin'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            s.allSurahs,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppTheme.green900op50,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Language toggle ───────────────────────────────────────────────────────────

class _LangToggle extends ConsumerWidget {
  const _LangToggle({required this.current});
  final AppLanguage current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEn = current == AppLanguage.english;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.green800,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.green900op08),
        boxShadow: const [
          BoxShadow(color: AppTheme.green800op30, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangChip(
            label: 'EN',
            active: isEn,
            onTap: () => ref.read(languageProvider.notifier).state = AppLanguage.english,
          ),
          _LangChip(
            label: 'ID',
            active: !isEn,
            onTap: () => ref.read(languageProvider.notifier).state = AppLanguage.indonesian,
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? AppTheme.green800 : Colors.white.withOpacity(0.6),
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

// ── Info pill ─────────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: const BoxDecoration(
        color: AppTheme.white15,
        borderRadius: BorderRadius.all(Radius.circular(99)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.white90),
          const SizedBox(width: 5),
          Text(label, style: AppTheme.pillLabel.copyWith(color: AppTheme.white90)),
        ],
      ),
    );
  }
}

// ── Surah card ────────────────────────────────────────────────────────────────

class _SurahCard extends StatelessWidget {
  const _SurahCard({
    required this.number,
    required this.displayName,
    required this.translation,
    required this.revelationType,
    required this.ayahCount,
    required this.arabicName,
    required this.lang,
    required this.onTap,
  });

  final int number;
  final String displayName;
  final String translation;
  final String revelationType;
  final int ayahCount;
  final String arabicName;
  final AppLanguage lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isMakki = revelationType.toLowerCase() == 'meccan';
    final tt = Theme.of(context).textTheme;
    final s = lang.strings;
    final revLabel = isMakki ? s.revelationMeccan : s.revelationMedian;

    return Card(
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  gradient: AppTheme.badgeGradient,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$number',
                  style: tt.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: tt.titleMedium?.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 5,
                      runSpacing: 3,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          translation,
                          style: tt.bodyMedium?.copyWith(
                            color: AppTheme.green900op55,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: isMakki ? AppTheme.green800op10 : const Color(0x26F59E0B),
                            borderRadius: const BorderRadius.all(Radius.circular(4)),
                          ),
                          child: Text(
                            revLabel,
                            style: AppTheme.sectionLabel.copyWith(
                              fontSize: 10,
                              letterSpacing: 0.3,
                              color: isMakki ? AppTheme.green800 : const Color(0xFF92400E),
                            ),
                          ),
                        ),
                        Text(
                          '$ayahCount ${s.ayahsCount}',
                          style: tt.bodyMedium?.copyWith(
                            color: AppTheme.green900op45,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 70,
                child: Text(
                  arabicName,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.arabicListTile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.detail,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String detail;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(message, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(detail),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: Text(retryLabel)),
        ],
      ),
    );
  }
}